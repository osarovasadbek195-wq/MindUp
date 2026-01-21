# Flutter PATH sozlash qo'llanmasi

## 1. PATH ga qo'shish (Windows 10/11)

1. **Windows qidiruvni oching** va "environment variables" yozing
2. **"Edit the system environment variables"** ni oching
3. **"Environment Variables..."** tugmasini bosing
4. **"System variables"** bo'limida **"Path"** ni toping
5. **"Edit..."** tugmasini bosing
6. **"New"** tugmasini bosing va quyidagi yo'lni qo'shing:
   ```
   D:\flutter\flutter\bin
   ```
7. **"OK"** barcha oynalarda

## 2. Terminalni yangilang

- Yangi PowerShell terminalini oching (Android Studio: `Ctrl+Shift+P` → "Terminal: Create New Terminal")
- Yoki kompyuterni qayta ishga tushiring

## 3. Tekshirish

Yangi terminalda quyidagi buyruqlarni bajaring:
```bash
flutter --version
dart --version
```

## 4. Agar ishlamasa

To'g'ridan-to'g'ri quyidagi buyruqlarni bajaring:
```bash
$env:PATH += ";D:\flutter\flutter\bin"
flutter --version
```

Bu faqat joriy sessiya uchun ishlaydi. Doimiy ishlashi uchun 1-qadamdagi PATH sozlamasi kerak.
