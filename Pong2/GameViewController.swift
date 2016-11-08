//
//  GameViewController.swift
//  Pong2
//
//  Created by Toma Alexandru on 11/08/2016.
//  Copyright (c) 2016 bart games. All rights reserved.
//

import UIKit
import SpriteKit

protocol GameViewControllerDelegate {
    func changeSceneToGameSceneWithPlayOption()
    func changeSceneToGameSceneWithAIOption()
    func changeSceneToMenuScene()
}

class GameViewController: UIViewController, GameViewControllerDelegate {
    var currentScene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeSceneToMenuScene()
    }
    
    func changeSceneToGameSceneWithPlayOption() {
        changeSceneToGameScene(GameOption.play)
    }
    
    func changeSceneToGameSceneWithAIOption() {
        changeSceneToGameScene(GameOption.ai)
    }
    
    func changeSceneToGameScene(_ option: GameOption) {
        let skView = view as! SKView
        
        currentScene = GameScene(size: skView.bounds.size)
        currentScene.scaleMode = .aspectFill
        
        let scene = currentScene as! GameScene
        scene.gvcDelegate = self
        scene.option = option
        
        skView.presentScene(currentScene)
    }
    
    func changeSceneToMenuScene() {
        let skView = view as! SKView
        
        currentScene = MenuScene(size: skView.bounds.size)
        currentScene.scaleMode = .aspectFill
        
        let scene = currentScene as! MenuScene
        scene.gvcDelegate = self
        
        skView.presentScene(currentScene)
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
