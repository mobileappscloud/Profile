//
//  HigiUser.swift
//  higi
//
//  Created by Dan Harms on 6/17/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class HigiUser {
    
    var userId, firstName, lastName, email, termsFile, privacyFile, gender: NSString!;
    
    var currentHigiScore, photoTime: Int!;
    
    var hasPhoto, emailCheckins, emailHigiNews: Bool!;
    
    var profileImage, fullProfileImage, blurredImage: UIImage!;
    
    var dateOfBirth: NSDate!;
    
    init() {
        hasPhoto = false;
        currentHigiScore = 0;
        emailCheckins = true;
        emailHigiNews = true;
    }
    
    init(dictionary: NSDictionary) {
        userId = dictionary["id"] as! NSString;
        firstName = (dictionary["firstName"] ?? "") as! NSString;
        lastName = (dictionary["lastName"] ?? "") as! NSString;
        email = dictionary["email"] as! NSString;
        hasPhoto = (dictionary["hasPhoto"] ?? false) as! Bool;
        currentHigiScore = (dictionary["currentHigiScore"] ?? 0) as! Int;
        photoTime = (dictionary["photoTime"] ?? 0) as! Int;
        
        profileImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(HigiApi.baseUrl)/view/\(userId)/profile,400.png?t=\(photoTime)")!)!);
        fullProfileImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(HigiApi.baseUrl)/view/\(userId)/profileoriginal.png?t=\(photoTime)")!)!);
        
        var notifications = dictionary["Notifications"] as! NSDictionary;
        emailCheckins = (notifications["EmailCheckins"] as! NSString) == "True";
        emailHigiNews = (notifications["EmailHigiNews"] as! NSString) == "True";
        
        var terms = dictionary["terms"] as! NSDictionary?;
        var privacy = dictionary["privacyAgreed"] as! NSDictionary?;
        
        if (terms != nil) {
            termsFile = terms!["termsFileName"] as! NSString;
        } else {
            termsFile = "";
        }
        if (privacy != nil) {
            privacyFile = privacy!["privacyFileName"] as! NSString;
        } else {
            privacyFile = "";
        }
        
        var birthday = dictionary["dateOfBirth"] as NSString?;
        if (birthday != nil) {
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "mm/dd/yyyy";
            dateOfBirth = dateFormatter.dateFromString(birthday!);
        }
        
        gender = dictionary["gender"] as? NSString;
        
        createBlurredImage();
    }
    
    func createBlurredImage() {
        if (fullProfileImage == nil) {
            fullProfileImage = profileImage;
        }
        var context = CIContext(options: nil);
        var inputImage = CIImage(CGImage: Utility.scaleImage(fullProfileImage, newSize: CGSize(width: fullProfileImage.size.width / 2, height: fullProfileImage.size.height / 2)).CGImage);
        var filter = CIFilter(name: "CIGaussianBlur");
        filter.setValue(inputImage, forKey: kCIInputImageKey);
        filter.setValue(NSNumber(float: 15.0), forKey: "inputRadius");
        var result = filter.valueForKey(kCIOutputImageKey) as! CIImage;
        
        var cgImage = context.createCGImage(result, fromRect: inputImage.extent());
        blurredImage = UIImage(CGImage: cgImage);
        
    }
    
    func retrieveProfileImages() {
        profileImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(HigiApi.baseUrl)/view/\(userId)/profile,400.png?t=\(photoTime)")!)!);
        fullProfileImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(HigiApi.baseUrl)/view/\(userId)/profileoriginal.png?t=\(photoTime)")!)!);
        createBlurredImage();
        NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.PROFILE_PICTURES, object: nil, userInfo: ["success": true]);
    }
    
}

