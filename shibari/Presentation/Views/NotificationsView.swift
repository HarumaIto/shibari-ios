import SwiftUI

struct NotificationsView: View {
    @Bindable var viewModel: NotificationsViewModel
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 0) { // spacing: 0 にして要素をくっつける
                    ForEach(viewModel.notifications) { notification in
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(notification.isRead ? Color.clear : Color.blue)
                                    .frame(width: 8, height: 8)
                                Image(systemName: notification.type.iconName)
                                    .foregroundColor(notification.type.color)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(notification.body)
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            // HStack全体をタップ可能にする
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("遷移先ID: \(notification.targetId ?? "なし")")
                            }
                            
                            // ★ 自分で区切り線を引く
                            Divider()
                            // 線の色をダークテーマに合わせる（プロジェクトの色に合わせてください）
                                .background(Color.gray.opacity(0.3))
                            // アイコンの右側から線が始まるiOS標準のスタイルを再現
                                .padding(.leading, 40)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("通知")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadNotifications()
            await viewModel.markAllAsRead()
        }
    }
}

#Preview {
    NotificationsView(
        viewModel: NotificationsViewModel(
            notificationRepository: NotificationRepositoryMock(),
            authRepository: AuthRepositoryMock()
        )
    )
}
