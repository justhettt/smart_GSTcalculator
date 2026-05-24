# 🧮 Smart GST Calculator

A powerful, all-in-one Flutter calculator app designed for Indian users — combining everyday calculations, GST computation, currency conversion, and unit conversion in a single clean interface.

---

## 📱 Features

### 1. 🔢 Simple Calculator
A clean, intuitive calculator for everyday arithmetic operations.
- Basic operations: Addition, Subtraction, Multiplication, Division
- Percentage calculation
- Decimal support
- Clear and backspace functions
- Responsive button layout for all screen sizes

### 2. 🧾 GST Calculator
Quickly compute GST-inclusive and GST-exclusive prices across all Indian tax slabs.
- Supports all GST slabs: **0%, 5%, 12%, 18%, 28%**
- Calculate GST on original price (Add GST)
- Extract GST from final price (Remove GST)
- Displays CGST + SGST breakdown
- Net amount, tax amount, and total amount shown clearly

### 3. 💱 Currency Converter
Convert between major world currencies with ease.
- Support for **INR, USD, EUR, GBP, AED, SGD, JPY, AUD, CAD**, and more
- Real-time exchange rate display
- Swap currencies with a single tap
- Clean conversion history

### 4. 📐 Unit Converter
A comprehensive unit conversion tool across multiple categories.

| Category     | Units Covered |
|--------------|---------------|
| Length       | mm, cm, m, km, inch, foot, yard, mile |
| Weight       | mg, g, kg, ton, pound, ounce |
| Temperature  | Celsius, Fahrenheit, Kelvin |
| Area         | sq. cm, sq. m, sq. km, acre, hectare |
| Volume       | ml, litre, gallon, cubic metre |
| Speed        | m/s, km/h, mph, knot |

---

## 🛠️ Tech Stack

| Layer        | Technology           |
|--------------|----------------------|
| Framework    | Flutter (Dart)       |
| State Mgmt   | Provider / setState  |
| UI           | Material Design 3    |
| Navigation   | Bottom Navigation Bar |
| Storage      | SharedPreferences    |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugin
- An Android or iOS device / emulator

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/smart-gst-calculator.git

# 2. Navigate to the project folder
cd smart-gst-calculator

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart                  # App entry point
├── screens/
│   ├── simple_calculator.dart # Basic calculator screen
│   ├── gst_calculator.dart    # GST calculator screen
│   ├── currency_converter.dart# Currency converter screen
│   └── unit_converter.dart    # Unit converter screen
├── widgets/
│   ├── calculator_button.dart # Reusable button widget
│   ├── result_card.dart       # Result display card
│   └── dropdown_selector.dart # Unit/currency selector
├── models/
│   ├── gst_model.dart         # GST logic model
│   └── conversion_model.dart  # Conversion logic model
└── utils/
    ├── constants.dart          # App-wide constants
    ├── gst_rates.dart          # GST slab data
    └── unit_data.dart          # Unit conversion factors
```

---

## 📸 Screenshots

> _Add your app screenshots here_

| Simple Calculator | GST Calculator | Currency Converter | Unit Converter |
|:-----------------:|:--------------:|:-----------------:|:--------------:|
| ![](#) | ![](#) | ![](#) | ![](#) |

---

## 🎯 Roadmap

- [ ] Dark mode support
- [ ] Live currency rates via API
- [ ] GST invoice generator (PDF export)
- [ ] History log for calculations
- [ ] Widget support for home screen
- [ ] Tablet-optimized layout

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add: your feature description'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** —

---

## 👨‍💻 Author

HET PATEL
- GitHub: [@justhettt](https://github.com/justhettt)


---

## ⭐ Support

If you found this project helpful, please consider giving it a ⭐ on GitHub — it means a lot!

---

> Built with ❤️ using Flutter · Made for Indian users & beyond
