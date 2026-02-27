import Foundation
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
class ProfileEditViewModel {
    private let userRepository: UserRepository
    private let currentUserId: String
    
    // UI側の入力状態
    var displayName: String = ""
    var currentPhotoUrl: String? = nil
    
    // PhotosPicker用の画像状態
    var selectedItem: PhotosPickerItem? = nil {
        didSet {
            Task { await loadMedia() }
        }
    }
    var selectedImageData: Data? = nil
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCompleted: Bool = false
    
    init(userRepository: UserRepository, currentUserId: String) {
        self.userRepository = userRepository
        self.currentUserId = currentUserId
        
        if (currentUserId.isEmpty) {
            return
        }
        Task { await loadUserProfile() }
    }
    
    private func loadUserProfile() async {
        isLoading = true
        do {
            if let user = try await userRepository.getUser(userId: currentUserId) {
                self.displayName = user.displayName
                self.currentPhotoUrl = user.photoUrl
            }
        } catch {
            self.errorMessage = "プロフィールの取得に失敗しました"
        }
        isLoading = false
    }
    
    private func loadMedia() async {
        guard let item = selectedItem else { return }
        isLoading = true
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    if let compressedData = ImageHelper.compressImage(image: image, maxSize: 512, quality: 0.7) {
                        selectedImageData = compressedData
                    } else {
                        errorMessage = "画像の処理に失敗しました"
                        selectedItem = nil
                        selectedImageData = nil
                    }
                } else {
                    errorMessage = "対応していない画像フォーマットです。"
                    selectedItem = nil
                    selectedImageData = nil
                }
            }
        } catch {
            errorMessage = "画像の読み込みに失敗しました"
        }
        isLoading = false
    }
    
    func saveProfile() async {
        guard !displayName.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            // Firestoreのユーザー情報を更新
            try await userRepository.updateProfile(
                userId: currentUserId, displayName: displayName, photoData: selectedImageData)
            
            isCompleted = true
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
