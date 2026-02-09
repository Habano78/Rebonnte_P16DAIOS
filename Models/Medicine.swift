import Foundation

struct Medicine: Identifiable, Codable {
        let id: String?
        let userId: String
        var name: String
        var brand: String
        var stock: Int
        var aisle: String
        var alertThreshold: Int
        var category: MedicineCategory
        var expirationDate: Date?
        
        var isLowStock: Bool {
                stock <= alertThreshold
        }
        
        var isExpired: Bool {
                guard let expirationDate else { return false }
                return expirationDate <= Date()
            }
}


enum MedicineCategory: String, CaseIterable, Identifiable, Codable {
    case antibiotic = "Antibiotique"
    case analgesic = "Analgésique"
    case antiInflammatory = "Anti-inflammatoire"
    case syrup = "Sirop"
    case cream = "Crème/Pommade"
    case vaccine = "Vaccin"
    case other = "Autre"

    var id: String { self.rawValue }
}
