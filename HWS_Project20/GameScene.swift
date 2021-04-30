//
//  GameScene.swift
//  HWS_Project20
//
//  Created by J on 2021/04/30.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    
    var leftEdge = -22
    var bottomtEdge = -22
    var rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "score: \(score)"
        }
    }
    
   
    override func didMove(to view: SKView) {
        
        //背景
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        //タイマーが起動するたびにlaunchFireworks（）が呼び出される
        gameTimer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
    }
    
    func createFireworks(xMovement: CGFloat, x: Int, y: Int){
        
        //node作成
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        //ランダムな色を設定
        switch Int.random(in: 1...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        //花火の動き
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        //pathをたどる
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        //火花
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        //nodeを追加
        fireworks.append(node)
        addChild(node)
        
    }
    
    @objc func launchFireworks(){
        
    }
}
