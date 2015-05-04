## iOS Swift - Pictures Near Me

The PicturesNearMe project demonstrates how you can query the Instagram API and get pictures of a specific location and a radius distance from it. It also shows the location distance from the current location to the tapped map point.

## Installation

Cloning the repository locally should work immediately with opening PicturesNearMe.xcworkspace. 
If any problems please try running in your terminal pod install to reinstall any pods. Also check if the target selected is the PicturesNearMe.
This application is tested with iPhone 5/6 simulator and an iPhone 6 device. In simulator you'll have to set Debug -> Location to something else than None.
Used Xcode 6.3 (6D570) and iOS SDK 8.3. It will properly work in previous SDKs and devices as well.

## Tests

We're using XCTest for this project.

There is one test against the InstagramApiRepository class testing the media/search endpoint for a New York latitude longitude and 3000 meters of distance. The testing is really connetcing to the Instagram service. Usually in a larger project we would break the repository and create a service (context) that will deal with the calls and serve data to the Repository.
This would allow to inject implementation code (personally I use a Service Locator class, not heavy DI frameworks, depends the project) in a protocol and mock the instagram service while testing or working.

As a later practice I added the Objective-C unit testing framework GRUnit, a lighter version of GHUnit to check if I can bridge the Swift files and test them (research in progress).

## Pods

The Pods are included in the repo, this is debatable of course, there advantages and disavantages, I usually like to have them included, http://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control.

The project is using the following pods.

Targets PicturesNearMe and PicturesNearMeTests include the **Alamofire** framework. A swift version from the author of AFNetworking Objective-C for HTTP networking.

Target 'Tests' is a target created to test GRUnit Unit Testing Framework, not applicable for the project currently.

## Asumptions - Thoughts

The Instagram API.

In their documentation they state:

*Do you need to authenticate?*

*Some API only require the use of a client_id. A client_id simply associates your server, script, or program with a specific application. However, other requests require authentication - specifically requests made on behalf of a user. Authenticated requests require an access_token. These tokens are unique to a user and should be stored securely. Access tokens may expire at any time in the future.*

And in the endpoint we are interested they show the requirement of an access token, **https://api.instagram.com/v1/media/search?lat=48.858844&lng=2.294351&access_token=ACCESS-TOKEN**, but it works with only passing the client_id too, but is not mentioned in the specific endpoint description.

The InstagramApiRepository is designed to handle receiving OAuth 2.0 authorization and authentication access token if it is needed, at the moment it is not applicable since the requirements are achieved with a client_id parameter but you can easily include a call of the **login** method that will take you to the browser and return to the app with the access token which will then be used for Instagram API calls.

I also noticed that the API is returning somewhat different pictures everytime which is interesting as well (need further investigation)
