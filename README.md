# 🏋️ REVA.FITNESS - Futuristic 3D/2D Anatomy Fitness Mobile App

A modern, high-performance Flutter application designed for real-time biomechanical analysis and muscle-targeted workout diagnostics. Features interactive 2D and 3D rotatable human anatomy models with real-time muscle highlighting and exercise guides.

---

## 📥 Download App

[![Direct Download APK](https://img.shields.io/badge/Direct%20Download-RevaFitness%20v3.0.0%20APK-FF5E00?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Parshuram9353/reva-fitness-app/raw/master/release/RevaFitness-v3.0.0.apk)

Get the ready-to-install Android application directly from the repository:
* 📲 **[Download RevaFitness-v3.0.0.apk (Latest v3.0)](https://github.com/Parshuram9353/reva-fitness-app/raw/master/release/RevaFitness-v3.0.0.apk)** *(~64.5 MB, Android 5.0+)*
* 📂 **[View All Available Releases (v1.0, v2.0, v3.0)](release/README.md)** with changelog and direct links.

---

## ✨ Features

- **🔄 Dual Anatomy View Modes**:
  - **2D Hologram View**: Interactive vector-rendered human anatomy model with instant Anterior (Front) and Posterior (Back) view switching.
  - **3D Rotatable View**: 360-degree drag-to-rotate muscular model projected using dynamic 3D-to-2D matrix math on a custom canvas.

- **🎯 Interactive Muscle Targeting**:
  - Touch any muscle group (Pectorals, Biceps, Abs, Quads, Deltoids, Lats, Calves, Glutes, etc.) to trigger glowing neon highlights.
  - Instant biomechanical scan with discoverability target reticles.

- **📊 Biomechanical Info Dashboard**:
  - **Train**: Targeted Dumbbell, Machine, and Home exercises for each muscle group.
  - **Anatomy**: Specifications and core movement kinematics.
  - **Mistakes**: Common injury risks and form mistakes to avoid.
  - **Stretch & Mobility**: Post-workout recovery stretches.
  - **Recovery**: Nutritional guidance and supplementation tips.

- **🔍 Search & Favorites**:
  - Instant muscle search with real-time suggestion dropdown.
  - Random diagnostic scan generator (`SCAN` button).
  - Bookmark favorite muscle targets for quick reference.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `>=3.0.0 <4.0.0`)
- **State Management**: [Flutter Riverpod](https://riverpod.dev/) (`^2.5.0`)
- **Rendering & Math**: Custom Matrix Projection, Canvas Path Parsing, Custom Painters
- **Animations**: `flutter_animate` (`^4.5.0`)
- **Typography & Styling**: `google_fonts` (`^6.2.0`)

---

## 🚀 Getting Started

### Prerequisites

Ensure you have installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- Android Studio / VS Code with Flutter extension
- An emulator or physical test device

### Installation & Execution

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Parshuram9353/reva-fitness-app.git
   cd reva-fitness-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   - On your connected phone or emulator:
     ```bash
     flutter run
     ```
   - On Windows Desktop:
     ```bash
     flutter run -d windows
     ```

---

## 📁 Project Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart         # Cyberpunk/Futuristic color palette
│       └── app_theme.dart          # Dark theme definition & typography
├── features/
│   ├── anatomy/
│   │   ├── data/                   # Local muscle database & domain models
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/          # Riverpod state providers
│   │       └── widgets/
│   │           ├── body_view_2d.dart  # 2D SVG Path Interactive View
│   │           └── body_view_3d.dart  # 3D Matrix Projection View
│   └── details_panel/
│       └── presentation/
│           └── screens/
│               └── info_dashboard_panel.dart # Expandable bottom drawer
└── main.dart                       # Main exploration screen & navigation
```

---

## 👤 Author

Developed with ❤️ by **Parshuram**.
