//
//  ViewController.swift
//  My Little Monster
//
//  Created by Caleb Stultz on 2/15/16.
//  Copyright © 2016 Caleb Stultz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var foodImg: DragImg!
    @IBOutlet weak var heartImg: DragImg!
    @IBOutlet weak var obedienceImg: DragImg!

    @IBOutlet weak var penalty1Img: SpringImageView!
    @IBOutlet weak var penalty2Img: SpringImageView!
    @IBOutlet weak var penalty3Img: SpringImageView!
    
    @IBOutlet weak var reviveBtn: UIButton!
    
    @IBOutlet weak var startLogo: SpringImageView!
    @IBOutlet weak var startBg: UIImageView!
    @IBOutlet weak var startBtn: SpringImageView!
    @IBOutlet weak var startGround: UIImageView!
    
    @IBOutlet weak var bubbleLbl: SpringLabel!
    @IBOutlet weak var speechBubble: SpringImageView!
    
    @IBOutlet weak var babyGolem: UIButton!
    @IBOutlet weak var golemSelect: UIButton!
    @IBOutlet weak var selectCharacter: UIButton!
    @IBOutlet weak var charSelectBg: UIImageView!
    @IBOutlet weak var golemNameLbl: UILabel!
    @IBOutlet weak var babyGolemNameLbl: UILabel!
    
    @IBOutlet weak var babyGolemSelected: SpringImageView!
    
    @IBOutlet weak var golemSelected: SpringImageView!
    
    @IBOutlet weak var selectedLbl: UILabel!
    
    @IBOutlet weak var selectScreenLogo: UIImageView!
    
    let dimAlpha: CGFloat = 0.2
    let opaque: CGFloat = 1.0
    let maxPenalties = 3
    
    var penalties = 0
    var timer: NSTimer!
    
    var monsterHappy = false
    var currentItem: UInt32?
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    var sfxObedience: AVAudioPlayer!
    var sfxReset: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemSelected()
        
        selectedLbl.text = "Select a character above!"
        bubbleLbl.text = "I want to play!"
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        obedienceImg.dropTarget = monsterImg
        
        reviveBtn.hidden = true
        
//        currentItem = rand
        
        penalty1Img.alpha = dimAlpha
        penalty2Img.alpha = dimAlpha
        penalty3Img.alpha = dimAlpha
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDroppedOnCharacter:", name: "onTargetDropped", object: nil)
        
        do {
            try musicPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!))
            
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            
            try sfxObedience = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("obedience", ofType: "wav")!))
            try sfxReset = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("click", ofType: "wav")!))

            
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxSkull.prepareToPlay()
            sfxObedience.prepareToPlay()
            sfxReset.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
