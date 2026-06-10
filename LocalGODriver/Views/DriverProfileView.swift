import SwiftUI

struct DriverProfileView: View {
    @EnvironmentObject private var vm: DriverViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    avatar.padding(.top, 12)
                    statusBadge
                    options
                    Text("LocalGO Driver v1.0.0")
                        .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary.opacity(0.45))
                        .padding(.bottom, 48)
                }
                .padding(.horizontal, 20)
            }
            .background(AppTheme.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var avatar: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 90, height: 90)
                Image(systemName: "bicycle").font(.system(size: 36)).foregroundColor(AppTheme.primary)
            }
            Text("Driver").font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            HStack(spacing: 4) {
                Image(systemName: "star.fill").font(.system(size: 12)).foregroundColor(.orange)
                Text("4.9 · Montreal").font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    private var statusBadge: some View {
        HStack {
            Circle().fill(vm.isOnline ? AppTheme.green : AppTheme.textSecondary).frame(width: 10, height: 10)
            Text(vm.isOnline ? "Online" : "Offline").font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
            Spacer()
            Text(String(format: "$%.2f earned today", vm.earningsToday)).font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.primary)
        }
        .padding(16).cardStyle()
    }

    private var options: some View {
        VStack(spacing: 1) {
            row(icon: "clock.arrow.circlepath", label: "Delivery History", color: AppTheme.navy)
            row(icon: "creditcard.fill", label: "Payout Method", color: .purple)
            row(icon: "car.fill", label: "Vehicle Info", color: .blue)
            row(icon: "bell.fill", label: "Notifications", color: .orange)
            row(icon: "questionmark.circle.fill", label: "Help & Support", color: .teal)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
    }

    private func row(icon: String, label: String, color: Color) -> some View {
        Button {} label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 36, height: 36)
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
