# 📱 Flutter CRUD Assignments

Two Flutter applications demonstrating CRUD (Create, Read, Update, Delete) operations using different state management and networking solutions.

---

## 📁 Repository Structure

```
flutter-crud-assignments/
├── assignment1_provider_http/   # PostBoard — Provider + http
└── assignment2_bloc_dio/        # ShopBoard — Bloc + Dio
```

---

## Assignment 1 — PostBoard

**State Management:** Provider &nbsp;|&nbsp; **Networking:** http &nbsp;|&nbsp; **API:** JSONPlaceholder

A post management app that performs full CRUD on blog posts using the [JSONPlaceholder](https://jsonplaceholder.typicode.com) REST API.

### Screenshots

| Home | Create | Edit | Delete |
|------|--------|------|--------|
| ![home](assignment1_provider_http/screenshots/home.png) | ![create](assignment1_provider_http/screenshots/create.png) | ![edit](assignment1_provider_http/screenshots/edit.png) | ![delete](assignment1_provider_http/screenshots/delete.png) |

### Features
- Fetch and display 20 posts from the API
- Create new posts with form validation
- Edit existing posts with pre-filled form
- Delete posts with a confirmation dialog
- Pull-to-refresh support
- Loading and error states

### Project Structure
```
lib/
├── main.dart
├── models/
│   └── post.dart
├── services/
│   └── api_service.dart
├── providers/
│   └── post_provider.dart
├── screens/
│   ├── home_screen.dart
│   └── add_edit_screen.dart
└── widgets/
    ├── post_card.dart
    └── empty_state_widget.dart
```

### Run
```bash
cd assignment1_provider_http
flutter pub get
flutter run
```

---

## Assignment 2 — ShopBoard

**State Management:** flutter_bloc &nbsp;|&nbsp; **Networking:** Dio &nbsp;|&nbsp; **API:** DummyJSON

A product management app that performs full CRUD on products using the [DummyJSON](https://dummyjson.com) REST API.

### Screenshots

| Home | Create | Edit | Delete |
![home](<assignment1_provider_http/flutter_application_1/lib/screenshots/Screenshot 2026-05-16 135255.png>) 
![home](<assignment2_bloc_dio/flutter_application_2/lib/screenshots/Screenshot 2026-05-16 141131.png>)  



![create](<assignment1_provider_http/flutter_application_1/lib/screenshots/Screenshot 2026-05-16 135611.png>)   
![create](<assignment2_bloc_dio/flutter_application_2/lib/screenshots/Screenshot 2026-05-16 141220.png>)

![edit](<assignment1_provider_http/flutter_application_1/lib/screenshots/Screenshot 2026-05-16 135826.png>) 
![edit](<assignment2_bloc_dio/flutter_application_2/lib/screenshots/Screenshot 2026-05-16 141339.png>)


![delete](<assignment1_provider_http/flutter_application_1/lib/screenshots/Screenshot 2026-05-16 135826.png>) 
![delete](<assignment2_bloc_dio/flutter_application_2/lib/screenshots/Screenshot 2026-05-16 141439.png>)

### Features
- Fetch and display 20 products from the API
- Create new products with form validation
- Edit existing products with pre-filled form
- Delete products with a confirmation dialog
- Pull-to-refresh support
- Loading, action-in-progress, and error states

### Project Structure
```
lib/
├── main.dart
├── models/
│   └── product.dart
├── services/
│   └── api_service.dart
├── bloc/
│   ├── product_bloc.dart
│   ├── product_event.dart
│   └── product_state.dart
├── screens/
│   ├── home_screen.dart
│   └── add_edit_screen.dart
└── widgets/
    ├── product_card.dart
    └── empty_state_widget.dart
```

### Run
```bash
cd assignment2_bloc_dio
flutter pub get
flutter run
```

---

## 🔍 Key Differences Between the Two

| | Assignment 1 | Assignment 2 |
|---|---|---|
| State management | Provider | flutter_bloc |
| HTTP client | http | Dio |
| API | JSONPlaceholder | DummyJSON |
| Resource | Posts | Products |
| State trigger | Method call | Event dispatch |
| UI listener | `Consumer` | `BlocBuilder` / `BlocConsumer` |
| Error handling | `try/catch` in provider | `DioException` switch + Bloc error state |

---

## 📦 Dependencies

| Package | Assignment 1 | Assignment 2 |
|---------|-------------|-------------|
| `provider` | ✅ | — |
| `http` | ✅ | — |
| `flutter_bloc` | — | ✅ |
| `dio` | — | ✅ |
| `equatable` | — | ✅ |