# 別働隊 -Shibari- (iOS)

このプロジェクトは、クローズドSNS型の目標達成・習慣化支援アプリ「別働隊 -Shibari-」の iOS アプリ用ソースコードです。
SwiftUI と Firebase を基盤とし、グループ内でのクエスト達成と相互レビューを実現します。

---

## 1. プロジェクトの概要と目的
「一人では続かない目標も、信頼できる仲間との『縛り』があれば達成できる」というコンセプトのもと開発されています。
証拠となる写真や動画を投稿し、メンバー同士が「承認/否認」を投票するシステムを備えた、規律重視の目標達成支援プラットフォームです。

## 2. 技術スタック
- **Language:** Swift 5.10+
- **Framework:** SwiftUI
- **State Management:** Observation framework (`@Observable`)
- **Asynchronous:** Swift Concurrency (async/await)
- **Backend Integration:** 
  - Firebase Auth (Google & Email)
  - Cloud Firestore (Database)
  - Firebase Storage (Media)
  - Firebase Messaging (Push Notifications)
- **Dependency Management:** Swift Package Manager (SPM)
- **CI/CD:** Codemagic

## 3. アーキテクチャと実装ルール
保守性とテスタビリティを確保するため、**MVVM (Model-View-ViewModel)** および **Repositoryパターン** を採用しています。

### 実装ルール
1. **Domain層とData層の分離:**
   - **Domain Model (`Domain/Models/`):** アプリ内のビジネスロジックやUIで使用する純粋なデータ型 (例: `User`)。
   - **DTO (`Data/DTOs/`):** Firestore への保存形式に最適化されたデータ型 (例: `UserDto`)。`@DocumentID` や `@ServerTimestamp` を含み、`toDomain()` / `fromDomain()` で相互変換を行います。

2. **Repositoryパターンの徹底:**
   - データアクセス（Firestore等）はすべて `Repository` インタフェースを通じて行います。
   - ViewModel は具体的な実装 (`UserRepositoryImpl` 等) ではなく、インタフェースに依存するように設計します。

3. **状態管理:**
   - iOS 17 以降の `@Observable` マクロを標準として使用します。
   - `RootView` から各 ViewModel へ Repository をインジェクトすることで、画面遷移と依存関係を整理しています。

---

## 4. 現在実装済みの主要機能
- **認証:** Googleログイン (GIDSignIn) およびメールアドレス認証。
- **グループ管理:** グループ作成、招待コードによる参加、メンバー管理。
- **クエスト管理:** グループ固有のクエスト（縛り）の選択と参加状態の同期。
- **タイムライン:** 
  - 写真・動画のアップロードとプレビュー。
  - ステータスバッジ（審査中、承認済み、否認済み）の表示。
- **ピアレビュー:** メンバーの投稿に対する「承認」「否認」の投票ロジック。
- **安全性:** ユーザーのブロック・通報機能（UGC対策）、利用規約 (Notion) 同意フロー。
- **アカウント管理:** プロフィール編集、退会（データ匿名化 ＋ Firebase Auth削除）。

## 5. ディレクトリ構造
```text
shibari/
├── shibariApp.swift      # アプリケーションのエントリーポイント
├── AppDelegate.swift     # Firebase / Push通知の初期設定とライフサイクル処理
├── ContentView.swift     # 初期コンテンツビュー（RootViewによって制御される場合が多い）
├── RootView.swift        # 認証状態に基づく画面遷移の制御ハブ
├── Info.plist            # アプリケーションの設定ファイル
├── shibari.entitlements  # アプリケーションの機能と権限設定
├── Assets.xcassets/      # アプリケーションのアセット（画像、カラー等）
├── Core/                 # コア機能と共通ユーティリティ
│   ├── Constants/        # 定数定義
│   │   └── NotionUrls.swift # Notion関連のURL定数
│   ├── DI/               # 依存性注入コンテナ
│   │   └── AppDIContainer.swift # アプリケーション全体のDIコンテナ
│   └── Utils/            # 共通ユーティリティ関数やヘルパークラス
├── Data/                 # データアクセス層
│   ├── DTOs/             # Firestoreマッピング用データ転送オブジェクト
│   └── Repositories/     # Repository インタフェースの具象実装
├── Domain/               # ビジネスロジック層
│   ├── Models/           # 純粋なビジネスドメインモデル
│   ├── Values/           # 列挙型や値オブジェクト
│   └── AppRepositories.swift # Repository インタフェース定義
├── Presentation/         # UI層
│   ├── ThemeColor.swift  # アプリケーションのテーマカラー定義
│   ├── Views/            # SwiftUIビューコンポーネント
│   ├── ViewModels/       # @Observable を使用したビューモデル
│   └── Components/       # 共通UIコンポーネント
└── Preview Content/      # Xcodeプレビュー用のモックデータやリポジトリ
    └── Repositories/     # モックリポジリの実装
```

## 6. 環境構築の手順
1. Xcode で `shibari.xcodeproj` を開きます。
2. Firebase コンソールから iOS アプリを追加し、`GoogleService-Info.plist` をダウンロードして `shibari/` ディレクトリ配下に配置します。
3. Googleログインを有効にするため、`Info.plist` の `URL types` に `REVERSED_CLIENT_ID` を設定します。

## 7. 今後の課題・未実装のタスク
- **プッシュ通知の本格導入:** `AppDelegate` でのトークン取得は実装済み。サーバーサイド（Cloud Functions）と連携した通知送信ロジックの動作確認が必要。
- **ページネーション:** タイムライン投稿の取得をカーソルベースのページネーションに移行し、高負荷時のパフォーマンスを改善。
- **オフライン対応:** Firestore のキャッシュ同期設定の最適化。
