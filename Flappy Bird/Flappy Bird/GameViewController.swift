//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by i-Techsys.com on 16/12/10.
//  Copyright © 2016年 i-Techsys. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


class GameViewController: UIViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let sk视图 = self.view as? SKView {
            if sk视图.scene == nil {
                //  创建场景
                let 长宽比 = sk视图.bounds.size.height / sk视图.bounds.size.width
                let 场景 = GameScene(size:CGSize(width: 320, height: 320 * 长宽比))
                sk视图.showsFPS = true
                sk视图.showsNodeCount = true
                sk视图.showsPhysics = true
                sk视图.ignoresSiblingOrder = true
                
                场景.scaleMode = .aspectFill
                
                sk视图.presentScene(场景)
            }
        }
    }

}

//class GameViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if let view = self.view as! SKView? {
//            if let scene = SKScene(fileNamed: "GameScene") {
//                scene.scaleMode = .aspectFill
//                view.presentScene(scene)
//            }
//            
//            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
//            view.ignoresSiblingOrder = true
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Release any cached data, images, etc that aren't in use.
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//}
