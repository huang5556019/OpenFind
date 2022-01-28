//
//  RealmModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import SwiftUI

class RealmModel: ObservableObject {
    let realm = try! Realm()

    @Published var lists = [List]()
}

protocol RealmModelListener: AnyObject {
    func listsUpdated()
}
