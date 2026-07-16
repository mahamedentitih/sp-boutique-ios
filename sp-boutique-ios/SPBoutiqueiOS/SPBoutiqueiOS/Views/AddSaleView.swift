import SwiftUI

struct AddSaleView: View {
    @EnvironmentObject var database: DatabaseService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPerfumeId: Int64 = 0
    @State private var quantity: String = "1"
    @State private var unitPrice: String = ""
    @State private var cart: [(perfumeId: Int64, quantity: Int64, unitPrice: Double)] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Add Item")) {
                    Picker("Perfume", selection: $selectedPerfumeId) {
                        ForEach(database.perfumes.filter { $0.quantity > 0 }, id: \.id) { perfume in
                            Text("\(perfume.name) - \(perfume.company) (\(perfume.quantity) left)")
                                .tag(perfume.id)
                        }
                    }
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    TextField("Unit Price (leave empty for sell price)", text: $unitPrice)
                        .keyboardType(.decimalPad)
                    Button("Add to Sale") {
                        addToCart()
                    }
                    .disabled(!canAdd)
                }

                if !cart.isEmpty {
                    Section(header: Text("Cart (\(cart.count) items)")) {
                        ForEach(Array(cart.enumerated()), id: \.offset) { index, item in
                            if let perfume = database.getPerfume(id: item.perfumeId) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(perfume.name)
                                        Text("Qty: \(item.quantity) x $\(item.unitPrice)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("$\(Int(item.unitPrice * Double(item.quantity)))")
                                    Button(action: { cart.remove(at: index) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Sale")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Complete Sale") {
                        completeSale()
                    }
                    .disabled(cart.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var canAdd: Bool {
        guard let selected = database.perfumes.first(where: { $0.id == selectedPerfumeId }),
              let qty = Int64(quantity), qty > 0 else { return false }
        return qty <= selected.quantity
    }

    private func addToCart() {
        guard let selected = database.perfumes.first(where: { $0.id == selectedPerfumeId }),
              let qty = Int64(quantity), qty > 0,
              qty <= selected.quantity else {
            alertMessage = "Invalid quantity or perfume not selected"
            showingAlert = true
            return
        }

        let unit = unitPrice.isEmpty ? selected.sellPrice : (Double(unitPrice) ?? selected.sellPrice)
        cart.append((perfumeId: selectedPerfumeId, quantity: qty, unitPrice: unit))
        quantity = "1"
        unitPrice = ""
    }

    private func completeSale() {
        database.createSale(items: cart)
        dismiss()
    }
}
