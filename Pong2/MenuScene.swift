//
//  MenuScene.swift
//  Pong
//
//  Created by Toma Alexandru on 13/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let MENU_TITLTE_OFFSET: CGFloat = 50

class MenuScene: SKScene {
    var title: SKLabelNode!
    var playButton: Button!
    var AIButton: Button!
    var gvcDelegate: GameViewControllerDelegate!
    
    func setTitle() {
        title = SKLabelNode(fontNamed: "Arial-Bold")
        title.text = "Pong"
        title.color = UIColor.white
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.fontSize = 50
        title.position = CGPoint(x: frame.midX, y: frame.maxY - MENU_TITLTE_OFFSET)
        
        addChild(title)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.black
        
        setTitle()
        playButton = Button(scene: self, text: "Play",
                            x: frame.midX, y: frame.midY,
                            action: gvcDelegate.changeSceneToGameSceneWithPlayOption)
        AIButton = Button(scene: self, text: "AI",
                            x: frame.midX, y: frame.midY - (DEFAULT_BUTTON_SIZE.height + BUTTON_DISTANCE),
                            action: gvcDelegate.changeSceneToGameSceneWithAIOption)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        playButton.press(firstTouch)
        AIButton.press(firstTouch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        playButton.release(firstTouch)
        AIButton.release(firstTouch)
    }
}
