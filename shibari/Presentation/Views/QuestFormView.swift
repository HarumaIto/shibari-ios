import SwiftUI

struct QuestFormView: View {
    @Bindable var viewModel: QuestFormViewModel
    @Environment(\.dismiss) private var dismiss
    var onSaved: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            ScrollView {
                VStack(spacing: 20) {
                    // タイトル
                    VStack(alignment: .leading, spacing: 8) {
                        Text("タイトル（必須）")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        TextField("縛りのタイトルを入力", text: $viewModel.title)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.textPrimary)
                    }

                    // 詳細・条件
                    VStack(alignment: .leading, spacing: 8) {
                        Text("詳細・条件（必須）")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        TextField("縛りの詳細や条件を入力", text: $viewModel.description, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.textPrimary)
                    }

                    // クエストの種類
                    VStack(alignment: .leading, spacing: 8) {
                        Text("クエストの種類")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Picker("種類", selection: $viewModel.type) {
                            ForEach(QuestType.allCases, id: \.self) { questType in
                                Text(questType.displayName).tag(questType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // 頻度
                    VStack(alignment: .leading, spacing: 8) {
                        Text("頻度")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Picker("頻度", selection: $viewModel.frequency) {
                            ForEach(QuestFrequency.allCases, id: \.self) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // 目標回数
                    VStack(alignment: .leading, spacing: 8) {
                        Text("目標回数（省略可）")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        TextField("例: 5", text: $viewModel.thresholdText)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(16)
            }
            .disabled(viewModel.isLoading)
        }
        .navigationTitle(viewModel.isNewQuest ? "新しい縛りを作成" : "縛りを編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    Task { await viewModel.save() }
                }
                .disabled(!viewModel.canSave)
                .foregroundColor(viewModel.canSave ? .tacticalRed : .textSecondary)
            }
        }
        .onChange(of: viewModel.isSaved) { _, newValue in
            if newValue {
                onSaved?()
                dismiss()
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
}

#Preview {
    NavigationStack {
        QuestFormView(
            viewModel: QuestFormViewModel(
                questRepository: QuestRepositoryMock(),
                groupId: "mock_group_id_456",
                initialQuest: nil
            )
        )
    }
    .environmentObject(AppDIContainer.mock)
}
