import Foundation
import SQLite3

class ListViewModel: ObservableObject {
    @Published var items: [ItemModel] = []
    private var db: OpaquePointer?
    
    init() {
        openDatabase()
        createTable()
        fetchItems()
    }
    
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("TodoList.sqlite")
        print(fileURL.path)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }
    
    private func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            memo TEXT,
            isCompleted INTEGER,
            date TEXT
        );
        """
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Items table created.")
            } else {
                print("Items table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    func fetchItems() {
        items.removeAll()
        
        let queryString = "SELECT * FROM items;"
        var queryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int64(queryStatement, 0)
                let title = String(cString: sqlite3_column_text(queryStatement, 1))
                let memo = String(cString: sqlite3_column_text(queryStatement, 2))
                let isCompleted = sqlite3_column_int(queryStatement, 3) != 0
                
                var date = Date()
                if let dateText = sqlite3_column_text(queryStatement, 4) {
                    let dateString = String(cString: dateText)
                    date = ISO8601DateFormatter().date(from: dateString) ?? Date()
                }
                
                items.append(ItemModel(id: id, title: title, memo: memo, isCompleted: isCompleted, date: date))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
    }
    
    func addItem(title: String,memo: String, date: Date) {
        let insertStatementString = "INSERT INTO items (title, memo, isCompleted, date) VALUES (?, ?, ?,?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 1, (memo as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, 0)
            let dateString = ISO8601DateFormatter().string(from: date)
            sqlite3_bind_text(insertStatement, 3, (dateString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(insertStatement)
        
        fetchItems()
    }
    //일정 완료,미완료 수정 function
    func updateItem(item: ItemModel) {
        let updateStatementString = "UPDATE items SET isCompleted = ?, date = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(updateStatement, 1, item.isCompleted ? 1 : 0)
            print("iscompleted\(item.isCompleted)")
            let dateString = ISO8601DateFormatter().string(from: item.date)
            sqlite3_bind_text(updateStatement, 2, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(updateStatement, 3, item.id)
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        
        sqlite3_finalize(updateStatement)
        
        fetchItems()
    }
    //일정 수정 Function
    func editItem(item: ItemModel) {
        let updateStatementString = "UPDATE items SET title = ?, memo = ?, date = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (item.title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (item.memo as NSString).utf8String, -1, nil)
            let dateString = ISO8601DateFormatter().string(from: item.date)
            sqlite3_bind_text(updateStatement, 3, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(updateStatement, 4, item.id)
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully edited item.")
                if let index = items.firstIndex(where: { $0.id == item.id }) {
                    items[index] = item
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Could not edit item. Error: \(errorMessage)")
            }
        } else {
            print("EDIT statement could not be prepared")
        }
        
        sqlite3_finalize(updateStatement)
        
        objectWillChange.send()
    }
    
    
    func deleteItem(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let item = items[index]
        
        let deleteStatementString = "DELETE FROM items WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int64(deleteStatement, 1, item.id)
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
        fetchItems()
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    deinit {
        sqlite3_close(db)
    }
}
