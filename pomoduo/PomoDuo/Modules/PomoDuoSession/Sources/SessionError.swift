//
//  SessionError.swift
//  PomoDuoSession
//
//  Created by Eliu Diaz on 27/12/25.
//

import Foundation

public enum SessionError: Error, LocalizedError {
    case sessionAlreadyActive
    case noActiveSession
    case sessionNotPaused
    case sessionNotInWorkPeriod
    case sessionNotInBreak
    case invalidConfiguration

    public var errorDescription: String? {
        switch self {
        case .sessionAlreadyActive:
            return "A session is already active"
        case .noActiveSession:
            return "No active session to perform this action"
        case .sessionNotPaused:
            return "Session is not paused"
        case .sessionNotInWorkPeriod:
            return "Session is not in work period"
        case .sessionNotInBreak:
            return "Session is not in break period"
        case .invalidConfiguration:
            return "Invalid session configuration"
        }
    }
}
