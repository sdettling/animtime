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
    let blueC : UIColor = UIColor(red: 87/255, green: 91/255, blue: 168/255, alpha: 1.0)
    let redC : UIColor = UIColor(red: 237/255, green: 28/255, blue: 36/255, alpha: 1.0)
    let keysBorderC : UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
    let keysGrayC : UIColor = UIColor(red: 65/255, green: 64/255, blue: 66/255, alpha: 1.0)
    let whiteText : UIColor = UIColor(red: 241/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let grayC : UIColor = UIColor.grayColor()
    let disabledGrayC : UIColor = UIColor.darkGrayColor()
    
    @IBOutlet var resetHoldLabel: UILabel!
    @IBOutlet var resetDot: UIView!
    @IBOutlet var startDot: UIView!
    
    @IBOutlet weak var startToggle: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var keyButton: UIButton!
    
    @IBOutlet var secondsInput: UITextField!
    @IBOutlet var framesInput: UITextField!
    @IBOutlet var fpsInput: UITextField!
    
    @IBOutlet var keyTable: UITableView!
    
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
        
        doneToolbar.items = items
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
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
// Setup table view for keys
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = keyTable.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        cell.contentView.backgroundColor = keysGrayC
        cell.textLabel?.textColor = whiteText
        cell.detailTextLabel?.textColor = whiteText
        cell.textLabel?.font = UIFont(name: "AvenirNextCondensed-Regular", size: 24)
        cell.detailTextLabel?.font = UIFont(name: "AvenirNextCondensed-Regular", size: 24)
        var timeSinceLast = 0
        cell.textLabel?.text = String(indexPath.row + 1) + "  ●  " + formatSeconds(keys[indexPath.row])
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
        enableReset()
        disableEditing()
    
        if stoppedTime == startTime {
            startTime = NSDate.timeIntervalSinceReferenceDate()
            stoppedTime = startTime
        }
        else {
            startTime = startTime + (NSDate.timeIntervalSinceReferenceDate() - stoppedTime)
            println(NSDate.timeIntervalSinceReferenceDate() - stoppedTime)
            println(startTime)
        }
        
        if !timerStarted {
            println(startTime)
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
            enableFpsSelect()
        }
        updateTimerLabel()
        enableFpsSelect()
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        println(stoppedTime)
        
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
            }
        }
    }
    
    func updateTimerLabel() {
        let calculatedTime:Float = Float(NSDate.timeIntervalSinceReferenceDate() - startTime)
        secondsInput.text = formatSeconds(calculatedTime)
        framesInput.text = calulateFrames(calculatedTime)
    }
    
    func updateKeysList() {
        self.keyTable.reloadData()
        let numberOfSections = keyTable.numberOfSections()
        let numberOfRows = keyTable.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            println(numberOfSections)
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
        //let time:Float = Float(Float(secondsElapsed)/100)
        let framesEquivalent:Float = secondsElapsed * fps
        return NSString(format:"%.2f",framesEquivalent)
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
        disableReset()
        stoppedTime = startTime
    }
    
    func convertToSeconds(timecode:String)-> Int {
        var splitTime = split(timecode) {$0 == ":"}
        println(splitTime.count)
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
        if fps == 0 {
            fps = prevFps
            if fps % 1 == 0 {
                fpsInput.text = NSString(format:"%g",fps)
            }
            else {
                fpsInput.text = NSString(format:"%.2f",fps)
            }
        }
        //updateTimerLabel()
        
        let totalSeconds = (framesInput.text as NSString).floatValue / fps
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        startTime = stoppedTime - NSTimeInterval(totalSeconds)
        
        println(startTime)
        
        secondsInput.text = formatSeconds(totalSeconds)
        //framesInput.text = calulateFrames(totalSeconds)
        
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
        println(NSDate.timeIntervalSinceReferenceDate() - startTime)
        let timediff:Float = Float(NSDate.timeIntervalSinceReferenceDate() - startTime)
        
        keys.append(timediff)
        updateKeysList()
    }
    
    @IBAction func resetGesture(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began
        {
            //keys = []
            keys.removeAll()
            updateKeysList()
            hasKeys = false
            resetTimer()
            println("start")
        }
        if sender.state == UIGestureRecognizerState.Ended
        {
            println("end")
        }
    }
    @IBAction func framesUpdated() {
        let frames = (framesInput.text as NSString).floatValue
        if (frames == 0) {
            framesInput.text = "0.00"
        }
        var secs:Float = frames / fps
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        startTime = stoppedTime - NSTimeInterval(secs)
        
        ///// set timer to start at entered time
        
        //var secs:Float = frames / fps
        //timeElapsed = secs
        enableStart()
    }
    @IBAction func framesEditing(sender: AnyObject) {
        let frames = (framesInput.text as NSString).floatValue
        var secs:Float = frames / fps
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
        
        let totalSeconds = (fr/fps)+sec+(min*60)
        
        println(min)
        println(sec)
        println(fr)

        secondsInput.text = formatSeconds(totalSeconds)
        framesInput.text = calulateFrames(totalSeconds)
        
        
        stoppedTime = NSDate.timeIntervalSinceReferenceDate()
        startTime = stoppedTime - NSTimeInterval(totalSeconds)
        
        //update frames accordingly
        
        
        //let seconds = convertToSeconds(secondsInput.text)
        
        ///// set timer to start at entered time
        
        //timeElapsed = (seconds)
        //secondsInput.text = formatSeconds(seconds)
        enableStart()
    }
    
    @IBAction func secondsEditing(sender: AnyObject) {
        //let secondsValue = (secondsInput.text as NSString).integerValue
        var secondsText = secondsInput.text as NSString
        var timeNumbers = secondsText.stringByReplacingOccurrencesOfString(":", withString: "") as NSString
        
        let chars:Int = timeNumbers.length
        
        if chars < 3 {
            secondsText = timeNumbers
            secondsInput.text = secondsText
        }
        else if chars > 2 && chars < 5 {
            let rangeL = chars - 2
            let secChar = timeNumbers.substringWithRange(NSRange(location: 0, length: rangeL))
            let frChar = timeNumbers.substringWithRange(NSRange(location: rangeL, length: 2))
            secondsText = secChar+":"+frChar
            secondsInput.text = secondsText
        }
        else if chars > 4 && chars < 7 {
            let rangeL = chars - 4
            let minChar = timeNumbers.substringWithRange(NSRange(location: 0, length: rangeL))
            let secChar = timeNumbers.substringWithRange(NSRange(location: rangeL, length: 2))
            let frChar = timeNumbers.substringWithRange(NSRange(location: rangeL+2, length: 2))
            secondsText = minChar+":"+secChar+":"+frChar
            secondsInput.text = secondsText
            if chars == 6 {
                self.secondsInput.resignFirstResponder()
            }
        }
    }
    
    func convertToFrames(minutes:Int, seconds:Int, frames:Int) {
        var calculatedframes:Float = 0
        
        calculatedframes = (Float(minutes * 60) * fps) + (Float(seconds) * fps) + Float(frames)
        
        println(calculatedframes)
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
        for key in keys {
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