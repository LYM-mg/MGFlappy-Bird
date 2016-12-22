//
//  GameScene.swift
//  Flappy Bird
//
//  Created by i-Techsys.com on 16/12/10.
//  Copyright © 2016年 i-Techsys. All rights reserved.
// //  多边形工具 - http://stackoverflow.com/questions/19040144  Skite

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: - 属性
    let 游戏世界 = SKNode()
    var 游戏区域起始点: CGFloat = 0
    var 游戏区域的高度: CGFloat = 0
    let 主角 = SKSpriteNode(imageNamed: "Bird0")
    let 帽子🎩 = SKSpriteNode(imageNamed: "Sombrero")

    // MARK: - 变动属性
    var 上一次更新时间: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let k重力: CGFloat = -400.0
    let k上冲速度: CGFloat = 200
    var 速度 = CGPoint.zero
    let k前景地面数 = 2
    let k前景移动速度: CGFloat = -150.0
    let k底部障碍物的最小乘数: CGFloat = 0.1
    let k底部障碍物的最大乘数: CGFloat = 0.6
    let k缺口参数:  CGFloat = 3.5
    let k首次生成障碍延迟时间: TimeInterval = 1.75
    let k每次生成障碍延迟时间: TimeInterval = 1.5
    
    let k留白: CGFloat = 20
    let k字体名字 = "AmericanTypewriter-Bold"
    var 得分标签: SKLabelNode!
    var 当前分数 = 0
    let k动画延迟 = 0.3
    let k角色动画总帧数 = 4
    
    var 主角撞击了地面布尔类型: Bool = false
    var 主角撞击了障碍物布尔类型: Bool = false
    var 当前游戏状态: 游戏状态 = .主菜单
    
    // MARK: - 创建音效
    let 叮的音效 = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let 拍打的音效 = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let 摔倒的音效 = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let 下落的音效 = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let 撞击地面的音效 = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let 砰的音效 = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let 得分的音效 = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // 设置物理引擎代理
        physicsWorld.contactDelegate = self
        
        // 关掉重力
        physicsWorld.gravity = CGVector.zero
        
        addChild(游戏世界)
        
        切换到主菜单()
    }
    
    // MARK: - 游戏流程
    fileprivate func 创建障碍物(_ 图片名: String) -> SKSpriteNode {
        let 障碍物 = SKSpriteNode(imageNamed: 图片名)
        障碍物.zPosition = 图层.障碍物.rawValue
        障碍物.userData = NSMutableDictionary()
        
        let offsetX = 障碍物.size.width * 障碍物.anchorPoint.x
        let offsetY = 障碍物.size.height * 障碍物.anchorPoint.y
        let path = CGMutablePath()
        path.move(to: CGPoint(x:  4 - offsetX, y: 0 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  7 - offsetX, y: 307 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  47 - offsetX, y: 308 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  48 - offsetX, y: 1 - offsetY), transform: CGAffineTransform.identity)
        path.closeSubpath()
        
        障碍物.physicsBody = SKPhysicsBody(polygonFrom: path)
        障碍物.physicsBody?.categoryBitMask = 物理层.障碍物
        障碍物.physicsBody?.collisionBitMask = 0
        障碍物.physicsBody?.contactTestBitMask = 物理层.游戏角色
        
        return 障碍物
    }
    
    fileprivate func 生成障碍物() {
        let 底部障碍物 = 创建障碍物("CactusBottom")
        底部障碍物.name = "底部障碍物"
        let 起始X坐标 = size.width + 底部障碍物.size.width/2
        let Y最小坐标 = (游戏区域起始点 - 底部障碍物.size.height/2) + 游戏区域的高度*k底部障碍物的最小乘数
        let Y最大坐标 = (游戏区域起始点 - 底部障碍物.size.height/2) + 游戏区域的高度*k底部障碍物的最大乘数
        
        底部障碍物.position = CGPoint(x: 起始X坐标, y: CGFloat.random(min: Y最小坐标, max: Y最大坐标))
        游戏世界.addChild(底部障碍物)
        
        let 顶部障碍物 = 创建障碍物("CactusTop")
        顶部障碍物.name = "顶部障碍物"
        顶部障碍物.zPosition = CGFloat(180).degreesToRadians()
        顶部障碍物.position = CGPoint(x: 起始X坐标, y: 底部障碍物.position.y + 底部障碍物.size.height/2 + 顶部障碍物.size.height/2 + 主角.size.height*k缺口参数)
        游戏世界.addChild(顶部障碍物)
        
        let X轴移动距离 = -(size.width + 底部障碍物.size.width)
        let 移动持续时间 = X轴移动距离 / k前景移动速度
        
        let 移动的动作序列 = SKAction.sequence([
            SKAction.moveBy(x: X轴移动距离, y: 0, duration: TimeInterval(移动持续时间)),
            SKAction.removeFromParent()
        ])
        底部障碍物.run(移动的动作序列)
        顶部障碍物.run(移动的动作序列)
    }
    
    fileprivate func 无限重生障碍物() {
        let 首次延迟 = SKAction.wait(forDuration: k首次生成障碍延迟时间)
        let 重生障碍 = SKAction.run(生成障碍物)
        let 每次重生间隔 = SKAction.wait(forDuration: k每次生成障碍延迟时间)
        let 重生的动作队列 = SKAction.sequence([重生障碍,每次重生间隔])
        let 无限重生 = SKAction.repeatForever(重生的动作队列)
        let 总的动作队列 = SKAction.sequence([首次延迟,无限重生])
        run(总的动作队列, withKey: "重生")
    }
    
    // MARK: - Touch Begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let 点击 = touches.first else { return }
        
        let 点击位置 = 点击.location(in: self)
        
        switch 当前游戏状态 {
            case .主菜单:
            if 点击位置.y < size.height * 0.15 {
                去学习()
            } else if 点击位置.x < size.width/2 {
                切换到教程状态()
            } else {
                去评价()
            }
                break
            case .教程:
                切换到游戏状态()
                break
            case .游戏:
                // 增加上冲速度
                主角飞一下()
                break
            case .跌落:
                break
            case .显示分数:
                break
            case .结束🔚:
                切换到新游戏()
                break
        }
    }
    
    fileprivate func 主角飞一下() {
        // 播放音效
        run(拍打的音效)
        速度 = CGPoint(x: 0, y: k上冲速度)
        
        /// 帽子的动画
        let 向上移动 = SKAction.moveBy(x: 0, y: 12, duration: 0.15)
        向上移动.timingMode = .easeInEaseOut
        let 向下移动 = 向上移动.reversed()
        帽子🎩.run(SKAction.sequence([向上移动, 向下移动]))
    }

    
    // MARK: - 更新
    override func update(_ 当前时间: TimeInterval) {
        if 上一次更新时间 > 0 {
            dt = 当前时间 - 上一次更新时间
        }else {
            dt = 0
        }
        上一次更新时间 = 当前时间
        
        switch 当前游戏状态 {
            case .主菜单:

                break
            case .教程:
//                切换到游戏状态()
                break
            case .游戏:
                更新主角()
                更新前景()
                撞击了地面的检查()
                撞击了障碍物的检查()
                更新得分()
                break
            case .跌落:
                更新主角()
                撞击了地面的检查()
                break
            case .显示分数:
                break
            case .结束🔚:
                切换到新游戏()
                break
        }
    }
    
    fileprivate func 更新主角() {
        let 加速度 = CGPoint(x: 0, y: k重力)
        速度 = 速度 + 加速度 * CGFloat(dt)
        主角.position = 主角.position + 速度 * CGFloat(dt)
        
        // 检测撞击地面时让其停留在地面上
        if 主角.position.y - 主角.size.height/2 < 游戏区域起始点 {
            主角.position = CGPoint(x: 主角.position.x, y: 主角.size.height/2 + 游戏区域起始点)
        }
    }
    
    fileprivate func 更新前景() {
        游戏世界.enumerateChildNodes(withName: "前景") { (匹配单位, _) in
            if let 前景 = 匹配单位 as? SKSpriteNode {
                let 地面的移动速度 = CGPoint(x: self.k前景移动速度, y: 0)
                前景.position += 地面的移动速度 * CGFloat(self.dt)
                
                if 前景.position.x < -前景.size.width {
                    前景.position += CGPoint(x: 前景.size.width*CGFloat(self.k前景地面数), y: 0)
                }
            }
        }
    }
}

