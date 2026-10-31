# Hợp Đồng ViewModel & Các Ràng Buộc Kỹ Thuật (CONSTRAINTS.md)

## 1. Hợp Đồng ViewModel Công Khai (Public UI Contracts)
Giao diện UI chỉ tương tác với ViewModel qua các trường (fields) và phương thức (methods) sau. Agent ngoài **KHÔNG ĐƯỢC PHÉP** gọi trực tiếp DataSource, API client hay Database:

| ViewModel | Trường công khai (State) | Phương thức giao diện gọi (Actions) |
|---|---|---|
| `AuthProvider` (`features/auth/.../auth_provider.dart:28`) | `status: AuthStatus`, `currentUser: UserEntity?`, `isLoading: bool`, `errorMessage: String?`, `isAuthenticated: bool`, `isStudent: bool`, `isRecruiter: bool` | `checkAuth(): Future<void>`, `login(email, pass)`, `loginWithGoogle()`, `loginWithGitHub()`, `register(...)`, `logout()` |
| `JobProvider` (`features/jobs/.../job_provider.dart:22`) | `jobs: List<JobEntity>`, `isLoading: bool`, `errorMessage: String?`, `filter: JobFilter` | `loadJobs(): Future<void>`, `search(query)`, `applyFilter(filter)`, `clearFilter()` |
| `SocialFeedProvider` (`features/social/.../social_feed_provider.dart:18`) | `posts: List<PostEntity>`, `isLoading: bool`, `isFetchingMore: bool` | `loadInitialPosts()`, `loadMorePosts()`, `createPost(content, images)` |
| `LocaleViewModel` (`core/localization/locale_view_model.dart:6`) | `locale: Locale`, `isVietnamese: bool` | `loadLocale(): Future<void>`, `setLocale(locale)`, `toggleLanguage()` |
| `ProfileEditViewModel` (`features/profile/.../profile_edit_view_model.dart:10`)| `fullName: String`, `isPrivate: bool`, `isLoading: bool`, `errorMessage: String?`, `isSaved: bool` | `setFullName(name)`, `setPrivate(val)`, `saveProfile(): Future<Result<Unit, AppFailure>>` |
| `SkillsViewModel` (`features/skills/.../skills_view_model.dart:12`) | `skills: List<SkillEntity>`, `isLoading: bool`, `errorMessage: String?` | `load(): Future<void>`, `addSkill(name, level)` |
| `ConsentViewModel` (`features/consent/.../consent_view_model.dart:10`) | `hasConsented: bool`, `isLoading: bool` | `load(): Future<void>`, `grantConsent()`, `revokeConsent()` |
| `RepoUploadViewModel` (`features/skills/.../repo_upload_view_model.dart:12`) | `repoUrl: String`, `isScanning: bool`, `errorMessage: String?` | `setRepoUrl(url)`, `scanRepo(): Future<Result<RepoScanResult, AppFailure>>` |
| `CoachProvider` (`features/coach/.../coach_provider.dart:20`) | `messages: List<CoachMessage>`, `isLoading: bool`, `remainingQuota: int` (tối đa 10/ngày) | `sendMessage(prompt): Future<void>`, `resetDailyQuota()` |

## 2. Các Bất Biến Phải Giữ Nguyên (Immutability Rules)
1. **Tên định tuyến (Route Names)**: Tuyệt đối giữ nguyên bảng route trong `app/lib/main.dart:178-188`:
   `/`, `/login`, `/register`, `/student-home`, `/recruiter-home`, `/skills`, `/analysis-consent`, `/repo-evidence`, `/edit-profile`.
2. **Khóa bản địa hóa (l10n keys)**: Các khóa trong file `app_vi.arb` và `app_en.arb` đang được test `arb_keys_test.dart` giám sát tự động; không được tự ý xóa hoặc đổi tên khóa.
3. **Cổng kiểm tra bảo mật (Guards)**: Không bỏ qua các bước kiểm tra auth token trước khi vào Home, và kiểm tra quyền AI Consent trước khi quét GitHub Repo.
4. **Hồ sơ mặc định riêng tư**: Mọi tài khoản khởi tạo phải giữ nguyên `isPrivate: true` theo quy định bảo mật riêng tư người dùng.

## 3. Quy Tắc Dự Án Cho Agent Bên Ngoài (Rules from AGENTS.md)
- **Không tự ý thêm thư viện ngoài**: Bất kỳ package mới nào thêm vào `pubspec.yaml` đều phải được Product Owner phê duyệt trước.
- **Không sửa kiểm thử cho qua (Do NOT hack tests)**: Kiểm thử thất bại phải tìm nguyên nhân từ giao diện; tuyệt đối không xóa hoặc sửa assertion của test hiện có.
- **Không đụng hạ tầng & CSDL**: Nghiêm cấm chỉnh sửa migration, Supabase RLS, hàm edge function phía backend.
- **Giới hạn độ dài tệp**: Tất cả các file mã nguồn và tài liệu mới hoặc sửa đổi không được vượt quá 200 dòng code.

## 4. Danh Sách Thư Viện UI Cho Phép (Whitelisted UI Packages)
Agent dựng lại giao diện chỉ được phép sử dụng các gói UI đã đăng ký sẵn trong `app/pubspec.yaml`:
- `flutter` & `flutter_localizations` (UI core)
- `provider: ^6.1.5+1` (State management)
- `shadcn_ui: ^0.57.3` (Modern UI components)
- `go_router: ^18.1.2` (Routing)
- `google_fonts: ^6.2.1` (Typography - Be Vietnam Pro)
- `lucide_icons_flutter: 4.0.1` (Icon set)
- `flutter_animate` (Animation micro-interactions)
- `intl: ^0.20.3` (Date/time & Number format)

## 5. Danh Sách Màn Hình Đang Thay Đổi / Tạm Hoãn (In-flight Features)
Để tránh công sức dựng lại 2 lần, agent ngoài cần lưu ý:
- **Chatbot Gia sư Coach (F-013, `coach_sheet.dart`)**: Đang trong quá trình hoàn thiện hạn mức 10 câu/ngày và kiểm tra consent trước khi gửi.
- **Chatbot RAG Tài liệu (F-026..028)**: Tính năng tra cứu văn bản tuyển dụng đang hoàn thiện trên backend, chưa có giao diện chính thức.
- **Màn hình Chat cũ (S-19)**: Màn hình tin nhắn 1-1 cũ đang được xem xét thay thế; tạm thời chưa cần đầu tư dựng lại chi tiết.
- **Báo cáo Lương Ẩn danh (Ticket 13 / F-018)**: Đang chuẩn bị tích hợp biểu đồ phân vị lương.

