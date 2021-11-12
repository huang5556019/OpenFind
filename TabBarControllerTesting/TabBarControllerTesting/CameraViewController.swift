//
//  CameraViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI
import TabBarController

class CameraViewController: UIViewController, PageViewController {
    var tabType: TabState = .camera
    var cameraViewModel: ToolbarViewModel.Camera!
    
    lazy var toolbar: CameraToolbarView = {
        self.cameraViewModel = .init()
        return CameraToolbarView(viewModel: cameraViewModel)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print("cam load")
    }
}

struct CameraToolbarView: View {
    @ObservedObject var viewModel: ToolbarViewModel.Camera
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack {
                ResultsIconView(count: $viewModel.resultsCount)
                Spacer()
                FlashIconView(isOn: $viewModel.flashOn)
            }
            .frame(maxWidth: .infinity)

            Color.clear

            HStack {
                FocusIconView(isOn: $viewModel.focusOn)
                Spacer()
                SettingsIconView()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ToolbarButton: View {
    var iconName: String
    var body: some View {
        Button {
            print("Pressed")
        } label: {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 19))
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.15))
                .cornerRadius(20)
        }
    }
}



