# AutoCare - Vehicle Service Tracker

AutoCare is a complete production-ready Flutter mobile application for vehicle owners to manage maintenance schedules, track expenses, and book service appointments.

## 📱 Features
- **User & Vehicle Management:** Manage multiple vehicles with detailed profiles.
- **Service Reminder System:** Local notifications for upcoming maintenance schedules.
- **Service History Tracking:** Detailed logging of past service records.
- **Expense Tracking & Analytics:** Real-time visual insights using `fl_chart`.
- **Service Center Map:** View nearby service centers using Google Maps.
- **Offline-First Architecture:** Powered by Hive for instantaneous data access with or without a connection.

## 🚀 Setup Instructions

1. **Clone the Repository**
   Ensure you have cloned this repository onto your machine.

2. **Install Dependencies**
   Navigate to the project root directory and run:
   ```bash
   flutter pub get
   ```

3. **Google Maps Setup**
   - For Android: Ensure you have your `google_maps_api_key` placed correctly in `android/app/src/main/AndroidManifest.xml` (Current mock version uses standard initializations without keys for local demo).
   - Follow standard Google Maps Flutter setup if modifying for production.

4. **Run the App**
   Connect a device or emulator and run:
   ```bash
   flutter run
   ```

## 🏗 Architecture
Follows a modular Clean Architecture using Riverpod for State Management and Hive for Local Data layers.

- `core/` contains global styles, services (Notifications, DB), and themes.
- `features/` contains modules: auth, dashboard, vehicle, expenses, service_center.

Enjoy managing your vehicles with AutoCare!
