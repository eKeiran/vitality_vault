# Vitality Vault

Vitality Vault is an AI-powered health companion designed to simplify the management of chronic illnesses. It allows users to upload medical lab reports, extract and understand key health information, visualize trends over time, and prepare meaningful questions for their healthcare providers.

Built with Flutter, Google Cloud, and the Gemini LLM, Vitality Vault brings clarity, control, and compassion to chronic care.

---

## 🧠 Inspiration

Managing a chronic illness like Hashimoto's disease is physically and mentally exhausting. This project was born from a personal need to stay on top of fluctuating lab results, scattered PDFs, and confusing medical jargon. Vitality Vault is my way of turning struggle into solution.

---

## 🏗️ Project Structure

/ (root)
├── frontend/ # Flutter app (mobile + web)
├── backend/ # Python ADK microservices
│ ├── lab_report_orchestrator/
│ └── lab_data_visualizer/
├── Dockerfile
├── README.md
└── requirements.txt


---

## ⚙️ Built With

Python, FastAPI, Flutter, Google Cloud Run, Firebase Auth, Firebase Hosting, Firebase Firestore, Google ADK, Gemini, google-genai, Matplotlib, Docker, Pydantic, aiohttp, tempfile, OS, GitHub

---

## 🚀 Getting Started

### Prerequisites

- Python 3.10+
- Flutter SDK
- Firebase project with Auth and Firestore enabled
- Google Cloud service account credentials (for Cloud Run + Gemini)

### Backend Setup

```bash
cd backend
pip install -r requirements.txt
uvicorn lab_report_orchestrator.server:app --port 8001
uvicorn lab_data_visualizer.server:app --port 8002

cd frontend
flutter pub get
flutter run -d chrome
```
## 🖼️ Features
Upload PDF or scanned medical reports

Automatic OCR + AI parsing using Gemini

Doctor-friendly summaries and highlights

Health trend visualizations (time-series, gauges)

Firebase-authenticated storage and access

Real-time cloud-hosted Flutter dashboard

## 🛠️ Deployment
We deploy our backend using Docker on Google Cloud Run. The frontend is hosted using Firebase Hosting.

## ✨ Future Plans
Multi-language support

Downloadable PDF summaries

Push notifications for test uploads

Mobile-first enhancements
