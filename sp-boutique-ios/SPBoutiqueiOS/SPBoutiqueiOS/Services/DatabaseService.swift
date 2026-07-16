import Foundation
import SQLite3

class DatabaseService: ObservableObject {
    static let shared = DatabaseService()

    @Published var perfumes: [Perfume] = []
    @Published var sales: [Sale] = []

    private var db: OpaquePointer?

    private init() {}

    func initialize() {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("sp-boutique.db")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }

        createTables()
        loadPerfumes()
        loadSales()
    }

    private func createTables() {
        let createPerfumes = """
        CREATE TABLE IF NOT EXISTS perfumes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            company TEXT NOT NULL,
            ml_size INTEGER NOT NULL,
            cost_price REAL NOT NULL,
            sell_price REAL NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 0,
            created_at TEXT DEFAULT (datetime('now','localtime'))
        );
        """

        let createSales = """
        CREATE TABLE IF NOT EXISTS sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            total_amount REAL NOT NULL,
            item_count INTEGER NOT NULL,
            created_at TEXT DEFAULT (datetime('now','localtime'))
        );
        """

        let createSaleItems = """
        CREATE TABLE IF NOT EXISTS sale_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER NOT NULL,
            perfume_id INTEGER NOT NULL,
            perfume_name TEXT NOT NULL,
            perfume_company TEXT NOT NULL,
            ml_size INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            unit_price REAL NOT NULL,
            total_price REAL NOT NULL
        );
        """

        execute(createPerfumes)
        execute(createSales)
        execute(createSaleItems)
    }

    private func execute(_ sql: String) {
        var errMsg: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &errMsg) != SQLITE_OK {
            let msg = errMsg.flatMap { String(cString: $0) } ?? "unknown error"
            print("SQL error: \(msg)")
        }
    }

    private func query(_ sql: String, params: [Any] = []) -> [[String: Any]] {
        var stmt: OpaquePointer?
        var results: [[String: Any]] = []

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            return results
        }

        for (i, param) in params.enumerated() {
            let idx = Int32(i + 1)
            if let intVal = param as? Int64 {
                sqlite3_bind_int64(stmt, idx, intVal)
            } else if let doubleVal = param as? Double {
                sqlite3_bind_double(stmt, idx, doubleVal)
            } else if let strVal = param as? String {
                sqlite3_bind_text(stmt, idx, strVal, -1, nil)
            }
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: Any] = [:]
            let colCount = sqlite3_column_count(stmt)
            for i in 0..<colCount {
                let name = String(cString: sqlite3_column_name(stmt, i))
                let type = sqlite3_column_type(stmt, i)
                switch type {
                case SQLITE_INTEGER:
                    row[name] = Int64(sqlite3_column_int64(stmt, i))
                case SQLITE_FLOAT:
                    row[name] = sqlite3_column_double(stmt, i)
                case SQLITE_TEXT:
                    row[name] = String(cString: sqlite3_column_text(stmt, i))
                case SQLITE_NULL:
                    row[name] = nil
                default:
                    row[name] = nil
                }
            }
            results.append(row)
        }

        sqlite3_finalize(stmt)
        return results
    }

    private func run(_ sql: String, params: [Any] = []) {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            if let stmt = stmt { sqlite3_finalize(stmt) }
            return
        }

        for (i, param) in params.enumerated() {
            let idx = Int32(i + 1)
            if let intVal = param as? Int64 {
                sqlite3_bind_int64(stmt, idx, intVal)
            } else if let doubleVal = param as? Double {
                sqlite3_bind_double(stmt, idx, doubleVal)
            } else if let strVal = param as? String {
                sqlite3_bind_text(stmt, idx, strVal, -1, nil)
            }
        }

        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }

    private func lastInsertRowID() -> Int64 {
        return sqlite3_last_insert_rowid(db)
    }

    private func mapPerfumeRow(_ row: [String: Any]) -> Perfume {
        Perfume(
            id: (row["id"] as? Int64) ?? 0,
            name: (row["name"] as? String) ?? "",
            company: (row["company"] as? String) ?? "",
            mlSize: (row["ml_size"] as? Int64) ?? 0,
            costPrice: (row["cost_price"] as? Double) ?? 0.0,
            sellPrice: (row["sell_price"] as? Double) ?? 0.0,
            quantity: (row["quantity"] as? Int64) ?? 0,
            createdAt: row["created_at"] as? String
        )
    }

    private func mapSaleRow(_ row: [String: Any]) -> Sale {
        Sale(
            id: (row["id"] as? Int64) ?? 0,
            totalAmount: (row["total_amount"] as? Double) ?? 0.0,
            itemCount: (row["item_count"] as? Int64) ?? 0,
            createdAt: row["created_at"] as? String
        )
    }

    func loadPerfumes() {
        let rows = query("SELECT * FROM perfumes ORDER BY datetime(created_at) DESC")
        perfumes = rows.map(mapPerfumeRow)
    }

    func loadSales() {
        let rows = query("SELECT * FROM sales ORDER BY datetime(created_at) DESC")
        sales = rows.map(mapSaleRow)
    }

    func createPerfume(name: String, company: String, mlSize: Int64, costPrice: Double, sellPrice: Double, quantity: Int64) -> Perfume {
        run("INSERT INTO perfumes (name,company,ml_size,cost_price,sell_price,quantity) VALUES (?,?,?,?,?,?)",
            params: [name, company, mlSize, costPrice, sellPrice, quantity])
        let id = lastInsertRowID()
        let row = query("SELECT * FROM perfumes WHERE id=?", params: [id])
        let perfume = row.first.map(mapPerfumeRow) ?? Perfume(id: id, name: name, company: company, mlSize: mlSize, costPrice: costPrice, sellPrice: sellPrice, quantity: quantity)
        perfumes.append(perfume)
        return perfume
    }

    func updatePerfume(_ perfume: Perfume) {
        run("UPDATE perfumes SET name=?,company=?,ml_size=?,cost_price=?,sell_price=?,quantity=? WHERE id=?",
            params: [perfume.name, perfume.company, perfume.mlSize, perfume.costPrice, perfume.sellPrice, perfume.quantity, perfume.id])
        if let idx = perfumes.firstIndex(where: { $0.id == perfume.id }) {
            perfumes[idx] = perfume
        }
    }

    func deletePerfume(id: Int64) {
        run("DELETE FROM perfumes WHERE id=?", params: [id])
        perfumes.removeAll { $0.id == id }
    }

    func getPerfume(id: Int64) -> Perfume? {
        let rows = query("SELECT * FROM perfumes WHERE id=?", params: [id])
        return rows.first.map(mapPerfumeRow)
    }

    func createSale(items: [(perfumeId: Int64, quantity: Int64, unitPrice: Double)]) -> Sale {
        let totalAmount = items.reduce(0.0) { $0 + $1.unitPrice * Double($1.quantity) }
        let itemCount = items.reduce(0) { $0 + $1.quantity }

        run("INSERT INTO sales (total_amount,item_count) VALUES (?,?)", params: [totalAmount, itemCount])
        let saleId = lastInsertRowID()

        for item in items {
            guard let perfume = getPerfume(id: item.perfumeId) else { continue }
            run("INSERT INTO sale_items (sale_id,perfume_id,perfume_name,perfume_company,ml_size,quantity,unit_price,total_price) VALUES (?,?,?,?,?,?,?,?)",
                params: [saleId, item.perfumeId, perfume.name, perfume.company, perfume.mlSize, item.quantity, item.unitPrice, item.unitPrice * Double(item.quantity)])
            run("UPDATE perfumes SET quantity = quantity - ? WHERE id=?", params: [item.quantity, item.perfumeId])
        }

        let row = query("SELECT * FROM sales WHERE id=?", params: [saleId])
        let sale = row.first.map(mapSaleRow) ?? Sale(id: saleId, totalAmount: totalAmount, itemCount: itemCount)
        sales.append(sale)
        loadPerfumes()
        return sale
    }

    func getSale(id: Int64) -> Sale? {
        let rows = query("SELECT * FROM sales WHERE id=?", params: [id])
        return rows.first.map(mapSaleRow)
    }

    func getSaleItems(saleId: Int64) -> [(id: Int64, perfumeName: String, perfumeCompany: String, mlSize: Int64, quantity: Int64, unitPrice: Double, totalPrice: Double)] {
        let rows = query("SELECT * FROM sale_items WHERE sale_id=? ORDER BY id", params: [saleId])
        return rows.compactMap { row in
            guard let id = row["id"] as? Int64 else { return nil }
            return (
                id: id,
                perfumeName: (row["perfume_name"] as? String) ?? "",
                perfumeCompany: (row["perfume_company"] as? String) ?? "",
                mlSize: (row["ml_size"] as? Int64) ?? 0,
                quantity: (row["quantity"] as? Int64) ?? 0,
                unitPrice: (row["unit_price"] as? Double) ?? 0.0,
                totalPrice: (row["total_price"] as? Double) ?? 0.0
            )
        }
    }

    func deleteSale(id: Int64) {
        let items = getSaleItems(saleId: id)
        for item in items {
            run("UPDATE perfumes SET quantity = quantity + ? WHERE id=?", params: [item.quantity, getPerfumeId(fromItem: item)])
        }
        run("DELETE FROM sale_items WHERE sale_id=?", params: [id])
        run("DELETE FROM sales WHERE id=?", params: [id])
        sales.removeAll { $0.id == id }
        loadPerfumes()
    }

    private func getPerfumeId(fromItem: (id: Int64, perfumeName: String, perfumeCompany: String, mlSize: Int64, quantity: Int64, unitPrice: Double, totalPrice: Double)) -> Int64 {
        let rows = query("SELECT id FROM perfumes WHERE name=? AND company=? AND ml_size=?", params: [fromItem.perfumeName, fromItem.perfumeCompany, fromItem.mlSize])
        return (rows.first?["id"] as? Int64) ?? 0
    }

    func getDashboardStats() -> (totalProducts: Int, totalSales: Int, totalRevenue: Double, todayRevenue: Double) {
        let totalProducts = (query("SELECT COUNT(*) as c FROM perfumes").first?["c"] as? Int64) ?? 0
        let totalSales = (query("SELECT COUNT(*) as c FROM sales").first?["c"] as? Int64) ?? 0
        let totalRevenue = (query("SELECT COALESCE(SUM(total_amount),0) as s FROM sales").first?["s"] as? Double) ?? 0.0

        let today = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let todayStr = formatter.string(from: today)
        let todayRevenue = (query("SELECT COALESCE(SUM(total_amount),0) as s FROM sales WHERE datetime(created_at) >= ?", params: [todayStr]).first?["s"] as? Double) ?? 0.0

        return (Int(totalProducts), Int(totalSales), totalRevenue, todayRevenue)
    }

    func getRecentSales(limit: Int = 5) -> [Sale] {
        let rows = query("SELECT * FROM sales ORDER BY datetime(created_at) DESC LIMIT ?", params: [Int64(limit)])
        return rows.map(mapSaleRow)
    }

    func getTopPerfumes(limit: Int = 5) -> [(name: String, company: String, total: Double)] {
        let rows = query("SELECT perfume_name as name, perfume_company as company, SUM(total_price) as total FROM sale_items GROUP BY perfume_id ORDER BY total DESC LIMIT ?", params: [Int64(limit)])
        return rows.compactMap { row in
            guard let name = row["name"] as? String, let company = row["company"] as? String, let total = row["total"] as? Double else { return nil }
            return (name: name, company: company, total: total)
        }
    }
}
