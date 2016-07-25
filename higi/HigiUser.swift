//
//  HigiUser.swift
//  higi
//
//  Created by Dan Harms on 6/17/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

enum BiologicalSex {
    case NotSet
    case Female
    case Male
    case Other
}

final class HigiUser {
    
    var userId, firstName, lastName, email, termsFile, privacyFile: NSString!;
    
    var biologicalSex: BiologicalSex = .NotSet
    
    var currentHigiScore, photoTime: Int!;
    
    var hasPhoto, emailCheckins, emailHigiNews: Bool!;
    
    var dateOfBirthString: String?
    
    var profileImage: UIImage?
    var fullProfileImage: UIImage?
    var blurredImage: UIImage?
    
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
        if let biologicalSexString = (dictionary["gender"] ?? "") as? String {
            switch biologicalSexString {
            case "f":
                biologicalSex = .Female
            case "m":
                biologicalSex = .Male
                
            default:
                biologicalSex = .NotSet
            }
        }
        hasPhoto = (dictionary["hasPhoto"] ?? false) as! Bool;
        currentHigiScore = (dictionary["currentHigiScore"] ?? 0) as! Int;
        photoTime = (dictionary["photoTime"] ?? 0) as! Int;
        
        if let profileImageURL = NSURL(string: "\(HigiApi.higiApiUrl)/view/\(userId)/profile,400.png?t=\(photoTime)") {
            if let data = NSData(contentsOfURL: profileImageURL), image = UIImage(data: data) {
                profileImage = image
            }
        }
        
        if let URL = NSURL(string: "\(HigiApi.higiApiUrl)/view/\(userId)/profileoriginal.png?t=\(photoTime)") {
            if let data = NSData(contentsOfURL: URL), image = UIImage(data: data) {
                fullProfileImage = image   
            }
        }
        
        let notifications = dictionary["Notifications"] as! NSDictionary;
        emailCheckins = (notifications["EmailCheckins"] as! NSString) == "True";
        emailHigiNews = (notifications["EmailHigiNews"] as! NSString) == "True";
        
        let terms = dictionary["terms"] as! NSDictionary?;
        let privacy = dictionary["privacyAgreed"] as! NSDictionary?;
        
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
        
        dateOfBirthString = dictionary["dateOfBirth"] as? String
        
        createBlurredImage();
    }
    
    func createBlurredImage() {
        var image: UIImage?
        image = (fullProfileImage != nil) ? fullProfileImage : profileImage
        guard let imageToBlur = image else {
            return
        }
        
        let context = CIContext(options: nil);
        let inputImage = CIImage(CGImage: Utility.scaleImage(imageToBlur, newSize: CGSize(width: imageToBlur.size.width / 2, height: imageToBlur.size.height / 2)).CGImage!);
        let filter = CIFilter(name: "CIGaussianBlur");
        filter!.setValue(inputImage, forKey: kCIInputImageKey);
        filter!.setValue(NSNumber(float: 15.0), forKey: "inputRadius");
        let result = filter!.valueForKey(kCIOutputImageKey) as! CIImage;
        
        let cgImage = context.createCGImage(result, fromRect: inputImage.extent);
        blurredImage = UIImage(CGImage: cgImage);
    }
    
    func retrieveProfileImages() {
        if let profileImageURL = NSURL(string: "\(HigiApi.higiApiUrl)/view/\(userId)/profile,400.png?t=\(photoTime)") {
            if let data = NSData(contentsOfURL: profileImageURL), image = UIImage(data: data) {
                profileImage = image
            }
        }
        
        if let URL = NSURL(string: "\(HigiApi.higiApiUrl)/view/\(userId)/profileoriginal.png?t=\(photoTime)") {
            if let data = NSData(contentsOfURL: URL), image = UIImage(data: data) {
                fullProfileImage = image
            }
        }
    
        createBlurredImage()
    }
    
}

