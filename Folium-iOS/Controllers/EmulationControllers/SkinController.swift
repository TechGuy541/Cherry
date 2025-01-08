//
//  SkinController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 13/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import GameController
import UIKit

class SkinController : LastPlayedPlayTimeController {
    var controllerView: ControllerView? = nil
    var skin: Skin
    init(game: GameBase, skin: Skin) {
        self.skin = skin
        super.init(game: game)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let orientation = skin.orientation(for: interfaceOrientation()) else { return }
        
        controllerView = .init(orientation: orientation, skin: skin, delegates: (button: self, thumbstick: self))
        guard let controllerView else { return }
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { skin.orientations.supportedInterfaceOrientations }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            let skin: Skin? = if let url = self.skin.url {
                try? SkinManager.shared.skin(from: url)
            } else {
                nil
            }
            
            guard let skin else { return }
            self.skin = skin
            
            guard let controllerView = self.controllerView,
                  let orientation = skin.orientation(for: self.interfaceOrientation()) else { return }
            
            controllerView.updateFrames(for: orientation, controllerDisconnected: GCController.controllers().isEmpty)
        }
    }
}

extension SkinController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        // Handle button touch began
    }
    
    func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        // Handle button touch ended
    }
    
    func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        // Handle button touch moved
    }
}

extension SkinController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
}
