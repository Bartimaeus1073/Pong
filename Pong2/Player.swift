//
//  Player.swift
//  Pong2
//
//  Created by Toma Alexandru on 11/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let PLAYER_SIZE = CGSize(width: 20, height: 100)
let PLAYER_OFFSET: CGFloat = 20
let PLAYER_TOUCHZONE_OFFSET: CGFloat = 100
let PLAYER_TOUCHZONE_DEFAULT: UIColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
let PLAYER_TOUCHZONE_HIGHLIGHT: UIColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.1)
let PLAYER_TOUCHZONE_WIN: UIColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.2)
let PLAYER_TOUCHZONE_LOSE: UIColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.2)

enum PlayerSide: Int, CustomStringConvertible {
    case left = 0, right
    
    var description: String {
        switch self {
            case .left: return "Left"
            case .right: return "Right"
        }
    }
    
    func getOpposite() -> PlayerSide {
        return self == PlayerSide.left ? PlayerSide.right : PlayerSide.left
    }
}

func clamp(_ value: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
    var newValue = value
    newValue = max(newValue, minVal)
    newValue = min(newValue, maxVal)
    
    return newValue
}

class Player: CustomStringConvertible {
    var name: String
    var score: Int = 0
    var sprite: SKSpriteNode!
    var side: PlayerSide
    var touchZone: SKSpriteNode!
    var canMove: Bool = false
    
    var description: String {
        return "\(side): \(sprite.position)"
    }
    
    init(name: String, side: PlayerSide) {
        self.name = name
        self.side = side
    }
    
    func reset() {
        score = 0
        sprite.position.y = touchZone.frame.midY
    }
    
    func setSprite(_ scene: SKScene) {
        let xPos: CGFloat = side == PlayerSide.left ?
                                scene.frame.minX + PLAYER_OFFSET :
                                scene.frame.maxX - PLAYER_OFFSET - PLAYER_SIZE.width
        
        sprite = SKSpriteNode(color: UIColor.white, size: PLAYER_SIZE)
        sprite.name = side.description.lowercased()
        sprite.position = CGPoint(x: xPos, y: scene.frame.midY)
        sprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        scene.addChild(sprite)
    }
    
    func setTouchZone(_ scene: SKScene) {
        let touchZoneX = side == PlayerSide.left ? scene.frame.minX : scene.frame.maxX
        touchZone = SKSpriteNode()
        touchZone.position = CGPoint(x: touchZoneX, y: scene.frame.minY)
        touchZone.size = CGSize(width: scene.frame.width / 2 - PLAYER_TOUCHZONE_OFFSET,
                                    height: scene.frame.height)
        touchZone.anchorPoint = CGPoint(x: side == PlayerSide.left ? 0 : 1, y: 0)
        resetTouchZone()
        
        scene.addChild(touchZone)
    }
    
    func highlighTouchZone() {
        touchZone.color = PLAYER_TOUCHZONE_HIGHLIGHT
    }
    
    func resetTouchZone() {
        touchZone.color = PLAYER_TOUCHZONE_DEFAULT
    }
    
    func setWinningTouchZone() {
        touchZone.color = PLAYER_TOUCHZONE_WIN
    }
    
    func setLosingTouchZone() {
        touchZone.color = PLAYER_TOUCHZONE_LOSE
    }
}
