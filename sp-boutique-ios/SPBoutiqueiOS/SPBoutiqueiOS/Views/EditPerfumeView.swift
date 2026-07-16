import SwiftUI

struct EditPerfumeView: View {
    @EnvironmentObject var database: DatabaseService
    @Environment(\.dismiss) private var dismiss

    let perfume: Perfume

    @State private var name: String
    @State private var company: String
    @State private var mlSize: String
    @State private var costPrice: String
    @State private var sellPrice: String
    @State private var quantity: String

    init(perfume: Perfume) {
        self.perfume = perfume
        _name = State(initialValue: perfume.name)
        _company = State(initialValue: perfume.company)
        _mlSize = State(initialValue: "\(perfume.mlSize)")
        _costPrice = State(initialValue: "\(perfume.costPrice)")
        _sellPrice = State(initialValue: "\(perfume.sellPrice)")
        _quantity = State(initialValue: "\(perfume.quantity)")
    }

    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                TextField("Name", text: $name)
                TextField("Company", text: $company)
                TextField("ML Size", text: $mlSize)
                    .keyboardType(.numberPad)
                TextField("Cost Price ($)", text: $costPrice)
                    .keyboardType(.decimalPad)
                TextField("Sell Price ($)", text: $sellPrice)
                    .keyboardType(.decimalPad)
                TextField("Quantity", text: $quantity)
                    .keyboardType(.numberPad)
            }
        }
        .navigationTitle("Edit Perfume")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    savePerfume()
                }
                .disabled(!isValid)
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !company.isEmpty && !mlSize.isEmpty && !costPrice.isEmpty && !sellPrice.isEmpty
    }

    private func savePerfume() {
        guard let ml = Int64(mlSize),
              let cost = Double(costPrice),
              let sell = Double(sellPrice),
              let qty = Int64(quantity) else { return }

        var updated = perfume
        updated.name = name
        updated.company = company
        updated.mlSize = ml
        updated.costPrice = cost
        updated.sellPrice = sell
        updated.quantity = qty

        database.updatePerfume(updated)
        dismiss()
    }
}
