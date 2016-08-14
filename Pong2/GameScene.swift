//
//  GameScene.swift
//  Pong2
//
//  Created by Toma Alexandru on 11/08/2016.
//  Copyright (c) 2016 bart games. All rights reserved.
//

import SpriteKit

enum GameOption: Int {
    case Play = 0, AI
}

class GameScene: SKScene, GameDelegate {
    let ping = SKAction.playSoundFileNamed("ping.wav", waitForCompletion: false)
    var game: Game!
    var scoreBoard: ScoreBoard!
    var pauseMenu: PauseMenu!
    var lastTime: CFTimeInterval!
    var gvcDelegate: GameViewControllerDelegate!
    var option: GameOption!
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        anchorPoint = CGPoint(x: 0, y: 0.5)
        
        game = Game(option: option)
        game.setDelegate(self)
        game.ball.setSprite(self)
        _ = game.players.map({$0.setSprite(self); $0.setTouchZone(self)})
        scoreBoard = ScoreBoard(scene: self)
        scoreBoard.gameDelegate = self
        pauseMenu = PauseMenu(scene: self, delegate: self)
    }
   
    override func update(currentTime: CFTimeInterval) {
        guard let lastTime = lastTime else {
            self.lastTime = currentTime
            return
        }
        
        let deltaTime: CGFloat = CGFloat(currentTime - lastTime)
        game.update(deltaTime, scene: self)
        
        self.lastTime = currentTime
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        if !game.paused {
            scoreBoard.press(firstTouch)
            game.touch(touches, scene: self)
        } else {
            pauseMenu.touch(firstTouch)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for player in game.players {
            guard player is PlayerHuman else {
                continue
            }
            
            let player = player as! PlayerHuman
            
            for touch in touches {
                if nodeAtPoint(touch.previousLocationInNode(self)) == player.touchZone && player.canMove {
                    player.moveTo(touch.locationInNode(self))
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        if game.paused {
            pauseMenu.release(firstTouch)
        }
    }
    
    // game delgate functions
    func ballHitWall() {
        scene?.runAction(ping)
    }
    
    func ballHitPlayer() {
        scene?.runAction(ping)
    }
    
    func roundStarted() {
        scoreBoard.hideWinLabel()
    }
    
    func roundEnded(winningSide: PlayerSide) {
        game.endRound(winningSide)
        scoreBoard.setScore(winningSide,
                            score: game.players[winningSide == PlayerSide.Left ? 0 : 1].score)
    }
    
    func gameEnded(winningSide: PlayerSide) {
        scoreBoard.presentWinner(game.players[winningSide == PlayerSide.Left ? 0 : 1].name)
        game.endGame(winningSide)
    }
    
    func gameReseted() {
        pauseMenu.hide()
        game.reset()
        scoreBoard.hideWinLabel()
        _ = game.players.map({scoreBoard.setScore($0.side, score: $0.score)})
    }
    
    func gamePaused() {
        pauseMenu.show()
        game.pause()
    }
    
    func gameResumed() {
        pauseMenu.hide()
        game.resume()
    }
    
    func returnMenu() {
        gvcDelegate.changeSceneToMenuScene()
    }
}
