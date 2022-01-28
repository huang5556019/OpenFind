//
//  ListsDetailVC+Add.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsDetailViewController {
    func addWord() {
        let newWord = EditableWord(string: "")
        model.list.words.insert(newWord, at: 0)
        wordsTableView.insertRows(at: [0.indexPath], with: .automatic)
    }
}

extension ListsDetailViewController {
    func updateTableViewHeightConstraint(animated: Bool = true) {
        let edgePadding = ListsDetailConstants.listSpacing
        let wordHeight = ListsDetailConstants.wordRowHeight * CGFloat(model.list.words.count)
        let height = edgePadding + wordHeight
        wordsTableViewHeightC.constant = height

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded() /// must be `view` for a smooth animation
            }
        }
    }
}
