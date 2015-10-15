//
//  GameViewController.swift
//  Dot Drop
//
//  Created by Jacob Sandum on 10/2/15.
//  Copyright (c) 2015 justfun. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import SceneKit
import GameKit


class GameViewController: UIViewController, ADBannerViewDelegate, GKGameCenterControllerDelegate {
    
    @IBOutlet var background: UIImageView!
    @IBOutlet var PlayButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var infoHidden: UIImageView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var adBanner: ADBannerView!
    
    var skView = SKView()
    var scene = SKScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adBanner.delegate = self
        adBanner.hidden = true
        self.canDisplayBannerAds = true
        
        self.interstitialPresentationPolicy =
            ADInterstitialPresentationPolicy.Manual
        
        skView = SKView(frame: self.view.frame)
        scene = GameScene(size: skView.bounds.size)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        authenticateLocalPlayer()
    }
    //memes
        //initiate gamecenter
        func authenticateLocalPlayer(){
            
            var localPlayer = GKLocalPlayer.localPlayer()
            
            localPlayer.authenticateHandler = {(viewController, error) -> Void in
                
                if (viewController != nil) {
                    self.presentViewController(viewController!, animated: true, completion: nil)
                }
                    
                else {
                    print((GKLocalPlayer.localPlayer().authenticated))
                }
            }
            
        }
    
    //send high score to leaderboard
    func saveHighscore(score:Int) {
        print("GK saving high score")
        //check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            
            var scoreReporter = GKScore(leaderboardIdentifier: "DotDropLeaderboard") //leaderboard id here
            
            scoreReporter.value = Int64(HighScore) //score variable here (same as above)
            
            var scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    print("error")
                }
            })
            
        }
        
    }
    
    @IBAction func leaderBoardButtonClicked(sender: AnyObject) {
        
        showLeader()
        
    }
    //shows leaderboard screen
    func showLeader() {
        var vc = self.view?.window?.rootViewController
        var gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBanner.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBanner.hidden = true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    func initGameCenter() {
        
        // Check if user is already authenticated in game center
        if GKLocalPlayer.localPlayer().authenticated == false {
            
            // Show the Login Prompt for Game Center
            GKLocalPlayer.localPlayer().authenticateHandler = {(viewController, error) -> Void in
                if viewController != nil {
                    self.presentViewController(viewController!, animated: true, completion: nil)
                    
                    // Add an observer which calls 'gameCenterStateChanged' to handle a changed game center state
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.addObserver(self, selector:"gameCenterStateChanged", name: "GKPlayerAuthenticationDidChangeNotificationName", object: nil)
                }
            }
        }
    }
    
    
    @IBAction func infoButtonClicked(sender: AnyObject) {
        
        self.infoHidden.hidden = false
        
    }
    
    @IBAction func settingsButtonClicked(sender: AnyObject) {
        
        
        
    }

    @IBAction func shareClicked(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://JustFunllc.com")!)
        
    }

    
    @IBAction func playClicked(sender: AnyObject) {
        
        UIView.animateWithDuration(2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6, options: [], animations: ({
            
            self.background.center.x = self.view.frame.width + 600
            self.PlayButton.center.x = self.view.frame.width + 600
            self.infoButton.center.x = self.view.frame.width + 600
            self.logo.center.x = self.view.frame.width + 600
            self.infoHidden.center.x = self.view.frame.width + 600
            self.settingsButton.center.x = self.view.frame.width + 600
            self.shareButton.center.x = self.view.frame.width + 600
            self.adBanner.center.x = self.view.frame.width + 600
            self.view.frame.width + 800
            
        }), completion: nil)
        
        self.view.addSubview(skView)
        skView.presentScene(scene)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    @IBAction func starButtonClicked(sender: AnyObject) {
        
        let url  = NSURL(string: "itms-apps://itunes.apple.com/app/bars/id1046181057")
        if UIApplication.sharedApplication().canOpenURL(url!) == true  {
            UIApplication.sharedApplication().openURL(url!)
        }
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
