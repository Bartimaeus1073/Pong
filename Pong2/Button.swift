//
//  Button.swift
//  Pong
//
//  Created by Toma Alexandru on 13/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let DEFAULT_BUTTON_SIZE = CGSize(width: 200, height: 50)
let BUTTON_HIGHLIGHT_ALPHA: CGFloat = 0.5
let BUTTON_DEFAULT_ALPHA: CGFloat = 0.8

class Button {
    var background: SKSpriteNode!
    var textLabel: SKLabelNode!
    var action: () -> ()
    var scene: SKScene
    var isPressed: Bool = false
    
    convenience init(scene: SKScene, text: String, x: CGFloat, y: CGFloat, action: @escaping () -> ()) {
        self.init(scene: scene, parent: scene, text: text, x: x, y: y, action: action)
    }
    
    init(scene: SKScene, parent: SKNode, text: String, x: CGFloat, y: CGFloat, action: @escaping () -> ()) {
        self.scene = scene
        self.action = action
        setSprite(parent, x: x, y: y)
        setText(text)
    }
    
    func touched(_ location: CGPoint) -> Bool {
        for node in scene.nodes(at: location) {
            if node ==  background {
                return true
            }
        }
        
        return false
    }
    
    func press(_ touch: UITouch) {
        if touched(touch.location(in: scene)) {
            background.alpha = BUTTON_HIGHLIGHT_ALPHA
            isPressed = true
        }
    }
    
    func release(_ touch: UITouch) {
        if touched(touch.location(in: scene)) && isPressed {
            action()
            isPressed = false
        }
        
        background.alpha = BUTTON_DEFAULT_ALPHA
    }
    
    func setText(_ text: String) {
        textLabel.text = text
    }
    
    func setSprite(_ parent: SKNode, x: CGFloat, y: CGFloat) {
        background = SKSpriteNode()
        background.color = UIColor.white
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: x, y: y)
        background.size = DEFAULT_BUTTON_SIZE
        background.zPosition = 1
        background.alpha = BUTTON_DEFAULT_ALPHA
        
        textLabel = SKLabelNode()
        textLabel.position = CGPoint(x: 0, y: 0)
        textLabel.fontColor = UIColor.black
        textLabel.zPosition = 2
        textLabel.horizontalAlignmentMode = .center
        textLabel.verticalAlignmentMode = .center
        
        background.addChild(textLabel)
        parent.addChild(background)
    }
}
