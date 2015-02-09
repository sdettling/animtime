//
//  EmailComposer.swift
//  ANIMTIME
//
//  Created by Stephen Dettling on 2/8/15.
//  Copyright (c) 2015 Stephen Dettling. All rights reserved.
//

import Foundation
import MessageUI

class EmailComposer: NSObject, MFMailComposeViewControllerDelegate {
    // Did this in order to mitigate needing to import MessageUI in my View Controller
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController(emailBody:String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setSubject("ANIMTIME Key List")
        mailComposerVC.setMessageBody(emailBody, isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}