//
//  PhotosVC+Cache.swift
//  Find
//
//  Created by Zheng on 1/13/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

extension PhotosViewController: ReturnCachedPhotos {
    func giveCachedPhotos(photos: [FindPhoto], returnResult: CacheReturn) {
        print("Given: \(photos)")
        
        var paths = [IndexPath]()
        for photo in photos {
            if let path = dataSource.indexPath(for: photo) {
                paths.append(path)
            }
        }
        reloadPaths(changedPaths: paths)
        
        sortPhotos(with: currentFilter)
        applySnapshot()
        
    }
}

extension PhotosViewController {
    func cache(_ shouldCache: Bool) {
        var selectedPhotos = [FindPhoto]()
        for indexPath in indexPathsSelected {
            if let item = dataSource.itemIdentifier(for: indexPath) {
                selectedPhotos.append(item)
            }
        }
        
        print("Should cache: \(shouldCache)")
        
        if shouldCache == true {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingViewController") as! CachingViewController
            
            var attributes = EKAttributes.centerFloat
            attributes.displayDuration = .infinity
            attributes.entryInteraction = .absorbTouches
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
            attributes.entryBackground = .color(color: .white)
            attributes.screenInteraction = .absorbTouches
            
            let cacheControllerHeight = max(screenBounds.size.height - CGFloat(300), 410)
            
            attributes.positionConstraints.size.height = .constant(value: cacheControllerHeight)
            attributes.positionConstraints.maxSize = .init(width: .constant(value: 450), height: .constant(value: 550))
            
            attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
            attributes.lifecycleEvents.didAppear = {
                cacheController.doneAnimating()
            }
            
            cacheController.photosToCache = selectedPhotos
            cacheController.getRealRealmModel = { [weak self] object in
                guard let self = self else { return nil }
                if let realObject = self.getRealRealmModel(from: object) {
                    return realObject
                } else {
                    return nil
                }
            }
            cacheController.finishedCache = self
            cacheController.view.layer.cornerRadius = 10
            
            selectButtonSelected = false
            SwiftEntryKit.dismiss()
            collectionView.allowsMultipleSelection = false
            
            SwiftEntryKit.display(entry: cacheController, using: attributes)
        } else {
            var changedIndexPaths = [IndexPath]()
            for findPhoto in selectedPhotos {
                if let editableModel = findPhoto.editableModel {
                    if let realModel = getRealRealmModel(from: editableModel)  {
                        if realModel.isDeepSearched { /// only unstar if already starred
                            
                            if let indexPath = dataSource.indexPath(for: findPhoto) {
                                changedIndexPaths.append(indexPath)
                            }
                            do {
                                try realm.write {
                                    realModel.isDeepSearched = false
                                    realm.delete(realModel.contents)
                                }
                            } catch {
                                print("Error starring photo \(error)")
                            }
                            editableModel.isDeepSearched = false
                            editableModel.contents.removeAll()
                        }
                    }
                }
            }
            reloadPaths(changedPaths: changedIndexPaths)
            sortPhotos(with: currentFilter)
            applySnapshot()
        }
        doneWithSelect()
    }
}
