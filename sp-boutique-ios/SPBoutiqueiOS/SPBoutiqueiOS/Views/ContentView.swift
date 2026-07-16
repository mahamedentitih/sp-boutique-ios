import SwiftUI

struct ContentView: View {
    @EnvironmentObject var database: DatabaseService

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            PerfumesView()
                .tabItem {
                    Label("Perfumes", systemImage: "flask.fill")
                }

            SalesView()
                .tabItem {
                    Label("Sales", systemImage: "cart.fill")
                }
        }
        .accentColor(Color("AccentColor"))
    }
}
