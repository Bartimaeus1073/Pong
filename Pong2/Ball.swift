//
//  Ball.swift
//  Pong2
//
//  Created by Toma Alexandru on 11/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit
import Darwin

let BALL_SIZE = CGSize(width: 13, height: 13)
let BALL_RANDOM_SEED: UInt32 = 500
let BALL_SPEED: CGFloat = 500
let BALL_MIN_SPEED: CGFloat = 300
let BALL_CLAMP_X: CGFloat = 0.5
let BALL_CLAMP_Y: CGFloat = 0.5
let BALL_SPEED_MODIFIER_PLAYER_HIT: CGFloat = 75
let BALL_SPEED_MODIFIER_WALL_HIT: CGFloat = 20
let BALL_HIT_PLAYER_MAX_ANGLE: CGFloat = 0.38 * π

// 0 is positive
func sign(_ value: CGFloat) -> CGFloat {
    return value < 0 ? -1 : 1
}

extension CGVector {
    func magnitude() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    func normalise() -> CGVector {
        let m = magnitude()
        
        return CGVector(dx: dx / m, dy: dy / m)
    }
}

class Collision {
    // checks collision between obj1 and obj2
    static func isColliding(_ obj1: SKNode, obj2: SKNode) -> Bool {
        return obj1.intersects(obj2)
    }
    
    static func isCollidingBounds(_ obj: SKNode, bounds: SKNode) -> Bool {
        return  obj.frame.maxX > bounds.frame.maxX ||
                obj.frame.minX < bounds.frame.minX ||
                obj.frame.maxY > bounds.frame.maxY ||
                obj.frame.minY < bounds.frame.minY
    }
    
    static func traceBack(_ velocity: CGVector, obj1: SKNode, obj2: SKNode) {
        guard isColliding(obj1, obj2: obj2) else {
            return
        }
        
        let invertedVelocity = CGVector(dx: -velocity.dx, dy: -velocity.dy)
        
        while Collision.isColliding(obj1, obj2: obj2) {
            obj1.position.x += invertedVelocity.dx
            obj1.position.y += invertedVelocity.dy
        }
    }
    
    static func traceBackBounds(_ velocity: CGVector, obj: SKNode, bounds: SKNode) {
        let invertedVelocity = CGVector(dx: -velocity.dx, dy: -velocity.dy)
        
        while Collision.isCollidingBounds(obj, bounds: bounds) {
            obj.position.x += invertedVelocity.dx
            obj.position.y += invertedVelocity.dy
        }
    }
}

class Ball: CustomStringConvertible {
    var velocity: CGVector = CGVector.zero
    var speed: CGFloat = 0
    var sprite: SKSpriteNode!
    var bounds: SKNode!
    var gameDelegate: GameDelegate!
    var oldVelocity: CGVector = CGVector.zero
    
    init() {
        speed = BALL_SPEED
    }
    
    var description: String {
        return "Position: \(sprite.position)\nVelocity: \(velocity)"
    }
    
    func randomVelocity(_ side: PlayerSide?) {
        var dx: CGFloat
        var dy: CGFloat
        let random = {return CGFloat(arc4random_uniform(BALL_RANDOM_SEED)) - CGFloat(BALL_RANDOM_SEED / 2)}
        
        repeat {
            dx = random()
            dy = random()
        } while dx == 0 && dy == 0
        
        var newVelocity = CGVector(dx: dx, dy: dy).normalise()
        
        if newVelocity.dx > -BALL_CLAMP_X && newVelocity.dx < BALL_CLAMP_X {
            newVelocity.dx += newVelocity.dx > 0 ? BALL_CLAMP_X : -BALL_CLAMP_X
        }
        
        newVelocity.dy = clamp(newVelocity.dy, minVal: -BALL_CLAMP_Y, maxVal: BALL_CLAMP_Y)
        newVelocity = newVelocity.normalise()
        
        if let side = side {
            if side == PlayerSide.left && newVelocity.dx > 0 ||
                    side == PlayerSide.right && newVelocity.dx < 0 {
                newVelocity.dx = -newVelocity.dx
            }
        }
        
        velocity = newVelocity
    }
    
    func setSprite(_ scene: SKScene) {
        sprite = SKSpriteNode(color: UIColor.white, size: BALL_SIZE)
        sprite.name = "ball"
        sprite.position = CGPoint(x: scene.frame.midX - BALL_SIZE.width / 2,
                                  y: scene.frame.midY - BALL_SIZE.height / 2)
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        sprite.zPosition = 0
        bounds = scene
        
        scene.addChild(sprite)
    }
    
    func start(_ side: PlayerSide?) {
        randomVelocity(side)
    }
    
    func resume() {
        velocity = oldVelocity
    }
    
    func stop() {
        oldVelocity = velocity
        velocity = CGVector.zero
    }
    
    func reset() {
        speed = BALL_SPEED
        sprite.position = CGPoint(x: bounds.frame.midX - BALL_SIZE.width / 2,
                                    y: bounds.frame.midY - BALL_SIZE.height / 2)
        stop()
    }
    
    func ballHitSide() -> PlayerSide? {
        if sprite.frame.minX < bounds.frame.minX {
            return .right
        }
        
        if sprite.frame.maxX > bounds.frame.maxX {
            return .left
        }
        
        return nil
    }
    
    func move(deltaTime dt: CGFloat, scene: SKScene) {
        sprite.position.x += velocity.dx * dt * speed
        sprite.position.y += velocity.dy * dt * speed
        
        // colide bounds
        if Collision.isCollidingBounds(sprite, bounds: bounds) {
            let winningSide = ballHitSide()
            gameDelegate.ballHitWall()
            Collision.traceBackBounds(velocity, obj: sprite, bounds: bounds)
            if let winningSide = winningSide {
                gameDelegate.roundEnded(winningSide)
            }
            velocity.dy = -velocity.dy
            speed += BALL_SPEED_MODIFIER_WALL_HIT
            return
        }
        
        // colide players
        let player1 = scene.childNode(withName: "left") as! SKSpriteNode
        let player2 = scene.childNode(withName: "right") as! SKSpriteNode
        
        if Collision.isColliding(sprite, obj2: player1) ||
                    Collision.isColliding(sprite, obj2: player2) {
            let player = Collision.isColliding(sprite, obj2: player1) ? player1 : player2
            
            let relativeY = -(player.frame.midY - sprite.frame.midY) /
                                    (player.frame.height / 2 + sprite.frame.height)
            let oldVelocity = velocity
            
            velocity.dx = -sign(velocity.dx) * cos(relativeY * BALL_HIT_PLAYER_MAX_ANGLE)
            velocity.dy = sin(relativeY * BALL_HIT_PLAYER_MAX_ANGLE)
            
            let speedMultiplier = abs(relativeY) - 0.25
            speed += speedMultiplier * BALL_SPEED_MODIFIER_PLAYER_HIT
            if speed < BALL_MIN_SPEED {
                speed = BALL_MIN_SPEED
            }
            
            Collision.traceBack(oldVelocity, obj1: sprite, obj2: player)
            gameDelegate.ballHitPlayer()
        }
    }
}
