//
//  TabBarViewController.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import Combine
import SwiftUI
import UIKit

class TabBarViewController: UIViewController {
    /// big, general area
    @IBOutlet var contentView: UIView!
    
    /// for the pages
    @IBOutlet var contentCollectionView: UICollectionView!
    lazy var contentPagingLayout: ContentPagingFlowLayout = {
        let flowLayout = ContentPagingFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getTabs = { [weak self] in
            let pages = self?.getPages?() ?? [PageViewController]()
            return pages.map { $0.tabType }
        }
        
        contentCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }()
    
    /// get data from `TabBarController`
    var getPages: (() -> [PageViewController])?
    var scrollViewDidScroll: ((UIScrollView) -> Void)?
    
    /// for tab bar (SwiftUI)
    @IBOutlet var tabBarContainerView: UIView!
    @IBOutlet var tabBarHeightC: NSLayoutConstraint!

    var excludedFrames = [CGRect]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = contentPagingLayout
        contentCollectionView.decelerationRate = .fast
        
        if let view = view as? TabControllerView {
            view.excludedFrames = { [weak self] in
                self?.excludedFrames ?? []
            }
            view.tappedExcludedView = { [weak self] in
                self?.contentCollectionView.isScrollEnabled = false
                DispatchQueue.main.async {
                    self?.contentCollectionView.isScrollEnabled = true
                }
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            let insets = self.view.safeAreaInsets
            
            let pages = self.getPages?() ?? []
            for page in pages {
                page.boundsChanged(to: size, safeAreaInset: insets)
            }
            self.updateSafeAreaLayoutGuide(
                bottomHeight: ConstantVars.tabBarTotalHeightExpanded,
                safeAreaInsets: insets
            )
        }
    }

    func updateSafeAreaLayoutGuide(bottomHeight: CGFloat, safeAreaInsets: UIEdgeInsets) {
        if let pages = getPages?() {
            for page in pages {
                page.additionalSafeAreaInsets.right = safeAreaInsets.right
                page.additionalSafeAreaInsets.bottom = bottomHeight - safeAreaInsets.bottom
                page.additionalSafeAreaInsets.left = safeAreaInsets.left
            }
        }
    }
    
    func updateTabBarHeight(_ tabState: TabState) {
        func changeTabHeight(constant: CGFloat) {
            DispatchQueue.main.async {
                self.tabBarHeightC.constant = constant
            }
        }
        
        switch tabState {
        case .photos:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeight)
        case .camera:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeightExpanded)
        case .lists:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeight)
        default:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeightExpanded)
        }
    }
    
    /// animated is TODO, since setting `tabState` triggers the `.sink`, which auto calls this function.
    func updateTabContent(_ tabState: TabState, animated: Bool) {
        let index: Int
        switch tabState {
        case .photos:
            index = 0
        case .camera:
            index = 1
        case .lists:
            index = 2
        default:
            return /// if not a standard tab, that means the user is scrolling. Standard tab set is via SwiftUI
        }
        
        if let attributes = contentPagingLayout.layoutAttributes[safe: index] {
            /// use `getTargetOffset` as to set flow layout's focused index correctly (for rotation)
            let targetOffset = contentPagingLayout.getTargetOffset(for: CGPoint(x: attributes.fullOrigin, y: 0), velocity: 0)
            contentCollectionView.setContentOffset(targetOffset, animated: animated)
        }
    }
}
