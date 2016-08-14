//
//  Game.swift
//  Pong2
//
//  Created by Toma Alexandru on 11/08/2016.
//  Copyright © 2016 bart games. All rights reserved.
//

import SpriteKit

let π: CGFloat = CGFloat(M_PI)
let GAME_WIN_SCORE = 7

protocol GameDelegate {
    func roundStarted()
    func roundEnded(winningSide: PlayerSide)
    func gameEnded(winningSide: PlayerSide)
    func gameReseted()
    func ballHitWall()
    func ballHitPlayer()
    func gamePaused()
    func gameResumed()
    func returnMenu()
}

class Game {
    var ball: Ball
    var players: [Player] = []
    var delegate: GameDelegate!
    var running: Bool = false
    var lastWin: PlayerSide? = nil
    var paused: Bool = false
    var gameOption: GameOption
    
    convenience init(option: GameOption) {
        var vsAI: Bool = false
        var name2: String = ""
        
        switch option {
        case .Play: vsAI = false; name2 = "Player 2"
        case .AI: vsAI = true; name2 = "AI"
        }
        
        self.init(name1: "Player 1", name2: name2, vsAI: vsAI, gameOption: option)
    }
    
    init(name1: String, name2: String, vsAI: Bool, gameOption: GameOption) {
        self.gameOption = gameOption
        ball = Ball()
        players.append(PlayerHuman(name: name1, side: PlayerSide.Left))
        players.append(vsAI ?
                        PlayerAI(name: name2, side: PlayerSide.Right) :
                        PlayerHuman(name: name2, side: PlayerSide.Right))
    }
    
    func setDelegate(delegate: GameDelegate) {
        self.delegate = delegate
        ball.gameDelegate = delegate
    }
    
    func reset() {
        running = false
        paused = false
        lastWin = nil
        _ = players.map({$0.reset(); $0.resetTouchZone()})
        ball.reset()
    }
    
    func pause() {
        ball.stop()
        _ = players.map({$0.canMove = false})
        paused = true
    }
    
    func resume() {
        ball.resume()
        _ = players.map({$0.canMove = true})
        paused = false
    }
    
    func roundStart() {
        running = true
        _ = players.map({$0.canMove = true; $0.resetTouchZone()})
        ball.reset()
        ball.start(lastWin)
        delegate.roundStarted()
    }
    
    func touch(touches: Set<UITouch>, scene: SKScene) {
        guard !paused else {
            return
        }
        
        if gameEnded() {
            delegate.gameReseted()
        } else if !running {
            if let oppositeSide = lastWin?.getOpposite() {
                var oppositePlayer = getPlayerFromSide(oppositeSide)
                
                if let humanPlayer = getHumanPlayer()
                where gameOption == GameOption.AI {
                    oppositePlayer = humanPlayer
                }
                
                for touch in touches {
                    if scene.nodeAtPoint(touch.locationInNode(scene)) == oppositePlayer.touchZone {
                        roundStart()
                    }
                }
            } else {
                roundStart()
            }
        }
    }
    
    func getHumanPlayer() -> Player? {
        for player in players {
            if player is PlayerHuman {
                return player
            }
        }
        
        return nil
    }
    
    func getAIPlayer() -> Player? {
        for player in players {
            if player is PlayerAI {
                return player
            }
        }
        
        return nil
    }
    
    func gameEnded() -> Bool {
        for player in players {
            if player.score >= GAME_WIN_SCORE {
                return true
            }
        }
 
        return false
    }
    
    func getPlayerFromSide(side: PlayerSide) -> Player {
        return players[side == PlayerSide.Left ? 0 : 1]
    }
    
    func endGame(side: PlayerSide) {
        let winningPlayer = getPlayerFromSide(side)
        let oppositePlayer = getPlayerFromSide(side.getOpposite())
        ball.stop()
        winningPlayer.setWinningTouchZone()
        oppositePlayer.setLosingTouchZone()
        _ = players.map({$0.canMove = false})
    }
    
    func update(deltaTime: CGFloat, scene: SKScene) {
        ball.move(deltaTime: deltaTime, scene: scene)
        
        if let playerAI = getAIPlayer()
        where gameOption == GameOption.AI {
            let playerAI = playerAI as! PlayerAI
            playerAI.move(ball)
        }
    }
    
    func endRound(side: PlayerSide) {
        let player = getPlayerFromSide(side)
        var oppositePlayer = getPlayerFromSide(side.getOpposite())
        player.score += 1
        running = false
        lastWin = side
        
        if let humanPlayer = getHumanPlayer()
            where gameOption == GameOption.AI {
            oppositePlayer = humanPlayer
        }
        
        oppositePlayer.highlighTouchZone()
        
        if gameEnded() {
            delegate.gameEnded(side)
        } else {
            ball.reset()
        }
    }
}