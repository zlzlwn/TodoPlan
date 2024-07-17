import SwiftUI

struct ListView: View {
    @State private var showSheetView = false
    @StateObject private var listViewModel = ListViewModel()
    @State private var newItemTitle = ""
    @State private var newItemDate = Date()
    @State private var searchText = ""
    @State private var showingCalendar = false
    @State private var showingAddView = false
    @State var showingsheetview = false
    @State private var selectedDate: Date?
    
    var body: some View {
        NavigationView {
            ZStack{
                
                
                VStack {
                    CalendarView(listViewModel: listViewModel,selectedDate: $selectedDate)
                    List {
                        SearchBar(text: $searchText)
                        
                        Section(header: Text("할 일 목록")) {
                            ForEach(filteredItems) { item in
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
                    //                }//else
                }//vstack(일정알림)
                .sheet(isPresented: $showingsheetview ){
                    Section(header: Text("일정 추가하기")) {
                        TextField("일정을 입력해주세요.", text: $newItemTitle)
                        DatePicker("날짜 및 시간", selection: $newItemDate)
                        Button(action: addItem) {
                            Text("추가")
                                .presentationDetents([.height(300)])
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            print("플로팅 버튼 눌림")
                            showingAddView = true
                            showingsheetview = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                        
                    }
                }//zstack(floating button)
                //            .navigationTitle("Todo List 📝")
////                .navigationBarItems(ㅋtrailing: Button(action: {
//                    showingCalendar.toggle()
//                }) {
//                    Image(systemName: showingCalendar ? "list.bullet" : "calendar")
//                })
                .onAppear {
                    listViewModel.fetchItems()
                }
            }
        }
        var filteredItems: [ItemModel] {
            let items = listViewModel.items.filter { item in
                searchText.isEmpty ? true : item.title.localizedCaseInsensitiveContains(searchText)
            }
            if let selectedDate = selectedDate {
                return items.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            }
            return items
        }
    }
    private func addItem() {
        if !newItemTitle.isEmpty {
            listViewModel.addItem(title: newItemTitle, date: newItemDate)
            newItemTitle = ""
            newItemDate = Date()
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
