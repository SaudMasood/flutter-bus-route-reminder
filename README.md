
# 🚌 Bus Route & Reminder App

<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&duration=3000&pause=1000&color=123C4A&center=true&vCenter=true&width=750&lines=Bus+Route+%26+Reminder+App;Owasoft+Technologies+%7C+Week+6;Flutter+%7C+Firebase+%7C+BLoC;Never+Miss+Your+Bus+Again!+%F0%9F%9A%8C" />

<br>

<img src="https://img.shields.io/badge/Flutter-Framework-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/BLoC-State%20Management-123C4A?style=for-the-badge" />
<img src="https://img.shields.io/badge/Firestore-Database-FF6F00?style=for-the-badge&logo=firebase&logoColor=white" />

<br><br>

### 🚀 Owasoft Technologies Pvt. Ltd.
### 📱 Flutter Development Internship — Week 6 Project

**A modern Flutter application for bus route management and smart travel reminders.**

</div>

---

# 📌 Internship Project

This project was developed as part of my **Flutter Development Internship at Owasoft Technologies Pvt. Ltd.**

### 📅 Week 6

**Project:** 🚌 Bus Route & Reminder App

### Main Learning & Development Areas

- Flutter application development
- Firebase integration
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Local notifications
- BLoC state management
- Admin and user roles
- UI/UX development
- Real-time backend integration
- Notification workflows

---

# ✨ About The Project

**Bus Route & Reminder App** is a Flutter-based mobile application designed to make daily bus travel easier and more organized.

Users can view available bus routes, select a bus, check its departure time, and set a personal reminder.

Administrators can manage bus routes and broadcast notifications to users when a new bus route is added.

> 🚌 **Find your bus. Choose your route. Set your reminder. Travel on time.**

---

# 🎯 Application Flow

```text
                    🚌 BUS ROUTE APP
                           │
             ┌─────────────┴─────────────┐
             │                           │
          👤 USER                    👨‍💼 ADMIN
             │                           │
        Login / Signup              Login / Signup
             │                           │
             ▼                           ▼
       User Home                  Admin Dashboard
             │                           │
       View Bus Routes             Manage Buses
             │                    ┌──────┼──────┐
             │                    ▼      ▼      ▼
       Select Bus                Add   Update  Delete
             │                    │      │      │
             ▼                    └──────┼──────┘
       Select Time                       │
             │                           ▼
             ▼                      Firestore
       Set Reminder                       │
             │                           ▼
             ▼                     Cloud Function
       🔔 Notification                    │
                                         ▼
                                        FCM
                                         │
                                         ▼
                                  📱 All Users
````

---

# 🚀 Features

## 👤 User Features

* 🔐 User Registration
* 🔑 User Login
* 🚌 View Available Bus Routes
* 📍 View Bus Route Information
* 🕐 View Departure Time
* ✅ Select Bus
* ⏰ Select Reminder Time
* 🔔 Set Personal Bus Reminder
* 📱 Local Scheduled Notification
* 🔔 Receive FCM Notifications
* 👤 View Profile
* 🚪 Logout

---

## 👨‍💼 Admin Features

* 🔐 Admin Registration
* 🔑 Admin Login
* 📊 Admin Dashboard
* ➕ Add Bus
* ✏️ Update Bus
* 🗑️ Delete Bus
* 🚌 Manage Bus Routes
* 🕐 Manage Departure Times
* 📢 Broadcast New Bus Notifications

---

# 🔥 Firebase Services

The application uses Firebase for authentication, database management, and notifications.

```text
Firebase
│
├── 🔐 Firebase Authentication
│
├── ☁️ Cloud Firestore
│
├── 🔔 Firebase Cloud Messaging
│
└── ⚡ Cloud Functions
```

---

## 🔐 Firebase Authentication

Firebase Authentication is used for:

* User registration
* User login
* Admin registration
* Admin login
* User identity management

User passwords are managed by Firebase Authentication and are not stored directly in Firestore.

---

# ☁️ Cloud Firestore

Firestore stores application data.

### Users

```text
users/{uid}

{
    name,
    email,
    role,
    fcmToken
}
```

### Buses

```text
buses/{busId}

{
    busNumber,
    route,
    departureTime
}
```

### Reminders

```text
reminders/{reminderId}

{
    userId,
    busId,
    reminderTime,
    sent
}
```

### Firestore Structure

```text
Collection
    ↓
Document
    ↓
