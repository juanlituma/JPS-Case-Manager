//
//  Models.swift
//  JPSCaseApp
//
//  Data models matching the FastAPI backend schemas.
//

import Foundation

// MARK: - Auth

struct UserOut: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let fullName: String?
    let isActive: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case fullName  = "full_name"
        case isActive  = "is_active"
        case createdAt = "created_at"
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let user: UserOut

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType   = "token_type"
        case user
    }
}

struct UserRegister: Codable {
    let username: String
    let email: String
    let fullName: String?
    let password: String

    enum CodingKeys: String, CodingKey {
        case username, email, password
        case fullName = "full_name"
    }
}

struct UserLogin: Codable {
    let username: String
    let password: String
}

// MARK: - Cases

enum DeliveryProvider: String, Codable, CaseIterable {
    case uber         = "Uber"
    case doorDash     = "DoorDash"
    case grabHub      = "GrabHub"
    case selfDelivery = "Self Delivery"

    var displayName: String { rawValue }
}

enum ComplaintType: String, Codable, CaseIterable {
    case notReceiveFood    = "not_receive_food"
    case foodBadQuality    = "food_bad_quality"
    case missingItem       = "missing_item"
    case receivedWrongOrder = "received_wrong_order"

    var displayName: String {
        switch self {
        case .notReceiveFood:    return "Not Receive Food"
        case .foodBadQuality:   return "Food Bad Quality"
        case .missingItem:      return "Missing Item"
        case .receivedWrongOrder: return "Received Wrong Order"
        }
    }
}

enum CaseStatus: String, Codable, CaseIterable {
    case open        = "open"
    case inProgress  = "in_progress"
    case resolved    = "resolved"

    var displayName: String {
        switch self {
        case .open:       return "Open"
        case .inProgress: return "In Progress"
        case .resolved:   return "Resolved"
        }
    }

    var color: String {
        switch self {
        case .open:       return "blue"
        case .inProgress: return "orange"
        case .resolved:   return "green"
        }
    }
}

struct CaseOut: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let solution: String?
    let deliveryProvider: DeliveryProvider?
    let complaintType: ComplaintType?
    let status: CaseStatus
    let createdById: Int?
    let createdByName: String?
    let assignedToId: Int?
    let assignedToName: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, solution, status
        case deliveryProvider = "delivery_provider"
        case complaintType    = "complaint_type"
        case createdById      = "created_by_id"
        case createdByName    = "created_by_name"
        case assignedToId     = "assigned_to_id"
        case assignedToName   = "assigned_to_name"
        case createdAt        = "created_at"
        case updatedAt        = "updated_at"
    }
}

struct CaseListOut: Codable {
    let total: Int
    let cases: [CaseOut]
}

struct CaseCreate: Codable {
    let title: String
    let description: String?
    let deliveryProvider: DeliveryProvider?
    let complaintType: ComplaintType?
    let assignedToId: Int?

    enum CodingKeys: String, CodingKey {
        case title, description
        case deliveryProvider = "delivery_provider"
        case complaintType    = "complaint_type"
        case assignedToId     = "assigned_to_id"
    }
}

// MARK: - Error

struct APIErrorResponse: Codable {
    let detail: String
}

enum AppError: LocalizedError {
    case serverError(String)
    case networkError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .serverError(let msg):  return msg
        case .networkError(let msg): return "Network error: \(msg)"
        case .unknown:               return "An unknown error occurred."
        }
    }
}
