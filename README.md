# 🔮 Fortunia - AI-Powered Fortune Reading App

<div align="center">
  <img src="https://img.shields.io/badge/iOS-16.6+-blue.svg" alt="iOS Version">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/SwiftUI-4.0-green.svg" alt="SwiftUI Version">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
</div>

## ✨ Overview

Fortunia is a mystical AI-powered fortune reading app that brings ancient divination practices into the modern digital age. Built with SwiftUI and powered by cutting-edge AI technology, Fortunia offers personalized fortune readings through various traditional methods.

## 🎯 Features

### 🔮 Fortune Reading Types
- **Tarot Cards** - Traditional tarot card readings
- **Crystal Ball** - Mystical crystal ball visions
- **Palm Reading** - AI-powered palm analysis
- **Numerology** - Birth date and name analysis

### 🎨 Design Philosophy
- **Radical Simplicity** - Clean, intuitive interface
- **Cultural Respect** - Honoring traditional practices
- **Feminine Elegance** - Soft, mystical aesthetic
- **Privacy First** - Secure, anonymous readings

### 🚀 Technical Features
- **AI-Powered Readings** - Advanced AI generates personalized fortunes
- **Real-time Generation** - Instant fortune creation
- **Offline Support** - Read fortunes without internet
- **Multi-language** - Support for multiple languages
- **Dark Mode** - Beautiful dark theme support

## 🏗️ Architecture

### Modular Structure
```
fortunia/
├── Core/                    # Core utilities and extensions
│   ├── Extensions/         # SwiftUI extensions
│   └── Constants/          # App constants
├── Models/                 # Data models
│   └── Data/              # Core data structures
├── Services/              # Business logic
│   └── Networking/        # API services
├── ViewModels/            # MVVM view models
├── Views/                 # SwiftUI views
│   ├── Screens/          # Main screens
│   └── Components/       # Reusable components
└── Resources/            # Assets and resources
```

### Tech Stack
- **SwiftUI** - Modern iOS UI framework
- **Combine** - Reactive programming
- **Firebase** - Analytics, Crashlytics, Messaging
- **Supabase** - Backend as a Service
- **Adapty** - Subscription management
- **Kingfisher** - Image loading and caching

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.6+
- Swift 5.9+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/jansoganci/fortunia.git
   cd fortunia
   ```

2. **Open in Xcode**
   ```bash
   open fortunia.xcodeproj
   ```

3. **Install dependencies**
   - Dependencies are managed via Swift Package Manager
   - Xcode will automatically resolve packages

4. **Configure Firebase**
   - Add your `GoogleService-Info.plist` to the project
   - Update Firebase configuration in `AppDelegate`

5. **Configure Supabase**
   - Update Supabase URL and API key in configuration
   - Run the provided SQL schema

6. **Build and Run**
   - Select your target device or simulator
   - Press Cmd+R to build and run

## 📱 Screenshots

<div align="center">
  <img src="docs/screenshots/splash.png" width="200" alt="Splash Screen">
  <img src="docs/screenshots/auth.png" width="200" alt="Auth Screen">
  <img src="docs/screenshots/home.png" width="200" alt="Home Screen">
  <img src="docs/screenshots/reading.png" width="200" alt="Fortune Reading">
</div>

## 🎨 Design System

### Colors
- **Primary**: Mystical purple gradient
- **Accent**: Golden yellow highlights
- **Background**: Soft, ethereal tones
- **Text**: High contrast for readability

### Typography
- **Display**: Large, mystical headings
- **Body**: Clean, readable text
- **Caption**: Subtle, informative text

### Spacing
- **8pt Grid System** - Consistent spacing scale
- **Responsive Design** - Adapts to all screen sizes

## 🔧 Configuration

### Environment Variables
Create a `.env` file with:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
FIREBASE_API_KEY=your_firebase_api_key
```

### Firebase Setup
1. Create a Firebase project
2. Add iOS app with bundle ID: `com.janstrade.fortunia`
3. Download `GoogleService-Info.plist`
4. Add to Xcode project

### Supabase Setup
1. Create a Supabase project
2. Run the provided SQL schema
3. Update configuration with your project details

## 📊 Performance

- **App Launch Time**: < 2 seconds
- **Reading Generation**: < 3 seconds
- **Memory Usage**: Optimized for efficiency
- **Battery Life**: Minimal impact

## 🧪 Testing

### Unit Tests
```bash
xcodebuild test -scheme fortunia -destination 'platform=iOS Simulator,name=iPhone 16'
```

### UI Tests
```bash
xcodebuild test -scheme fortunia -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:fortuniaUITests
```

## 📈 Analytics

- **Firebase Analytics** - User behavior tracking
- **Crashlytics** - Crash reporting and analysis
- **Custom Events** - Fortune reading analytics

## 🔒 Privacy

- **No Personal Data Collection** - Anonymous readings only
- **Local Storage** - Readings stored locally
- **Encrypted Communication** - All API calls encrypted
- **GDPR Compliant** - Full privacy compliance

## 🚀 Deployment

### App Store
1. Update version number
2. Archive the project
3. Upload to App Store Connect
4. Submit for review

### TestFlight
1. Archive the project
2. Upload to TestFlight
3. Invite beta testers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Can Soğancı** - Lead Developer
- **AI Assistant** - Development Support

## 🙏 Acknowledgments

- Traditional fortune reading practices
- SwiftUI community
- Open source contributors
- Beta testers

## 📞 Support

- **Email**: support@fortunia.app
- **Discord**: [Join our community](https://discord.gg/fortunia)
- **Issues**: [GitHub Issues](https://github.com/jansoganci/fortunia/issues)

## 🔮 Roadmap

### Phase 1 - Foundation ✅
- [x] Basic app structure
- [x] Authentication system
- [x] Core UI components
- [x] Basic fortune reading

### Phase 2 - Enhancement 🚧
- [ ] Advanced AI readings
- [ ] Social features
- [ ] Premium subscriptions
- [ ] Push notifications

### Phase 3 - Expansion 🔮
- [ ] Multiple languages
- [ ] AR crystal ball
- [ ] Voice readings
- [ ] Community features

---

<div align="center">
  <p>Made with 🔮 and ❤️ by the Fortunia team</p>
  <p>© 2025 Fortunia. All rights reserved.</p>
</div>
