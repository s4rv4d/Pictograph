//
//  MainEncodingView.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let mainFontSize: CGFloat = 20

private let bigButtonHeight: CGFloat = 60
private let buttonBorderWidth: CGFloat = 0.5
private let buttonCenterMargin: CGFloat = 5

private let encryptionMargin: CGFloat = 25
private let encryptionVerticalMargin: CGFloat = 20

class MainEncodingView: UIView {
    
    //UI elements
    var encodeButton = PictographHighlightButton()
    var decodeButton = PictographHighlightButton()
    var encryptionKeyField = PictographInsetTextField()
    var encryptionLabel = UILabel()
    var encryptionSwitch = UISwitch()
    var encryptionInfoViewBorder = UIView()
    
    //MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let encryptionEnabled = PictographDataController.sharedController.getUserEncryptionEnabled()
        
        //Label for enabling encryption, location for views based off this view
        encryptionLabel.text = "Use Password"
        encryptionLabel.font = UIFont.boldSystemFontOfSize(mainFontSize)
        encryptionLabel.textColor = UIColor.whiteColor()
        encryptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(encryptionLabel)
        
        //0px from left
        addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Left, relatedBy: .Equal, toItem:self, attribute: .Left, multiplier:1, constant:encryptionMargin))
        
        let screenSize = max(UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width)
        if screenSize <= 568 {
            //iPhone 5 and iPhone 4 size screens
            //20px from top of screen
            addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Top, relatedBy: .Equal, toItem:self, attribute: .Top, multiplier:1, constant:encryptionVerticalMargin))
        } else {
            //All other devices
            //-140px(above) center of view
            addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Top, relatedBy: .Equal, toItem:self, attribute: .CenterY, multiplier:1, constant:-encryptionVerticalMargin * 7))
        }
        
        
        //Switch for enabling encryption
        encryptionSwitch.on = encryptionEnabled
        encryptionSwitch.translatesAutoresizingMaskIntoConstraints = false
        addSubview(encryptionSwitch)
        
        //50px from right, center Y = encryptionLabel's center y
        addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -encryptionMargin))
        addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: encryptionLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        
        //Textfield where encryption key is stored
        encryptionKeyField.alpha = encryptionEnabled ? 1.0 : 0.5
        encryptionKeyField.enabled = encryptionEnabled
        encryptionKeyField.secureTextEntry = !PictographDataController.sharedController.getUserShowPasswordOnScreen()
        encryptionKeyField.backgroundColor = UIColor.whiteColor()
        encryptionKeyField.font = UIFont.systemFontOfSize(mainFontSize)
        encryptionKeyField.placeholder = "Encryption Password"
        encryptionKeyField.text = PictographDataController.sharedController.getUserEncryptionKey()
        encryptionKeyField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(encryptionKeyField)
        
        //50px from left, right, -80px (above) center y
        addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Top, relatedBy: .Equal, toItem:encryptionLabel, attribute:.Bottom, multiplier:1, constant:encryptionVerticalMargin))
        addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Left, relatedBy:.Equal, toItem:self, attribute: .Left, multiplier:1, constant:encryptionMargin))
        addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Right, relatedBy: .Equal, toItem:self,  attribute: .Right, multiplier:1, constant:-encryptionMargin))
        
        
        //Border between text label and switch for enabling and disabling encryption
        encryptionInfoViewBorder.backgroundColor = UIColor.whiteColor()
        encryptionInfoViewBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(encryptionInfoViewBorder)
        
        //Halfway between the textfield and the buttons, 30px from left, right, 1px tall
        addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Top, relatedBy: .Equal, toItem: encryptionKeyField, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: encryptionMargin - 10))
        addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -encryptionMargin + 10))
        addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        
        
        //Encode button
        encodeButton.backgroundColor = UIColor.whiteColor()
        encodeButton.setTitleColor(mainAppColor, forState: .Normal)
        encodeButton.setTitleColor(mainAppColorHighlighted, forState: .Highlighted)
        encodeButton.setTitle("Hide Message", forState: .Normal)
        encodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        encodeButton.layer.cornerRadius = 2.0
        
        addSubview(encodeButton)
        
        //20px from border, 40px from left, right, 60px tall
        addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Top, relatedBy: .Equal, toItem: encryptionInfoViewBorder, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: encryptionMargin))
        addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: -buttonCenterMargin))
        addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
        
        //Decode button
        decodeButton.backgroundColor = UIColor.whiteColor()
        decodeButton.setTitleColor(mainAppColor, forState: .Normal)
        decodeButton.setTitleColor(mainAppColorHighlighted, forState: .Highlighted)
        decodeButton.setTitle("Show Message", forState: .Normal)
        decodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        decodeButton.layer.cornerRadius = 2.0
        
        addSubview(decodeButton)
        
        //20px from encodeButton, 40px from left, right, 60px tall
        addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Top, relatedBy: .Equal, toItem: encryptionInfoViewBorder, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: buttonCenterMargin))
        addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -encryptionMargin))
        addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}