//
//  Scoreboard.swift
//  Pong2
//
//  Created by Toma Alexandru on 12/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let SCOREBOARD_SIZE = CGSize(width: 3, height: 32)
let SCOREBOARD_OFFSET: CGFloat = 20
let WIN_LABEL_SIZE: CGFloat = 50
let SCOREBOARD_EXTRA_TOUCH: CGFloat = 40

class ScoreBoard {
    let playerLeftScore = SKLabelNode(text: "0")
    let playerRightScore = SKLabelNode(text: "0")
    let verticalBar = SKSpriteNode(color: UIColor.white, size: SCOREBOARD_SIZE)
    let scoreBoard = SKNode()
    let winLabel = SKLabelNode()
    
    var gameDelegate: GameDelegate!
    
    init(scene: SKScene) {
        winLabel.fontSize = WIN_LABEL_SIZE
        winLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        winLabel.horizontalAlignmentMode = .center
        winLabel.verticalAlignmentMode = .center
        winLabel.isHidden = true
        
        scoreBoard.addChild(playerLeftScore)
        scoreBoard.addChild(verticalBar)
        scoreBoard.addChild(playerRightScore)
        scoreBoard.position = CGPoint(x: scene.frame.midX - verticalBar.frame.width / 2,
                                      y: scene.frame.maxY - SCOREBOARD_OFFSET)
        setPlayerScoreNode(playerLeftScore, side: PlayerSide.left)
        setPlayerScoreNode(playerRightScore, side: PlayerSide.right)
        
        scene.addChild(scoreBoard)
        scene.addChild(winLabel)
    }
    
    func press(_ touch: UITouch) {
        guard let scene = scoreBoard.scene else {
            return
        }
        
        var touchRect = scoreBoard.calculateAccumulatedFrame()
        let newWidth = touchRect.width + SCOREBOARD_EXTRA_TOUCH
        let newHeight = touchRect.height + SCOREBOARD_EXTRA_TOUCH
        touchRect = CGRect(x: touchRect.minX - SCOREBOARD_EXTRA_TOUCH / 2,
                           y: touchRect.minY - SCOREBOARD_EXTRA_TOUCH / 2,
                           width: newWidth, height: newHeight)
        if touchRect.contains(touch.location(in: scene)) {
            gameDelegate.gamePaused()
        }
    }
    
    func presentWinner(_ name: String) {
        winLabel.isHidden = false
        winLabel.text = "\(name) has won!"
    }
    
    func hideWinLabel() {
        winLabel.isHidden = true
    }
    
    func setScore(_ side: PlayerSide, score: Int) {
        if side == PlayerSide.left {
            playerLeftScore.text = String(score)
        } else {
            playerRightScore.text = String(score)
        }
    }
    
    func setPlayerScoreNode(_ score: SKLabelNode, side: PlayerSide) {
        score.position = CGPoint(x: score.frame.width * (side == PlayerSide.left ? -1 : 1), y: 0)
        score.fontName = "AvenirNext-Bold"
        score.verticalAlignmentMode = .center
        score.horizontalAlignmentMode = .center
        score.name = side.description.lowercased()
    }
}
