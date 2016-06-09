//
//  GameViewController.swift
//  Dot Drop
//
//  Created by Jacob Sandum on 10/2/15.
//  Copyright (c) 2015 justfun. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit
import GameKit
import GoogleMobileAds
import Social

var audioOn: Bool = true



class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADInterstitialDelegate {
    var interstitialAdView: UIView = UIView()
    @IBOutlet var background: UIImageView!
    @IBOutlet var PlayButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var logo: UIImageView!
    @IBOutlet var infoHidden: UIImageView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var starButton: UIButton!
    @IBOutlet var trophyButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    var skView = SKView()
    var scene = SKScene()
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HighScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-2881724328700674/1430232147")
        let request = GADRequest()
    
        self.interstitial.loadRequest(request)
        self.interstitial = reloadInterstitialAd()
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "displayAd", name: "GameOver", object: nil)
        
        print(self.view.subviews[0])
        print(self.view.subviews[1])
        print(self.view.subviews[2])
        //loadInterstitialAd()
        backButton.userInteractionEnabled = false
        backButton.hidden = true
        //self.backButton.bringSubviewToFront(skView)
        skView = SKView(frame: self.view.frame)
        scene = GameScene(size: skView.bounds.size)
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        authenticateLocalPlayer()
    }
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
    
    func reloadInterstitialAd() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: "ca-app-pub-2881724328700674/4302973345")
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        self.interstitial = reloadInterstitialAd()
    }
    
    func displayAd() {
        
        print("Displaying Ad")
        if self.interstitial.isReady {
            self.interstitial.presentFromRootViewController(self)
        }
    }
    
    //send high score to leaderboard
    
    @IBAction func leaderBoardButtonClicked(sender: AnyObject) {
        
        showLeader()
        
    }
    //shows leaderboard screen
    func showLeader() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
        gcVC.leaderboardIdentifier = "DotDropLeaderboard"
        self.presentViewController(gcVC, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
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
        
        switch (infoHidden.hidden) {
            
        case false:
            print("Hiding Info Image")
            infoHidden.hidden = true
            break;
        case true:
            print("Showing Info Image")
            infoHidden.hidden = false
        default:
            break;
        }
        audioButton.hidden = true
    }
    @IBAction func settingsButtonClicked(sender: AnyObject) {
        
        switch (audioButton.hidden) {
  
        case false:
            print("Hiding AudioButton")
            audioButton.hidden = true
    break;
        case true:
            print("Showing AudioButton")
            audioButton.hidden = false
  default:
    break;
}
        infoHidden.hidden = true
        
    }

    @IBAction func shareClicked(sender: AnyObject) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            var tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetShare.setInitialText("Try and beat my high score of \(HighScore) In Dot Drop! https://appsto.re/us/UTLq_.i")
            self.presentViewController(tweetShare, animated: true, completion: nil)
            
        } else {
            
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to tweet.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }

    @IBAction func audioButtonClicked(sender: AnyObject) {
        let off : UIImage = UIImage(named:"audioOff")!
        let on : UIImage = UIImage(named:"audioOn")!
        switch (audioOn) {
            
        case false:
            audioButton.setImage(on, forState: UIControlState.Normal)
            turnAudioOn()
            print("Turning On Audio")
    break;
        case true:
            audioButton.setImage(off, forState: UIControlState.Normal)
            turnAudioOff()
            print("Turning Off Audio")
  default:
    break;
}

        
    }
    
    func turnAudioOff() {
        
        audioOn = false
        
    }
    
    func turnAudioOn() {
        
        audioOn = true
        
    }
    @IBAction func backToMenuClicked(sender: AnyObject) {
        
        UIView.animateWithDuration(2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6, options: [], animations: ({
            
            self.background.center.x = self.view.frame.width - 600
            self.PlayButton.center.x = self.view.frame.width - 600
            self.infoButton.center.x = self.view.frame.width - 600
            self.logo.center.x = self.view.frame.width - 600
            self.infoHidden.center.x = self.view.frame.width - 600
            self.settingsButton.center.x = self.view.frame.width - 600
            self.shareButton.center.x = self.view.frame.width - 600
            self.starButton.center.x = self.view.frame.width - 600
            self.trophyButton.center.x = self.view.frame.width - 600
            self.audioButton.center.x = self.view.frame.width - 600
            //self.view.frame.width - 800
            
        }), completion: nil)
        
        skView.removeFromSuperview()
        
    }
    
    @IBAction func playClicked(sender: AnyObject) {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6, options: [], animations: ({
            
            self.background.center.x = self.view.frame.width + 600
            self.PlayButton.center.x = self.view.frame.width + 600
            self.infoButton.center.x = self.view.frame.width + 600
            self.logo.center.x = self.view.frame.width + 600
            self.infoHidden.center.x = self.view.frame.width + 600
            self.settingsButton.center.x = self.view.frame.width + 600
            self.shareButton.center.x = self.view.frame.width + 600
            self.starButton.center.x = self.view.frame.width + 600
            self.trophyButton.center.x = self.view.frame.width + 600
            self.audioButton.center.x = self.view.frame.width + 600
            //self.view.frame.width + 800
            
        }), completion: nil)
        
        self.view.addSubview(skView)
        print("test")
        print(self.view.subviews.count)
        for subview:UIView in self.view.subviews {
            
            print(subview)
            
        }
        if self.view.subviews[self.view.subviews.count - 1] != skView {
            print("Found")
            self.view.addSubview(skView)
            
        }
        
        skView.presentScene(scene)
        backButton.userInteractionEnabled = true
        backButton.hidden = false
        //skView.bringSubviewToFront(backButton)
        //self.view.bringSubviewToFront(backButton)
        //UIView.transitionFromView(skView, toView: backButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: nil)
        skView.insertSubview(backButton, aboveSubview: skView
        )
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    @IBAction func starButtonClicked(sender: AnyObject) {
        
        let url  = NSURL(string: "https://appsto.re/us/UTLq_.i")
        if UIApplication.sharedApplication().canOpenURL(url!) == true  {
            UIApplication.sharedApplication().openURL(url!)
        }
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
