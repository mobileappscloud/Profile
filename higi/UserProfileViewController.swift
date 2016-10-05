//
//  UserProfileViewController.swift
//  higi
//
//  Created by Faisal Syed on 10/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var grayView: UIView! {
        didSet {
            grayView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        }
    }
    let imageView: UIImageView =
    {
        let view = UIImageView()
        //view.backgroundColor = UIColor.blueColor()
        let image = UIImage(named: "my_avatar")
        view.image = image
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
        label.textColor = UIColor(red:0.19, green:0.43, blue:0.86, alpha:1.0)
        label.font = UIFont.boldSystemFontOfSize(25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followersLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Followers"
        label.textColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
        label.font = UIFont.boldSystemFontOfSize(10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followersNumbersLabel: UILabel =
    {
        let label = UILabel()
        label.text = "100"
        label.textColor = UIColor(red:0.19, green:0.43, blue:0.86, alpha:1.0)
        label.font = UIFont.boldSystemFontOfSize(25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followButton: UIButton =
    {
        let btn = UIButton(type: .System)
        btn.setTitle("FOLLOW", forState: .Normal)
        btn.backgroundColor = UIColor(red:0.19, green:0.43, blue:0.86, alpha:1.0)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
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
        
        let leftButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action:#selector(UserProfileViewController.dismissViewController))
        navigationItem.leftBarButtonItem = leftButton
        
        navBar.items = [navigationItem]
        return navBar
        
    }()
    
    let temporaryContainerView: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.lightGrayColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let deviceImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "turn-phone-icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    func dismissViewController()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    lazy var myTableView: UITableView =
    {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //nav bar
        self.view.addSubview(navigationBar)
        
        //Header
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(locationLabel)
        view.addSubview(followingLabel)
        view.addSubview(followingNumbersLabel)
        view.addSubview(followersLabel)
        view.addSubview(followersNumbersLabel)
        view.addSubview(followButton)
        
        //Middle
        view.addSubview(temporaryContainerView)
        view.addSubview(deviceImageView)
        
        //tableView
        view.addSubview(myTableView)

        setUpUI()
        
      //  let sortedViews = segmentedControl.subviews.sort( { $0.frame.origin.x < $1.frame.origin.x } )
       // sortedViews[0].tintColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
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
        imageView.bottomAnchor.constraintEqualToAnchor(grayView.topAnchor, constant: -25).active = true
        
        /*//border
        separatorLine.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        separatorLine.heightAnchor.constraintEqualToConstant(2).active = true
        separatorLine.topAnchor.constraintEqualToAnchor(followingLabel.bottomAnchor, constant: 116).active = true*/
        
       // nameLabel
        nameLabel.leftAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant:17.5).active = true
        nameLabel.topAnchor.constraintEqualToAnchor(navigationBar.bottomAnchor, constant: 35).active = true
        
        //locationLabel
        locationLabel.leftAnchor.constraintEqualToAnchor(nameLabel.leftAnchor).active = true
        locationLabel.topAnchor.constraintEqualToAnchor(nameLabel.bottomAnchor, constant: 2.0).active = true
        
        //followingLabel
        followingLabel.topAnchor.constraintEqualToAnchor(locationLabel.bottomAnchor, constant: 10).active = true
        followingLabel.centerXAnchor.constraintEqualToAnchor(locationLabel.centerXAnchor).active = true
        followingLabel.leftAnchor.constraintEqualToAnchor(nameLabel.leftAnchor).active = true
        
        //followingNumbersLabel
        followingNumbersLabel.topAnchor.constraintEqualToAnchor(followingLabel.bottomAnchor, constant: 1).active  = true
        followingNumbersLabel.centerXAnchor.constraintEqualToAnchor(followingLabel.centerXAnchor).active = true
        followingNumbersLabel.leftAnchor.constraintEqualToAnchor(nameLabel.leftAnchor).active = true
        
        //followersLabel
        followersLabel.leftAnchor.constraintEqualToAnchor(followingLabel.rightAnchor, constant: 1).active = true
        followersLabel.topAnchor.constraintEqualToAnchor(followingLabel.topAnchor).active = true
        
        //followersNumbersLabel
        followersNumbersLabel.topAnchor.constraintEqualToAnchor(followersLabel.bottomAnchor, constant: 1).active  = true
        followersNumbersLabel.centerXAnchor.constraintEqualToAnchor(followersLabel.centerXAnchor).active = true
        followersNumbersLabel.leftAnchor.constraintEqualToAnchor(followersLabel.leftAnchor).active = true
        
        //followButton
        followButton.widthAnchor.constraintEqualToConstant(100).active = true
        followButton.heightAnchor.constraintEqualToConstant(40).active = true
        followButton.leftAnchor.constraintEqualToAnchor(followersLabel.rightAnchor, constant: 7).active = true
        followButton.topAnchor.constraintEqualToAnchor(followersLabel.topAnchor).active = true
        
        //temporaryContainer
        temporaryContainerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        temporaryContainerView.heightAnchor.constraintEqualToConstant(175).active = true
        temporaryContainerView.topAnchor.constraintEqualToAnchor(grayView.bottomAnchor).active = true
        
        //deviceImageView
        deviceImageView.topAnchor.constraintEqualToAnchor(temporaryContainerView.topAnchor, constant:10).active = true
        deviceImageView.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -20).active = true
        
        //tableView
        myTableView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        myTableView.topAnchor.constraintEqualToAnchor(temporaryContainerView.bottomAnchor).active = true
        myTableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        myTableView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    }
    
    //MARK Table View Delegate and DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        cell.textLabel?.text = "Test"
        
        return cell
    }
}
