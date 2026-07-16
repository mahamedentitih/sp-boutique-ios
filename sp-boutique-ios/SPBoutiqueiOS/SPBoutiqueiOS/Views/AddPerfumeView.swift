import SwiftUI

struct AddPerfumeView: View {
    @EnvironmentObject var database: DatabaseService
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var company: String = ""
    @State private var mlSize: String = ""
    @State private var costPrice: String = ""
    @State private var sellPrice: String = ""
    @State private var quantity: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

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
        .navigationTitle("Add Perfume")
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
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !company.isEmpty && !mlSize.isEmpty && !costPrice.isEmpty && !sellPrice.isEmpty
    }

    private func savePerfume() {
        guard let ml = Int64(mlSize),
              let cost = Double(costPrice),
              let sell = Double(sellPrice),
              let qty = Int64(quantity) else {
            alertMessage = "Please enter valid numbers"
            showingAlert = true
            return
        }
        database.createPerfume(name: name, company: company, mlSize: ml, costPrice: cost, sellPrice: sell, quantity: qty)
        dismiss()
    }
}
