# 🏗️ FORTUNIA - MODULAR ARCHITECTURE

## 📁 **Folder Structure**

```
fortunia/
├── Core/
│   ├── Constants/
│   │   └── AppConstants.swift
│   └── Extensions/
│       ├── Color+Extensions.swift
│       ├── Typography+Extensions.swift
│       ├── Spacing+Extensions.swift
│       └── CornerRadius+Extensions.swift
├── Models/
│   ├── Data/
│   │   ├── User.swift
│   │   └── FortuneReading.swift
│   ├── API/
│   └── UI/
├── Services/
│   ├── Networking/
│   │   └── NetworkService.swift
│   ├── Auth/
│   ├── Analytics/
│   └── Storage/
├── ViewModels/
│   └── BaseViewModel.swift
├── Views/
│   ├── Components/
│   └── Screens/
└── Utils/
```

## 🎯 **Architecture Principles**

1. **Separation of Concerns** - Each layer has a specific responsibility
2. **Dependency Injection** - Services are injected, not hardcoded
3. **Protocol-Oriented** - Use protocols for testability
4. **MVVM Pattern** - Clear separation between View and Business Logic
5. **Reactive Programming** - Combine for data flow

## 📋 **Next Steps**

- [ ] Create AuthService
- [ ] Create AnalyticsService
- [ ] Create SupabaseService
- [ ] Create ViewModels for each screen
- [ ] Create reusable UI components
