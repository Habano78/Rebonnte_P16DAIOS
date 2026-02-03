import Foundation
import FirebaseFirestoreSwift

import Foundation

struct Medicine: Identifiable, Equatable, Sendable {
    let id: String
    var name: String
    var stock: Int
    var aisle: String
}
