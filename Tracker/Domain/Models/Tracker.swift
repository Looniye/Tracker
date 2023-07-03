import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let label: String
    let emoji: String
    let color: UIColor
    let completedDaysCount: Int
    let schedule: [Weekday]?
    
    init(id: UUID = UUID(), label: String, emoji: String, color: UIColor, completedDaysCount: Int, schedule: [Weekday]?) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.color = color
        self.completedDaysCount = completedDaysCount
        self.schedule = schedule
    }
    
    init(tracker: Tracker) {
        self.id = tracker.id
        self.label = tracker.label
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.completedDaysCount = tracker.completedDaysCount
        self.schedule = tracker.schedule
    }
    
    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color else { fatalError() }
        
        self.id = UUID()
        self.label = data.label
        self.emoji = emoji
        self.color = color
        self.completedDaysCount = data.completedDaysCount
        self.schedule = data.schedule
    }
    
    var data: Data {
        Data(label: label, emoji: emoji, color: color, completedDaysCount: completedDaysCount, schedule: schedule)
    }
}

extension Tracker {
    struct Data {
        var label: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        var completedDaysCount: Int = 0
        var schedule: [Weekday]? = nil
    }
}

enum Weekday: String, CaseIterable, Comparable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thurshday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortForm: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thurshday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        guard
            let first = Self.allCases.firstIndex(of: lhs),
            let second = Self.allCases.firstIndex(of: rhs)
        else { return false }
        
        return first < second
    }
}

extension Weekday {
    static func code(_ weekdays: [Weekday]?) -> String? {
        guard let weekdays else { return nil }
        let indexes = weekdays.map { Self.allCases.firstIndex(of: $0) }
        var result = ""
        for i in 0..<7 {
            if indexes.contains(i) {
                result += "1"
            } else {
                result += "0"
            }
        }
        return result
    }
    
    static func decode(from string: String?) -> [Weekday]? {
        guard let string else { return nil }
        var weekdays = [Weekday]()
        for (index, value) in string.enumerated() {
            guard value == "1" else { continue }
            let weekday = Self.allCases[index]
            weekdays.append(weekday)
        }
        return weekdays
    }
}
