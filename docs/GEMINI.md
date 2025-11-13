# WiesbadenAfterDark iOS App

## Project Overview

This is the iOS client for **WiesbadenAfterDark**, a mobile application designed to help users discover and engage with nightlife venues in Wiesbaden, Germany. The app is built with **SwiftUI** and utilizes modern iOS technologies like **SwiftData** for local persistence and **Swift Concurrency** for asynchronous operations.

The application provides a comprehensive guide to local venues, including bars, clubs, and restaurants. Users can browse venues, view details, check opening hours, and see user ratings. The app is designed to be a one-stop-shop for nightlife, with features for booking, events, community engagement, and loyalty rewards.

### Core Technologies

*   **UI Framework:** SwiftUI
*   **Data Persistence:** SwiftData
*   **Concurrency:** Swift Concurrency (async/await)
*   **Authentication:** Phone number-based authentication with mock services.
*   **Payments:** Stripe integration is planned but not yet implemented.
*   **Backend:** A backend is planned (potentially using Firebase), but the app currently uses mock services for data.

### Architecture

The project follows a feature-based architecture, with a clear separation of concerns between UI, view models, services, and models.

*   **`App/`**: Contains the main app entry point and top-level navigation.
*   **`Core/`**: Contains the core business logic, including models, service protocols, and mock service implementations.
*   **`Features/`**: Contains the different features of the app, such as Onboarding, Discover, VenueDetail, etc. Each feature has its own set of views and view models.
*   **`Shared/`**: Contains reusable components, design system elements (theme, typography), and extensions.

## Building and Running

To build and run the project, you will need Xcode 16+ and an iOS simulator or a physical device running iOS 17.0+.

1.  Clone the repository.
2.  Open the `WiesbadenAfterDark.xcodeproj` file in Xcode.
3.  Select a simulator or a connected device.
4.  Click the "Run" button or press `Cmd+R`.

The app currently uses mock data, so no backend setup is required to run it.

## Development Conventions

*   **SwiftUI and Swift Concurrency:** The project is built entirely with SwiftUI and uses `async/await` for all asynchronous operations.
*   **SwiftData:** SwiftData is used for local data persistence. All models are defined as `SwiftData` models.
*   **MVVM:** The app uses the Model-View-ViewModel (MVVM) pattern to separate UI from business logic.
*   **Mock Services:** For each service protocol in `Core/Protocols`, there is a corresponding mock implementation in `Core/Services`. This allows for easy testing and development without a live backend.
*   **Feature-Based Grouping:** The project is organized by features, making it easy to navigate and understand the codebase.
*   **Concurrency Safety:** The project has been updated to be compatible with Swift 6's concurrency model, with `Sendable` conformance and `@MainActor` isolation where necessary.
