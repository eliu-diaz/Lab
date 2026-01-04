//
//  SessionConfig.swift
//  PomoDuoSession
//
//  Created by Eliu Diaz on 27/12/25.
//

import Foundation

/// Configuration for a Pomodoro session
public struct SessionConfig: Equatable, Codable {
    public var workDuration: TimeInterval
    public var breakDuration: TimeInterval
    public var longBreakDuration: TimeInterval
    public var sessionsUntilLongBreak: Int

    public init(
        workDuration: TimeInterval = 25 * 60,  // 25 minutes
        breakDuration: TimeInterval = 5 * 60,   // 5 minutes
        longBreakDuration: TimeInterval = 15 * 60,  // 15 minutes
        sessionsUntilLongBreak: Int = 4
    ) {
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.longBreakDuration = longBreakDuration
        self.sessionsUntilLongBreak = sessionsUntilLongBreak
    }

    public static let `default` = SessionConfig()
}