// MARK: - 设置的相关方法
extension GameScene {
    fileprivate func 设置教程() {
        let 教程 = SKSpriteNode(imageNamed: "Tutorial")
        教程.position = CGPoint(x: size.width * 0.5 , y: 游戏区域的高度 * 0.4 + 游戏区域起始点)
        教程.name = "教程"
        教程.zPosition = 图层.UI.rawValue
        游戏世界.addChild(教程)
        
        let 准备 = SKSpriteNode(imageNamed: "Ready")
        准备.position = CGPoint(x: size.width * 0.5, y: 游戏区域的高度 * 0.7 + 游戏区域起始点)
        准备.name = "教程"
        准备.zPosition = 图层.UI.rawValue
        游戏世界.addChild(准备)
        
        let 向上移动 = SKAction.moveBy(x: 0, y: 50, duration: 0.4)
        向上移动.timingMode = .easeInEaseOut
        let 向下移动 = 向上移动.reversed()
        
        主角.run(SKAction.repeatForever(SKAction.sequence([
            向上移动,向下移动
            ])), withKey: "起飞")
        
        var 角色贴图组: Array<SKTexture> = []
        
        for i in 0..<k角色动画总帧数 {
            角色贴图组.append(SKTexture(imageNamed: "Bird\(i)"))
        }

        
        for i in stride(from: 0, to: (k角色动画总帧数-1), by: -1) {
            角色贴图组.append(SKTexture(imageNamed: "Bird\(i)"))
        }
        
        let 扇动翅膀的动画 = SKAction.animate(with: 角色贴图组, timePerFrame: 0.07)
        主角.run(SKAction.repeatForever(扇动翅膀的动画))
    }
    
    
    fileprivate func 设置背景() {
        let 背景 = SKSpriteNode(imageNamed: "Background")
        背景.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        背景.position = CGPoint(x: size.width/2, y: size.height)
        背景.zPosition = 图层.背景.rawValue
        游戏世界.addChild(背景)
        
        游戏区域起始点 = size.height - 背景.size.height
        游戏区域的高度 = 背景.size.height
        
        let 左下 = CGPoint(x: 0, y: 游戏区域起始点)
        let 右下 = CGPoint(x: size.width, y: 游戏区域起始点)
        
        self.physicsBody = SKPhysicsBody(edgeFrom: 左下, to: 右下)
        self.physicsBody?.categoryBitMask = 物理层.地面
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 物理层.游戏角色
    }
    
