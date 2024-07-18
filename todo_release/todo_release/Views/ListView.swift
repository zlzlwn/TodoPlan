import SwiftUI

struct ListView: View {
    @StateObject private var listViewModel = ListViewModel() // ListView 전체에서 데이터 관리에 사용

    // 새 항목 추가 시 사용
    @State private var newItemTitle = "" // 새 항목의 제목
    @State private var newItemMemo = "" // 새 항목의 메모
    @State private var newItemDate = Date() // 새 항목의 날짜

    @State private var searchText = "" // 검색 기능에 사용

    @State private var selectedDate: Date? // CalendarView에서 선택된 날짜

    // 항목 수정 시 사용
    @State private var editItemTitle = "" // 수정 중인 항목의 제목
    @State private var editItemMemo = "" // 수정 중인 항목의 메모
    @State private var editItemDate = Date() // 수정 중인 항목의 날짜

    @State private var showingItemSheet = false // 항목 추가/수정 시트 표시 여부
    @State private var editingItem: ItemModel? // 현재 수정 중인 항목
    @State private var isEditMode = false // 현재 수정 모드인지 여부
    
 
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
                                            var updatedItem = item
                                            updatedItem.isCompleted.toggle() // 상태 전환
                                            listViewModel.updateItem(item: updatedItem)
                                            print("업데이트 실행")
                                            print("iscompleted 바뀌는지 확인: \(updatedItem.isCompleted)")
                                        }
                                    }
                                    //수정
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            editingItem = item
                                            editItemTitle = item.title
                                            editItemMemo = item.memo
                                            editItemDate = item.date
                                            isEditMode = true
                                            showingItemSheet = true
                                            print("수정 모드 시작: isEditMode = \(isEditMode)")
                                            print("#################")
                                            print("title:\(editItemTitle)memo:\(editItemMemo)date:\(editItemDate)")
                                            print("#################")
                                            
                                            
                                        } label: {
                                            Label("수정", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                
                            }
                            //삭제
                            .onDelete(perform: listViewModel.deleteItem)
                            
                            
                        }
                    }
                    .listStyle(PlainListStyle())
                    //                }//else
                }//vstack(일정알림)
                
                .sheet(isPresented: $showingItemSheet) {
                    ItemEditView(
                        title: isEditMode ? $editItemTitle : $newItemTitle,
                        memo: isEditMode ? $editItemMemo : $newItemMemo,
                        date: isEditMode ? $editItemDate : $newItemDate,
                        isEditMode: $isEditMode,
                        onSave: {
                            if isEditMode {
                                if var updatedItem = editingItem {
                                    updatedItem.title = editItemTitle
                                    updatedItem.memo = editItemMemo
                                    updatedItem.date = editItemDate
                                    print("타이틀\(updatedItem.title),메모\(updatedItem.memo),날짜\(updatedItem.date)")
                                    listViewModel.editItem(item: updatedItem)
                                }
                            } else {
                                addItem()
                            }
                            showingItemSheet = false
                            isEditMode = false
                        },
                        onCancel: {
                            showingItemSheet = false
                            isEditMode = false
                        },
                        buttonTitle: isEditMode ? "수정" : "추가"
                    )
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            print("플로팅 버튼 눌림")
                            isEditMode = false
                            newItemTitle = ""
                            newItemMemo = ""
                            newItemDate = Date()
                            showingItemSheet = true
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
            listViewModel.addItem(title: newItemTitle, memo: newItemMemo, date: newItemDate)
            newItemTitle = ""
            newItemMemo = ""
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
