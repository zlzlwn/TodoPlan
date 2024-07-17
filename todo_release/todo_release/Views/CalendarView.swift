import SwiftUI

struct CalendarView: View {
    @ObservedObject var listViewModel: ListViewModel
    @State private var currentDate = Date()
    @Binding var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                }
                Text(monthYearString(from: currentDate))
                    .font(.headline)
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayView(date: date, events: eventsForDate(date), isSelected: Binding(
                                                    get: { selectedDate == date },
                                                    set: { _ in selectedDate = date }
                                                ))
                    } else {
                        Text("")
                    }
                }
            }
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        let monthFirstWeekdays = calendar.dateComponents([.weekday], from: monthInterval.start).weekday! - 1
        
        let totalDays = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day!
        
        var days: [Date?] = Array(repeating: nil, count: monthFirstWeekdays)
        for day in 1...totalDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [ItemModel] {
        return listViewModel.items.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func changeMonth(_ value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}

struct DayView: View {
    let date: Date
    let events: [ItemModel]
    @Binding var isSelected: Bool
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text(String(calendar.component(.day, from: date)))
                .fontWeight(calendar.isDateInToday(date) ? .bold : .regular)
            ForEach(events.prefix(3)) { event in
                Text(event.title)
                    .font(.system(size: 8))
                    .lineLimit(1)
                    .foregroundColor(event.isCompleted ? .green : .blue)
            }
        }
        .padding(4)
        .background(isSelected ? Color.blue.opacity(0.3) : (calendar.isDateInToday(date) ? Color.yellow.opacity(0.3) : Color.clear))
        .cornerRadius(8)
        .onTapGesture {
            isSelected.toggle()
        }
    }
}
