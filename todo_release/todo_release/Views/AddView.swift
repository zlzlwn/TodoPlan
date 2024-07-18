import SwiftUI

struct AddView: View {
    @Binding var title: String
    @Binding var memo: String
    @Binding var date: Date
    var onSave: () -> Void
    var buttonTitle: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일정 정보")) {
                    TextField("일정을 입력해주세요.", text: $title)
                    TextField("메모를 입력해주세요.", text: $memo)
                    DatePicker("날짜 및 시간", selection: $date)
                }
            }
            .navigationTitle(buttonTitle == "추가" ? "일정 추가하기" : "일정 수정하기")
            .navigationBarItems(
                leading: Button("취소") {
                    // 취소 로직
                },
                trailing: Button(buttonTitle) {
                    onSave()
                }
            )
        }
        .presentationDetents([.height(300)])
    }
}
