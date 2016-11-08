//
//  GameScene.swift
//  Pong2
//
//  Created by Toma Alexandru on 11/08/2016.
//  Copyright (c) 2016 bart games. All rights reserved.
//

import SpriteKit

enum GameOption: Int {
    case play = 0, ai
}

class GameScene: SKScene, GameDelegate {
    let ping = SKAction.playSoundFileNamed("ping.wav", waitForCompletion: false)
    var game: Game!
    var scoreBoard: ScoreBoard!
    var pauseMenu: PauseMenu!
    var lastTime: CFTimeInterval!
    var gvcDelegate: GameViewControllerDelegate!
    var option: GameOption!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y: 0.5)
        
        game = Game(option: option)
        game.setDelegate(self)
        game.ball.setSprite(self)
        _ = game.players.map({$0.setSprite(self); $0.setTouchZone(self)})
        scoreBoard = ScoreBoard(scene: self)
        scoreBoard.gameDelegate = self
        pauseMenu = PauseMenu(scene: self, delegate: self)
    }
   
    override func update(_ currentTime: TimeInterval) {
        guard let lastTime = lastTime else {
            self.lastTime = currentTime
            return
        }
        
        let deltaTime: CGFloat = CGFloat(currentTime - lastTime)
        game.update(deltaTime, scene: self)
        
        self.lastTime = currentTime
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for player in game.players {
            guard player is PlayerHuman else {
                continue
            }
            
            let player = player as! PlayerHuman
            
            for touch in touches {
                if atPoint(touch.previousLocation(in: self)) == player.touchZone && player.canMove {
                    player.moveTo(touch.location(in: self))
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else {
            return
        }
        
        if game.paused {
            pauseMenu.release(firstTouch)
        }
    }
    
    // game delgate functions
    func ballHitWall() {
        scene?.run(ping)
    }
    
    func ballHitPlayer() {
        scene?.run(ping)
    }
    
    func roundStarted() {
        scoreBoard.hideWinLabel()
    }
    
    func roundEnded(_ winningSide: PlayerSide) {
        game.endRound(winningSide)
        scoreBoard.setScore(winningSide,
                            score: game.players[winningSide == PlayerSide.left ? 0 : 1].score)
    }
    
    func gameEnded(_ winningSide: PlayerSide) {
        scoreBoard.presentWinner(game.players[winningSide == PlayerSide.left ? 0 : 1].name)
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
