# 💎 Clarity AI - Professional AI Chat Application

Clarity AI is a sophisticated, Flutter-based chat application designed to provide a seamless conversational experience similar to leading AI platforms. It features a custom **Python FastAPI** backend that handles real-time streaming responses from **OpenRouter** (GPT-4, Claude 3, Gemini, etc.) and delivers them to a polished, **AMOLED-optimized** Flutter frontend.

This project demonstrates an advanced implementation of **Server-Sent Events (SSE)** for typewriter-style streaming, robust state management with **Riverpod**, and local persistence for chat history.

---

## ✨ Features

- **🚀 Real-Time Streaming**: Responses stream character-by-character using Server-Sent Events (SSE), providing immediate feedback without waiting for full completion.
- **🎨 Modern UI/UX**: A clean interface featuring "Gemini Blue" branding, floating input capsules, and an AMOLED pure black background for battery efficiency.
- **💻 Code Syntax Highlighting**: Automatic formatting of code blocks with a dark terminal style, making technical responses easy to read.
- **📚 Chat History**: Full conversation persistence using local storage. Save, view, and manage past interactions effortlessly.
- **🧠 Smart Context**: The backend manages conversation arrays, allowing the AI to maintain context within a session.
- **📱 Cross-Platform**: Built with Flutter, supporting Android, iOS, Web, and Desktop from a single codebase.

---

## 🛠 Tech Stack

### Frontend (Flutter)
- **State Management**: [Flutter Riverpod](https://riverpod.dev/)
- **Networking**: [Dio](https://pub.dev/packages/dio) (Handling streams & timeouts)
- **UI Components**: Google Fonts (Inter), Iconsax, Flutter Animate
- **Storage**: Shared Preferences (Local persistence)
- **Rendering**: Flutter Markdown (Rich text & code parsing)

### Backend (Python)
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/)
- **Server**: Uvicorn
- **Concurrency**: Async/Await with AIOHTTP
- **API Integration**: OpenRouter API (Access to OpenAI, Anthropic, Meta models)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable)
- [Python 3.8+](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)

### 1. Backend Setup
1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```
2. **Create and activate a virtual environment:**
   ```bash
   python -m venv venv
   # Windows
   venv\Scripts\activate
   # macOS/Linux
   source venv/bin/activate
   ```
3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
4. **Configure Environment Variables:**
   Create a `.env` file in the `backend/` folder:
   ```env
   OPENROUTER_API_KEY=your_api_key_here
   ```
5. **Run the server:**
   ```bash
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

### 2. Frontend Setup
1. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```
2. **Configure Backend URL:**
   Open `lib/services/chat_service.dart` and update the `baseUrl`:
   - **Emulator**: `http://10.0.2.2:8000`
   - **Physical Device**: Your local IP (e.g., `http://192.168.1.10:8000`)
   - **Production**: Your hosted URL (e.g., `https://your-app.onrender.com`)
3. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```text
lib/
├── main.dart                 # Entry point & Theme config
├── models/
│   └── message.dart          # Chat data models
├── providers/
│   └── chat_provider.dart    # Riverpod state logic
├── screens/
│   ├── chat_screen.dart      # Main chat interface
│   └── chat_history_screen.dart # Saved conversations
├── services/
│   ├── chat_service.dart     # API & Streaming logic
│   └── storage_service.dart  # Local data persistence
└── widgets/
    ├── chat_input.dart       # Floating input capsule
    ├── message_bubble.dart   # Chat bubble UI
    ├── typing_indicator.dart # Loading animation
    └── typewriter_markdown.dart # Smooth rendering effect

backend/
├── main.py                   # FastAPI server
├── requirements.txt          # Python deps
└── .env                      # API Credentials (Hidden)
```

---

## 🌐 Deployment

### Hosting on Render (Free Tier)
1. Push your code to GitHub.
2. Create a new **Web Service** on Render.
3. **Build Command**: `pip install -r requirements.txt`
4. **Start Command**: `python -m uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Add `OPENROUTER_API_KEY` to **Environment Variables**.

> **Note**: To prevent the free tier from sleeping, you can use a service like [cron-job.org](https://cron-job.org/) to ping your backend `/` endpoint every 14 minutes.

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
