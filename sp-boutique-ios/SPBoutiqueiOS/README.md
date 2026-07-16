# SP Boutique - iOS

Native iOS version of the SP Boutique Perfume Management System, built with SwiftUI and SQLite.

## What This Is

This is a complete rewrite of the Electron desktop app you found at:
`C:\Program Files\SP-Boutique-Desktop (8)\sp-boutique-app`

**Original app built with:**
- React (frontend, bundled with Vite)
- Express.js (backend API)
- sql.js (SQLite in browser)
- Electron (desktop wrapper)

**iOS app built with:**
- SwiftUI (native iOS UI framework)
- SQLite3 (native iOS database, built into iOS)
- Pure Swift (no webviews, no bridging)

## Features

All features from the original app are implemented:

- **Dashboard**: Stats, recent sales, top perfumes
- **Perfumes**: Add, edit, delete, list with search
- **Sales**: Create sales, view details, delete sales
- **Database**: Local SQLite database (compatible with original `.db` file)

## Database Compatibility

The iOS app uses the same SQLite schema as the original app. You can migrate data by copying the `data.db` file from:
```
C:\Program Files\SP-Boutique-Desktop (8)\sp-boutique-app\data\data.db
```

To the iOS app's data directory after first launch (the database is stored in the app's Application Support folder).

## How to Build & Run

1. Open this folder in Xcode:
   - Double-click `SPBoutiqueiOS.xcodeproj` or open Xcode and choose `Open Existing Project`
   - If no `.xcodeproj` exists yet, create a new iOS App project in Xcode:
     - Product Name: `SPBoutiqueiOS`
     - Interface: SwiftUI
     - Language: Swift
     - Remove `ContentView.swift`, `SPBoutiqueiOSApp.swift`, and other auto-generated files
     - Drag the `SPBoutiqueiOS/` folder into the project

2. Build and run on iOS Simulator or physical device:
   - Select your target (iPhone 15 or later recommended)
   - Press `Cmd + R` to build and run

3. App will launch with the Dashboard tab

## Project Structure

```
SPBoutiqueiOS/
├── SPBoutiqueiOS.xcodeproj/
├── SPBoutiqueiOS/
│   ├── SPBoutiqueiOSApp.swift      # App entry point
│   ├── Models/
│   │   ├── Perfume.swift
│   │   ├── Sale.swift
│   │   └── SaleItem.swift
│   ├── Services/
│   │   └── DatabaseService.swift   # SQLite layer
│   ├── Views/
│   │   ├── ContentView.swift       # Tab view
│   │   ├── DashboardView.swift     # Stats, recent sales, top products
│   │   ├── PerfumesView.swift      # Perfume list
│   │   ├── AddPerfumeView.swift    # Add perfume form
│   │   ├── EditPerfumeView.swift   # Edit perfume form
│   │   ├── SalesView.swift         # Sales list
│   │   ├── AddSaleView.swift       # Create sale
│   │   └── SaleDetailView.swift    # Sale details
│   └── Assets.xcassets/
│       └── logo.png
└── Info.plist
```
