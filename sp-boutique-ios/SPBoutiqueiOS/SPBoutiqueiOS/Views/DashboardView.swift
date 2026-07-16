import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var database: DatabaseService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    StatsGrid()
                    RecentSalesSection()
                    TopPerfumesSection()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                database.loadPerfumes()
                database.loadSales()
            }
        }
    }

    private func StatsGrid() -> some View {
        let stats = database.getDashboardStats()
        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(title: "Products", value: "\(stats.totalProducts)", icon: "flask.fill", color: .blue)
            StatCard(title: "Sales", value: "\(stats.totalSales)", icon: "cart.fill", color: .green)
            StatCard(title: "Revenue", value: formatCurrency(stats.totalRevenue), icon: "dollarsign.circle.fill", color: .orange)
            StatCard(title: "Today", value: formatCurrency(stats.todayRevenue), icon: "sunrise.fill", color: .purple)
        }
    }

    private func RecentSalesSection() -> some View {
        let recent = database.getRecentSales()
        return VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sales")
                .font(.title2.bold())
            ForEach(recent) { sale in
                NavigationLink(destination: SaleDetailView(saleId: sale.id)) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("Sale #\(sale.id)")
                                .fontWeight(.medium)
                            Text(sale.createdAt ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(formatCurrency(sale.totalAmount))
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }

    private func TopPerfumesSection() -> some View {
        let top = database.getTopPerfumes()
        return VStack(alignment: .leading, spacing: 12) {
            Text("Top Perfumes")
                .font(.title2.bold())
            ForEach(Array(top.enumerated()), id: \.offset) { index, perfume in
                HStack {
                    Text("#\(index + 1)")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.orange))
                    VStack(alignment: .leading) {
                        Text(perfume.name)
                            .fontWeight(.medium)
                        Text(perfume.company)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(formatCurrency(perfume.total))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
