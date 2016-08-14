//
//  PlayerHuman.swift
//  Pong
//
//  Created by Toma Alexandru on 13/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

class PlayerHuman: Player {
    func moveTo(location: CGPoint) {
        sprite.position.y = clamp(location.y, minVal: touchZone.frame.minY + sprite.frame.height / 2,
                                  maxVal: touchZone.frame.maxY - sprite.frame.height / 2)
    }
}