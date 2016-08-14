//
//  PlayerAI.swift
//  Pong
//
//  Created by Toma Alexandru on 13/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class PlayerAI: Player {
    func move(ball: Ball) {
        sprite.position.y = ball.sprite.frame.midY
        
        sprite.position.y = clamp(sprite.position.y,
                                  minVal: touchZone.frame.minY + sprite.frame.height / 2,
                                  maxVal: touchZone.frame.maxY - sprite.frame.height / 2)
    }
}