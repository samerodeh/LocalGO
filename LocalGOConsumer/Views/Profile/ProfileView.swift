import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var name = ""
    @State private var phone = ""
    @State private var showSignOutConfirm = false
    @State private var savedToast = false

    private var user: AppUser? { auth.currentUser }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    avatarSection.padding(.top, 12)

                    if user?.isGuest == true {
                        guestCard
                    } else {
                        editableFields
                    }

                    optionsList
                    signOutButton

                    Text("LocalGO v1.0.0")
                        .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary.opacity(0.45))
                        .padding(.bottom, 48)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                name = user?.name ?? ""
                phone = user?.phone ?? ""
            }
            .overlay(alignment: .top) {
                if savedToast {
                    Text("Profile saved")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(AppTheme.navy, in: Capsule())
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
            .confirmationDialog("Sign out of LocalGO?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { auth.signOut() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Avatar
    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                Text(user?.initials ?? "G")
                    .font(.system(size: 34, weight: .black)).foregroundColor(.white)
            }
            VStack(spacing: 3) {
                Text(user?.name ?? "Guest")
                    .font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                if let email = user?.email, !email.isEmpty {
                    Text(email).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
                }
                providerBadge
            }
        }
    }

    private var providerBadge: some View {
        Group {
            switch user?.provider {
            case .apple:
                badge(icon: "apple.logo", text: "Apple Account", color: AppTheme.navy)
            case .guest:
                badge(icon: "person.crop.circle.dashed", text: "Guest Session", color: AppTheme.textSecondary)
            default:
                badge(icon: "envelope.fill", text: "Email Account", color: AppTheme.primary)
            }
        }
    }

    private func badge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 10))
            Text(text).font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(color.opacity(0.1), in: Capsule())
        .padding(.top, 2)
    }

    // MARK: - Guest upsell
    private var guestCard: some View {
        VStack(spacing: 12) {
            Text("You're browsing as a guest")
                .font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            Text("Create an account to save your details, track orders, and check out faster.")
                .font(.system(size: 14)).foregroundColor(AppTheme.textSecondary).multilineTextAlignment(.center)
            Button { auth.signOut() } label: {
                Text("Create Account").font(.system(size: 16, weight: .bold)).primaryButtonStyle()
            }
        }
        .padding(20)
        .cardStyle()
        .padding(.horizontal, 20)
    }

    // MARK: - Editable fields
    private var editableFields: some View {
        VStack(spacing: 10) {
            field(icon: "person.fill", title: "Full Name", value: $name, kb: .default)
            field(icon: "phone.fill", title: "Phone", value: $phone, kb: .phonePad)
            Button { saveProfile() } label: {
                Text("Save Changes").font(.system(size: 15, weight: .bold)).primaryButtonStyle()
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 20)
    }

    private func field(icon: String, title: String, value: Binding<String>, kb: UIKeyboardType) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 15)).foregroundColor(AppTheme.primary).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 11, weight: .medium)).foregroundColor(AppTheme.textSecondary)
                TextField(title, text: value).font(.system(size: 15)).foregroundColor(AppTheme.textPrimary).keyboardType(kb)
            }
            Spacer()
        }
        .padding(16).cardStyle()
    }

    // MARK: - Options
    private var optionsList: some View {
        VStack(spacing: 1) {
            optionRow(icon: "clock.arrow.circlepath",  label: "Order History",      color: AppTheme.navy)
            optionRow(icon: "mappin.and.ellipse",      label: "Saved Addresses",    color: .blue)
            optionRow(icon: "creditcard.fill",         label: "Payment Methods",    color: .purple)
            optionRow(icon: "bell.fill",               label: "Notifications",      color: .orange)
            optionRow(icon: "questionmark.circle.fill",label: "Help & Support",     color: .teal)
            optionRow(icon: "lock.shield.fill",        label: "Privacy & Security", color: AppTheme.green)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        .padding(.horizontal, 20)
    }

    private func optionRow(icon: String, label: String, color: Color) -> some View {
        Button {} label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                    Image(systemName: icon).font(.system(size: 15)).foregroundColor(color)
                }
                Text(label).font(.system(size: 15)).foregroundColor(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.white)
        }
    }

    // MARK: - Sign out
    private var signOutButton: some View {
        Button { showSignOutConfirm = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text(user?.isGuest == true ? "Exit Guest Session" : "Sign Out")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous))
        }
        .padding(.horizontal, 20)
    }

    private func saveProfile() {
        auth.updateProfile(name: name, phone: phone)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { savedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { savedToast = false }
        }
    }
}
