import SwiftUI
import PhotosUI
import AVKit

struct PostView: View {
    @Bindable var viewModel: PostViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var videoPlayer: AVPlayer?
    @State private var tempVideoURL: URL?
    @State private var videoWriteTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // メインのUI定義が圧倒的にスッキリします
                    mediaContainer
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .onChange(of: viewModel.selectedMediaData) { _, newData in
                            handleMediaChange(newData: newData)
                        }
                    
                    if viewModel.selectedMediaData != nil {
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .any(of: [.images, .videos]), photoLibrary: .shared()) {
                            Text("メディアを選び直す")
                                .fontWeight(.bold)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("一言コメント（任意）")
                            .foregroundColor(.textSecondary)
                            .font(.subheadline)
                        
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
                    .disabled(viewModel.isLoading || viewModel.selectedMediaData == nil)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("証拠を提出")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
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
