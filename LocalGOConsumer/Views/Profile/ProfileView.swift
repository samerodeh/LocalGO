import SwiftUI

struct ProfileView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    avatarSection.padding(.top, 12)
                    editableFields
                    optionsList
                    Text("LocalGO v1.0.0")
                        .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary.opacity(0.45))
                        .padding(.bottom, 48)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Avatar
    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                Text(name.isEmpty ? "G" : String(name.prefix(1)).uppercased())
                    .font(.system(size: 38, weight: .black)).foregroundColor(.white)
            }
            Text(name.isEmpty ? "Guest" : name)
                .font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            if !email.isEmpty {
                Text(email).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    // MARK: - Fields
    private var editableFields: some View {
        VStack(spacing: 10) {
            profileField(icon: "person.fill",    title: "Full Name",  value: $name,  kb: .default)
            profileField(icon: "envelope.fill",  title: "Email",      value: $email, kb: .emailAddress)
            profileField(icon: "phone.fill",     title: "Phone",      value: $phone, kb: .phonePad)
        }
        .padding(.horizontal, 20)
    }

    private func profileField(icon: String, title: String, value: Binding<String>, kb: UIKeyboardType) -> some View {
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
            optionRow(icon: "info.circle.fill",        label: "About LocalGO",      color: AppTheme.primary)
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
}
