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
        changeSceneToGameScene(GameOption.Play)
    }
    
    func changeSceneToGameSceneWithAIOption() {
        changeSceneToGameScene(GameOption.AI)
    }
    
    func changeSceneToGameScene(option: GameOption) {
        let skView = view as! SKView
        
        currentScene = GameScene(size: skView.bounds.size)
        currentScene.scaleMode = .AspectFill
        
        let scene = currentScene as! GameScene
        scene.gvcDelegate = self
        scene.option = option
        
        skView.presentScene(currentScene)
    }
    
    func changeSceneToMenuScene() {
        let skView = view as! SKView
        
        currentScene = MenuScene(size: skView.bounds.size)
        currentScene.scaleMode = .AspectFill
        
        let scene = currentScene as! MenuScene
        scene.gvcDelegate = self
        
        skView.presentScene(currentScene)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
