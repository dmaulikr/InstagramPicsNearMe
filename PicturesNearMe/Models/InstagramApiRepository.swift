//
//  InstagramApiRepository.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/18/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import Alamofire
import CoreLocation

private let _SharedInstance = InstagramApiRepository()

enum InstagramErrorCode : Int {
    case kInstagramErrorCodeNone = 0,
    kInstagramErrorCodeAccessNotGranted,
    kInstagramErrorCodeUserCancelled
}

class InstagramApiRepository {

    private let kKeyClientId = "client_id"
    private let kKeyAccessToken = "access_token"
    
    private let kInstagramAppClientIdConfigurationKey = "InstagramAppClientId"
    private let kInstagramAppRedirectUrlConfigurationKey = "InstagramAppRedirectURL"
    private let kInstagramAuthorizationResponseAccessTokenKey = "picturesnearme:#access_token"
    private let kInstagramBaseUrlDefault = "https://api.instagram.com/v1/"
    private let kInstagramAuthorizationUrlDefault = "https://api.instagram.com/oauth/authorize/"
    private let kInstagramErrorDomain = "InstagramKitErrorDomain"
    
    private var appClientId : String!
    private var appRedirectUrl : String!
    private var accessToken : String!
    private var loginCompletionHandler:((NSError?) -> Void)?
    
    var isLoggedIn : Bool
    
    class var sharedInstance: InstagramApiRepository {
        return _SharedInstance
    }

    init() {
        self.isLoggedIn = false
        // Normally you would persist this info to NSUserDefaults or any other persistence preference
        appClientId = NSBundle.mainBundle().objectForInfoDictionaryKey(kInstagramAppClientIdConfigurationKey) as! String
        appRedirectUrl = NSBundle.mainBundle().objectForInfoDictionaryKey(kInstagramAppRedirectUrlConfigurationKey) as! String
    }
    
    func login(completionHandler: ((NSError?) -> Void)?) {
        let params = [ kKeyClientId: appClientId, "redirect_uri": appRedirectUrl, "response_type": "token", "scope": "basic" ]
        var queryElements = NSMutableArray()
        for (key, value) in params {
            queryElements.addObject("\(key)=\(value)")
        }
        var queryString = queryElements.componentsJoinedByString("&")
        var url = NSURL(string: "\(kInstagramAuthorizationUrlDefault)?\(queryString)")
        loginCompletionHandler = completionHandler
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func logout() {
        //    Clear all cookies so the next time the user wishes to switch accounts,
        //    they can do so
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        storage.cookies?.each { cookie in
            storage.deleteCookie(cookie as! NSHTTPCookie)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        self.accessToken = nil
        println("User is now logged out")
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var appRedirectURL = NSURL(string: self.appRedirectUrl)
        if (appRedirectURL!.scheme != url.scheme || appRedirectURL!.host != url.host) {
            return false
        }
        let dict = queryStringParametersFromString(url.absoluteString!)
        let accessToken : String! = dict[kInstagramAuthorizationResponseAccessTokenKey] as! String;
        if accessToken != nil {
            self.accessToken = accessToken
            if (self.loginCompletionHandler != nil){
                self.loginCompletionHandler = nil
            }
        }
        else if loginCompletionHandler != nil {
            let localizedDescription = NSLocalizedString("Authorization not granted.", tableName: "", bundle: NSBundle.mainBundle(), value: "", comment: "Error notification to indicate Instagram OAuth token was not provided.")
            let error = NSError(domain: kInstagramErrorDomain, code: InstagramErrorCode.kInstagramErrorCodeAccessNotGranted.rawValue, userInfo: [ NSLocalizedDescriptionKey: localizedDescription])
            self.loginCompletionHandler!(error)
        }
        self.loginCompletionHandler = nil
        return true
    }
    
    private func queryStringParametersFromString(urlFragment: String) -> NSDictionary {
        var dict = NSMutableDictionary()
        urlFragment.componentsSeparatedByString("&").each { component in
            let pairs = component.componentsSeparatedByString("=")
            if pairs.count != 2 {
                return
            }
            let key = pairs[0].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let value = pairs[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            dict.setObject(value!, forKey: key!)
        }
        return dict
    }
    
    func getMedia(coordinates: CLLocationCoordinate2D, distance: Double, completionHandler: ((NSArray) -> Void)!) {
        var params = [String: AnyObject]()
        if self.accessToken != nil {
            params[kKeyAccessToken] = self.accessToken
        } else {
            params[kKeyClientId] = self.appClientId
        }
        params["lat"] = coordinates.latitude
        params["lng"] = coordinates.longitude
        params["distance"] = distance
        Alamofire.request(Method.GET, "\(kInstagramBaseUrlDefault)media/search", parameters: params, encoding: ParameterEncoding.URL)
            .responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, JSON, error) -> Void in
                // We would normally use an efficient serializer e.g. JSONModel
                let arrayData = JSON!["data"] as! NSArray
                var instagramMedia = NSMutableArray()
                for instaDict in arrayData {
                    let imagesDict = instaDict["images"] as! NSDictionary
                    let locationDict = instaDict["location"] as! NSDictionary
                    let userDict = instaDict["user"] as! NSDictionary
                    let resolutionDict = imagesDict["standard_resolution"] as! NSDictionary
                    let imageUrl = resolutionDict["url"] as! String
                    let username = userDict["username"] as! String
                    let coordinates = CLLocationCoordinate2DMake(locationDict["latitude"] as! Double, locationDict["longitude"] as! Double)
                    instagramMedia.addObject(InstaMedia(imageUrl: imageUrl, username: username, distance: 0, locationCoordinate: coordinates))
                }
                if completionHandler != nil {
                    completionHandler(instagramMedia)
                }
//                println(instagramMedia)
            }
    }
    
    
    
}