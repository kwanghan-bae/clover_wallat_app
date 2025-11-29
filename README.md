# 🍀 Clover Wallet App

Clover Wallet의 크로스 플랫폼 모바일/웹 애플리케이션입니다. Flutter로 개발되었으며, 로또 번호 관리, QR 스캔, 커뮤니티 기능을 제공합니다.

## 🚀 Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider / ViewModel Pattern
- **Auth**: Supabase Auth (Google Sign-In)
- **Network**: http, json_serializable
- **Features**:
  - **Camera**: QR Code Scanning (Mobile)
  - **Maps**: Google Maps Integration (Lotto Spots)
  - **OCR**: Ticket Number Extraction

## 📱 Features

1. **Lotto Management**: QR 코드로 로또 티켓을 스캔하여 저장하고 당첨 여부를 확인합니다.
2. **Community**: 사용자들과 당첨 후기 및 정보를 공유합니다.
3. **Map**: 근처 로또 판매점을 지도에서 확인합니다.
4. **Number Generation**: 다양한 알고리즘으로 추천 번호를 생성합니다.

## 🛠 Setup & Run

### Prerequisites
- Flutter SDK
- Android Studio / Xcode (Mobile)
- Chrome (Web)

### 1. 설정 (Configuration)
`lib/utils/api_config.dart` 파일에서 백엔드 API 주소를 관리합니다.

```dart
class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      // 배포된 백엔드 주소
      return 'https://clover-wallet-api.onrender.com';
    }
    // 로컬 개발용 주소
    return 'http://localhost:8080';
  }
}
```

### 2. 실행 (Mobile)
```bash
# 의존성 설치
flutter pub get

# 앱 실행 (에뮬레이터 또는 디바이스 연결 필요)
flutter run
```

### 3. 실행 (Web)

**로컬 백엔드 연동 (개발 모드):**
```bash
# 로컬 백엔드(localhost:8080)가 실행 중이어야 합니다.
flutter run -d chrome
```

**배포된 백엔드 연동 (릴리즈 모드):**
```bash
# 실제 운영 서버와 통신합니다.
flutter run -d chrome --release
```

## 🌐 Web Build & Deployment

웹 버전을 배포하기 위해 정적 파일을 생성합니다.

```bash
flutter build web
```

`build/web` 디렉토리에 생성된 파일들을 호스팅 서비스에 업로드하면 됩니다.
- **Vercel / Netlify**: `build/web` 폴더를 루트로 설정하여 배포
- **GitHub Pages**: `docs` 폴더로 복사하거나 `gh-pages` 브랜치 사용

## 🔗 Backend Integration
이 앱은 [Clover Wallet API](https://github.com/kwanghan-bae/clover-wallet)와 연동되어 작동합니다.
로그인 시 백엔드와 사용자 정보를 동기화하며, 모든 데이터는 백엔드 DB에 저장됩니다.