Fields
```

---

# 🔔 Notification System

The application uses **two notification systems**.

## 1️⃣ Personal Bus Reminder

Personal reminders use local notifications.

```text
User selects bus
       ↓
Select reminder time
       ↓
HomeBloc
       ↓
NotificationService
       ↓
Local Notification
       ↓
🔔 User Reminder
```

The reminder is scheduled directly on the user's device.

---

## 2️⃣ Admin Broadcast Notification

When an admin adds a new bus:

```text
Admin
  ↓
Add Bus
  ↓
Cloud Firestore
  ↓
Cloud Function
  ↓
FCM Topic: all_users
  ↓
📱📱📱
All Users
```

Users subscribe to:

```text
all_users
```

This allows the backend to send a notification to all subscribed users.

---

# 🧠 BLoC State Management

The project uses **BLoC** for managing application state.

### Basic BLoC Flow

```text
UI
 ↓
Event
 ↓
BLoC
 ↓
Firebase / Notification Service
 ↓
State
 ↓
UI
```

Example:

```dart
context.read<HomeBloc>().add(
  GetBusesRequested(),
);
```

Flow:

```text
GetBusesRequested
       ↓
HomeBloc
       ↓
Firestore
       ↓
HomeLoaded
       ↓
Bus List
```

---

# 🚌 Bus Selection Flow

```text
Available Routes
       ↓
Select Bus
       ↓
BusSelected Event
       ↓
HomeBloc
       ↓
Selected Bus State
       ↓
UI Updates
```

---

# ⏰ Reminder Flow

```text
Select Bus
      ↓
Select Time
      ↓
ReminderTimeSelected
      ↓
HomeBloc
      ↓
SetReminderRequested
      ↓
NotificationService
      ↓
Local Notification
```

---

# 📁 Project Structure

```text
lib/
│
├── main.dart
│
├── core/
│   ├── app_colors.dart
│   ├── app_theme.dart
│   ├── app_constants.dart
│   │
│   └── services/
│       └── notification services/
│           └── notification_service.dart
│
└── features/
    │
    ├── splash/
    │   └── screen/
    │       └── splash_screen.dart
    │
    ├── admin/
    │   │
    │   ├── auth/
    │   │   ├── bloc/
    │   │   └── screen/
    │   │
    │   ├── main_screen/
    │   │   └── screen/
    │   │
    │   └── dashboard/
    │       ├── bloc/
    │       ├── model/
    │       └── screen/
    │
    └── user/
        │
        ├── auth/
        │   ├── bloc/
        │   ├── model/
        │   └── screen/
        │
        ├── main/
        │   └── screen/
        │
        ├── home/
        │   ├── bloc/
        │   ├── model/
        │   └── screen/
        │
        ├── onboarding/
        │   └── screen/
        │
        └── profile/
            ├── bloc/
            ├── model/
            └── screen/
```

---

# 🎨 UI/UX Design

The application uses a clean and modern transport-inspired design.

### Main Brand Colors

```dart
static const Color primary = Color(0xFF123C4A);
static const Color cream = Color(0xFFF1E9D2);
```

### Design Features

* 🎨 Modern color combination
* 🚌 Bus-focused visual elements
* 🔘 Rounded buttons
* 📦 Clean cards
* 📱 Responsive mobile layout
* 🔔 Clear reminder section
* ✨ Simple navigation
* 👌 User-friendly interface

---

# 🛠️ Technology Stack

| Technology                     | Purpose                      |
| ------------------------------ | ---------------------------- |
| 🐦 Flutter                     | Mobile Application           |
| 🎯 Dart                        | Programming Language         |
| 🔐 Firebase Authentication     | User/Admin Authentication    |
| ☁️ Cloud Firestore             | Database                     |
| 🔔 Firebase Cloud Messaging    | Push Notifications           |
| ⚡ Cloud Functions              | Backend Notification Trigger |
| 🧠 BLoC                        | State Management             |
| 🔔 Flutter Local Notifications | Personal Reminders           |
| 🕐 Timezone                    | Scheduled Notifications      |
| ⚖️ Equatable                   | BLoC State Comparison        |
| 💻 VS Code                     | Development                  |
| 🤖 Android Studio              | Android Development          |
| 🌐 GitHub                      | Version Control              |

---

# 📦 Main Packages

```yaml
flutter_bloc:
equatable:
firebase_core:
firebase_auth:
cloud_firestore:
firebase_messaging:
flutter_local_notifications:
timezone:
```

---

# ⚙️ Installation

### 1. Clone Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

### 2. Open Project

```bash
cd bus-route-reminder
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Connect the Flutter application with your Firebase project.

