# 🚀 Fluxter

**Scalable Flutter Architecture** — A production-ready Flutter template implementing the **Feature-First + Riverpod** pattern. Clean, modular, and designed to scale seamlessly.

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Architecture](#-architecture)
- [Folder Structure](#-folder-structure)
- [Tech Stack](#-tech-stack)
- [Installation](#-installation)
- [Core Module](#-core-module)
  - [Network Layer](#1-network-layer)
  - [Local Storage](#2-local-storage)
- [Features Layer](#-features-layer)
  - [Domain (Models)](#1-domain-models)
  - [Data (Repositories)](#2-data-repositories)
  - [Presentation (Screens & Controllers)](#3-presentation-screens--controllers)
- [App Layer](#-app-layer)
  - [Config](#1-config--app-module)
  - [Router](#2-router--redirection-guarding)
  - [Theme & Color System](#3-theme--color-system)
  - [Localization](#4-localization)
  - [Widgets](#5-widgets)
  - [Extensions](#6-extensions)
  - [Helpers](#7-helpers)
- [Rapid Generation Tools](#-rapid-generation-tools)
- [Code Generation](#-code-generation)
- [Naming Conventions](#-naming-conventions)
- [License](#-license)

---

## 📖 About the Project

Fluxter is an **architecture template** designed to provide a robust and clean foundation for enterprise Flutter projects. Centered around **Clean Architecture** principles and a modular **Feature-First** structure, Fluxter provides:

- ✅ Clear Separation of Concerns (Presentation, Domain, Data, Core, App)
- ✅ Modern state management via **Riverpod 3.x with `@riverpod` Auto-Generated Providers**
- ✅ Type-safe network layer (**Dio + Retrofit**)
- ✅ Smart token refresh with automatic queueing
- ✅ Automatic reactive redirection on session expiry
- ✅ Structured local storage (**SharedPreferences**)
- ✅ Declarative routing with auth guards (**GoRouter**)
- ✅ Immutable models with code generation (**Freezed + JSON Serializable**)
- ✅ Consistent dark/light theme system powered by Riverpod
- ✅ Dynamic dual-language localization (EN & ID) with `.tr` extension
- ✅ Rich extension library (DateTime, String, Num, Widget, Context)
- ✅ Comprehensive reusable widget library (Button, TextField, Alert, ListView, GridView, Image, Loading, InkWell, Empty State)

---

## 🏗 Architecture

Fluxter organizes the codebase by **features** rather than global technical layers. Within each feature directory under `lib/features/`, the code is split into three clean layers: **Domain**, **Data**, and **Presentation**.

1. **Presentation Layer**:
   * **Screen (View)**: Consumes state and displays the UI.
   * **Controller (Notifier/AsyncNotifier)**: Manages UI state, handles user actions, and communicates with Repositories.
2. **Data Layer**:
   * **Repository**: Manages data coordination (fetching from Remote, caching to Local).
   * **ApiService (Retrofit)**: Handles network interactions.
   * **LocalStorage (SharedPreferences)**: Manages persistent cache.
3. **Core Layer**:
   * Foundational infrastructure such as `ApiResult`, `ApiResponse`, and `ApiManager`.

### Data Flow
1. **Screen**: Renders the UI and observes states via Riverpod `ConsumerWidget` or `ConsumerStatefulWidget`.
2. **Controller**: Manages user interactions, calls repositories, and updates states extending Riverpod's `Notifier` or `AsyncNotifier`.
3. **Repository**: Coordinates fetching remote data from `ApiService` and local storage from `LocalStorage`.
4. **Core**: Declares foundational infrastructure services.

---

## 📁 Folder Structure

```
lib/
├── main.dart                          # Application entry point & ProviderScope
│
├── app/                               # App-wide components
│   ├── fluxter_app.dart               # Root widget (MaterialApp.router)
│   ├── config/
│   │   ├── app_config.dart            # Global configurations (base URL, timeouts)
│   │   └── app_module.dart            # Service initialization (LocalStorage boot)
│   ├── localization/
│   │   ├── app_translations.dart      # Translation engine + .tr extension
│   │   ├── translation_keys.dart      # Translation key constants
│   │   ├── en_us.dart                 # English translations
│   │   └── id_id.dart                 # Indonesian translations
│   ├── router/
│   │   └── app_router.dart            # Navigation config (GoRouter) + Auth Guards
│   ├── theme/
│   │   ├── app_color.dart             # Color constants + dynamic theme resolver
│   │   └── app_theme.dart             # Light & Dark theme definitions
│   ├── utils/
│   │   ├── extensions/
│   │   │   ├── extensions.dart        # Barrel export for all extensions
│   │   │   ├── context_extension.dart # Theme, ColorScheme & MediaQuery shortcuts
│   │   │   ├── date_time_extension.dart # DateTime & String date formatting
│   │   │   ├── num_extension.dart     # Spacing helpers (e.g. 16.height, 8.width)
│   │   │   ├── string_extension.dart  # Validation & manipulation helpers
│   │   │   └── widget_extension.dart  # Alignment, scroll, padding & margin wrappers
│   │   └── helpers/
│   │       ├── locale_helper.dart     # Locale state notifier (localeProvider)
│   │       ├── snackbar_helper.dart   # Global ScaffoldMessenger snackbars
│   │       └── theme_helper.dart      # Theme state notifier (themeModeProvider)
│   └── widgets/
│       ├── app_alert.dart             # Unified dialog & bottom sheet alerts
│       ├── app_button.dart            # Multi-variant button (filled, outlined, etc.)
│       ├── app_empty.dart             # Empty state placeholder widget
│       ├── app_grid_view.dart         # GridView with refresh, pagination & empty state
│       ├── app_image.dart             # Network/Asset/File image with loading & error
│       ├── app_ink_well.dart          # Container with material ripple feedback
│       ├── app_list_view.dart         # ListView with refresh, pagination & empty state
│       ├── app_loading.dart           # Loading indicator + overlay (dialog/bottom sheet)
│       └── app_text_field.dart        # Multi-variant text field with password toggle
│
├── core/                              # Shared foundation
│   ├── network/
│   │   ├── api_manager.dart           # DioException error mapping utility
│   │   ├── api_response.dart          # Sealed generic API response wrapper
│   │   ├── api_result.dart            # Sealed type for ApiSuccess / ApiError
│   │   ├── api_service.dart           # Retrofit clients & dioProvider
│   │   └── api_token_interceptor.dart  # Token refresh handler + force logout hook
│   └── storage/
│       └── local_storage.dart         # SharedPreferences wrapper & provider
│
└── features/                          # Feature-First modules
    ├── auth/
    │   ├── data/
    │   │   └── auth_repository.dart   # Auth Repository implementation
    │   ├── domain/
    │   │   ├── token.dart             # Token Model (Freezed)
    │   │   └── user.dart              # User Model (Freezed)
    │   └── presentation/
    │       ├── auth_controller.dart   # Auth AsyncNotifier & Session State
    │       └── login_screen.dart      # Login Screen UI
    └── home/
        └── presentation/
            └── home_screen.dart       # Home Screen UI

```

---

## 🛠 Tech Stack

| Category            | Library                           | Version   | Function                           |
|---------------------|-----------------------------------|-----------|------------------------------------|
| State Management    | `flutter_riverpod` + `annotation` | ^3.3.2    | State management & DI (code-gen)   |
| Routing             | `go_router`                       | ^17.3.0   | Declarative routing                |
| Network (HTTP)      | `dio`                             | ^5.9.2    | HTTP client                        |
| REST API client     | `retrofit`                        | ^4.9.2    | Retrofit type-safe annotations     |
| Local Storage       | `shared_preferences`              | ^2.5.5    | Persistent preferences storage     |
| Data Modeling       | `freezed` + `freezed_annotation`  | ^3.x      | Type-safe immutable classes        |
| Serialization       | `json_serializable`               | ^6.14.0   | JSON serialization/de-serialization|
| Date Formatting     | `intl`                            | ^0.20.2   | Internationalized date/number formatting |
| Network Logging     | `awesome_dio_interceptor`         | ^1.3.0    | Pretty Dio request/response logger |

---

## ⚙ Installation

Run the installation script in the root directory of your Flutter project:

**Windows (PowerShell):**
```powershell
curl.exe -sO https://raw.githubusercontent.com/dhotsky/fluxter/main/install.dart ; dart run install.dart ; del install.dart
```

**Mac / Linux:**
```bash
curl -sO https://raw.githubusercontent.com/dhotsky/fluxter/main/install.dart && dart run install.dart && rm install.dart
```

💡 **Interactive Options:**
During installation, the installer will ask if you want to include dynamic dual-language localization (EN & ID). If you opt out, it will automatically strip the localization dependencies, files, translation helper extensions (`.tr`), and keep the template clean in English-only mode.

---

## 🧱 Core Module

### 1. Network Layer

Located in `lib/core/network/`, it configures the network client via manual Riverpod providers.

#### 1.1 Providers
- **`dioProvider`**: Instantiates a single `Dio` client equipped with `ApiTokenInterceptor` and logs.
- **`apiServiceProvider`**: Exposes the type-safe `ApiService` Retrofit client.

#### 1.2 ApiTokenInterceptor
A queued interceptor that catches expired credentials:
- Automatically attaches Bearer tokens.
- Queue-based token refresh: if several requests fail with `401 Unauthorized` simultaneously, only one refresh request is dispatched. The other requests wait and retry using the new token.
- Automatic logout: If the token refresh fails, it calls `onTokenExpired` to notify the `AuthController` and prompt a redirection back to the Login screen.

### 2. Local Storage

Located in `lib/core/storage/local_storage.dart`, provides a `SharedPreferences` wrapper exposed via `localStorageProvider`. Supports storing tokens, theme preferences, locale settings, and custom key-value data.

---

## 📦 Features Layer

Each feature is organized cleanly inside its own folder. For example, the `auth` feature:

### 1. Domain (Models)
Define business models using `Freezed` for immutability.
Example: `lib/features/auth/domain/user.dart`
```dart
@freezed
abstract class User with _$User {
  const factory User({
    String? id,
    String? name,
    String? email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### 2. Data (Repositories)
Handles operations by pulling remote data and syncing with local storage.
Example: `lib/features/auth/data/auth_repository.dart`
```dart
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(apiServiceProvider),
    ref.watch(localStorageProvider),
  );
}
```

### 3. Presentation (Screens & Controllers)
State is managed by a `Controller` inheriting the auto-generated notifier base class.
Example: `lib/features/auth/presentation/auth_controller.dart`
```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() {
    return ref.watch(authRepositoryProvider).currentUser;
  }

  Future<ApiResult<User>> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).login(email, password);
    result.when(
      success: (user) => state = AsyncData(user),
      error: (msg, _) => state = AsyncError(Exception(msg), StackTrace.current),
    );
    return result;
  }
}
```

---

## 🎨 App Layer

### 1. Config & App Module

- **`app_config.dart`**: Global configurations such as base URL and timeouts.
- **`app_module.dart`**: Centralizes service initialization. Call `AppModule.initService()` in `main()` to boot async services like `LocalStorage` before the app starts.

```dart
class AppModule {
  static Future<void> initService() async {
    await LocalStorage.init();
  }
}
```

### 2. Router & Redirection Guarding
Routing is defined declaratively using `goRouterProvider` in `app_router.dart`. It watches `authControllerProvider` using `RouterNotifier` as a `refreshListenable` to enforce session guarding:
* **Unauthenticated**: Users are redirected immediately to `/login`.
* **Authenticated**: Users trying to open `/login` are automatically forwarded to `/home`.

### 3. Theme & Color System

#### AppColor
`app_color.dart` provides a complete design token system with:
- **Primary, Semantic, and Neutral** color constants for light and dark themes.
- **`themeColor()` resolver**: Dynamically returns the correct color based on the current `Brightness`.
- **`AppColorContextExtension`**: Shorthand access via `BuildContext` — e.g. `context.textPrimary`, `context.surface`, `context.border`.

```dart
// Static usage
AppColor.textPrimary(context)

// Extension usage (recommended)
context.textPrimary
context.surface
context.card
context.divider
```

#### Theme Mode
`theme_helper.dart` exposes a `themeModeProvider` (`Notifier<ThemeMode>`) that persists the user's dark/light preference to `LocalStorage` and toggles reactively.

```dart
// Toggle theme anywhere
ref.read(themeModeProvider.notifier).toggleTheme();
```

### 4. Localization

Fluxter includes a lightweight, Riverpod-powered dual-language localization system (EN & ID) without heavy third-party packages.

| File                       | Description                                    |
|----------------------------|------------------------------------------------|
| `app_translations.dart`    | Translation engine + `.tr` / `.trParams()` extensions |
| `translation_keys.dart`    | Centralized translation key constants          |
| `en_us.dart`               | English translation map                        |
| `id_id.dart`               | Indonesian translation map                     |
| `locale_helper.dart`       | `LocaleNotifier` state management (persisted)  |

#### Usage
```dart
// Simple translation
TranslationKeys.welcome.tr

// Parameterized translation
TranslationKeys.welcomeUser.trParams({'value': 'John'})

// Change locale
ref.read(localeProvider.notifier).setLocale('id');
```

### 5. Widgets

Fluxter ships with a comprehensive, production-ready widget library:

#### AppButton
A **unified button component** replacing all Flutter button variants with a single, consistent API. Supports **7 constructors** for different use cases:

| Constructor             | Description                                 |
|-------------------------|---------------------------------------------|
| `AppButton()`           | Filled primary button (default)             |
| `AppButton.outlined()`  | Outlined border button                      |
| `AppButton.shadow()`    | Elevated button with shadow                 |
| `AppButton.danger()`    | Red destructive action button               |
| `AppButton.soft()`      | Subtle surface-colored button               |
| `AppButton.text()`      | Minimal text-only button                    |
| `AppButton.custom()`    | Fully custom child widget                   |

All variants support `isLoading`, `isDisabled`, `prefixIcon`, `suffixIcon`, custom colors, and animated transitions.

```dart
// Filled button
AppButton(text: 'Login', onPressed: () {})

// Danger button with loading
AppButton.danger(text: 'Delete', isLoading: true, onPressed: () {})

// Dynamic button via custom
AppButton.custom(onPressed: () {}, child: Icon(Icons.favorite))
```

---

#### AppTextField
A **multi-variant text field** with built-in password visibility toggle, title labels, and form validation.

| Constructor                  | Style                                      |
|------------------------------|--------------------------------------------|
| `AppTextField()`             | Outlined (default) — bordered rounded      |
| `AppTextField.outlined()`    | Same as default                            |
| `AppTextField.underline()`   | Underline-only border                      |
| `AppTextField.basic()`       | Borderless minimal field                   |
| `AppTextField.floating()`    | Shadow-elevated card-style field           |

```dart
AppTextField(
  title: 'Email',
  hintText: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
)

AppTextField.floating(
  title: 'Password',
  isPassword: true,  // Auto password toggle icon
)
```

---

#### AppAlert
Unified alert system supporting both **Dialog** and **Bottom Sheet** formats:

| Method                              | Description                               |
|-------------------------------------|-------------------------------------------|
| `AppAlert.showDialogAlert()`        | Simple informational dialog popup         |
| `AppAlert.showBottomSheetAlert()`   | Simple informational bottom sheet         |
| `AppAlert.showConfirmationDialog()` | Yes/No confirmation dialog (returns bool) |
| `AppAlert.showConfirmationBottomSheet()` | Yes/No confirmation bottom sheet    |

Confirmation alerts support an `isDanger` flag for destructive actions.

---

#### AppListView
A reusable `ListView` component with built-in support for:
- ♻️ **Pull to Refresh** (`onRefresh`)
- 📄 **Load More / Pagination** (`onLoadMore` with 90% scroll threshold)
- 📭 **Empty State** (defaults to `AppEmpty`, customizable)
- ⏳ **Initial Loading State**
- 📌 **Optional Header Widget**

```dart
AppListView(
  numberOfItems: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index].name)),
  onRefresh: () => controller.refresh(),
  onLoadMore: () => controller.loadMore(),
  isLoadMoreLoading: state.isPaginating,
  hasReachedMax: state.hasReachedMax,
)
```

---

#### AppGridView
A reusable `GridView` component with the same feature set as `AppListView`:
- ♻️ Pull to Refresh, 📄 Pagination, 📭 Empty State, ⏳ Loading State
- Configurable `crossAxisCount`, `mainAxisSpacing`, `crossAxisSpacing`, and `childAspectRatio`.

```dart
AppGridView(
  numberOfItems: products.length,
  crossAxisCount: 2,
  childAspectRatio: 0.75,
  itemBuilder: (context, index) => ProductCard(products[index]),
  onRefresh: () => controller.refresh(),
  onLoadMore: () => controller.loadMore(),
  hasReachedMax: state.hasReachedMax,
)
```

---

#### AppImage
A unified image component supporting **Network**, **Asset**, and **File** sources with built-in loading states, error fallbacks, aspect ratio, and border radius.

```dart
// Network image with border radius
AppImage.network('https://example.com/photo.jpg', borderRadius: 12)

// Asset image with aspect ratio
AppImage.asset('assets/images/banner.png', aspectRatio: 16/9)

// File image
AppImage.file('/path/to/local/image.jpg', width: 200, height: 200)
```

---

#### AppInkWell
A premium, customizable interactable widget that behaves like a `Container` but features **Material ripple splash feedback**. Ideal for list items, cards, and custom buttons.

```dart
AppInkWell(
  onTap: () {},
  borderRadius: BorderRadius.circular(12),
  backgroundColor: context.card,
  padding: EdgeInsets.all(16),
  child: Text('Tap me'),
)
```

---

#### AppEmpty
A reusable empty state placeholder widget with customizable title, message, icon, and optional action button.

```dart
AppEmpty(
  title: 'No Data Found',
  message: 'There is nothing to display right now.',
  icon: Icons.inbox_outlined,
  action: AppButton(text: 'Retry', onPressed: () {}),
)
```

---

#### AppLoading & AppLoadingOverlay
- **`AppLoading`**: Inline loading indicator with optional text label, customizable size and color.
- **`AppLoadingOverlay`**: Blocks user interaction with a modal loading overlay — available as either a **Dialog** or **Bottom Sheet**.

```dart
// Inline loading
AppLoading(text: 'Fetching data...')

// Show overlay
AppLoadingOverlay.showAsDialog(context, text: 'Processing...');

// Hide overlay
AppLoadingOverlay.hide(context);
```

---

### 6. Extensions

Fluxter provides a rich set of Dart extension methods to reduce boilerplate. All extensions are exported via a single barrel file:

```dart
import 'package:fluxter/app/utils/extensions/extensions.dart';
```

#### ContextExtension (`BuildContext`)
```dart
context.theme          // ThemeData
context.textTheme      // TextTheme
context.colorScheme    // ColorScheme
context.isDarkMode     // bool
context.width          // Screen width
context.height         // Screen height
context.padding        // Safe area padding
```

#### NumExtension (`num`)
```dart
16.height              // SizedBox(height: 16)
8.width                // SizedBox(width: 8)
```

#### StringExtension (`String`)
```dart
'test@email.com'.isValidEmail       // true
'abc123'.isValidPassword            // true
'081234567890'.isValidPhoneNumber    // true
'hello'.capitalizeFirst             // 'Hello'
```

#### DateTimeExtension (`DateTime` & `String`)
```dart
DateTime.now().toFormattedDate       // '06 June 2026'
DateTime.now().toFormattedTime       // '14:30'
DateTime.now().toFormattedDateTime   // '06 June 2026, 14:30'

'2026-06-06'.toFormattedDateDefault  // '06 June 2026'
```

#### WidgetExtension (`Widget`)
```dart
// Alignment
myWidget.center
myWidget.align(Alignment.topLeft)

// Scrollable
myWidget.toScrollable

// Padding
myWidget.paddingAll(16)
myWidget.paddingSymmetric(horizontal: 12, vertical: 8)
myWidget.paddingOnly(left: 16, top: 8)

// Margin
myWidget.marginAll(16)
myWidget.marginSymmetric(horizontal: 12)
myWidget.marginOnly(bottom: 24)
```

### 7. Helpers

#### SnackbarHelper
Global snackbar utility attached to `MaterialApp.router` via `scaffoldMessengerKey`. Callable from anywhere without requiring `BuildContext`:

```dart
SnackbarHelper.showSuccess('Data saved successfully');
SnackbarHelper.showError('Something went wrong');
SnackbarHelper.showInfo('New update available');
SnackbarHelper.showWarning('Connection unstable');
```

#### ThemeHelper
Riverpod-powered `ThemeModeNotifier` that persists dark/light mode preference:

```dart
ref.read(themeModeProvider.notifier).toggleTheme();
```

#### LocaleHelper
Riverpod-powered `LocaleNotifier` that persists language preference and syncs with `AppTranslations`:

```dart
ref.read(localeProvider.notifier).setLocale('id');  // Switch to Indonesian
ref.read(localeProvider.notifier).setLocale('en');  // Switch to English
```

---

## 🚀 Rapid Generation Tools

Fluxter provides fast code-generation scripts to accelerate feature creation:

### 1. Generate Feature
Run the command below to generate feature folders and populated template files under `lib/features/`:
```bash
dart run :fluxter_create <feature_name> [flags]
```
*Flags:*
- `--stateful` / `--stateless` : Specifies screen widget type (default is stateless).
- `--controller` / `--no-controller` : Specifies whether to generate a controller (default is true).
- `--state` / `--no-state` : Specifies whether to generate a custom Freezed state model for the controller.

*Example:* `dart run :fluxter_create profile --stateful --state`
Generates:
* `lib/features/profile/presentation/profile_screen.dart` (Stateful ConsumerWidget)
* `lib/features/profile/presentation/profile_controller.dart` (Riverpod `@riverpod` controller with state)
* `lib/features/profile/presentation/profile_state.dart` (Freezed state model)

*(If run without flags, the tool provides an interactive step-by-step prompt menu)*


### 2. Generate Model from JSON
Generate a Freezed model from pasted JSON:
```bash
# Global / shared model
dart run :fluxter_model <model_name>

# Model inside a specific feature
dart run :fluxter_model <model_name> --<feature_name>
```
*Examples:*
* `dart run :fluxter_model profile` → `lib/features/shared/domain/profile.dart`
* `dart run :fluxter_model user --profile` → `lib/features/profile/domain/user.dart`

### 3. Generate Repository
Generate a data repository with optional dependency injection flags:
```bash
# Standard clean repository
dart run :fluxter_repository <name>

# Repository inside a specific feature with ApiService and LocalStorage injected
dart run :fluxter_repository <name> --<feature_name> --api-service --local-storage
```
*Flags:*
- `--api-service` : Injects `ApiService` dependency and sets up Riverpod provider watch block.
- `--local-storage` : Injects `LocalStorage` dependency and sets up Riverpod provider watch block.
*Examples:*
* `dart run :fluxter_repository auth` → `lib/features/auth/data/auth_repository.dart` (Clean repository)
* `dart run :fluxter_repository payment --api-service --local-storage` → `lib/features/payment/data/payment_repository.dart` (With ApiService and LocalStorage)

### 4. Interactive Translation Generator
Add translation keys dynamically into localization files (`translation_keys.dart`, `en_us.dart`, and `id_id.dart`):
```bash
dart run :fluxter_translate
```
This interactive script will guide you to enter the Translation Key (in camelCase/snake_case), the English string, and the Indonesian translation, then injects them safely and automatically into the files.

---

## 🔄 Code Generation

Run `build_runner` to build Freezed, JSON Serializer, and Retrofit files:
```bash
# Compile code generation once
dart run build_runner build

# Run in watch-mode to auto-build changes
dart run build_runner watch
```

---

## 📝 Naming Conventions

| Component             | Case Convention           | Example                          |
|-----------------------|---------------------------|----------------------------------|
| File                  | `snake_case`              | `login_screen.dart`              |
| Class                 | `PascalCase`              | `AuthController`                 |
| Variable/Function     | `camelCase`               | `isLoading`, `login()`           |
| UI Feature Folder     | `snake_case`              | `lib/features/auth/`             |
| Route path            | `kebab-case` with `/`     | `/login`, `/home`                |
| Provider              | `camelCase` + `Provider`  | `authControllerProvider`         |
```
