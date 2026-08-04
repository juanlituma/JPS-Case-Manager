//
//  NetworkManager.swift
//  JPSCaseApp
//
//  All API calls to the FastAPI backend using async/await + URLSession.
//

import Foundation

final class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

    private let base = Config.baseURL

    // MARK: - Helpers

    private func makeRequest(
        path: String,
        method: String = "GET",
        body: Encodable? = nil,
        token: String? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: "\(base)\(path)") else {
            throw AppError.networkError("Invalid URL: \(base)\(path)")
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }

        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.detail
                      ?? "HTTP \(http.statusCode)"
            throw AppError.serverError(msg)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AppError.networkError("Failed to decode response: \(error.localizedDescription)")
        }
    }

    // MARK: - Auth

    /// Register a new user account.
    func register(username: String, email: String, fullName: String?, password: String) async throws -> UserOut {
        let body = UserRegister(username: username, email: email, fullName: fullName, password: password)
        let req = try makeRequest(path: "/auth/register", method: "POST", body: body)
        return try await perform(req)
    }

    /// Login and receive a JWT token.
    func login(username: String, password: String) async throws -> TokenResponse {
        let body = UserLogin(username: username, password: password)
        let req = try makeRequest(path: "/auth/login", method: "POST", body: body)
        return try await perform(req)
    }

    // MARK: - Cases

    /// Create a new case.
    func createCase(
        title: String,
        description: String?,
        deliveryProvider: DeliveryProvider?,
        complaintType: ComplaintType?,
        token: String
    ) async throws -> CaseOut {
        let body = CaseCreate(
            title: title,
            description: description,
            deliveryProvider: deliveryProvider,
            complaintType: complaintType,
            assignedToId: nil
        )
        let req = try makeRequest(path: "/cases", method: "POST", body: body, token: token)
        return try await perform(req)
    }

    /// Fetch paginated list of cases belonging to the given user.
    func fetchCases(token: String, userId: Int, skip: Int = 0, limit: Int = 50) async throws -> CaseListOut {
        let req = try makeRequest(
            path: "/cases?created_by_id=\(userId)&skip=\(skip)&limit=\(limit)",
            method: "GET",
            token: token
        )
        return try await perform(req)
    }
}
