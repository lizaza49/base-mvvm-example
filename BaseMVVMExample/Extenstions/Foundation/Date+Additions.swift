//
//  Date+Additions.swift
//  BaseMVVMExample
//
//  Created by Admin on 20/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

///
extension Date {
    
    // MARK: Constructors
    
    /**
     */
    func years(ago years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: -abs(years), to: self) ?? Date()
    }

    /**
     */
    static func years(ago years: Int) -> Date {
        return Date().years(ago: years)
    }
    
    // MARK: Modificators
    
    func trimming(dateComponents: [Calendar.Component]) -> Date {
        var date = self
        for component in dateComponents {
            if let trimmedDate = Calendar.current.date(bySetting: component, value: 0, of: date) {
                date = trimmedDate
            }
        }
        return date
    }
    
    /**
     */
    func trimmingTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    /**
     */
    func settingCurrentTime() -> Date {
        let calendar = Calendar.current
        let currentDate = Date()
        print(calendar.component(.minute, from: currentDate))
        let timeComponents: [(component: Calendar.Component, value: Int)] = [Calendar.Component]([.hour, .minute, .second, .nanosecond])
            .map { ($0, calendar.component($0, from: currentDate)) }
        var resultDate = self
        timeComponents.forEach {
            resultDate = calendar.date(bySetting: $0.component, value: $0.value, of: resultDate)!
        }
        return resultDate
    }
    
    /**
     */
    func settingMaxTime() -> Date {
        return trimmingTime().incrementing(.day, by: 1).incrementing(.minute, by: -1)
    }
    
    /**
     */
    func settingTimeToFit(_ range: ClosedRange<Date>) -> Date {
        let calendar = Calendar.current
        
        let hours = calendar.component(.hour, from: self)
        let hoursRange = (calendar.component(.hour, from: range.lowerBound) ... calendar.component(.hour, from: range.upperBound))
        let hoursToFit = min(max(hours, hoursRange.lowerBound), hoursRange.upperBound)
        
        let minutes = calendar.component(.minute, from: self)
        let minutesRange = (calendar.component(.minute, from: range.lowerBound) ... calendar.component(.minute, from: range.upperBound))
        let minutesToFit = min(max(minutes, minutesRange.lowerBound), minutesRange.upperBound)
        
        var resultDate = self
        resultDate = calendar.date(bySetting: .hour, value: hoursToFit, of: resultDate)!
        resultDate = calendar.date(bySetting: .minute, value: minutesToFit, of: resultDate)!
        return resultDate
    }
    
    /**
     */
    func settingDay(asIn date: Date) -> Date {
        let calendar = Calendar.current
        var resultDate = self
        let componentsToSet: [Calendar.Component] = [.year, .month, .day]
        componentsToSet.forEach {
            resultDate = calendar.date(bySetting: $0, value: calendar.component($0, from: date), of: resultDate)!
        }
        return resultDate
    }
    
    /**
     */
    func settingTime(asIn date: Date) -> Date {
        let calendar = Calendar.current
        var resultDate = self
        let componentsToSet: [Calendar.Component] = [.hour, .minute, .second, .nanosecond]
        componentsToSet.forEach {
            resultDate = calendar.date(bySetting: $0, value: calendar.component($0, from: date), of: resultDate)!
        }
        return resultDate
    }
    
    /**
     */
    func incrementing(_ component: Calendar.Component, by value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }
    
    /**
     */
    func addingTime(of date: Date) -> Date {
        var resultDate = self
        let calendar = Calendar.current
        let components = [Calendar.Component]([.hour, .minute, .second, .nanosecond])
        components.forEach {
            resultDate = calendar.date(byAdding: $0, value: calendar.component($0, from: date), to: resultDate)!
        }
        return resultDate
    }
    
    /**
     */
    func adding(workingDays: Int) -> Date {
        let calendar = Calendar.current
        let targetDate = self
        var followingDays = (1 ... workingDays).compactMap {
            calendar.date(byAdding: .day, value: $0, to: targetDate)
        }
        while (followingDays.last?.isWeekend() ?? false) {
            let nextDate = calendar.date(byAdding: .day, value: 1, to: followingDays.last!)!
            if nextDate.isWeekend() {
                followingDays.append(nextDate)
            }
            else {
                break
            }
        }
        
        let nonWeekendFollowingDays = followingDays.filter { date -> Bool in
            return !date.isWeekend()
        }
        let lastNonWeekendIndex = followingDays.firstIndex(of: nonWeekendFollowingDays.last ?? targetDate) ?? 0
        let numberOfWeekends = followingDays.count - nonWeekendFollowingDays.count
        if lastNonWeekendIndex == followingDays.count - 1 {
            return followingDays.last!
        }
        else if lastNonWeekendIndex < followingDays.count {
            return calendar.date(byAdding: .day, value: numberOfWeekends + 1, to: followingDays[lastNonWeekendIndex])!
        }
        else {
            return calendar.date(byAdding: .day, value: numberOfWeekends + 1, to: targetDate)!
        }
    }
    
    // MARK: Checks
    
    /**
     */
    func isWeekend() -> Bool {
        let calendar = Calendar.current
        var weekday = calendar.component(.weekday, from: self) + 1 - calendar.firstWeekday
        if weekday <= 0 {
            weekday += 7
        }
        return (6 ... 7) ~= weekday
    }
}
