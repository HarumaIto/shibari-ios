import SwiftUI
import PhotosUI

struct PostView: View {
    @Bindable var viewModel: PostViewModel
    // ★追加: 前の画面に戻るための環境変数（Androidの onNavigateBack の代わり）
    @Environment(\.dismiss) private var dismiss
    
    @State private var videoPlayer: AVPlayer?
    @State private var tempVideoURL: URL?
    @State private var videoWriteTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // --- 1. 画像プレビューエリア ---
                    Rectangle()
                        .fill(Color.slateSurfaceVariant)
                        .aspectRatio(1.0, contentMode: .fit)
                        .cornerRadius(16)
                        .overlay(
                            SwiftUI.Group {
                                if let data = viewModel.selectedImageData, let uiImage = UIImage(data: data) {
                                    // 選択された画像を表示
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    // 画像が未選択の場合は、ここをタップしてライブラリを開く
                                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images, photoLibrary: .shared()) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 64))
                                            .foregroundColor(.tacticalRed)
                                    }
                                }
                            }
                        )
                        .clipped()
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // --- 2. 写真を選び直すボタン ---
                    if viewModel.selectedImageData != nil {
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images, photoLibrary: .shared()) {
                            Text("写真を選び直す")
                                .fontWeight(.bold)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    // --- 3. コメント入力 ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("一言コメント (任意)")
                            .foregroundColor(.textSecondary)
                            .font(.subheadline)
                        
                        // Androidの OutlinedTextField に近いデザイン
                        TextEditor(text: $viewModel.comment)
                            .frame(height: 120)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.slateSurfaceVariant, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 40)
                    
                    // --- 4. 送信ボタン ---
                    Button(action: {
                        Task { await viewModel.submitPost() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("タイムラインに投稿する")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .disabled(viewModel.isLoading || viewModel.selectedImageData == nil)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("証拠を提出")
        .navigationBarTitleDisplayMode(.inline)
        // キーボード外をタップしたら閉じる
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        // ★ 投稿成功時、自動で前の画面（今日のノルマ）に戻る
        .onChange(of: viewModel.isCompleted) { _, isCompleted in
            if isCompleted { dismiss() }
        }
        .onDisappear {
            videoWriteTask?.cancel()
            videoWriteTask = nil
            videoPlayer?.pause()
            videoPlayer = nil
            if let url = tempVideoURL {
                try? FileManager.default.removeItem(at: url)
                tempVideoURL = nil
            }
        }
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
    
    // MARK: - Subviews
    private var mediaContainer: some View {
        Rectangle()
            .fill(Color.slateSurfaceVariant)
            .aspectRatio(1.0, contentMode: .fit)
            .cornerRadius(16)
            .overlay(mediaContent) // 中身を別の変数として切り出し
            .clipped()
    }
    
    @ViewBuilder
    private var mediaContent: some View {
        if let data = viewModel.selectedMediaData {
            if viewModel.isSelectedMediaVideo {
                // 動画プレビュー
                if let player = videoPlayer {
                    VideoPlayer(player: player)
                } else {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            } else if let uiImage = UIImage(data: data) {
                // 画像プレビュー
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            // 未選択状態
            PhotosPicker(selection: $viewModel.selectedItem, matching: .any(of: [.images, .videos]), photoLibrary: .shared()) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.tacticalRed)
            }
        }
    }
    
    // MARK: - Methods
    @MainActor
    private func handleMediaChange(newData: Data?) {
        videoPlayer?.pause()
        videoPlayer = nil
        
        // Cancel any in-flight write before starting a new one
        videoWriteTask?.cancel()
        videoWriteTask = nil
        
        // Clean up previous temp file before creating a new one
        if let oldURL = tempVideoURL {
            try? FileManager.default.removeItem(at: oldURL)
            tempVideoURL = nil
        }
        
        if viewModel.isSelectedMediaVideo, let data = newData {
            videoWriteTask = Task {
                let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                do {
                    try await Task.detached(priority: .utility) {
                        try data.write(to: tempFileURL)
                    }.value
                    guard !Task.isCancelled else {
                        try? FileManager.default.removeItem(at: tempFileURL)
                        return
                    }
                    tempVideoURL = tempFileURL
                    videoPlayer = AVPlayer(url: tempFileURL)
                } catch {
                    if !Task.isCancelled {
                        viewModel.errorMessage = "動画のプレビューに失敗しました"
                    }
                }
            }
        }
    }
}
