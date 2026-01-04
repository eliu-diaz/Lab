import Afluent
import Foundation
import Combine

public final class _PomoDuoSessionManager: PomoDuoSessionManager {
    private let sessionSubject = CurrentValueSubject<Session?, Never>(nil)
    private var timer: Timer?

    public var currentSession: Session? {
        sessionSubject.value
    }

    public var sessionPublisher: AnyPublisher<Session?, Never> {
        sessionSubject.eraseToAnyPublisher()
    }

    public init() {}

    public func startSession(config: SessionConfig) async throws {
        guard currentSession == nil else {
            throw SessionError.sessionAlreadyActive
        }

        guard config.workDuration > 0, config.breakDuration > 0 else {
            throw SessionError.invalidConfiguration
        }

        let session = Session(
            workDuration: config.workDuration,
            breakDuration: config.breakDuration,
            state: .working(remainingSeconds: Int(config.workDuration)),
            isCompleted: false
        )

        sessionSubject.send(session)
        startTimer()
    }

    public func pauseSession() async throws {
        guard var session = currentSession else {
            throw SessionError.noActiveSession
        }

        switch session.state {
        case .working(let remaining):
            session.state = .paused(pausedState: .duringWork(remainingSeconds: remaining))
            stopTimer()
            sessionSubject.send(session)

        case .onBreak(let remaining):
            session.state = .paused(pausedState: .duringBreak(remainingSeconds: remaining))
            stopTimer()
            sessionSubject.send(session)

        case .paused:
            throw SessionError.sessionNotPaused

        case .idle, .completed:
            throw SessionError.noActiveSession
        }
    }

    public func resumeSession() async throws {
        guard var session = currentSession else {
            throw SessionError.noActiveSession
        }

        guard case .paused(let pausedState) = session.state else {
            throw SessionError.sessionNotPaused
        }

        switch pausedState {
        case .duringWork(let remaining):
            session.state = .working(remainingSeconds: remaining)
            sessionSubject.send(session)
            startTimer()

        case .duringBreak(let remaining):
            session.state = .onBreak(remainingSeconds: remaining)
            sessionSubject.send(session)
            startTimer()
        }
    }

    public func stopSession() async throws {
        guard var session = currentSession else {
            throw SessionError.noActiveSession
        }

        stopTimer()
        session.state = .completed
        session.endTime = Date()
        session.isCompleted = false  // Stopped early, not completed
        sessionSubject.send(session)

        // Clear session after a brief moment
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        sessionSubject.send(nil)
    }

    public func completeWorkPeriod() async throws {
        guard var session = currentSession else {
            throw SessionError.noActiveSession
        }

        guard case .working = session.state else {
            throw SessionError.sessionNotInWorkPeriod
        }

        stopTimer()
        session.state = .onBreak(remainingSeconds: Int(session.breakDuration))
        sessionSubject.send(session)
        startTimer()
    }

    public func completeBreakPeriod() async throws {
        guard var session = currentSession else {
            throw SessionError.noActiveSession
        }

        guard case .onBreak = session.state else {
            throw SessionError.sessionNotInBreak
        }

        stopTimer()
        session.state = .completed
        session.endTime = Date()
        session.isCompleted = true
        sessionSubject.send(session)

        // Clear session after a brief moment
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        sessionSubject.send(nil)
    }

    // MARK: - Private Timer Management

    private func startTimer() {
        stopTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timerTick() {
        guard var session = currentSession else {
            stopTimer()
            return
        }

        switch session.state {
        case .working(let remaining):
            if remaining > 1 {
                session.state = .working(remainingSeconds: remaining - 1)
                sessionSubject.send(session)
            } else {
                // Work period complete
                Task {
                    try? await completeWorkPeriod()
                }
            }

        case .onBreak(let remaining):
            if remaining > 1 {
                session.state = .onBreak(remainingSeconds: remaining - 1)
                sessionSubject.send(session)
            } else {
                // Break period complete
                Task {
                    try? await completeBreakPeriod()
                }
            }

        case .paused, .idle, .completed:
            stopTimer()
        }
    }
}
