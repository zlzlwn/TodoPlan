// ItemModel.swift
import Foundation

struct ItemModel: Identifiable {
    let id: Int64
    var title: String
    var memo: String
    var isCompleted: Bool
    var date: Date
}