Enable:

```text
Firebase Authentication
Cloud Firestore
Firebase Cloud Messaging
Cloud Functions
```

### 5. Run

```bash
flutter run
```

---

# 🧪 Testing

## User Testing

```text
Signup
 ↓
Login
 ↓
View Routes
 ↓
Select Bus
 ↓
Select Time
 ↓
Set Reminder
 ↓
🔔 Notification
```

## Admin Testing

```text
Admin Login
 ↓
Dashboard
 ↓
Add Bus
 ↓
Firestore
 ↓
Cloud Function
 ↓
FCM
 ↓
📱 User Notification
```

---

# 🔐 Security

The application separates authentication from application data.

```text
Firebase Authentication
          ↓
        UID
          ↓
Firestore users/{uid}
          ↓
     Role Checking
          ↓
    User / Admin
```

Roles:

```text
user
admin
```

Admin functionality should be protected using appropriate Firebase Security Rules before production deployment.

---

# 📊 Architecture

```text
                    Flutter App
                        │
                        ▼
                  ┌───────────┐
                  │    BLoC   │
                  └─────┬─────┘
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
       Firebase Services     Notification Service
             │                     │
      ┌──────┼──────┐              │
      ▼      ▼      ▼              ▼
     Auth Firestore FCM       Local Notification
              │
              ▼
       Cloud Functions
              │
              ▼
             FCM
              │
              ▼
         📱 Users
```

---

# 🌟 Week 6 Internship Learning

During **Week 6 of my Flutter Internship at Owasoft Technologies Pvt. Ltd.**, I worked on:

* Flutter application development
* Firebase Authentication
* Cloud Firestore
* Firebase Cloud Messaging
* Local Notifications
* BLoC State Management
* Admin/User role implementation
* Bus CRUD operations
* Reminder functionality
* Firebase service integration
* UI/UX improvement
* Git/GitHub workflow

---

# 👨‍💻 Developer

<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=25&duration=3000&pause=1000&color=123C4A&center=true&vCenter=true&width=700&lines=Saud+Masood;Software+Engineer;Flutter+Developer;AI+Developer;Mobile+App+Developer" />

### **Saud Masood**

🎓 **BS Computer Science**
💻 **Software Engineer**
📱 **Flutter Developer**
🤖 **AI Developer / AI Engineer**

I am passionate about building modern mobile applications using:

```text
Flutter
Dart
Firebase
BLoC
REST APIs
AI / Machine Learning
Database Technologies
```

---

# 💼 Internship

### Owasoft Technologies Pvt. Ltd.

**Flutter Development Internship**

📌 **Project:** Bus Route & Reminder App
📅 **Week:** 6
💻 **Domain:** Flutter Development

This project represents my Week 6 development work and practical learning during the internship.

---

# 📬 Contact Me

<div align="center">

### 📧 Email

**[saudmasood974@gmail.com](mailto:saudmasood974@gmail.com)**

### 📱 WhatsApp

**03065059974**

<br>

<a href="mailto:saudmasood974@gmail.com">
<img src="https://img.shields.io/badge/Email-saudmasood974%40gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white" />
</a>

<a href="https://wa.me/923065059974">
<img src="https://img.shields.io/badge/WhatsApp-03065059974-25D366?style=for-the-badge&logo=whatsapp&logoColor=white" />
</a>

</div>

---

# 🚀 Future Improvements

Planned features:

* 🗺️ Live Bus Tracking
* 📍 GPS-Based Bus Location
* ⭐ Favorite Routes
* 🔎 Route Search
* 🚌 Multiple Bus Stops
* 📊 Admin Analytics
* 🔔 Advanced Reminder Management
* 📱 Improved Notification Controls
* 🌐 Production Backend Improvements

---

# ❤️ Acknowledgement

Special thanks to **Owasoft Technologies Pvt. Ltd.** for providing the opportunity to work on practical Flutter development projects and gain experience with modern mobile application technologies.

---

<div align="center">

## 🚌 Find Your Bus. ⏰ Set Your Reminder. 🚀 Travel Smarter.

<br>

**Developed by Saud Masood**

**Flutter Development Internship — Week 6**

**Owasoft Technologies Pvt. Ltd.**

<br>

<img src="https://capsule-render.vercel.app/api?type=waving&color=123C4A&height=120&section=footer" />

</div>
