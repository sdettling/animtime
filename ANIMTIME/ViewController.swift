//
//  ViewController.swift
//  ANIMTIME
//
//  Created by Stephen Dettling on 2/3/15.
//  Copyright (c) 2015 Stephen Dettling. All rights reserved.
//

//When already reset (all 0s) disable reset button
    //enable when timer starts, or f/s is greater than 0, or keys exist

//While editing
    //disable start, reset button

//While timer running
    //disable editing

//While keys exist
    //disable editing


import UIKit
import MessageUI

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let emailComposer = EmailComposer()
    let messageComposer = MessageComposer()
    
    var timeElapsed:Int = 0
    var timerRunning: Bool = false
    var timerStarted: Bool = false
    var fps:Float = 24.0
    var keys: [Int] = []
    var hasKeys: Bool = false
    let greenC : UIColor = UIColor.greenColor()
    let redC : UIColor = UIColor.redColor()
    let blueC : UIColor = UIColor.blueColor()
    let grayC : UIColor = UIColor.grayColor()
    let disabledGrayC : UIColor = UIColor.darkGrayColor()
    
    @IBOutlet var fpsSegmented: UISegmentedControl!
    
    //@IBOutlet weak var secondsDisplay: UILabel!
    //@IBOutlet weak var framesDisplay: UILabel!
    
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
        self.keyTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.addDoneButtonOnKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
        self.framesInput.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.fpsInput.resignFirstResponder()
        self.framesInput.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = keyTable.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        cell.contentView.backgroundColor = UIColor.grayColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        var timeSinceLast = 0
        if indexPath.row > 0 {
            timeSinceLast = keys[indexPath.row] - keys[(indexPath.row - 1)]
        }
        cell.textLabel?.text = String(indexPath.row) + "    " + formatSeconds(keys[indexPath.row])
        cell.detailTextLabel?.text = formatSeconds(timeSinceLast) + "    " + calulateFrames(keys[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
        
        if !timerStarted {
            let myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "advanceTime", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(myTimer, forMode: NSRunLoopCommonModes)
            timerStarted = true
        }
        
        startToggle.setTitle("STOP", forState: .Normal)
        startToggle.setTitleColor(redC, forState: .Normal)
        startToggle.layer.borderColor = redC.CGColor
        
        resetButton.layer.zPosition = 0;
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
        
        timerRunning = false
        startToggle.setTitle("START", forState: .Normal)
        startToggle.setTitleColor(greenC, forState: .Normal)
        startToggle.layer.borderColor = greenC.CGColor
        
        resetButton.layer.zPosition = 1;
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
        secondsInput.text = formatSeconds(timeElapsed)
        framesInput.text = calulateFrames(timeElapsed)
    }
    
    func updateKeysList() {
        self.keyTable.reloadData()
    }
    
    func enableFpsSelect() {
        fpsInput.enabled = true
        fpsInput.layer.borderColor = grayC.CGColor
        fpsSegmented.setEnabled(true, forSegmentAtIndex: 0)
        fpsSegmented.setEnabled(true, forSegmentAtIndex: 1)
        fpsSegmented.setEnabled(true, forSegmentAtIndex: 2)
        fpsSegmented.tintColor = grayC
    }
    
    func disableFpsSelect() {
        fpsInput.enabled = false
        fpsInput.layer.borderColor = disabledGrayC.CGColor
        fpsSegmented.setEnabled(false, forSegmentAtIndex: 0)
        fpsSegmented.setEnabled(false, forSegmentAtIndex: 1)
        fpsSegmented.setEnabled(false, forSegmentAtIndex: 2)
        fpsSegmented.tintColor = disabledGrayC
    }
    
    func calulateFrames(secondsElapsed:Int)-> String {
        let time:Float = Float(Float(secondsElapsed)/100)
        let framesEquivalent:Float = time * fps
        return NSString(format:"%.2f",framesEquivalent)
    }
    
    func formatSeconds(secondsElapsed:Int)-> String {
        let time:Float = Float(Float(secondsElapsed)/100)
        let minutes = UInt32(time / 60)
        let seconds = UInt32(UInt32(time) - minutes * 60)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        var strFraction = NSString(format:"%.2f",time)
        let stringCount = strFraction.length - 2
        strFraction = strFraction.substringWithRange(NSRange(location: stringCount, length: 2))
        let timeString = "\(strMinutes):\(strSeconds).\(strFraction)"
        return timeString
    }
    
    func resetTimer() {
        timeElapsed = 0
        secondsInput.text = "00:00.00"
        framesInput.text = "0000.00"
        enableEditing()
        enableFpsSelect()
        enableStart()
        disableReset()
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
            fpsInput.text = NSString(format:"%.2f",fps)
        }
        switch fps
        {
        case 24:
            fpsSegmented.selectedSegmentIndex = 0
        case 30:
            fpsSegmented.selectedSegmentIndex = 1
        case 25:
            fpsSegmented.selectedSegmentIndex = 2
        default:
            fpsSegmented.selectedSegmentIndex = UISegmentedControlNoSegment
        }
        updateTimerLabel()
        enableStart()
    }
    @IBAction func fpsQuickSelect(sender: UISegmentedControl, forEvent event: UIEvent) {
        switch fpsSegmented.selectedSegmentIndex
        {
        case 0:
            fps = 24
        case 1:
            fps = 30
        case 2:
            fps = 25
        default:
            break; 
        }
        fpsInput.text = NSString(format:"%g",fps)
        updateTimerLabel()
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
        keys.append(timeElapsed)
        updateKeysList()
    }
    
    @IBAction func resetGesture(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began
        {
            keys = []
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
        var secs:Float = frames / fps * 100
        timeElapsed = (Int(secs))
        enableStart()
    }
    @IBAction func framesEditing(sender: AnyObject) {
        let frames = (framesInput.text as NSString).floatValue
        var secs:Float = frames / fps * 100
        secondsInput.text = formatSeconds(Int(secs))
    }
    
    @IBAction func secondsUpdated() {
        let seconds = convertToSeconds(secondsInput.text)
        timeElapsed = (seconds)
        secondsInput.text = formatSeconds(seconds)
        enableStart()
    }
    
    @IBAction func secondsEditing(sender: AnyObject) {
        let seconds = convertToSeconds(secondsInput.text)
        framesInput.text = calulateFrames(seconds)
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