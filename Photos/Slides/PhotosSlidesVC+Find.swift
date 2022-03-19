//
//  PhotosSlidesVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    /// start finding for a photo.
    /// If metadata does not exist, start scanning. Once done, `model.updateSlidesAt` in `PhotosSlidesVC+Listen` will be called.
    func startFinding(for findPhoto: FindPhoto) {
        if let metadata = findPhoto.photo.metadata, metadata.isScanned {
            self.find(in: findPhoto)
        } else {
            Find.prioritizedAction = .individualPhoto
            self.searchNavigationProgressViewModel.start(progress: .auto(estimatedTime: 1.5))

            var findOptions = FindOptions()
            findOptions.priority = .waitUntilNotBusy
            findOptions.action = .individualPhoto
            self.model.scanPhoto(findPhoto.photo, findOptions: findOptions, inBatch: false)
        }
    }

    /// find and show results
    func find(in findPhoto: FindPhoto) {
        guard let metadata = findPhoto.photo.metadata else { return }
        let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)

        let highlightSet = FindPhoto.HighlightsSet(
            stringToGradients: self.slidesSearchViewModel.stringToGradients,
            highlights: highlights
        )

        var newFindPhoto = findPhoto
        newFindPhoto.associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
        newFindPhoto.highlightsSet = highlightSet

        if let slidesState = model.slidesState, let index = slidesState.getFindPhotoIndex(photo: findPhoto.photo) {
            self.model.slidesState?.findPhotos[index] = newFindPhoto
        }
        
        if model.resultsState != nil {
            let summary = searchViewModel.getSummaryString()
            slidesSearchPromptViewModel.resetText = summary
        }

        slidesSearchPromptViewModel.resultsText = newFindPhoto.getResultsText()
        slidesSearchPromptViewModel.show(true)
        slidesSearchPromptViewModel.updateBarHeight?()
    }
}
