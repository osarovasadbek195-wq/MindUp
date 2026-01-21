# MindUp - AI Powered Smart Learning Assistant

## Loyiha haqida
MindUp - bu shaxsiy rivojlanish va o'rganish jarayonini avtomatlashtiruvchi aqlli yordamchi.
Ilova quyidagi texnologiyalardan foydalanadi:
- **Clean Architecture:** Kodning tartibli va oson o'zgaruvchanligi uchun.
- **Isar Database:** Offline rejimda ishlovchi tezkor ma'lumotlar bazasi.
- **Cascade Engine:** Spaced Repetition (oraliqli takrorlash) algoritmi.
- **Google Gemini AI:** Avtomatik reja va savollar tuzish uchun.
- **Voice Control:** Ilovani ovoz orqali boshqarish.

## Ishga tushirish bo'yicha qo'llanma

1. **Kutubxonalarni yuklash:**
   Terminalda loyiha papkasiga kirib, quyidagi buyruqni bering:
   ```bash
   flutter pub get
   ```

2. **Kodlarni generatsiya qilish (Isar uchun):**
   Ma'lumotlar bazasi adapterlarini yaratish uchun:
   ```bash
   dart run build_runner build
   ```

3. **API Kalitni kiritish:**
   `lib/main.dart` faylini oching va `geminiApiKey` o'zgaruvchisiga o'zingizning Google Gemini API kalitingizni yozing:
   ```dart
   const String geminiApiKey = "SIZNING_API_KALITINGIZ";
   ```

4. **Ilovani ishga tushirish:**
   ```bash
   flutter run
   ```

## Asosiy Funksiyalar

- **📅 Smart Calendar:** Kunlik vazifalarni ko'rish va boshqarish.
- **🤖 AI Input:** "Inventory mavzusida 10 ta so'z top" deb yozing yoki ayting, AI o'zi reja tuzadi.
- **🎙️ Voice Command:** Mikrofon tugmasini bosib gapiring:
    - *"Add words about Travel"* (Sayohat haqida so'z qo'sh)
    - *"Show stats"* (Statistikani ko'rsat)
    - *"Start study"* (O'rganishni boshla)
- **📊 Analytics:** O'zlashtirish darajasini grafiklarda kuzatib boring.
