//
//  ViewController.swift
//  Quad Controller
//
//  Created by  WhiteCatGroup on 12.01.16.
//  Copyright © 2016 WhiteCatGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var editAddress: UITextField!
    @IBOutlet weak var editScript: UITextView!
    @IBOutlet weak var lbScript: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        lbScript.hidden = true
        editScript.hidden = true
        btnSend.enabled = false
        
        if kIsFileExists(FileName: "lastip.txt") {
            let text: String? = kLoadTextFile(FileName: "lastip.txt")
            if text != nil {
                editAddress.text = text!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickBackground(sender: AnyObject) {
        editAddress.resignFirstResponder()
        editScript.resignFirstResponder()
    }

    @IBAction func clickSend(sender: AnyObject) {
        btnSend.enabled = false
        SRWebClient.POST("http://" + editAddress.text! + "/run").data(["script":editScript.text.base64Encoded()]).send({ (response: AnyObject!, status: Int) -> Void in
            
                kShowMessage(Title: "Message", Text: (response as! String), Delegate: self)
                self.btnSend.enabled = true
            
            }, failure: { (error: NSError!) -> Void in
                
                kShowMessage(Title: "Error", Text: error.localizedDescription , Delegate: self)
                self.btnSend.enabled = true
        })
    }

    @IBAction func clickConnect(sender: AnyObject) {
        SRWebClient.GET("http://" + editAddress.text! + "/life").send({ (response: AnyObject!, status: Int) -> Void in
            
                if ((response as! String) == "alive") {
                    self.editAddress.text!.writeToDocumentsDir("lastip.txt") // save last available address
                    self.lbScript.hidden = false
                    self.editScript.hidden = false
                    self.btnSend.enabled = true
                    kShowMessage(Title: "Message", Text: "Connected", Delegate: self)
                } else {
                    self.lbScript.hidden = true
                    self.editScript.hidden = true
                    self.btnSend.enabled = false
                    kShowMessage(Title: "Message", Text: "Unable to connect: \"" + (response as! String) + "\"", Delegate: self)
                }
            
            }, failure: { (error: NSError!) -> Void in
                
                self.lbScript.hidden = true
                self.editScript.hidden = true
                self.btnSend.enabled = false
                kShowMessage(Title: "Error", Text: error.localizedDescription, Delegate: self)
                
        })
    }
    

}

