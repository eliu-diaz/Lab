//
//  SessionState.swift
//  PomoDuoSession
//
//  Created by Eliu Diaz on 27/12/25.
//

/// Represents the current state of a Pomodoro session
public enum SessionState: Equatable, Codable {
    case idle
    case working(remainingSeconds: Int)
    case onBreak(remainingSeconds: Int)
    case paused(pausedState: PausedState)
    case completed

    public enum PausedState: Equatable, Codable {
        case duringWork(remainingSeconds: Int)
        case duringBreak(remainingSeconds: Int)
    }

    public var isPaused: Bool {
        if case .paused = self {
            return true
        }
        return false
    }

    public var isActive: Bool {
        switch self {
        case .working, .onBreak:
            return true
        default:
            return false
        }
    }
}
