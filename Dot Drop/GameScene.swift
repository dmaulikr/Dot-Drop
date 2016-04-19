//
//  GameScene.swift
//  Dot Drop
//
//  Created by Jacob Sandum on 10/2/15.
//  Copyright (c) 2015 justfun. All rights reserved.
//

import SpriteKit
import UIKit
import iAd
import AVFoundation
import GameKit
import Darwin

public var HighScore: Int = 0
public var score: Int = 0
public var IsPaused = false

struct Physics {
    
    static let Enemy :UInt32 = 0x1 << 0
    static let Bar : UInt32 = 0x1 << 1
    
}

public func pauseGame(){
    
    IsPaused = true
}

public func resumeGame(){
    
    IsPaused = false
    
}

class GameScene: SKScene, SKPhysicsContactDelegate, ADBannerViewDelegate {
    
    var colorNeeded: SKColor = SKColor()
    var bar:SKShapeNode = SKShapeNode()
    var button: SKNode! = nil
    var increment: CGFloat = 0.01
    var radius: CGFloat = 30
    var ChangeCounter = 0
    var NodeClicked = ""
    var AwaitingRestart = false
    var gameOver = false
    
    var Green = SKShapeNode()
    var Red = SKShapeNode()
    var Yellow = SKShapeNode()
    var Purple = SKShapeNode()
    var Blue = SKShapeNode()
    var Green2 = SKShapeNode()
    var Red2 = SKShapeNode()
    var Yellow2 = SKShapeNode()
    var Purple2 = SKShapeNode()
    var Blue2 = SKShapeNode()
    //var sparkEmitter = SKEmitterNode(fileNamed: "Animations/Spark")
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var ScoreLabel:SKLabelNode!
    var HighScoreLabel:SKLabelNode!
    var RestartLabel:SKLabelNode!
    var BackButton:SKSpriteNode!
    var π = M_PI
    var clickPlayer: AVAudioPlayer = AVAudioPlayer()
    var hitPlayer: AVAudioPlayer = AVAudioPlayer()
    var jumpPlayer: AVAudioPlayer = AVAudioPlayer()
    var musicPlayer: AVAudioPlayer = AVAudioPlayer()
    var pointPlayer: AVAudioPlayer = AVAudioPlayer()
    var pop2Player: AVAudioPlayer = AVAudioPlayer()
    
    var Background = SKSpriteNode()
    var startTimer = NSTimer()
    
    
    var CustomWidth: UInt32 = UInt32()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        
        
        //Add this back in if you want the color needed to change every minute
        //var timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "update", userInfo: nil, repeats: true)
        
        CustomWidth = UInt32(frame.size.width - 300)
        print("Normal Width Is: \(frame.size.width)")
        print("Other Width Is: \(UIScreen.mainScreen().bounds.size.width)")
        print("Middle is: \(self.size.width / 2)")
        
