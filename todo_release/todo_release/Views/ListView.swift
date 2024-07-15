import SwiftUI

struct ListView: View {
    @StateObject private var listViewModel = ListViewModel()
    @State private var newItemTitle = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("일정 추가하기")) {
                        HStack {
                            TextField("일정을 입력해주세요.", text: $newItemTitle)
                            Button(action: addItem) {
                                Text("추가")
                            }
                        }
                    }
                    
                    Section(header: Text("할 일 목록")) {
                        ForEach(listViewModel.items) { item in
                            ListRowView(item: item)
                                .onTapGesture {
                                    withAnimation(.linear) {
                                        listViewModel.updateItem(item: item)
                                    }
                                }
                        }
                        .onDelete(perform: listViewModel.deleteItem)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Todo List 📝")
            .onAppear {
                listViewModel.fetchItems()
            }
        }
    }
    
    private func addItem() {
        if !newItemTitle.isEmpty {
            listViewModel.addItem(title: newItemTitle)
            newItemTitle = ""
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListView()
        }
    }
}
