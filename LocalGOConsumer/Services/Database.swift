import Foundation
import SQLite3

/// Lightweight SQLite database — the app's real on-disk persistence layer for
/// users, orders, and payment methods. The database file lives in Application
/// Support. Passwords are stored only as salt + hash (see CredentialStore).
///
/// This is a thin, dependency-free wrapper over the system `sqlite3` library.
/// In production the same schema would live on your server; the app would talk
/// to it over the network. Here it stands in as a genuine local database.
final class Database {
    static let shared = Database()

    private var db: OpaquePointer?
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private let queue = DispatchQueue(label: "com.localgo.db")

    private init() {
        open()
        migrate()
    }

    // MARK: - Setup

    private func open() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let path = dir.appendingPathComponent("localgo.sqlite").path
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("DB open failed: \(lastError)")
        }
    }

    private func migrate() {
        exec("""
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            phone TEXT NOT NULL,
            provider TEXT NOT NULL,
            created_at REAL NOT NULL,
            email_verified INTEGER NOT NULL DEFAULT 0,
            two_factor INTEGER NOT NULL DEFAULT 0,
            salt BLOB,
            password_hash BLOB
        );
        """)
        exec("""
        CREATE TABLE IF NOT EXISTS orders (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            restaurant_id TEXT NOT NULL,
            restaurant_name TEXT NOT NULL,
            address TEXT NOT NULL,
            placed_at REAL NOT NULL,
            total REAL NOT NULL,
            payment_brand TEXT,
            payment_last4 TEXT,
            items_json TEXT NOT NULL
        );
        """)
        exec("""
        CREATE TABLE IF NOT EXISTS payment_methods (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            brand TEXT NOT NULL,
            last4 TEXT NOT NULL,
            exp_month INTEGER NOT NULL,
            exp_year INTEGER NOT NULL,
            is_default INTEGER NOT NULL DEFAULT 0
        );
        """)
    }

    // MARK: - Users

    func upsertUser(user: AppUser, salt: Data, passwordHash: Data) {
        queue.sync {
            let sql = """
            INSERT INTO users (id,name,email,phone,provider,created_at,email_verified,two_factor,salt,password_hash)
            VALUES (?,?,?,?,?,?,?,?,?,?)
            ON CONFLICT(id) DO UPDATE SET
              name=excluded.name, email=excluded.email, phone=excluded.phone,
              provider=excluded.provider, email_verified=excluded.email_verified,
              two_factor=excluded.two_factor, salt=excluded.salt, password_hash=excluded.password_hash;
            """
            guard let stmt = prepare(sql) else { return }
            defer { sqlite3_finalize(stmt) }
            bindText(stmt, 1, user.id)
            bindText(stmt, 2, user.name)
            bindText(stmt, 3, user.email.lowercased())
            bindText(stmt, 4, user.phone)
            bindText(stmt, 5, user.provider.rawValue)
            sqlite3_bind_double(stmt, 6, user.createdAt.timeIntervalSince1970)
            sqlite3_bind_int(stmt, 7, user.emailVerified ? 1 : 0)
            sqlite3_bind_int(stmt, 8, user.twoFactorEnabled ? 1 : 0)
            bindBlob(stmt, 9, salt)
            bindBlob(stmt, 10, passwordHash)
            sqlite3_step(stmt)
        }
    }

    func userRow(email: String) -> (user: AppUser, salt: Data, hash: Data)? {
        userRow(where: "email = ?", value: email.lowercased())
    }
    func userRow(id: String) -> (user: AppUser, salt: Data, hash: Data)? {
        userRow(where: "id = ?", value: id)
    }

    private func userRow(where clause: String, value: String) -> (user: AppUser, salt: Data, hash: Data)? {
        queue.sync {
            let sql = "SELECT id,name,email,phone,provider,created_at,email_verified,two_factor,salt,password_hash FROM users WHERE \(clause) LIMIT 1;"
            guard let stmt = prepare(sql) else { return nil }
            defer { sqlite3_finalize(stmt) }
            bindText(stmt, 1, value)
            guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
            let user = AppUser(
                id: columnText(stmt, 0),
                name: columnText(stmt, 1),
                email: columnText(stmt, 2),
                phone: columnText(stmt, 3),
                provider: AuthProvider(rawValue: columnText(stmt, 4)) ?? .email,
                createdAt: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 5)),
                emailVerified: sqlite3_column_int(stmt, 6) == 1,
                twoFactorEnabled: sqlite3_column_int(stmt, 7) == 1
            )
            return (user, columnBlob(stmt, 8), columnBlob(stmt, 9))
        }
    }

    func updateUserFields(id: String, name: String, phone: String) {
        execBound("UPDATE users SET name=?, phone=? WHERE id=?;") { stmt in
            self.bindText(stmt, 1, name); self.bindText(stmt, 2, phone); self.bindText(stmt, 3, id)
        }
    }
    func setEmailVerified(id: String, _ v: Bool) {
        execBound("UPDATE users SET email_verified=? WHERE id=?;") { stmt in
            sqlite3_bind_int(stmt, 1, v ? 1 : 0); self.bindText(stmt, 2, id)
        }
    }
    func setTwoFactor(id: String, _ v: Bool) {
        execBound("UPDATE users SET two_factor=? WHERE id=?;") { stmt in
            sqlite3_bind_int(stmt, 1, v ? 1 : 0); self.bindText(stmt, 2, id)
        }
    }
    func updatePassword(id: String, salt: Data, hash: Data) {
        execBound("UPDATE users SET salt=?, password_hash=? WHERE id=?;") { stmt in
            self.bindBlob(stmt, 1, salt); self.bindBlob(stmt, 2, hash); self.bindText(stmt, 3, id)
        }
    }

    // MARK: - Orders

    func insertOrder(_ order: OrderRecord, userId: String) {
        let itemsJSON = (try? JSONEncoder().encode(order.lines)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        execBound("""
        INSERT INTO orders (id,user_id,restaurant_id,restaurant_name,address,placed_at,total,payment_brand,payment_last4,items_json)
        VALUES (?,?,?,?,?,?,?,?,?,?);
        """) { stmt in
            self.bindText(stmt, 1, order.id)
            self.bindText(stmt, 2, userId)
            self.bindText(stmt, 3, order.restaurantId)
            self.bindText(stmt, 4, order.restaurantName)
            self.bindText(stmt, 5, order.address)
            sqlite3_bind_double(stmt, 6, order.placedAt.timeIntervalSince1970)
            sqlite3_bind_double(stmt, 7, order.total)
            if let b = order.paymentBrand { self.bindText(stmt, 8, b) } else { sqlite3_bind_null(stmt, 8) }
            if let l = order.paymentLast4 { self.bindText(stmt, 9, l) } else { sqlite3_bind_null(stmt, 9) }
            self.bindText(stmt, 10, itemsJSON)
        }
    }

    func orders(userId: String) -> [OrderRecord] {
        queue.sync {
            let sql = "SELECT id,restaurant_id,restaurant_name,address,placed_at,total,payment_brand,payment_last4,items_json FROM orders WHERE user_id=? ORDER BY placed_at DESC;"
            guard let stmt = prepare(sql) else { return [] }
            defer { sqlite3_finalize(stmt) }
            bindText(stmt, 1, userId)
            var result: [OrderRecord] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                let json = columnText(stmt, 8)
                let lines = (try? JSONDecoder().decode([OrderLine].self, from: Data(json.utf8))) ?? []
                result.append(OrderRecord(
                    id: columnText(stmt, 0),
                    restaurantId: columnText(stmt, 1),
                    restaurantName: columnText(stmt, 2),
                    address: columnText(stmt, 3),
                    placedAt: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4)),
                    total: sqlite3_column_double(stmt, 5),
                    paymentBrand: columnTextOptional(stmt, 6),
                    paymentLast4: columnTextOptional(stmt, 7),
                    lines: lines
                ))
            }
            return result
        }
    }

    // MARK: - Payment methods

    func insertPayment(_ method: PaymentMethod, userId: String) {
        execBound("INSERT INTO payment_methods (id,user_id,brand,last4,exp_month,exp_year,is_default) VALUES (?,?,?,?,?,?,?);") { stmt in
            self.bindText(stmt, 1, method.id)
            self.bindText(stmt, 2, userId)
            self.bindText(stmt, 3, method.brand)
            self.bindText(stmt, 4, method.last4)
            sqlite3_bind_int(stmt, 5, Int32(method.expMonth))
            sqlite3_bind_int(stmt, 6, Int32(method.expYear))
            sqlite3_bind_int(stmt, 7, method.isDefault ? 1 : 0)
        }
    }

    func payments(userId: String) -> [PaymentMethod] {
        queue.sync {
            let sql = "SELECT id,brand,last4,exp_month,exp_year,is_default FROM payment_methods WHERE user_id=? ORDER BY is_default DESC, rowid DESC;"
            guard let stmt = prepare(sql) else { return [] }
            defer { sqlite3_finalize(stmt) }
            bindText(stmt, 1, userId)
            var result: [PaymentMethod] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(PaymentMethod(
                    id: columnText(stmt, 0),
                    brand: columnText(stmt, 1),
                    last4: columnText(stmt, 2),
                    expMonth: Int(sqlite3_column_int(stmt, 3)),
                    expYear: Int(sqlite3_column_int(stmt, 4)),
                    isDefault: sqlite3_column_int(stmt, 5) == 1
                ))
            }
            return result
        }
    }

    func setDefaultPayment(id: String, userId: String) {
        execBound("UPDATE payment_methods SET is_default=0 WHERE user_id=?;") { stmt in self.bindText(stmt, 1, userId) }
        execBound("UPDATE payment_methods SET is_default=1 WHERE id=?;") { stmt in self.bindText(stmt, 1, id) }
    }

    func deletePayment(id: String) {
        execBound("DELETE FROM payment_methods WHERE id=?;") { stmt in self.bindText(stmt, 1, id) }
    }

    // MARK: - Low-level helpers

    private var lastError: String { String(cString: sqlite3_errmsg(db)) }

    private func exec(_ sql: String) {
        queue.sync {
            if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
                print("DB exec error: \(lastError)")
            }
        }
    }

    private func execBound(_ sql: String, _ bind: (OpaquePointer) -> Void) {
        queue.sync {
            guard let stmt = prepare(sql) else { return }
            defer { sqlite3_finalize(stmt) }
            bind(stmt)
            sqlite3_step(stmt)
        }
    }

    private func prepare(_ sql: String) -> OpaquePointer? {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("DB prepare error: \(lastError) — \(sql)")
            return nil
        }
        return stmt
    }

    private func bindText(_ stmt: OpaquePointer, _ index: Int32, _ value: String) {
        sqlite3_bind_text(stmt, index, value, -1, SQLITE_TRANSIENT)
    }
    private func bindBlob(_ stmt: OpaquePointer, _ index: Int32, _ data: Data) {
        data.withUnsafeBytes { raw in
            _ = sqlite3_bind_blob(stmt, index, raw.baseAddress, Int32(data.count), SQLITE_TRANSIENT)
        }
    }
    private func columnText(_ stmt: OpaquePointer, _ index: Int32) -> String {
        guard let c = sqlite3_column_text(stmt, index) else { return "" }
        return String(cString: c)
    }
    private func columnTextOptional(_ stmt: OpaquePointer, _ index: Int32) -> String? {
        guard sqlite3_column_type(stmt, index) != SQLITE_NULL, let c = sqlite3_column_text(stmt, index) else { return nil }
        return String(cString: c)
    }
    private func columnBlob(_ stmt: OpaquePointer, _ index: Int32) -> Data {
        guard let ptr = sqlite3_column_blob(stmt, index) else { return Data() }
        let count = Int(sqlite3_column_bytes(stmt, index))
        return Data(bytes: ptr, count: count)
    }
}
