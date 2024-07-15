// ListViewModel.swift
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
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }
    
    private func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isCompleted INTEGER
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
                let isCompleted = sqlite3_column_int(queryStatement, 2) != 0
                
                items.append(ItemModel(id: id, title: title, isCompleted: isCompleted))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
    }
    
    func addItem(title: String) {
        let insertStatementString = "INSERT INTO items (title, isCompleted) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, 0)
            
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
    
    func updateItem(item: ItemModel) {
        let updateStatementString = "UPDATE items SET isCompleted = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(updateStatement, 1, item.isCompleted ? 0 : 1)
            sqlite3_bind_int64(updateStatement, 2, item.id)
            
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
        // Note: SQLite doesn't support direct reordering.
        // If you need to maintain order, you might want to add an 'order' column
        // and update it here.
    }
    
    deinit {
        sqlite3_close(db)
    }
}
