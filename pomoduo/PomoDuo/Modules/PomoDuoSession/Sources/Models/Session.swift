//
//  Session.swift
//  PomoDuoSession
//
//  Created by Eliu Diaz on 27/12/25.
//

import Foundation

/// Represents a Pomodoro session with its timing and state
public struct Session: Identifiable, Equatable, Codable {
    public let id: UUID
    public let startTime: Date
    public var endTime: Date?
    public let workDuration: TimeInterval
    public let breakDuration: TimeInterval
    public var state: SessionState
    public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        workDuration: TimeInterval,
        breakDuration: TimeInterval,
        state: SessionState = .idle,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.state = state
        self.isCompleted = isCompleted
    }
}