//        startTimer()
        changeGameState(monsterHappy = true)
        
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeGameState", userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        
        if !monsterHappy {
            
            penalties++
            sfxSkull.play()
//            itemsReturned()
            
            if penalties == 1 {
                penalty1Img.alpha = opaque
                penalty1Img.animation = "zoomIn"
                penalty1Img.animate()
                penalty2Img.alpha = dimAlpha
            } else if penalties == 2 {
                penalty2Img.alpha = opaque
                penalty2Img.animation = "zoomIn"
                penalty2Img.animate()
                penalty3Img.alpha = dimAlpha
            } else if penalties >= 3 {
                penalty3Img.alpha = opaque
                penalty3Img.animation = "zoomIn"
                penalty3Img.animate()
            } else {
                penalty1Img.alpha = dimAlpha
                penalty2Img.alpha = dimAlpha
                penalty3Img.alpha = dimAlpha
            }
            
        }
    
        itemSelected()
        
        monsterHappy = false
        
        if penalties >= maxPenalties {
            gameOver()
        }
        
    }
    
    func itemDroppedOnCharacter(notif: AnyObject) {
        monsterHappy = true
        startTimer()
        
        foodImg.alpha = dimAlpha
        foodImg.userInteractionEnabled = false
        heartImg.alpha = dimAlpha
        heartImg.userInteractionEnabled = false
        obedienceImg.alpha = dimAlpha
        obedienceImg.userInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else if currentItem == 1 {
            sfxBite.play()
        } else if currentItem == 2 {
            sfxObedience.play()
        }
        
        fadeOutSpeechBubble()
    }
    
    func itemsReturned() {
        //Code to return items to original point so that a disabled item (food, heart, obey) can't be dropped after a life is lost.
    }
    
    func muteBtns() {
        foodImg.alpha = dimAlpha
        foodImg.userInteractionEnabled = false
        heartImg.alpha = dimAlpha
        heartImg.userInteractionEnabled = false
        obedienceImg.alpha = dimAlpha
        obedienceImg.userInteractionEnabled = false
    }
    
    func gameOver() {
        timer.invalidate()
        monsterImg.playDeathAnimation()
        sfxDeath.play()
        muteBtns()
        fadeOutSpeechBubble()
        reviveBtn.hidden = false
    }
    
    func animateSpeechBubble() {
        bubbleLbl.animation = "fadeIn"
        bubbleLbl.animate()
        speechBubble.animation = "fadeIn"
        speechBubble.animate()
    }
    
    func fadeOutSpeechBubble() {
        bubbleLbl.animation = "fadeOut"
        bubbleLbl.animate()
        speechBubble.animation = "fadeOut"
        speechBubble.animate()
    }
    
    func enableSelectBtn() {
        if babyGolemSelected.hidden == false || golemSelected.hidden == false {
        selectCharacter.alpha = 1.0
        selectCharacter.userInteractionEnabled = true
        }
    }
    
    @IBAction func babyGolemSelected(sender: AnyObject) {
        golemSelected.hidden = true
        babyGolemSelected.hidden = false
        babyGolemSelected.animation = "zoomIn"
        babyGolemSelected.animate()
        enableSelectBtn()
        selectedLbl.text = "Baby Golem selected!"
        sfxReset.play()
    }
    
    @IBAction func golemSelected(sender: AnyObject) {
        babyGolemSelected.hidden = true
        golemSelected.hidden = false
        golemSelected.animation = "zoomIn"
        golemSelected.animate()
        enableSelectBtn()
        selectedLbl.text = "Golem selected!"
        sfxReset.play()
    }
    
    
    func itemSelected() {
        let rand = arc4random_uniform(3)
        
        if rand == 0 {
            foodImg.alpha = dimAlpha
            foodImg.userInteractionEnabled = false
            heartImg.alpha = opaque
            heartImg.userInteractionEnabled = true
            obedienceImg.alpha = dimAlpha
            obedienceImg.userInteractionEnabled = false
            print ("Heart!")
            bubbleLbl.text = "Love me!"
        } else if rand == 1 {
            heartImg.alpha = dimAlpha
            heartImg.userInteractionEnabled = false
            foodImg.alpha = opaque
            foodImg.userInteractionEnabled = true
            obedienceImg.alpha = dimAlpha
            obedienceImg.userInteractionEnabled = false
            print ("Food!")
            bubbleLbl.text = "I'm so hungry!"
        } else if rand == 2 {
            heartImg.alpha = dimAlpha
            heartImg.userInteractionEnabled = false
            foodImg.alpha = dimAlpha
            foodImg.userInteractionEnabled = false
            obedienceImg.alpha = opaque
            obedienceImg.userInteractionEnabled = true
            print ("Obedience!")
            bubbleLbl.text = "I'm so great!"
        }
        
        animateSpeechBubble()
        
        currentItem = rand
    }
    
    @IBAction func reviveBtn(sender: AnyObject) {
        monsterImg.playIdleAnimation()
        penalty1Img.alpha = dimAlpha
        penalty2Img.alpha = dimAlpha
        penalty3Img.alpha = dimAlpha
        penalties = 0
        itemSelected(currentItem = 0)
        startTimer()
        sfxReset.play()
        reviveBtn.hidden = true
    }
    
    @IBAction func startGame(sender: AnyObject) {
        startLogo.hidden = true
        startBtn.hidden = true
        startBg.hidden = true
        startGround.hidden = true
        sfxReset.play()
}
    @IBAction func selectCharacterBtn(sender: AnyObject) {
        charSelectBg.hidden = true
        babyGolem.hidden = true
        golemSelect.hidden = true
        babyGolemNameLbl.hidden = true
        golemNameLbl.hidden = true
        selectCharacter.hidden = true
        babyGolemSelected.hidden = true
        golemSelected.hidden = true
        selectedLbl.hidden = true
        selectScreenLogo.hidden = true
        sfxReset.play()
        startTimer()
        animateSpeechBubble()
        bubbleLbl.hidden = false
        speechBubble.hidden = false
    }
}