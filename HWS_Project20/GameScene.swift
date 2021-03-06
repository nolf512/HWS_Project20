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
        
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 1...3) {
        
        case 0:
            createFireworks(xMovement: 0, x: 512, y: bottomtEdge)
            createFireworks(xMovement: 0, x: 512 - 200, y: bottomtEdge)
            createFireworks(xMovement: 0, x: 512 - 100, y: bottomtEdge)
            createFireworks(xMovement: 0, x: 512 + 200, y: bottomtEdge)
            createFireworks(xMovement: 0, x: 512 + 100, y: bottomtEdge)
            
        case 1:
            createFireworks(xMovement: 0, x: 512, y: bottomtEdge)
            createFireworks(xMovement: -200, x: 512 - 200, y: bottomtEdge)
            createFireworks(xMovement: -100, x: 512 - 100, y: bottomtEdge)
            createFireworks(xMovement: 100, x: 512 + 200, y: bottomtEdge)
            createFireworks(xMovement: 2000, x: 512 + 100, y: bottomtEdge)
            
        case 2:
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomtEdge + 400)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomtEdge + 300)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomtEdge + 200)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomtEdge + 100)
            createFireworks(xMovement: movementAmount, x: leftEdge, y: bottomtEdge)
            
        case 3:
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomtEdge + 400)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomtEdge + 300)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomtEdge + 200)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomtEdge + 100)
            createFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomtEdge)
            
        default:
            break
        }
        
    }
    
    
    func checkTouches(_ touces: Set<UITouch>){
        guard let touch = touces.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        //nodeをループしてfireworkを見つける
        for case let node as SKSpriteNode in nodesAtPoint { //型キャストができたらループを実行
            guard node.name == "firework" else { continue }
            
            //内部ループ
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            //nodeをfireworkからselectedに変更
            node.name = "selected"
            node.colorBlendFactor = 0
        }
        
    }
    
    //タッチ情報を送信
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            
            //花火が垂直方向に900進んだら配列から削除
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    
    func explode(firework: SKNode){
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            
            //fireworkの位置で爆発させる
            emitter.position = firework.position
            addChild(emitter)
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks(){
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
        
    }
    
}
