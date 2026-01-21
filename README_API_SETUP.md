# 🔑 API Key Setup Guide

## 📋 Nimalar Kerak:
- OpenAI API key
- Flutter proyekti

## 🛠️ Qadamlar:

### 1️⃣ .env Faylni Sozlash:
```bash
# .env.example faylini nusxalang
cp .env.example .env

# .env faylni oching va API key ni kiriting:
OPENAI_API_KEY=your_openai_api_key_here
```

### 2️⃣ Dependenciesni O'rnatish:
```bash
flutter pub get
```

### 3️⃣ Appni Ishga Tushirish:
```bash
flutter run
```

## 🔒 Xavfsizlik:
- ✅ `.env` fayl `.gitignore` ga qo'shilgan
- ✅ API key GitHub ga saqlanmaydi
- ✅ Faqat sizning local kompyuteringizda saqlanadi

## 🚀 GitHub Da Ishlatish:
1. Repository ni clone qiling
2. `.env.example` faylini `.env` ga nusxalang
3. O'zingizning API key ingizni kiriting
4. `flutter run` bilan ishga tushuring

## 📱 AI Funksiyalari:
API key bilan quyidagi funksiyalar ishlaydi:
- ✅ Smart task generation
- ✅ AI search
- ✅ Intelligent task suggestions

API key siz ham app ishlaydi, lekin AI funksiyalari ishlamaydi.

## 🆘 Yordam:
Agar API key ishlamasa:
1. Key to'g'ri ekanligini tekshiring
2. OpenAI hisobingizda balans borligini tekshiring
3. `.env` fayl to'g'ri joyda ekanligini tekshiring
