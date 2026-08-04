//
//  Config.swift
//  JPSCaseApp
//
//  ⚠️ Change BASE_URL to your server's local network IP before running on a real device.
//  Example: "http://192.168.66.4:8282"
//

import Foundation

enum Config {
    /// Your FastAPI backend URL — change to your machine's local IP when on a real device.
    static let baseURL = "http://192.168.66.4:8282"

    /// How often (in seconds) the notification view polls for new cases.
    static let pollInterval: TimeInterval = 10
}
