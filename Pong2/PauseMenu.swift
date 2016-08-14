//
//  PauseMenu.swift
//  Pong
//
//  Created by Toma Alexandru on 13/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let BUTTON_DISTANCE: CGFloat = 15
let BACKGROUND_COLOR = UIColor(red: 255, green: 255, blue: 255, alpha: 0.2)

class PauseMenu {
    let resumeButton: Button
    let resetButton: Button
    let menuButton: Button
    let root: SKNode = SKNode()
    let gameDelegate: GameDelegate
    let background: SKSpriteNode
    
    init(scene: SKScene, delegate: GameDelegate) {
        self.gameDelegate = delegate
        root.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        root.zPosition = 5
        
        resumeButton = Button(scene: scene, parent: root, text: "Resume",
                              x: 0, y: DEFAULT_BUTTON_SIZE.height + BUTTON_DISTANCE,
                              action: gameDelegate.gameResumed)
        resetButton = Button(scene: scene, parent: root, text: "Reset",
                              x: 0, y: 0, action: gameDelegate.gameReseted)
        menuButton = Button(scene: scene, parent: root, text: "Menu",
                              x: 0, y: -(DEFAULT_BUTTON_SIZE.height + BUTTON_DISTANCE),
                              action: gameDelegate.returnMenu)
        background = SKSpriteNode()
        background.size = scene.size
        background.position = CGPoint(x: 0, y: 0)
        background.color = BACKGROUND_COLOR
        
        root.addChild(background)
        
        hide()
        scene.addChild(root)
    }
    
    func touch(touch: UITouch) {
        resumeButton.press(touch)
        resetButton.press(touch)
        menuButton.press(touch)
    }
    
    func release(touch: UITouch) {
        resumeButton.release(touch)
        resetButton.release(touch)
        menuButton.release(touch)
    }
    
    func hide() {
        root.hidden = true
    }
    
    func show() {
        root.hidden = false
    }
}