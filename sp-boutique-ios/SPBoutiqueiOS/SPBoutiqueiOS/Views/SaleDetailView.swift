import SwiftUI

struct SaleDetailView: View {
    @EnvironmentObject var database: DatabaseService
    let saleId: Int64
    @State private var sale: Sale?
    @State private var items: [(id: Int64, perfumeName: String, perfumeCompany: String, mlSize: Int64, quantity: Int64, unitPrice: Double, totalPrice: Double)] = []

    var body: some View {
        List {
            if let sale = sale {
                Section(header: Text("Sale Info")) {
                    HStack {
                        Text("Sale ID")
                        Spacer()
                        Text("#\(sale.id)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(sale.createdAt ?? "")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Items")
                        Spacer()
                        Text("\(sale.itemCount)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(formatCurrency(sale.totalAmount))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }

                Section(header: Text("Items")) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.perfumeName)
                                .font(.headline)
                            Text(item.perfumeCompany)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("\(item.quantity) x $\(Int(item.unitPrice))")
                                Spacer()
                                Text("$\(Int(item.totalPrice))")
                                    .bold()
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Sale Details")
        .onAppear {
            self.sale = database.getSale(id: saleId)
            self.items = database.getSaleItems(saleId: saleId)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
