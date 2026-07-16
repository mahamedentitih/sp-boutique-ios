import SwiftUI

struct SalesView: View {
    @EnvironmentObject var database: DatabaseService
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(database.sales) { sale in
                    NavigationLink(destination: SaleDetailView(saleId: sale.id)) {
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading) {
                                Text("Sale #\(sale.id)")
                                    .font(.headline)
                                Text("\(sale.itemCount) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(formatCurrency(sale.totalAmount))
                                    .font(.body.bold())
                                Text(sale.createdAt ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            database.deleteSale(id: sale.id)
                        }
                    }
                }
            }
            .navigationTitle("Sales (\(database.sales.count))")
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    AddSaleView()
                }
            }
            .onAppear {
                database.loadSales()
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
