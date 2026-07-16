import Foundation

struct Perfume: Identifiable, Codable {
    let id: Int64
    var name: String
    var company: String
    var mlSize: Int64
    var costPrice: Double
    var sellPrice: Double
    var quantity: Int64
    var createdAt: String?

    init(id: Int64 = 0, name: String, company: String, mlSize: Int64, costPrice: Double, sellPrice: Double, quantity: Int64 = 0, createdAt: String? = nil) {
        self.id = id
        self.name = name
        self.company = company
        self.mlSize = mlSize
        self.costPrice = costPrice
        self.sellPrice = sellPrice
        self.quantity = quantity
        self.createdAt = createdAt
    }
}
