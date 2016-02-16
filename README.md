![higi logo](https://higi.com/downloads/press_kit/higi_color-transparent_logo.png)

[![Build Status](http://higi-jenk-win.cloudapp.net:8080/buildStatus/icon?job=Mobile iOS Main)](http://higi-jenk-win.cloudapp.net:8080/job/Mobile%20iOS%20Main/)
![platform iOS](https://img.shields.io/badge/platform-ios-lightgray.svg)
![language Swift](https://img.shields.io/badge/language-Swift%202.1.1-orange.svg)

Requirements
------------
- Xcode 7.2.1+
- iOS 8.0+ SDK


Setup
-----

- Clone the repository. This project manages dependencies with [`submodules`](http://www.git-scm.com/book/en/v2/Git-Tools-Submodules) so they will need to be checked out as well. Checkout the main repository and submodules using the following command:

  `git clone --recursive git@github.com:higish/ios-main.git`

  *Note - Run the following command from the project root if you have already checked out the repository, but failed to clone the submodules:*
  
    `git submodule update --init --recursive`

- Open the project in Xcode or your favorite compatible IDE
- Build and Run!

Dependencies
------------
__The following dependencies are managed via `git submodules`:__
- [**AFNetworking**](https://github.com/AFNetworking/AFNetworking) - Library for making HTTP network requests. 

  *Note: If we continue to use this library, we will need to update to a version backed by __NSURLSession__ as opposed to __NSURLConnection__. Furthermore, it may be wise to switch to the Swift counterpart [**Alamofire**](https://github.com/Alamofire/Alamofire.git).*
- [**Core Plot**](https://github.com/higish/core-plot) - Library to plot data on interactive graphs. Used to display a user's health data.
- [**Fabric**](https://github.com/higish/ios-fabric) - Parent SDK for useful developer tools.
  - [**Crashlytics**](https://github.com/higish/ios-crashlytics) - Crash analytics & beta testing framework which runs as a kit under the Fabric SDK.
- [**Flurry**](https://github.com/flurry/Flurry-iOS-SDK.git) - Mobile analytics framework.
- [**Google Maps**](https://github.com/higish/ios-google-maps.git) - Mapping framework used in place of MapKit...
  - [**Google Maps Utilities**](https://github.com/higish/google-maps-ios-utils) - Utilities to supplement Google Maps such as clustering annotations.
- [**MWFeedParser**](https://github.com/mwaterfall/MWFeedParser.git) - This repository contains a useful category which helps parse NSStrings with HTML.
- [**Swift Keychain Wrapper**](https://github.com/jrendel/SwiftKeychainWrapper.git) - Swift-compatible wrapper around the iOS Keychain, used to store sensitive user data such as passwords.
- [**SWRevealViewController**](https://github.com/John-Lluch/SWRevealViewController.git) - Classes for menu drawer and reveal navigation.

  *Note: It is likely that this dependency will be removed for many obvious reasons, some of which are described by [Apple: Designing Intuitive User Experiences - 211 WWDC 2014 @ 31:57](http://devstreaming.apple.com/videos/wwdc/2014/211xxmyz80g30i9/211/211_hd_designing_intuitive_user_experiences.mov?dl=1). There's another interesting article [here](http://techcrunch.com/2014/05/24/before-the-hamburger-button-kills-you/), and some interesting predictions made [here](http://thenextweb.com/opinion/2015/09/14/apples-plan-to-kill-the-hamburger-menu/) which align with the general consensus of the iOS team.*

- [**mergegenstrings**](https://github.com/higish/ios-merge-genstrings) - Useful, Swift-compatible python script which can be used to generate & merge localizable strings.  

__The following dependencies were copied directly into the project source:__

- [**UIImage+Orientation**]() - Category used to fix the orientation of images modified on device. The source was copied from a StackOverflow answer.

Contributing
------------
- Create a fork off the main higi repository. 
- Create a feature or bug-fix branch off of development.
- Due to federal regulations, every commit must reference a JIRA ticket. 
  Commit messages should be formatted accordingly: 
  
  _{TICKET}: {Commit message}_ --> _HMI-999: Implement teleportation module_
- Submit a pull request once the feature/fix is code complete. Be sure to add/update any relevant documentation, dependencies, and/or tests.

Testing
-------
TBD

Nightly Builds
--------------
There are two nightly builds which are sent to quality assurance testers. The app is built using the **production** and **QA** schemes by a [Jenkins build server](http://higi-jenk-win.cloudapp.net:8080/job/Mobile%20iOS%20Main/).

App Store Link
---------------
[![App Badge](http://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg)](https://geo.itunes.apple.com/us/app/higi/id599485135?mt=8)

