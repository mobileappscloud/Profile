//
//  UserProfileViewController.swift
//  higi
//
//  Created by Faisal Syed on 10/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController
{

    let imageView: UIImageView =
    {
        let view = UIImageView()
        view.backgroundColor = UIColor.redColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("123")
        
        view.addSubview(imageView)
        
        setUpUI()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setUpUI()
    {
        //x,y,w,h
        imageView.widthAnchor.constraintEqualToConstant(200).active = true
        imageView.heightAnchor.constraintEqualToConstant(200).active = true
        imageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        imageView.centerYAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    }
}
