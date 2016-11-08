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
    func roundEnded(_ winningSide: PlayerSide)
    func gameEnded(_ winningSide: PlayerSide)
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
        case .play: vsAI = false; name2 = "Player 2"
        case .ai: vsAI = true; name2 = "AI"
        }
        
        self.init(name1: "Player 1", name2: name2, vsAI: vsAI, gameOption: option)
    }
    
    init(name1: String, name2: String, vsAI: Bool, gameOption: GameOption) {
        self.gameOption = gameOption
        ball = Ball()
        players.append(PlayerHuman(name: name1, side: PlayerSide.left))
        players.append(vsAI ?
                        PlayerAI(name: name2, side: PlayerSide.right) :
                        PlayerHuman(name: name2, side: PlayerSide.right))
    }
    
    func setDelegate(_ delegate: GameDelegate) {
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
    
    func touch(_ touches: Set<UITouch>, scene: SKScene) {
        guard !paused else {
            return
        }
        
        if gameEnded() {
            delegate.gameReseted()
        } else if !running {
            if let oppositeSide = lastWin?.getOpposite() {
                var oppositePlayer = getPlayerFromSide(oppositeSide)
                
                if let humanPlayer = getHumanPlayer()
                , gameOption == GameOption.ai {
                    oppositePlayer = humanPlayer
                }
                
                for touch in touches {
                    if scene.atPoint(touch.location(in: scene)) == oppositePlayer.touchZone {
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
    
    func getPlayerFromSide(_ side: PlayerSide) -> Player {
        return players[side == PlayerSide.left ? 0 : 1]
    }
    
    func endGame(_ side: PlayerSide) {
        let winningPlayer = getPlayerFromSide(side)
        let oppositePlayer = getPlayerFromSide(side.getOpposite())
        ball.stop()
        winningPlayer.setWinningTouchZone()
        oppositePlayer.setLosingTouchZone()
        _ = players.map({$0.canMove = false})
    }
    
    func update(_ deltaTime: CGFloat, scene: SKScene) {
        ball.move(deltaTime: deltaTime, scene: scene)
        
        if let playerAI = getAIPlayer()
        , gameOption == GameOption.ai {
            let playerAI = playerAI as! PlayerAI
            playerAI.move(ball)
        }
    }
    
    func endRound(_ side: PlayerSide) {
        let player = getPlayerFromSide(side)
        var oppositePlayer = getPlayerFromSide(side.getOpposite())
        player.score += 1
        running = false
        lastWin = side
        
        if let humanPlayer = getHumanPlayer()
            , gameOption == GameOption.ai {
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
