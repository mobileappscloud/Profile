//
//  VideoPlayer.swift
//  higi
//
//  Created by Remy Panicker on 8/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import AVKit
import AVFoundation

final class VideoPlayer {
    
    static func play(video: Post.Video, viewControllerToPresent: UIViewController?) {
        let url = video.asset.URI
        let player = AVPlayer(URL: url)
        let videoViewController = AVPlayerViewController()
        videoViewController.player = player
        
        dispatch_async(dispatch_get_main_queue(), {
            guard let viewControllerToPresent = viewControllerToPresent else { return }
            
            viewControllerToPresent.presentViewController(videoViewController, animated: true, completion: { [weak videoViewController] in
                videoViewController?.player?.play()
                })
        })
    }
}
