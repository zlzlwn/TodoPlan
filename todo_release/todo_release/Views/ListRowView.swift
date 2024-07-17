import SwiftUI

struct ListRowView: View {
    let item: ItemModel
    
    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                .foregroundColor(item.isCompleted ? .green : .red)
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.title2)
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var item1 = ItemModel(id: 1, title: "First item!", isCompleted: false, date: Date())
    static var item2 = ItemModel(id: 2, title: "Second Item.", isCompleted: true, date: Date().addingTimeInterval(86400))
    
    static var previews: some View {
        Group {
            ListRowView(item: item1)
            ListRowView(item: item2)
        }
        .previewLayout(.sizeThatFits)
    }
}