    fileprivate func 设置前景() {
        for index in 0..<k前景地面数 {
            let 前景 = SKSpriteNode(imageNamed: "Ground")
            前景.anchorPoint = CGPoint(x: 0, y: 1.0)
            前景.position = CGPoint(x: CGFloat(index)*前景.size.width, y: 游戏区域起始点)
            前景.zPosition = 图层.前景.rawValue
            前景.name = "前景"
            游戏世界.addChild(前景)
        }
    }
    
    fileprivate func  设置主角🐦() {
        主角.position = CGPoint(x: size.width*0.2, y: 游戏区域起始点 + 游戏区域的高度*0.4)
        主角.zPosition = 图层.前景.rawValue
        
        let offsetX = 主角.size.width * 主角.anchorPoint.x
        let offsetY = 主角.size.height * 主角.anchorPoint.y
        let path = CGMutablePath()
        path.move(to: CGPoint(x:  3 - offsetX, y: 12 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  18 - offsetX, y: 22 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  28 - offsetX, y: 27 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  39 - offsetX, y: 23 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  39 - offsetX, y: 9 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  25 - offsetX, y: 4 - offsetY), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x:  5 - offsetX,  y: 2 - offsetY), transform: CGAffineTransform.identity)
        path.closeSubpath()
        主角.physicsBody = SKPhysicsBody(polygonFrom: path)
        
