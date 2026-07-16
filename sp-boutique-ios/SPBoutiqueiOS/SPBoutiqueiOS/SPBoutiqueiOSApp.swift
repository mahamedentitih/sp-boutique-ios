import SwiftUI

@main
struct SPBoutiqueiOSApp: App {
    let database = DatabaseService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(database)
                .onAppear {
                    database.initialize()
                }
        }
    }
}
