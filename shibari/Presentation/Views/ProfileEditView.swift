import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Bindable var viewModel: ProfileEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // --- 1. アイコン画像変更エリア ---
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack(alignment: .bottomTrailing) {
                            // 現在の画像 or 選択された新しい画像
                            SwiftUI.Group {
                                if let data = viewModel.selectedImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else if let photoUrl = viewModel.currentPhotoUrl, let url = URL(string: photoUrl) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            Color.slateSurfaceVariant
                                        }
                                    }
                                } else {
                                    // 画像がない場合のデフォルトアイコン
                                    Circle()
                                        .fill(Color.slateSurfaceVariant)
                                        .overlay(
                                            Text(String(viewModel.displayName.prefix(1)))
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.tacticalRed, lineWidth: 2))
                            
                            // 右下のカメラバッジ
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.white)
                                .background(Color.slateBackground.clipShape(Circle()))
                                .offset(x: 4, y: 4)
                        }
                    }
                    .padding(.top, 32)
                    
                    // --- 2. 隊員名入力エリア ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("表示名 (ニックネーム)")
                            .foregroundColor(.textSecondary)
                            .font(.subheadline)
                        
                        TextField("名前を入力", text: $viewModel.displayName)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.slateSurfaceVariant, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // --- 3. 保存ボタン ---
                    Button(action: {
                        Task { await viewModel.saveProfile() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("変更を保存する")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .disabled(viewModel.isLoading || viewModel.displayName.isEmpty)
                }
            }
        }
        .navigationTitle("プロフィール編集")
        .navigationBarTitleDisplayMode(.inline)
        // キーボード外をタップしたら閉じる
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        // 保存成功時に自動で戻る
        .onChange(of: viewModel.isCompleted) { _, isCompleted in
            if isCompleted { dismiss() }
        }
        // エラーアラート
        .alert("エラー", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(
            viewModel: ProfileEditViewModel(
                userRepository: UserRepositoryMock(),
                currentUserId: "mock_user_1"
            )
        )
    }
    .environmentObject(AppDIContainer.mock)
}
