import SwiftUI
struct ItemEditView: View {
//    @Binding var item: ItemModel
    @Binding var title: String
    @Binding var memo: String
    @Binding var date: Date
    @Binding var isEditMode: Bool
    var onSave: () -> Void
    var onCancel: () -> Void
    var buttonTitle: String
    
    var body: some View {
        NavigationView {
            Form {
                TextField("제목", text: $title)
                TextField("메모", text: $memo)
                DatePicker("날짜", selection: $date)
            }
            .navigationTitle(isEditMode ? "일정 수정하기" : "일정 추가하기")
            .navigationBarItems(
                leading: Button("취소") {
                    onCancel()
                },
                trailing: Button(buttonTitle) {
                    onSave()
                }
            )
        }
        .onAppear {
            print("ItemEditView appeared: isEditMode = \(isEditMode)")
            print("title:\(title)memo:\(memo)date:\(date)")
        }
        
    }
}