        self.size.width = UIScreen.mainScreen().bounds.size.width
        self.size.height = UIScreen.mainScreen().bounds.size.height
        print("Width is now: \(self.size.width)")
        
        
        Background = SKSpriteNode(imageNamed: "images/edit/background")
        Background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 )
        Background.zPosition = -1.0
        
        self.addChild(Background)
        
        //Physics
        //self.physicsWorld.gravity = CGVector( dx: 0.0, dy: -0.2 )
        //self.physicsWorld.contactDelegate = self
        print(physicsWorld.speed)
        
        setupCircles()
        spawnCircles()
        
        changeColorNeeded()
        
        addRectangleToBottom()
        
        if RestartLabel == nil && ScoreLabel == nil && HighScoreLabel == nil {
            
           setupLabels()
            setupAudioPlayers()
        }
        
        if audioOn == true {
            
            musicPlayer.play()
        }
        
        HighScore = userDefaults.integerForKey("highscore")
        print("High Score Saved in Defaults equals: \(userDefaults.integerForKey("highscore"))")
        HighScoreLabel.text = "HighScore: \(String(HighScore))"
        //sparkEmitter!.position = CGPointMake(-100, -100)
        //self.addChild(sparkEmitter!)
        //sparkEmitter!.targetNode = self
    }
    
     
    
    func addRestartLabel() {
        
        RestartLabel = SKLabelNode(fontNamed: "Prodotto In Cina")
        RestartLabel.text = "Click Anywhere To Restart"
        RestartLabel.fontSize = 20
        RestartLabel.fontColor = SKColor.blueColor()
        RestartLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 10)
        AwaitingRestart = true
        
        self.addChild(RestartLabel)
        
    }
    
    func removeRestartLabel() {
        
        RestartLabel.removeFromParent()
        AwaitingRestart = false
    }
    
    func removeScoreLabels() {
        
        ScoreLabel.removeFromParent()
        HighScoreLabel.removeFromParent()
        
    }
    
    func addBackScoreLabels() {
        
        self.addChild(ScoreLabel)
        self.addChild(HighScoreLabel)
        
    }
    
    func buttonAction(sender:UIButton!)
    {
        print("Button tapped")
    }
    
    func waitForRestart() {
        
        self.physicsWorld.speed = 0
        addRestartLabel()
        removeScoreLabels()
    }
    
    func goBackToMenu() {
        
        
    }
    
    func restartGame() {
        
        //self.physicsWorld.speed = 1.0
        spawnCircles()
        changeColorNeeded()
        removeRestartLabel()
        addBackScoreLabels()
        //self.physicsWorld.gravity = CGVector( dx: 0.0, dy: -0.2 )
    }
    
    func setupLabels()  {
        
        ScoreLabel = SKLabelNode(fontNamed: "Prodotto In Cina")
        ScoreLabel.text = "Score: 0"
        ScoreLabel.fontSize = 20
        ScoreLabel.fontColor = SKColor.blueColor()
        ScoreLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 50)
        
        self.addChild(ScoreLabel)
        
        HighScoreLabel = SKLabelNode(fontNamed: "Prodotto In Cina")
        HighScoreLabel.text = "High Score: 0"
        HighScoreLabel.fontSize = 20
        HighScoreLabel.fontColor = SKColor.blueColor()
        HighScoreLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 10)
        
        self.addChild(HighScoreLabel)
        
    }
    
    func setupCircles() {
    
        Green = SKShapeNode(circleOfRadius: radius) // Size of Circle
        Green.position.y = frame.size.height
        Green.strokeColor = SKColor.clearColor()
        Green.glowWidth = 1.0
        Green.fillColor = SKColor.greenColor()
        Green.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Green.physicsBody?.categoryBitMask = Physics.Enemy
        Green.physicsBody?.contactTestBitMask = Physics.Bar
        Green.physicsBody?.collisionBitMask = Physics.Bar
        Green.physicsBody?.dynamic = true
        Green.name = "Enemy"
        
        Red = SKShapeNode(circleOfRadius: radius) // Size of Circle
        Red.position.y = frame.size.height
        Red.strokeColor = SKColor.clearColor()
        Red.glowWidth = 1.0
        Red.fillColor = SKColor.redColor()
        Red.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Red.physicsBody?.categoryBitMask = Physics.Enemy
        Red.physicsBody?.contactTestBitMask = Physics.Bar
        Red.physicsBody?.collisionBitMask = Physics.Bar
        Red.physicsBody?.dynamic = true
        Red.name = "Enemy"
        
        Blue = SKShapeNode(circleOfRadius: radius) // Size of Circle
        Blue.position.y = frame.size.height
        Blue.strokeColor = SKColor.clearColor()
        Blue.glowWidth = 1.0
        Blue.fillColor = SKColor.blueColor()
        Blue.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Blue.physicsBody?.categoryBitMask = Physics.Enemy
        Blue.physicsBody?.contactTestBitMask = Physics.Bar
        Blue.physicsBody?.collisionBitMask = Physics.Bar
        Blue.physicsBody?.dynamic = true
        Blue.name = "Enemy"
        
        Yellow = SKShapeNode(circleOfRadius: radius) // Size of Circle
        Yellow.position.y = frame.size.height
        Yellow.strokeColor = SKColor.clearColor()
        Yellow.glowWidth = 1.0
        Yellow.fillColor = SKColor.yellowColor()
        Yellow.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Yellow.physicsBody?.categoryBitMask = Physics.Enemy
        Yellow.physicsBody?.contactTestBitMask = Physics.Bar
        Yellow.physicsBody?.collisionBitMask = Physics.Bar
        Yellow.physicsBody?.dynamic = true
        Yellow.name = "Enemy"
        
        Purple = SKShapeNode(circleOfRadius: radius) // Size of Circle
        Purple.position.y = frame.size.height
        Purple.strokeColor = SKColor.clearColor()
        Purple.glowWidth = 1.0
        Purple.fillColor = SKColor.purpleColor()
        Purple.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Purple.physicsBody?.categoryBitMask = Physics.Enemy
        Purple.physicsBody?.contactTestBitMask = Physics.Bar
        Purple.physicsBody?.collisionBitMask = Physics.Bar
        Purple.physicsBody?.dynamic = true
        Purple.name = "Enemy"
        
        self.addChild(Green)
        self.addChild(Red)
        self.addChild(Blue)
        self.addChild(Yellow)
        self.addChild(Purple)
    }
    
    func update(){
        
        changeColorNeeded()
        
    }
    
    
    func changeGreen(){
    
        if IsPaused == false{
        
        Green.position.y = frame.size.height + CGFloat(arc4random_uniform(100) + 1)
        
        var PositionX: CGFloat = CGFloat(UInt32(radius) + arc4random_uniform(UInt32(self.frame.width - 2.0 * radius)))
        
        
        Green.position.x = CGFloat(PositionX)
            
            while Green.containsPoint(Red.position) || Green.containsPoint(Blue.position) || Green.containsPoint(Yellow.position) || Green.containsPoint(Purple.position) {
                print("Overlap Detected")
                changeGreen()
                
            }
            let randomX: CGFloat = CGFloat(drand48())
            print("RandomX For Impulse = \(randomX)")
            self.Green.physicsBody?.applyImpulse(CGVectorMake(0, -200))
            print(self.Green.position.y)
        }
        
    }
    
    func changeRed(){
        
        if IsPaused == false{
        
        Red.position.y = frame.size.height + CGFloat(arc4random_uniform(100) + 1)

        var PositionX: CGFloat = CGFloat(UInt32(radius) + arc4random_uniform(UInt32(self.frame.width - 2.0 * radius)))

        
        Red.position.x = CGFloat(PositionX)
            
            while Red.containsPoint(Blue.position) || Red.containsPoint(Yellow.position) || Red.containsPoint(Green.position) || Red.containsPoint(Purple.position) {
                print("Overlap Detected")
                changeRed()
                
            }
            let randomX: CGFloat = CGFloat(drand48())
            print("RandomX For Impulse = \(randomX)")
            self.Red.physicsBody?.applyImpulse(CGVectorMake(0, -200))
            print(self.Red.position.y)
        }
    }
    
    func changeBlue()   {
        
        if IsPaused == false{
            
        Blue.position.y = frame.size.height + CGFloat(arc4random_uniform(100) + 1)
        
        var PositionX: CGFloat = CGFloat(UInt32(radius) + arc4random_uniform(UInt32(self.frame.width - 2.0 * radius)))
        
        Blue.position.x = CGFloat(PositionX)
            
            while Blue.containsPoint(Red.position) || Blue.containsPoint(Yellow.position) || Blue.containsPoint(Green.position) || Blue.containsPoint(Purple.position) {
                print("Overlap Detected")
                changeBlue()
                
            }
            let randomX: CGFloat = CGFloat(drand48())
            print("RandomX For Impulse = \(randomX)")
            print("Applying Impulse")
            self.Blue.physicsBody?.applyImpulse(CGVectorMake(0, -200))
            print(self.Blue.position.y)
        }
    }
    
    func changeYellow() {
        
        if IsPaused == false{
        
        Yellow.position.y = frame.size.height  + CGFloat(arc4random_uniform(100) + 1)
        
        var PositionX: CGFloat = CGFloat(UInt32(radius) + arc4random_uniform(UInt32(self.frame.width - 2.0 * radius)))
        
        
        Yellow.position.x = CGFloat(PositionX)
            
            while Yellow.containsPoint(Red.position) || Yellow.containsPoint(Blue.position) || Yellow.containsPoint(Green.position) || Yellow.containsPoint(Purple.position) {
                print("Overlap Detected")
                changeYellow()
                
            }
            let randomX: CGFloat = CGFloat(drand48())
            print("RandomX For Impulse = \(randomX)")
            self.Yellow.physicsBody?.applyImpulse(CGVectorMake(0, -200))
            print(self.Yellow.position.y)
        }
    }
    
    func changePurple() {
        
        if IsPaused == false{
        
        Purple.position.y = frame.size.height + CGFloat(arc4random_uniform(100) + 1)
        
        var PositionX: CGFloat = CGFloat(UInt32(radius) + arc4random_uniform(UInt32(self.frame.width - 2.0 * radius)))
        
        
        Purple.position.x = CGFloat(PositionX)
            
            while Purple.containsPoint(Red.position) || Purple.containsPoint(Blue.position) || Purple.containsPoint(Yellow.position) || Purple.containsPoint(Green.position) {
                print("Overlap Detected")
                changePurple()
                
            }
            let randomX: CGFloat = CGFloat(drand48())
            print("RandomX For Impulse = \(randomX)")
            self.Purple.physicsBody?.applyImpulse(CGVectorMake(0, -200))
            print(self.Purple.position.y)
        }
    }
    
    func spawnCircles() {
        
        changeRed()
        changeBlue()
        changeGreen()
        changeYellow()
        changePurple()
    }
    
    func randomYPos() -> Double{
        
        var rand = Double(arc4random_uniform(UInt32(0.10) + UInt32(0.8)))
        
        return rand
    }
    
    func changeColorNeeded() -> SKColor {
        
        colorNeeded = randomColor()
        return self.colorNeeded
        
    }
    
    func addRectangleToBottom()   {
        
        bar = SKShapeNode(rectOfSize: CGSize(width: self.size.width, height: 100))
        bar.name = "bar"
        bar.fillColor = SKColor.blackColor()
        bar.position = CGPointMake(self.size.width / 2, 20)
        
        self.addChild(bar)
        
    }
    
    func addBackground()    {
        
        Background = SKSpriteNode(imageNamed: "background")
        Background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 )
        self.addChild(Background)
        
    }
    
    func randomColor() -> SKColor{
        var colors: [SKColor] = [SKColor.yellowColor(),     SKColor.blueColor(), SKColor.greenColor(), SKColor.redColor(), SKColor.purpleColor()]
        
        var rand = Int(arc4random_uniform(4) + 0)
        
        return colors[rand]
    }
    
    
    func saveHighScore(HighScoreInput : Int) {
        
        if HighScoreInput >= HighScore {
            
            userDefaults.setInteger(HighScoreInput, forKey: "highscore")
            print("Setting High Score In Defaults to: \(HighScore)")
            HighScoreLabel.text = ("High Score: \(String(HighScoreInput))")
            HighScore = HighScoreInput
            
            let leaderboardID = "DotDropLeaderboard"
            let sScore = GKScore(leaderboardIdentifier: leaderboardID)
            sScore.value = Int64(score)
            
            let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
            
            GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError?) -> Void in
                if error != nil {
                    print("Error")
                    print(error!.localizedDescription)
                } else {
                    print("Score submitted")
                    
                }
            })
        }
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */

        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if AwaitingRestart == true{
                
                restartGame()
                gameOver = false
                
            }
            
            //sparkEmitter!.position = location
            
            if Red.containsPoint(location)  {
                
                NodeClicked = "Red"
                
            }
            
            if Blue.containsPoint(location)  {
                
                NodeClicked = "Blue"
                
            }
            
            if Yellow.containsPoint(location)  {
                
                NodeClicked = "Yellow"
                
            }
            
            if Green.containsPoint(location)  {
                
                NodeClicked = "Green"
                
            }
            
            if Purple.containsPoint(location)  {
                
                NodeClicked = "Purple"
                
            }
            
            switch  colorNeeded  {
            case SKColor.redColor():
                
                if Red.containsPoint(location)   {
                    
                    lose()
                }
                
                if Blue.containsPoint(location) || Yellow.containsPoint(location) || Green.containsPoint(location) || Purple.containsPoint(location) {
                    
                    notLose()
                    
                
                }
                
                break
            case SKColor.blueColor():
                
                if Blue.containsPoint(location)   {
                    
                    lose()
                }
                
                if Red.containsPoint(location) || Yellow.containsPoint(location) || Green.containsPoint(location) || Purple.containsPoint(location) {
                    
                    notLose()
                    
                    
                }
                
                break
            case SKColor.yellowColor():
                
                if Yellow.containsPoint(location)   {
                    
                    lose()
                }
                
            if Red.containsPoint(location) || Blue.containsPoint(location) || Green.containsPoint(location) || Purple.containsPoint(location) {
                
                notLose()
                
                
            }
                
                
                break
                
            case SKColor.greenColor():
                
                if Green.containsPoint(location)   {
                
                    lose()
                }
                
                if Red.containsPoint(location) || Blue.containsPoint(location) || Yellow.containsPoint(location) || Purple.containsPoint(location) {
                    
                    notLose()
                    
                    
                }
                
                
                break
                
            case SKColor.purpleColor():
                
                if Purple.containsPoint(location)   {
                    
                    lose()
                }
                
                if Red.containsPoint(location) || Blue.containsPoint(location) || Yellow.containsPoint(location) || Green.containsPoint(location) {
                    
                    notLose()
                    
                    
                }
                
                
                break
                
            default:

                break
                
            }
            
            
        }
    }
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if audioOn == false {
            
            try musicPlayer.stop()
            
        }
        
        if AwaitingRestart == false {
        
        if Red.position.y <= 0 && colorNeeded == SKColor.redColor() {
            
            changeRed()
            
        }
        
        if Blue.position.y <= 0 && colorNeeded == SKColor.blueColor(){
            
            changeBlue()
            
        }
        
        if Yellow.position.y <= 0 && colorNeeded == SKColor.yellowColor(){
            
            changeYellow()
            
        }
        
        if Purple.position.y <= 0 && colorNeeded == SKColor.purpleColor(){
            
            changePurple()
        }
        
        if Green.position.y <= 0 && colorNeeded == SKColor.greenColor(){
            
            changeGreen()
            
        }
        
        switch colorNeeded  {
            
        case SKColor.redColor():
            
            if Blue.position.y <= 0 || Yellow.position.y <= 0 || Green.position.y <= 0 || Purple.position.y <= 0  {
                
                lose()
                
            }
                
            break
            
        case SKColor.blueColor():
            
            if Red.position.y <= 0 || Yellow.position.y <= 0 || Green.position.y <= 0 || Purple.position.y <= 0  {
                
                lose()
                
            }
            
            break
            
        case SKColor.yellowColor():
            
            if Red.position.y <= 0 || Blue.position.y <= 0 || Green.position.y <= 0 || Purple.position.y <= 0  {
                
                lose()
                
            }
            
            break
        case SKColor.greenColor():
            
            if Red.position.y <= 0 || Blue.position.y <= 0 || Yellow.position.y <= 0 || Purple.position.y <= 0  {
                
                lose()
                
            }
            
            break
        case SKColor.purpleColor():
            
            if Red.position.y <= 0 || Blue.position.y <= 0 || Yellow.position.y <= 0 || Green.position.y <= 0  {
                
                lose()
                
            }
            
            break
        default:
            break
            
            
            
        }
        
        bar.fillColor = colorNeeded
        }
        
    }

    func lose() {
        if audioOn == true{
        hitPlayer.play()
        }
        print("Lose, high score is: \(HighScore)")
        if score > HighScore    {
            saveHighScore(score)
        }
        score = 0
        ScoreLabel.text = String(score)
        waitForRestart()
        
            
        if let controller = self.view?.window?.rootViewController as? GameViewController {
            controller.requestInterstitialAdPresentation()
            print("Requesting ad")
        }
        gameOver = true
    let controllerGK = GameViewController()
        
        //controllerGK.saveHighscore(HighScore)
    }
    
    func notLose() {
        
        print("Safe Click")
        score++
        print(score)
        ScoreLabel.text = ("Score: \(String(score))")
        if audioOn == true{
        pop2Player.play()
        }
        nodeClickedSwitch()
        
    }
    
    func nodeClickedSwitch()    {
        
        switch NodeClicked{
            
        case "Red":
            changeRed()
            break
            
        case "Blue":
            changeBlue()
            break
            
        case "Yellow":
            changeYellow()
            break
            
        case "Green":
            changeGreen()
            break
            
        case "Purple":
            changePurple()
            break
            
            
            
        default:
            
            break
        }
        
    }
    
    func setupAudioPlayers() {
        
        do {
            try clickPlayer = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource("sounds/click", ofType: "wav")!), fileTypeHint:nil)
            clickPlayer.prepareToPlay()
            
            try hitPlayer = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource("sounds/hit", ofType: "wav")!), fileTypeHint:nil)
            hitPlayer.prepareToPlay()
            
            try jumpPlayer = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource("sounds/jump", ofType: "wav")!), fileTypeHint:nil)
            jumpPlayer.prepareToPlay()
            
            try musicPlayer = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource("sounds/music", ofType: "mp3")!), fileTypeHint:nil)
            musicPlayer.numberOfLoops = -1
            musicPlayer.prepareToPlay()
            
            try pointPlayer = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource("sounds/point", ofType: "wav")!), fileTypeHint:nil)
            pointPlayer.prepareToPlay()
            
            try pop2Player = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource("sounds/pop2", ofType: "wav")!), fileTypeHint:nil)
            pop2Player.prepareToPlay()
        } catch {
            //Handle the error
        }
        
    }

}
