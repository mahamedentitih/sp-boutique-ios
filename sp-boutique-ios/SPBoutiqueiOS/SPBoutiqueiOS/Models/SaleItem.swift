import Foundation

struct SaleItem: Identifiable, Codable {
    let id: Int64
    var saleId: Int64
    var perfumeId: Int64
    var perfumeName: String
    var perfumeCompany: String
    var mlSize: Int64
    var quantity: Int64
    var unitPrice: Double
    var totalPrice: Double

    init(id: Int64 = 0, saleId: Int64, perfumeId: Int64, perfumeName: String, perfumeCompany: String, mlSize: Int64, quantity: Int64, unitPrice: Double, totalPrice: Double) {
        self.id = id
        self.saleId = saleId
        self.perfumeId = perfumeId
        self.perfumeName = perfumeName
        self.perfumeCompany = perfumeCompany
        self.mlSize = mlSize
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = totalPrice
    }
}
