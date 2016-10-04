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

    @IBOutlet weak var grayView: UIView!
    let imageView: UIImageView =
    {
        let view = UIImageView()
        view.backgroundColor = UIColor.blueColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Name"
        label.textColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
        label.font = UIFont.boldSystemFontOfSize(17)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationLabel: UILabel =
    {
        let label = UILabel()
        label.text = "City, State"
        label.textColor = UIColor(red:0.35, green:0.35, blue:0.35, alpha:1.0)
        label.font = UIFont(name: "Medium", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followingLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Following"
        label.textColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
        label.font = UIFont.boldSystemFontOfSize(10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followingNumbersLabel: UILabel =
    {
        let label = UILabel()
        label.text = "100"
        label.textColor = UIColor.blueColor()
        label.font = UIFont.boldSystemFontOfSize(25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followersLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Followers"
        label.textColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
        label.font = UIFont.boldSystemFontOfSize(7.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followersNumbersLabel: UILabel =
    {
        let label = UILabel()
        label.text = "100"
        label.textColor = UIColor.blueColor()
        label.font = UIFont.boldSystemFontOfSize(25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followButton: UIButton =
    {
        let btn = UIButton(type: .System)
        btn.setTitle("FOLLOW", forState: .Normal)
        btn.backgroundColor = UIColor.blueColor()
        btn.titleLabel?.textColor = UIColor.whiteColor()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    class func instanceFromNib() ->UIView
    {
        return UINib(nibName: "UserProfileView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    lazy var navigationBar: UINavigationBar =
    {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64))
        navBar.backgroundColor = UIColor.blueColor()
        let navigationItem = UINavigationItem()
        navigationItem.title = "Profile"
        
        let leftButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = leftButton
        
        navBar.items = [navigationItem]
        return navBar
        
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.addSubview(navigationBar)
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(locationLabel)
        view.addSubview(followingLabel)
        /*view.addSubview(followingNumbersLabel)
        view.addSubview(followersLabel)
        view.addSubview(followersNumbersLabel)
        view.addSubview(followButton)*/
        
        setUpUI()
        
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setUpUI()
    {
        //imageView
        imageView.widthAnchor.constraintEqualToConstant(100).active = true
        imageView.heightAnchor.constraintEqualToConstant(100).active = true
        imageView.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 17.5).active = true
        imageView.topAnchor.constraintEqualToAnchor(navigationBar.bottomAnchor, constant: 17.5).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(grayView.topAnchor, constant: -12.5).active = true
        
        /*//border
        separatorLine.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        separatorLine.heightAnchor.constraintEqualToConstant(2).active = true
        separatorLine.topAnchor.constraintEqualToAnchor(followingLabel.bottomAnchor, constant: 116).active = true*/
        
       // nameLabel
        nameLabel.leftAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant:17.5).active = true
        nameLabel.topAnchor.constraintEqualToAnchor(navigationBar.bottomAnchor, constant: 35).active = true
        
        //locationLabel
        locationLabel.leftAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant: 17.5).active = true
        locationLabel.topAnchor.constraintEqualToAnchor(nameLabel.bottomAnchor, constant: 2.0).active = true
        
        //followingLabel
        followingLabel.topAnchor.constraintEqualToAnchor(locationLabel.bottomAnchor, constant: 10).active = true
        followingLabel.leftAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant: 17.5).active = true
        
        /*//followingNumbersLabel
        followingNumbersLabel.topAnchor.constraintEqualToAnchor(followingLabel.bottomAnchor, constant: 8).active  = true
        followingNumbersLabel.centerXAnchor.constraintEqualToAnchor(followingLabel.centerXAnchor).active = true
        followingNumbersLabel.leftAnchor.constraintEqualToAnchor(followingLabel.leftAnchor).active = true
        
        //followersLabel
        followersLabel.leftAnchor.constraintEqualToAnchor(followingLabel.rightAnchor, constant: 45).active = true
        followersLabel.topAnchor.constraintEqualToAnchor(followingLabel.topAnchor).active = true
        
        //followersNumbersLabel
        followersNumbersLabel.topAnchor.constraintEqualToAnchor(followersLabel.bottomAnchor, constant: 8).active  = true
        followersNumbersLabel.centerXAnchor.constraintEqualToAnchor(followersLabel.centerXAnchor).active = true
        followersNumbersLabel.leftAnchor.constraintEqualToAnchor(followersLabel.leftAnchor).active = true
        
        //followButton
        followButton.widthAnchor.constraintEqualToConstant(100).active = true
        followButton.heightAnchor.constraintEqualToConstant(40).active = true
        followButton.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: 25).active = true
        //followButton.leftAnchor.constraintEqualToAnchor(followersLabel.rightAnchor, constant: 45).active = true */
    }
}
