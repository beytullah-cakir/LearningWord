# 📚 LearnWords

A modern, AI-powered language learning assistant built with Flutter. LearnWords helps you master new vocabulary through tiered daily challenges, interactive exercises, and intelligent feedback powered by Google Gemini.

![App Screenshot Placeholder](https://via.placeholder.com/800x400?text=LearnWords+Modern+UI+Preview)

## ✨ Features

-   **🧠 AI-Powered Learning**: Uses Google Gemini to generate contextual example sentences and provide real-time feedback on your sentence building skills.
-   **📅 Tiered Daily Challenges**:
    -   **Yesterday's Words**: Reinforce new vocabulary with active testing (Spelling, Speed Match, Voice Shadowing).
    -   **Older Words (2-3 days)**: Take your learning to the next level by building your own sentences and receiving AI feedback.
-   **🎮 Interactive Exercises**:
    -   **Spelling Mastery**: Practice writing words correctly.
    -   **Speed Match**: Fast-paced word-meaning association game.
    -   **Voice Shadowing**: Improve your pronunciation with speech-to-text feedback.
-   **📱 Modern UI/UX**: Premium design with glassmorphism effects, smooth animations, and a vibrant light theme.
-   **📂 Content Management**: Easily add, edit, and organize your word list with a quick-access bottom sheet interface.
-   **🔒 Offline Support**: Local SQLite database ensures your data is always available, even without an internet connection (AI features require online access).

## 🚀 Getting Started

### Prerequisites

-   Flutter SDK (v3.0.0 or higher)
-   Dart SDK
-   A Google Gemini API Key

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/beytullah-cakir/LearningWord.git
    cd LearningWord
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure API Key**:
    Open `lib/core/services/ai_service.dart` (and other related files) and replace `'YOUR_GEMINI_API_KEY_HERE'` with your actual Gemini API key.

4.  **Run the App**:
    ```bash
    flutter run
    ```

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/)
-   **Language**: [Dart](https://dart.dev/)
-   **Database**: [SQLite](https://pub.dev/packages/sqflite)
-   **AI Engine**: [Google Generative AI](https://pub.dev/packages/google_generative_ai)
-   **State Management**: `StatefulWidget` (Standard Flutter)
-   **Local Storage**: `shared_preferences`

## 🎨 Design Aesthetics

LearnWords follows a modern design philosophy:
-   **Vibrant Color Palette**: Using Indigo and Slate for a premium feel.
-   **Glassmorphism**: Subtle blurs and container styling for depth.
-   **Micro-interactions**: Intuitive animations during list swipes and game transitions.

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ for language learners everywhere.*