        主角.physicsBody?.categoryBitMask = 物理层.游戏角色
        主角.physicsBody?.collisionBitMask = 0
        主角.physicsBody?.contactTestBitMask = 物理层.障碍物 | 物理层.地面
        
        游戏世界.addChild(主角)
    }
    
    fileprivate func 设置帽子🎩() {
        帽子🎩.position = CGPoint(x: 31-帽子🎩.size.width/2, y: 29-帽子🎩.size.height/2)
        主角.addChild(帽子🎩)
    }
    
    fileprivate func 设置得分标签() {
        得分标签 = SKLabelNode(fontNamed: k字体名字)
        得分标签.fontColor = SKColor(colorLiteralRed: 101/255.0, green: 71/255.0, blue: 73/255.0, alpha: 1.0)
        得分标签.position = CGPoint(x: size.width/2, y: size.height-k留白)
        得分标签.verticalAlignmentMode = .top
        得分标签.text = "0"
        得分标签.zPosition = 图层.UI.rawValue
        游戏世界.addChild(得分标签)
    }
    
    fileprivate func 设置记分板() {
        if 当前分数 > 最高分() {
            设置最高分(最高分: 当前分数)
        }
        
        let 记分板 = SKSpriteNode(imageNamed: "ScoreCard")
        记分板.position = CGPoint(x: size.width/2, y: size.height/2)
        记分板.zPosition = 图层.UI.rawValue
        游戏世界.addChild(记分板)
        
        let 当前分数标签 = SKLabelNode(fontNamed: k字体名字)
        当前分数标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        当前分数标签.position = CGPoint(x: -记分板.size.width / 4, y: -记分板.size.height / 3)
        当前分数标签.text = "\(当前分数)"
        当前分数标签.zPosition = 图层.UI.rawValue
        记分板.addChild(当前分数标签)
        
        let 最高分标签 = SKLabelNode(fontNamed: k字体名字)
        最高分标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        最高分标签.position = CGPoint(x: 记分板.size.width / 4, y: -记分板.size.height / 3)
        最高分标签.text = "\(最高分())"
        最高分标签.zPosition = 图层.UI.rawValue
        记分板.addChild(最高分标签)
        
        let 游戏结束 = SKSpriteNode(imageNamed: "GameOver")
        游戏结束.position = CGPoint(x: size.width/2, y: size.height/2 + 记分板.size.height/2 + k留白 + 游戏结束.size.height/2)
        游戏结束.zPosition = 图层.UI.rawValue
        游戏世界.addChild(游戏结束)
        
        let ok按钮 = SKSpriteNode(imageNamed: "Button")
        ok按钮.position = CGPoint(x: size.width/4, y: size.height/2 - 记分板.size.height/2 - k留白 - ok按钮.size.height/2)
        ok按钮.zPosition = 图层.UI.rawValue
        游戏世界.addChild(ok按钮)
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = CGPoint.zero
        ok.zPosition = 图层.UI.rawValue
        ok按钮.addChild(ok)
        
        let 分享按钮 = SKSpriteNode(imageNamed: "ButtonRight")
        分享按钮.position = CGPoint(x: size.width * 0.75, y: size.height/2 - 记分板.size.height/2 - k留白 - 分享按钮.size.height/2)
        分享按钮.zPosition = 图层.UI.rawValue
        游戏世界.addChild(分享按钮)
        
        let 分享 = SKSpriteNode(imageNamed: "Share")
        分享.position = CGPoint.zero
        分享.zPosition = 图层.UI.rawValue
        分享按钮.addChild(分享)
        
        游戏结束.setScale(0)
        游戏结束.alpha = 0
        let 动画组 = SKAction.group([
            SKAction.fadeIn(withDuration: k动画延迟),
            SKAction.scale(to: 1.0, duration: k动画延迟)
            ])
        动画组.timingMode = .easeInEaseOut
        
        游戏结束.run(SKAction.sequence([
            SKAction.wait(forDuration: k动画延迟),
            动画组
            ]))
        
        记分板.position = CGPoint(x: size.width / 2, y: -记分板.size.height/2)
        let 向上移动的动画 = SKAction.move(to: CGPoint(x: size.width / 2, y: size.height / 2), duration: k动画延迟)
        向上移动的动画.timingMode = .easeInEaseOut
        记分板.run(SKAction.sequence([
            SKAction.wait(forDuration: k动画延迟 * 2),
            向上移动的动画
            ]))
        
        ok按钮.alpha = 0
        分享按钮.alpha = 0
        
        let 渐变动画 = SKAction.sequence([
            SKAction.wait(forDuration: k动画延迟 * 3),
            SKAction.fadeIn(withDuration: k动画延迟)
            ])
        ok按钮.run(渐变动画)
        分享按钮.run(渐变动画)
        
        let 声音特效 = SKAction.sequence([
            SKAction.wait(forDuration: k动画延迟),
            砰的音效,
            SKAction.wait(forDuration: k动画延迟),
            砰的音效,
            SKAction.wait(forDuration: k动画延迟),
            砰的音效,
            SKAction.run(切换到结束状态)
            ])
        
        run(声音特效)
    }

    func 设置主菜单() {
        
        // logo
        
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x: size.width/2, y: size.height * 0.8)
        logo.name = "主菜单"
        logo.zPosition = 图层.UI.rawValue
        游戏世界.addChild(logo)
        
        // 开始游戏按钮
        
        let 开始游戏按钮 = SKSpriteNode(imageNamed: "Button")
        开始游戏按钮.position = CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        开始游戏按钮.name = "主菜单"
        开始游戏按钮.zPosition = 图层.UI.rawValue
        游戏世界.addChild(开始游戏按钮)
        
        let 游戏 = SKSpriteNode(imageNamed: "Play")
        游戏.position = CGPoint.zero
        开始游戏按钮.addChild(游戏)
        
        // 评价按钮
        
        let 评价按钮 = SKSpriteNode(imageNamed: "Button")
        评价按钮.position = CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        评价按钮.zPosition = 图层.UI.rawValue
        评价按钮.name = "主菜单"
        游戏世界.addChild(评价按钮)
        
        let 评价 = SKSpriteNode(imageNamed: "Rate")
        评价.position = CGPoint.zero
        评价按钮.addChild(评价)
        
        // 学习按钮
        
        let 学习 = SKSpriteNode(imageNamed: "button_learn")
        学习.position = CGPoint(x: size.width * 0.5, y: 学习.size.height/2 + k留白)
        学习.name = "主菜单"
        学习.zPosition = 图层.UI.rawValue
        游戏世界.addChild(学习)
        
        // 学习按钮的动画
        let 放大动画 = SKAction.scale(to: 1.02, duration: 0.75)
        放大动画.timingMode = .easeInEaseOut
        
        let 缩小动画 = SKAction.scale(to: 0.98, duration: 0.75)
        缩小动画.timingMode = .easeInEaseOut
        
        学习.run(SKAction.repeatForever(SKAction.sequence([
            放大动画,缩小动画
            ])), withKey: "主菜单")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didEnd(_ 碰撞双方: SKPhysicsContact) {
        let 被撞对象 = 碰撞双方.bodyA.categoryBitMask ==
            物理层.游戏角色 ? 碰撞双方.bodyB : 碰撞双方.bodyA
        
        if 被撞对象.categoryBitMask == 物理层.地面 {
            主角撞击了地面布尔类型 = true
        }
        if 被撞对象.categoryBitMask == 物理层.障碍物 {
            主角撞击了地面布尔类型 = true
            主角撞击了障碍物布尔类型 = true
        }

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
}


