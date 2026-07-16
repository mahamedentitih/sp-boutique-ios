import Foundation

struct Sale: Identifiable, Codable {
    let id: Int64
    var totalAmount: Double
    var itemCount: Int64
    var createdAt: String?

    init(id: Int64 = 0, totalAmount: Double, itemCount: Int64, createdAt: String? = nil) {
        self.id = id
        self.totalAmount = totalAmount
        self.itemCount = itemCount
        self.createdAt = createdAt
    }
}
