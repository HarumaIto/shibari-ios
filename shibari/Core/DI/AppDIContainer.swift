import SwiftUI
import Combine

@MainActor
class AppDIContainer: ObservableObject {
    // MARK: - Repositories
    let authRepository: AuthRepository
    let userRepository: UserRepository
    let groupRepository: GroupRepository
    let timelineRepository: TimelineRepository
    let reportRepository: ReportRepository
    let questRepository: QuestRepository
    let notificationRepository: NotificationRepository

    // MARK: - Initializer
    init(
        authRepository: AuthRepository,
        userRepository: UserRepository,
        groupRepository: GroupRepository,
        timelineRepository: TimelineRepository,
        reportRepository: ReportRepository,
        questRepository: QuestRepository,
        notificationRepository: NotificationRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.groupRepository = groupRepository
        self.timelineRepository = timelineRepository
        self.reportRepository = reportRepository
        self.questRepository = questRepository
        self.notificationRepository = notificationRepository
    }
        
    convenience init() {
        self.init(
            authRepository: AuthRepositoryImpl(),
            userRepository: UserRepositoryImpl(),
            groupRepository: GroupRepositoryImpl(),
            timelineRepository: TimelineRepositoryImpl(),
            reportRepository: ReportRepositoryImpl(),
            questRepository: QuestRepositoryImpl(),
            notificationRepository: NotificationRepositoryImpl()
        )
    }

    // MARK: - Mock for Previews
    static var mock: AppDIContainer {
        AppDIContainer(
            authRepository: AuthRepositoryMock(),
            userRepository: UserRepositoryMock(),
            groupRepository: GroupRepositoryMock(),
            timelineRepository: TimelineRepositoryMock(),
            reportRepository: ReportRepositoryMock(),
            questRepository: QuestRepositoryMock(),
            notificationRepository: NotificationRepositoryMock()
        )
    }

    // MARK: - View Factories

    @ViewBuilder
    func makeRootView() -> some View {
        RootView(viewModel: RootViewModel(
            authRepository: authRepository,
            userRepository: userRepository,
            groupRepository: groupRepository,
            timelineRepository: timelineRepository,
            reportRepository: reportRepository,
            questRepository: questRepository
        ))
    }

    @ViewBuilder
    func makeAuthSelectionView(onNavigateToNext: @escaping () -> Void) -> some View {
        AuthSelectionView(
            viewModel: AuthViewModel(
                authRepository: authRepository,
                userRepository: userRepository
            ),
            onNavigateToNext: onNavigateToNext
        )
    }

    @ViewBuilder
    func makeLoginView(onNavigateToNext: @escaping () -> Void) -> some View {
        LoginView(
            viewModel: AuthViewModel(
                authRepository: authRepository,
                userRepository: userRepository
            ),
            onNavigateToNext: onNavigateToNext
        )
    }

    @ViewBuilder
    func makeSignUpView(onNavigateToNext: @escaping () -> Void) -> some View {
        SignUpView(
            viewModel: AuthViewModel(
                authRepository: authRepository,
                userRepository: userRepository
            ),
            onNavigateToNext: onNavigateToNext
        )
    }

    @ViewBuilder
    func makeProfileSetupView(currentUserId: String, onNavigateToNext: @escaping () -> Void) -> some View {
        ProfileSetupView(
            viewModel: ProfileSetupViewModel(
                userRepository: userRepository,
                authRepository: authRepository,
                currentUserId: currentUserId
            ),
            onNavigateToNext: onNavigateToNext
        )
    }

    @ViewBuilder
    func makeGroupSelectionView(currentUserId: String, onNavigateToNext: @escaping () -> Void) -> some View {
        GroupSelectionView(
            viewModel: GroupSelectionViewModel(
                groupRepository: groupRepository,
                userRepository: userRepository,
                currentUserId: currentUserId
            ),
            onNavigateToNext: onNavigateToNext
        )
    }

    @ViewBuilder
    func makeQuestSelectionView(groupId: String, currentUserId: String, onNavigateToMain: @escaping () -> Void) -> some View {
        QuestSelectionView(
            viewModel: QuestSelectionViewModel(
                questRepository: questRepository,
                userRepository: userRepository,
                groupId: groupId,
                currentUserId: currentUserId
            ),
            onNavigateToMain: onNavigateToMain
        )
    }

    func makeTimelineViewModel(currentUserId: String, groupId: String) -> TimelineViewModel {
        TimelineViewModel(
            timelineRepository: timelineRepository,
            userRepository: userRepository,
            reportRepository: reportRepository,
            currentUserId: currentUserId,
            groupId: groupId
        )
    }

    func makeQuestsViewModel() -> QuestsViewModel {
        QuestsViewModel(
            authRepository: authRepository,
            userRepository: userRepository,
            questRepository: questRepository
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            authRepository: authRepository,
            userRepository: userRepository,
            groupRepository: groupRepository,
            questRepository: questRepository
        )
    }

    @ViewBuilder
    func makeMainTabView(currentUserId: String, groupId: String, onLogoutRequest: @escaping () -> Void) -> some View {
        MainTabView(
            currentUserId: currentUserId,
            groupId: groupId,
            timelineViewModel: makeTimelineViewModel(currentUserId: currentUserId, groupId: groupId),
            questsViewModel: makeQuestsViewModel(),
            profileViewModel: makeProfileViewModel(),
            onLogoutRequest: onLogoutRequest
        )
    }

    @ViewBuilder
    func makePostView(questId: String) -> some View {
        PostView(
            viewModel: PostViewModel(
                questId: questId,
                timelineRepository: timelineRepository,
                authRepository: authRepository,
                userRepository: userRepository,
                questRepository: questRepository
            )
        )
    }

    @ViewBuilder
    func makeProfileEditView(currentUserId: String) -> some View {
        ProfileEditView(
            viewModel: ProfileEditViewModel(
                userRepository: userRepository,
                currentUserId: currentUserId
            )
        )
    }

    @ViewBuilder
    func makeGroupView() -> some View {
        GroupView(
            viewModel: GroupViewModel(
                groupRepository: groupRepository,
                authRepository: authRepository,
                userRepository: userRepository,
                questRepository: questRepository
            )
        )
    }

    @ViewBuilder
    func makeGroupQuestListView(groupId: String) -> some View {
        GroupQuestListView(
            viewModel: GroupQuestListViewModel(
                questRepository: questRepository,
                groupId: groupId
            )
        )
    }

    @ViewBuilder
    func makeQuestFormView(groupId: String, initialQuest: Quest?, onSaved: @escaping () -> Void) -> some View {
        QuestFormView(
            viewModel: QuestFormViewModel(
                questRepository: questRepository,
                groupId: groupId,
                initialQuest: initialQuest
            ),
            onSaved: onSaved
        )
    }

    @ViewBuilder
    func makeNotificationsView() -> some View {
        NotificationsView(
            viewModel: NotificationsViewModel(
                notificationRepository: notificationRepository,
                authRepository: authRepository
            )
        )
    }

    @ViewBuilder
    func makeCommentView(postId: String, currentUserId: String) -> some View {
        CommentView(
            viewModel: CommentViewModel(
                postId: postId,
                timelineRepository: timelineRepository,
                userRepository: userRepository,
                currentUserId: currentUserId
            )
        )
    }
}
