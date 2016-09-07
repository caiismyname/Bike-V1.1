//
//  addAnnouncementViewController.swift
//  Bike iOS
//
//  Created by David Cai on 9/5/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class addAnnouncementViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    let ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("addAnnouncements did load")
        
        // Setting the textfield/view appearence settigns
        messageTextView.layer.borderWidth = 1.0
        messageTextView.layer.borderColor = UIColor.init(red: CGFloat(200.0/255.0), green: CGFloat(200.0/255.0), blue: CGFloat(206.0/255.0), alpha: CGFloat(1)).CGColor
        messageTextView.layer.cornerRadius = 10.0
        
        // Can't save until you've entered stuff
        saveButtonOutlet.enabled = false
        
        // Set the delegates
        titleTextField.delegate = self
        messageTextView.delegate = self
    
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextField and UITextView Delegates
    
    func enableSave() {
        if titleTextField.text?.isEmpty == false && messageTextView.text.isEmpty == false {
            saveButtonOutlet.enabled = true
        } else {
            saveButtonOutlet.enabled = false
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        enableSave()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        enableSave()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        enableSave()
    }
    
    // MARK: Actions
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveAction(sender: UIBarButtonItem) {
        print("saveAction")
        print(titleTextField.text!)
        print(messageTextView.text!)
        ref.child("colleges/\(thisUser.college)/announcements/\(titleTextField.text!)").setValue(["type": "general", "message": messageTextView.text!, "authorUsername": thisUser.userName, "authorFullname": thisUser.fullName])
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
