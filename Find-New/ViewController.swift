//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class ViewController: UIViewController {
    let realmModel = RealmModel()
    let cameraViewModel = CameraViewModel()
    let listsViewModel = ListsViewModel()
    let toolbarViewModel = ToolbarViewModel()
    
    lazy var photos: PhotosController = PhotosBridge.makeController()

    lazy var camera: CameraController = CameraBridge.makeController(
        cameraViewModel: cameraViewModel,
        realmModel: realmModel
    )

    lazy var lists: ListsController = ListsBridge.makeController(
        listsViewModel: listsViewModel,
        toolbarViewModel: toolbarViewModel,
        realmModel: realmModel
    )
    
    lazy var tabController: TabBarController = {
        photos.viewController.toolbarViewModel = toolbarViewModel
        
        let tabController = TabControllerBridge.makeTabController(
            pageViewControllers: [photos.viewController, camera.viewController, lists.searchNavigationController],
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel
        )
        
        tabController.delegate = self
        
        self.addChildViewController(tabController.viewController, in: self.view)

        let searchBar = camera.viewController.searchViewController.searchBarView ?? UIView()
        let searchBarBounds = searchBar.convert(searchBar.bounds, to: nil)
        tabController.viewController.excludedFrames = [searchBarBounds]
        return tabController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = tabController
        
        realmModel.loadSampleLists()
        lists.viewController.listsUpdated()
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: nil)
        let searchContainerFrame = camera.viewController.searchContainerView.convert(camera.viewController.searchContainerView.bounds, to: nil)

        if searchContainerFrame.contains(location) {
            return false
        }
        
        return true
    }
}

extension ViewController: TabBarControllerDelegate {
    func willBeginNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photos.viewController.willBecomeActive()
            camera.viewController.willBecomeInactive()
            lists.searchNavigationController.willBecomeInactive()
        case .camera:
            photos.viewController.willBecomeInactive()
            camera.viewController.willBecomeActive()
            lists.searchNavigationController.willBecomeInactive()
        case .lists:
            photos.viewController.willBecomeInactive()
            camera.viewController.willBecomeInactive()
            lists.searchNavigationController.willBecomeActive()
        default: break
        }
    }
    
    func didFinishNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photos.viewController.didBecomeActive()
            camera.viewController.didBecomeInactive()
            lists.searchNavigationController.didBecomeInactive()
        case .camera:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeActive()
            lists.searchNavigationController.didBecomeInactive()
        case .lists:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeInactive()
            lists.searchNavigationController.didBecomeActive()
        default: break
        }
    }
}
