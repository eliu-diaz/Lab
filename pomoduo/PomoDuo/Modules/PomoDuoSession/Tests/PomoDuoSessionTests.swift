import Testing
import Foundation

import Afluent
import Combine
import FactoryKit
import FactoryTesting
import PomoDuoSession

// MARK: - Session Manager Tests

@Suite("PomoDuo Session Manager Tests")
final class PomoDuoSessionManagerTests {
    var cancellables: Set<Combine.AnyCancellable>!

    init() {
        cancellables = Set<Combine.AnyCancellable>()
    }

    // MARK: - Start Session Tests

    @Test
    func sessionManagerStartsSession_thenCreatesActiveSession() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        // Act
        try await manager.startSession(config: config)

        // Assert
        #expect(manager.currentSession != nil)
        #expect(manager.currentSession?.state.isActive == true)
    }

    @Test
    func sessionManagerStartsSession_withDefaultConfig() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        
        // Act
        try await manager.startSession(config: .default)

        // Assert
        let session = try #require(manager.currentSession, "Expected current session to exist")

        #expect(session.workDuration == 25 * 60)
        #expect(session.breakDuration == 5 * 60)
    }

    @Test
    func sessionMangerStartsSession_whenActiveSessionExists_thenThrowsError() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        // Act
        try await manager.startSession(config: config)

        // Assert
        await #expect(throws: SessionError.sessionAlreadyActive) {
            try await manager.startSession(config: config)
        }
    }

    @Test
    func sessionManagerStartsSession_withInvalidConfig_thenThrowsError() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let invalidConfig = SessionConfig(workDuration: 0, breakDuration: 5)

        // Act & Assert
        await #expect(throws: SessionError.invalidConfiguration) {
            try await manager.startSession(config: invalidConfig)
        }
    }

    @Test
    func sessionManager_whenStartedSession_thenHasWorkingState() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 600, breakDuration: 300)

        // Act
        try await manager.startSession(config: config)

        // Assert
        guard case .working(let remaining) = manager.currentSession?.state else {
            Issue.record("Expected session to be in working state")
            return
        }

        #expect(remaining == 600)
    }

    // MARK: - Pause/Resume Tests

    @Test
    func sessionManager_whenPausingSession_thenSessionStateIsPaused() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        // Act
        try await manager.startSession(config: config)
        try await manager.pauseSession()

        // Assert
        #expect(manager.currentSession?.state.isPaused == true)
    }

    @Test
    func sessionManagerPausesSession_whenNoSessionThrowsError() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        
        // Act & Assert
        await #expect(throws: SessionError.noActiveSession) {
            try await manager.pauseSession()
        }
    }

    @Test
    func sessionManagerResumesSession_whenPausedSession_thenTransitionsBackToWorkingState() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        try await manager.startSession(config: config)
        try await manager.pauseSession()
        try await manager.resumeSession()

        #expect(manager.currentSession?.state.isActive == true)
    }

    @Test("Resuming when session is not paused throws error")
    func sessionManagerResumes_whenNotPaused_thenThrowsError() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        // Act
        try await manager.startSession(config: config)

        // Assert
        await #expect(throws: SessionError.sessionNotPaused) {
            try await manager.resumeSession()
        }
    }

    // MARK: - Stop Session Tests

    @Test("Stopping active session marks it as completed")
    func sessionManagerStopsActiveSession_whenSessionAlreadyActive_thenSessionIsCompleted() async throws {
        let sub = SingleValueSubject<Void>()
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        try await manager.startSession(config: config)
        var clearedSession = false
        
        manager.sessionPublisher
            .dropFirst()
            .sink { session in
                if session == nil {
                    clearedSession = true
                    try? sub.send(())
                }
            }
            .store(in: &cancellables)
        
        try await manager.stopSession()
        
        try await sub.execute()
        #expect(clearedSession == true)
    }

    @Test("Stopping when no session is active throws error")
    func stopWhenNoSessionThrowsError() async throws {
        let manager = Container.shared.sessionManager()
        
        await #expect(throws: SessionError.noActiveSession) {
            try await manager.stopSession()
        }
    }

    // MARK: - Work/Break Transition Tests

    @Test("Completing work period transitions to break")
    func completeWorkPeriodTransitionsToBreak() async throws {
        // Arrange
        let config = SessionConfig(workDuration: 10, breakDuration: 5)
        let manager = Container.shared.sessionManager()

        try await manager.startSession(config: config)
        try await manager.completeWorkPeriod()

        guard case .onBreak(let remaining) = manager.currentSession?.state else {
            Issue.record("Expected session to be on break")
            return
        }

        #expect(remaining == 5)
    }

    @Test("Completing work period when not in work throws error")
    func completeWorkPeriodWhenNotInWorkThrowsError() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        try await manager.startSession(config: config)
        try await manager.completeWorkPeriod()

        await #expect(throws: SessionError.sessionNotInWorkPeriod) {
            try await manager.completeWorkPeriod()
        }
    }

    @Test("Completing break period marks session as completed")
    func completeBreakPeriodMarksCompleted() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        try await manager.startSession(config: config)
        try await manager.completeWorkPeriod()

        let sub = SingleValueSubject<Void>()
        var sessionCompleted = false

        manager.sessionPublisher
            .dropFirst() // Skip initial transitions
            .sink { session in
                if session?.state == .completed {
                    sessionCompleted = true
                } else if session == nil && sessionCompleted {
                    try? sub.send(())
                }
            }
            .store(in: &cancellables)

        try await manager.completeBreakPeriod()

        try await sub.execute()
        #expect(sessionCompleted)
    }

    // MARK: - Session Publisher Tests

    @Test("Session publisher emits session changes")
    func sessionPublisherEmitsChanges() async throws {
        // Arrange
        let manager = Container.shared.sessionManager()
        let config = SessionConfig(workDuration: 10, breakDuration: 5)

        let sub = SingleValueSubject<Void>()
        var receivedSession: Session?

        manager.sessionPublisher
            .sink { session in
                if session != nil {
                    receivedSession = session
                    try? sub.send(())
                }
            }
            .store(in: &cancellables)

        try await manager.startSession(config: config)

        try await sub.execute()
        #expect(receivedSession != nil)
    }
}
