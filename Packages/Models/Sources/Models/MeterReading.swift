import Foundation

public struct MeterReading: Equatable {
    
    public enum Status: Equatable {
        case notStarted
        case working(progress: Double)
        case finished
    }
    
    public let amountEarned: Double
    public var progress: Double {
        switch status {
        case .notStarted:
            return 0
        case .finished:
            return 1
        case .working(let progress):
            return progress
        }
    }
    public let status: Status
}


// MARK: - Instantiation

public extension MeterReading {
    static let notStarted = MeterReading(amountEarned: 0, status: .notStarted)
    
    static func finished(amountEarned: Double) -> MeterReading {
        .init(amountEarned: amountEarned, status: .finished)
    }
    
    static func working(amountEarned: Double, progress: Double) -> MeterReading {
        .init(amountEarned: amountEarned, status: .working(progress: progress))
    }
    
    static func accumulated(amountEarned: Double, status: Status) -> MeterReading {
        return .init(amountEarned: amountEarned, status: status)
    }
}
