//
//  PomoDuoSessionManager.swift
//  PomoDuoSession
//
//  Created by Eliu Diaz on 27/12/25.
//

import Combine

/// Manages Pomodoro session lifecycle and state
public protocol PomoDuoSessionManager: AnyObject {
    /// The current active session, if any
    var currentSession: Session? { get }

    /// Publisher for session state changes
    var sessionPublisher: AnyPublisher<Session?, Never> { get }

    /// Starts a new Pomodoro session with the given configuration
    /// - Parameter config: The session configuration
    /// - Throws: SessionError if a session is already active
    func startSession(config: SessionConfig) async throws

    /// Pauses the current active session
    /// - Throws: SessionError if no session is active or session cannot be paused
    func pauseSession() async throws

    /// Resumes a paused session
    /// - Throws: SessionError if no session is paused
    func resumeSession() async throws

    /// Stops the current session
    /// - Throws: SessionError if no session is active
    func stopSession() async throws

    /// Completes the current work period and starts break
    /// - Throws: SessionError if no work session is active
    func completeWorkPeriod() async throws

    /// Completes the current break period
    /// - Throws: SessionError if no break is active
    func completeBreakPeriod() async throws
}
