//
//  ViewController.swift
//  ANIMTIME
//
//  Created by Stephen Dettling on 2/3/15.
//  Copyright (c) 2015 Stephen Dettling. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let emailComposer = EmailComposer()
    let messageComposer = MessageComposer()
    
    var startTime = NSDate.timeIntervalSinceReferenceDate()
    var timeElapsed:Int = 0
    var timerRunning: Bool = false
    var timerStarted: Bool = false
    var stoppedTime = NSDate.timeIntervalSinceReferenceDate()
    var fps:Float = 24.0
    var keys: [Float] = []
    var hasKeys: Bool = false
    let greenC : UIColor = UIColor(red: 0, green: 166/255, blue: 81/255, alpha: 1.0)
    let yellowC : UIColor = UIColor(red: 243/255, green: 202/255, blue: 47/255, alpha: 1.0)
    let blueC : UIColor = UIColor(red: 98/255, green: 89/255, blue: 215/255, alpha: 1.0)
    let redC : UIColor = UIColor(red: 237/255, green: 28/255, blue: 36/255, alpha: 1.0)
    let keysBorderC : UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
    let keysGrayC : UIColor = UIColor(red: 65/255, green: 64/255, blue: 66/255, alpha: 1.0)
    let outlinesGrayC : UIColor = UIColor(red: 89/255, green: 90/255, blue: 93/255, alpha: 1.0)
    let whiteText : UIColor = UIColor(red: 241/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let grayC : UIColor = UIColor.grayColor()
    let disabledGrayC : UIColor = UIColor.darkGrayColor()
    
    @IBOutlet var resetHoldLabel: UILabel!
    @IBOutlet var resetDot: UIView!
    @IBOutlet var startDot: UIView!
    @IBOutlet var dot1: UIView!
    @IBOutlet var dot2: UIView!
    @IBOutlet var dot3: UIView!
    
    @IBOutlet weak var startToggle: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var keyButton: UIButton!
    
    @IBOutlet var secondsInput: UITextField!
    @IBOutlet var framesInput: UITextField!
    @IBOutlet var fpsInput: UITextField!
    
    @IBOutlet var keyTable: UITableView!
    
    @IBOutlet var fpsOutline: UIView!
    @IBOutlet var timeOutline: UIView!
    @IBOutlet var framesOutline: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fpsInput.delegate = self
        self.secondsInput.delegate = self
        self.framesInput.delegate = self
        self.keyTable.backgroundColor = keysGrayC
        self.keyTable.allowsSelection = false
        self.keyTable.rowHeight = 40
        self.keyTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.addDoneButtonOnKeyboard()
        
        //Add outlines to elements
        fpsOutline.layer.borderColor = outlinesGrayC.CGColor
        fpsOutline.layer.borderWidth = 2
        fpsOutline.layer.cornerRadius = 6
        timeOutline.layer.borderColor = outlinesGrayC.CGColor
        timeOutline.layer.borderWidth = 2
        timeOutline.layer.cornerRadius = 6
        framesOutline.layer.borderColor = outlinesGrayC.CGColor
        framesOutline.layer.borderWidth = 2
        framesOutline.layer.cornerRadius = 6
        
        startToggle.layer.borderColor = greenC.CGColor
        startToggle.layer.borderWidth = 2
        startToggle.layer.cornerRadius = 6
        
        resetButton.layer.borderColor = yellowC.CGColor
        resetButton.layer.borderWidth = 2
        resetButton.layer.cornerRadius = 6
        
        keyButton.layer.borderColor = blueC.CGColor
        keyButton.layer.borderWidth = 2
        keyButton.layer.cornerRadius = 6
        
        resetDot.layer.cornerRadius = 6
        startDot.layer.cornerRadius = 6
        dot1.layer.cornerRadius = 6
        dot2.layer.cornerRadius = 6
        dot3.layer.cornerRadius = 6
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// Add done button to number keyboard
    
    func addDoneButtonOnKeyboard()
    {
        var doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        var items = NSMutableArray()
        items.addObject(flexSpace)
        items.addObject(done)
        
        doneToolbar.items = items as [AnyObject]
        doneToolbar.sizeToFit()
        
        self.fpsInput.inputAccessoryView = doneToolbar
        self.secondsInput.inputAccessoryView = doneToolbar
        self.framesInput.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.fpsInput.resignFirstResponder()
        self.secondsInput.resignFirstResponder()
        self.framesInput.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
// Setup table view for keys
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = keyTable.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        cell.contentView.backgroundColor = keysGrayC
        cell.textLabel?.textColor = whiteText
        cell.detailTextLabel?.textColor = whiteText
        cell.textLabel?.font = UIFont(name: "AvenirNextCondensed-Regular", size: 24)
        cell.detailTextLabel?.font = UIFont(name: "AvenirNextCondensed-Regular", size: 24)
        var timeSinceLast = 0
        var keyNum = indexPath.row + 1
        var strKeyNum = String(keyNum)
        if keyNum < 10 {
            strKeyNum = "\u{2000}\u{2000}" + String(keyNum)
        }
        else if keyNum < 100 {
            strKeyNum = "\u{2000}" + String(keyNum)
        }
        
        cell.textLabel?.text = strKeyNum + "  ●  " + formatSeconds(keys[indexPath.row])
        cell.detailTextLabel?.text = calulateFrames(keys[indexPath.row])
        
        return cell
    }
    
    
    func disableEditing() {
        secondsInput.enabled = false
        framesInput.enabled = false
    }
    
    func enableEditing() {
        secondsInput.enabled = true
        framesInput.enabled = true
    }
    
    func disableStart() {
        startToggle.enabled = false
    }
    
    func enableStart() {
        startToggle.enabled = true
    }
    
    func disableReset() {
        resetButton.enabled = false
    }
    
    func enableReset() {
        resetButton.enabled = true
    }
    
    
    
    func startTimer() {
        timerRunning = true
        disableEditing()
    
        if stoppedTime == startTime {
            startTime = NSDate.timeIntervalSinceReferenceDate()
            stoppedTime = startTime
        }
        else {
            startTime = startTime + (NSDate.timeIntervalSinceReferenceDate() - stoppedTime)
        }
        
        if !timerStarted {
            let myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "advanceTime", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(myTimer, forMode: NSRunLoopCommonModes)
            timerStarted = true
        }
        
        startToggle.setTitle("STOP", forState: .Normal)
        startToggle.setTitleColor(redC, forState: .Normal)
        startToggle.layer.borderColor = redC.CGColor
        startDot.backgroundColor = redC
        
        resetDot.backgroundColor = blueC
        resetHoldLabel.layer.zPosition = 0;
        resetButton.layer.zPosition = 0;
        resetDot.layer.zPosition = 2;
        keyButton.layer.zPosition = 1;
        resetButton.alpha = 0;
        keyButton.alpha = 1;
        
        disableFpsSelect()
        
    }
    
    func stopTimer() {
        if !hasKeys {
            enableEditing()
        }
        updateTimerLabel()
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        
        timerRunning = false
        startToggle.setTitle("START", forState: .Normal)
        startToggle.setTitleColor(greenC, forState: .Normal)
        startToggle.layer.borderColor = greenC.CGColor
        startDot.backgroundColor = greenC
        
        resetDot.backgroundColor = yellowC
        resetHoldLabel.layer.zPosition = 3;
        resetButton.layer.zPosition = 1;
        resetDot.layer.zPosition = 2;
        keyButton.layer.zPosition = 0;
        resetButton.alpha = 1;
        keyButton.alpha = 0;
    }
    
    func advanceTime() {
        if timerRunning {
            timeElapsed += 1
            if ( timeElapsed%3 == 0 ) {
                updateTimerLabel()
                var calculatedTime:Float = Float(NSDate.timeIntervalSinceReferenceDate() - startTime)
                if calculatedTime > 3600 {
                    stopTimer()
                    resetTimer()
                }
            }
        }
    }
    
    func updateTimerLabel() {
        var calculatedTime:Float = Float(NSDate.timeIntervalSinceReferenceDate() - startTime)
        secondsInput.text = formatSeconds(calculatedTime)
        framesInput.text = calulateFrames(calculatedTime)
    }
    
    func updateKeysList() {
        self.keyTable.reloadData()
        let numberOfSections = keyTable.numberOfSections()
        let numberOfRows = keyTable.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            keyTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    func enableFpsSelect() {
        fpsInput.enabled = true
        fpsInput.layer.borderColor = grayC.CGColor
    }
    
    func disableFpsSelect() {
        fpsInput.enabled = false
        fpsInput.layer.borderColor = disabledGrayC.CGColor
    }
    
    func calulateFrames(secondsElapsed:Float)-> String {
        let framesEquivalent:Float = secondsElapsed * fps
        return NSString(format:"%.2f",framesEquivalent) as String
    }
    
    func formatSeconds(secondsElapsed:Float)-> String {
        let time:Float = secondsElapsed
        let minutes = UInt32(time / 60)
        let seconds = UInt32(UInt32(time) - minutes * 60)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        let fraction = Int(round(secondsElapsed * fps % fps))
        let strFraction = fraction > 9 ? String(fraction):"0" + String(fraction)
        let timeString = "\(strMinutes):\(strSeconds):\(strFraction)"
        return timeString
    }
    
    func resetTimer() {
        timeElapsed = 0
        stoppedTime = 0
        secondsInput.text = "00:00:00"
        framesInput.text = "0.00"
        enableEditing()
        enableFpsSelect()
        enableStart()
        stoppedTime = startTime
    }
    
    func convertToSeconds(timecode:String)-> Int {
        var splitTime = split(timecode) {$0 == ":"}
        if splitTime.count == 1 {
            var seconds = (secondsInput.text as NSString).floatValue
            return Int(seconds * 100)
        }
        else if splitTime.count == 2 {
            var seconds: Float = (splitTime[1] as NSString).floatValue
            var minutes: Float = (splitTime[0] as NSString).floatValue
            var totalSeconds = minutes * 60 + seconds
            return Int(totalSeconds * 100)
        }
        else
        {
            return 0
        }
    }
    
    @IBAction func fpsUpdated() {
        let prevFps = fps
        fps = (fpsInput.text as NSString).floatValue
        if fps >= 100 {
            fps = prevFps
            self.fpsInput.resignFirstResponder()
            let alertController = UIAlertController(title: "Error", message: "FPS must be less than 100.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        if fps == 0 {
            fps = prevFps
        }
        if fps % 1 == 0 {
            fpsInput.text = NSString(format:"%g",fps) as String
        }
        else {
            fpsInput.text = NSString(format:"%.2f",fps) as String
        }
        
        let totalSeconds = (framesInput.text as NSString).floatValue / fps
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        startTime = stoppedTime - NSTimeInterval(totalSeconds)
        
        secondsInput.text = formatSeconds(totalSeconds)
        
        enableStart()
    }
    
    
    @IBAction func startButton() {
        if timerRunning {
            stopTimer()
        }
        else {
            startTimer()
        }
    }
    
    @IBAction func intervalButton() {
        if !hasKeys {
            hasKeys = true
            disableEditing()
            disableFpsSelect()
        }
        let timediff:Float = Float(NSDate.timeIntervalSinceReferenceDate() - startTime)
        
        keys.append(timediff)
        updateKeysList()
    }
    
    @IBAction func resetGesture(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began
        {
            keys.removeAll()
            updateKeysList()
            hasKeys = false
            resetTimer()
        }
    }
    @IBAction func framesUpdated() {
        let frames = (framesInput.text as NSString).floatValue
        if (frames == 0) {
            framesInput.text = "0.00"
        }
        else {
            framesInput.text = NSString(format:"%.2f",frames) as String
        }
        var secs:Float = frames / fps
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        startTime = stoppedTime - NSTimeInterval(secs)

        enableStart()
    }
    @IBAction func framesEditing(sender: AnyObject) {
        let frames = (framesInput.text as NSString).floatValue
        var secs:Float = frames / fps
        
        if secs > 3600 {
            secs = 0
            self.framesInput.resignFirstResponder()
            let alertController = UIAlertController(title: "Error", message: "The number of frames you entered exceeded the maximum allowed time of 1 hour.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        secondsInput.text = formatSeconds(secs)
    }
    
    @IBAction func secondsUpdated() {
        var secondsText = secondsInput.text as NSString
        var timeNumbers = secondsText.stringByReplacingOccurrencesOfString(":", withString: "") as NSString
        var timeInt = timeNumbers.integerValue
        let chars:Int = timeNumbers.length
        var min:Float = 0
        var sec:Float = 0
        var fr:Float = 0
        if chars < 3 {
            fr = timeNumbers.floatValue
        }
        else if chars > 2 && chars < 5 {
            let rangeL = chars - 2
            let secChar = timeNumbers.substringWithRange(NSRange(location: 0, length: rangeL)) as NSString
            let frChar = timeNumbers.substringWithRange(NSRange(location: rangeL, length: 2)) as NSString
            sec = secChar.floatValue
            fr = frChar.floatValue
        }
        else if chars > 4 && chars < 7 {
            let rangeL = chars - 4
            let minChar = timeNumbers.substringWithRange(NSRange(location: 0, length: rangeL)) as NSString
            let secChar = timeNumbers.substringWithRange(NSRange(location: rangeL, length: 2)) as NSString
            let frChar = timeNumbers.substringWithRange(NSRange(location: rangeL+2, length: 2)) as NSString
            min = minChar.floatValue
            sec = secChar.floatValue
            fr = frChar.floatValue
        }
        
        var totalSeconds = (fr/fps)+sec+(min*60)
        
        if totalSeconds > 3600 {
            totalSeconds = 0
            let alertController = UIAlertController(title: "Error", message: "The time you entered exceeded the maximum allowed time of 1 hour.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        secondsInput.text = formatSeconds(totalSeconds)
        framesInput.text = calulateFrames(totalSeconds)
        
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        startTime = stoppedTime - NSTimeInterval(totalSeconds)

        enableStart()
    }
    
    @IBAction func secondsEditing(sender: AnyObject) {
        var secondsText = secondsInput.text as NSString
        var timeNumbers = secondsText.stringByReplacingOccurrencesOfString(":", withString: "") as NSString
        
        let chars:Int = timeNumbers.length
        
        if chars < 3 {
            secondsText = timeNumbers
            secondsInput.text = secondsText as String
        }
        else if chars > 2 && chars < 5 {
            let rangeL = chars - 2
            let secChar = timeNumbers.substringWithRange(NSRange(location: 0, length: rangeL))
            let frChar = timeNumbers.substringWithRange(NSRange(location: rangeL, length: 2))
            secondsText = secChar+":"+frChar
            secondsInput.text = secondsText as String
        }
        else if chars > 4 && chars < 7 {
            let rangeL = chars - 4
            let minChar = timeNumbers.substringWithRange(NSRange(location: 0, length: rangeL))
            let secChar = timeNumbers.substringWithRange(NSRange(location: rangeL, length: 2))
            let frChar = timeNumbers.substringWithRange(NSRange(location: rangeL+2, length: 2))
            secondsText = minChar+":"+secChar+":"+frChar
            secondsInput.text = secondsText as String
            if chars == 6 {
                self.secondsInput.resignFirstResponder()
            }
        }
    }
    
    func convertToFrames(minutes:Int, seconds:Int, frames:Int) {
        var calculatedframes:Float = 0
        
        calculatedframes = (Float(minutes * 60) * fps) + (Float(seconds) * fps) + Float(frames)

    }
    
    func convertToTimecode(time:Float)->String {
        let minutes = UInt32(time / 60)
        let seconds = UInt32(UInt32(time) - minutes * 60)
        let strMinutes = String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        let timeString = "\(strMinutes):\(strSeconds)"
        return timeString
    }
    
    func prepareTextForShare()->String {
        var textBody:String = ""
        for (index, key) in enumerate(keys) {
            textBody = textBody + String(index+1)
            textBody = textBody + " - "
            textBody = textBody + formatSeconds(key)
            textBody = textBody + "     "
            textBody = textBody + calulateFrames(key)
            textBody = textBody + "\n"
        }
        
        return textBody
    }
    
    @IBAction func sendEmail(sender: AnyObject) {
        let configuredMailComposeViewController = emailComposer.configuredMailComposeViewController(prepareTextForShare())
        if emailComposer.canSendMail() {
            presentViewController(configuredMailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    
    @IBAction func sendMessage(sender: AnyObject) {
        prepareTextForShare()
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController(prepareTextForShare())
            
            // Present the configured MFMessageComposeViewController instance
            // Note that the dismissal of the VC will be handled by the messageComposer instance,
            // since it implements the appropriate delegate call-back
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
        
    }
    
    @IBAction func fpsEditStart(sender: AnyObject) {
        disableStart()
    }
    @IBAction func secondsEditingStart(sender: AnyObject) {
        disableStart()
    }
    @IBAction func framesEditStart(sender: AnyObject) {
        disableStart()
    }
    
}