// MARK: - 游戏状态
extension GameScene {
    fileprivate func 撞击了障碍物的检查() {
        if 主角撞击了障碍物布尔类型 {
            主角撞击了障碍物布尔类型 = false
            切换到跌落状态()
        }
    }
    
    /// 更新得分
    func 更新得分() {
        游戏世界.enumerateChildNodes(withName: "顶部障碍物") { (匹配单位, _) in
            if let 障碍物 = 匹配单位 as? SKSpriteNode {
                if let 已通过 = 障碍物.userData?["已通过"] as? NSNumber {
                    if 已通过.boolValue {
                        return   // 已经计算过一次得分了
                    }
                }
                
                if self.主角.position.x > (障碍物.position.x + 障碍物.size.width/2)  {
                    self.当前分数 += 1
                    self.得分标签.text = "\(self.当前分数)"
                    self.run(self.得分的音效)
                    
                    障碍物.userData?["已通过"] = NSNumber(value: true)
                }
            }
        }
    }
    
    
    fileprivate func 停止重生障碍物() {
        removeAction(forKey: "重生")
        游戏世界.enumerateChildNodes(withName: "底部障碍物") { (匹配单位, _) in
            匹配单位.removeAllActions()
        }
        游戏世界.enumerateChildNodes(withName: "顶部障碍物") { (匹配单位, _) in
            匹配单位.removeAllActions()
        }
    }
    
    fileprivate func 撞击了地面的检查() {
        if 主角撞击了地面布尔类型 {
            主角撞击了地面布尔类型 = false
            速度 = CGPoint.zero
            主角.zRotation = CGFloat(-90).degreesToRadians()
            主角.position = CGPoint(x: 主角.position.x, y: 游戏区域起始点 + 主角.size.width/2)
            
            run(撞击地面的音效)
            切换到显示分数的状态()
        }
    }

    // MARK: - 切换状态
    /// 切换到跌落状态
    fileprivate func 切换到跌落状态() {
        当前游戏状态 = .跌落
        
        run(SKAction.sequence([
            摔倒的音效,
            SKAction.wait(forDuration: 0.1),
            下落的音效
            ]))
        
        主角.removeAllActions()
        停止重生障碍物()
    }
    
    fileprivate func 切换到显示分数的状态() {
        当前游戏状态 = .显示分数
        主角.removeAllActions()
        停止重生障碍物()
        设置记分板()
    }
    
    fileprivate func 切换到主菜单() {
        当前游戏状态 = .主菜单
        
        设置背景()
        设置前景()
        设置主角🐦()
        设置帽子🎩()
        设置主菜单()
    }

    
    fileprivate func 切换到教程状态() {
        当前游戏状态 = .教程

        游戏世界.enumerateChildNodes(withName: "主菜单") { (匹配单位, _) in
            匹配单位.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.05),
                SKAction.removeFromParent() ]))
        }
        
        设置得分标签()
        设置教程()
    }
    
    fileprivate func 切换到游戏状态() {
         当前游戏状态 = .游戏
        
         游戏世界.enumerateChildNodes(withName: "教程") { (匹配单位, _) in
            匹配单位.run(SKAction.sequence([
                                            SKAction.fadeOut(withDuration: 0.05),
                                            SKAction.removeFromParent() ]))
        }
        
        无限重生障碍物()
        主角飞一下()
    }
}

// MARK: 分数
extension GameScene {
    
    func 最高分() -> Int {
        return UserDefaults.standard.integer(forKey: "最高分")
    }
    
    func 设置最高分(最高分: Int) {
        UserDefaults.standard.set(最高分, forKey: "最高分")
        UserDefaults.standard.synchronize()
    }
    
    func 切换到新游戏() {
        run(砰的音效)
        
        let 新的游戏场景 = GameScene.init(size: size)
        let 切换特效 = SKTransition.fade(with: SKColor.black, duration: 0.05)
        view?.presentScene(新的游戏场景, transition: 切换特效)
    }
    
    func 切换到结束状态() {
        当前游戏状态 = .结束🔚
    }
}

// MARK: - 其他 https://github.com/LYM-mg/MGFlappy-Bird
extension GameScene {
    fileprivate func 去学习() {
        let 学习代码网址 = "https://github.com/LYM-mg/MGFlappy-Bird"
        guard let url = URL(string: 学习代码网址) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    fileprivate func 去评价() {
        let appStore网址 = "http://itunes.apple.com/app/id1077251372?mt=8"
        guard let url = URL(string: appStore网址) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
}
