# interviews

**InstaMe** is a simple app for viewing an Instragram user's photos and nearby photos from other Instagram users. InstaMe only has access to photos in an [Instagram developer sandbox](https://www.instagram.com/developer).

### Technical Breakdown

#### Assumptions
The authenticated Instagram user must have access to the configured sandbox. Also the redirect URL must be compatible (i.e. there is no error handling). See `clientId` and `redirectHost` in `AuthViewController`.

It is also helpful for there to be images available for the current Instagram user (i.e. there is no empty support).

There is no way to logout or change Instagram users. A workaround is to revoke sandbox authorization in [Instagram Authorized Applications](https://www.instagram.com/accounts/manage_access/); this will force the authorization prompt which provides a *Not me* link to switch users.

#### Third-party Components
[**CocoaPods**](https://cocoapods.org/) is a dependency manager that makes it trivial to pull in third-party libraries.

[**JSONModel**](https://github.com/jsonmodel/jsonmodel) is a general-purpose JSON-based strongly-typed object library (very similar to what I built @ PayPal in Foundation). This is used behind the `Model` abstraction to simplify the parsing of service responses into strongly-typed model objects.

[**SAMKeychain**](https://github.com/soffes/SAMKeychain) is a keychain wrapper library that makes it trivial to persist/retrieve account passwords. This is used behind the `State` abstraction for secure storage of access token(s).

[**CHTCollectionViewWaterfallLayout**](https://github.com/chiahsien/CHTCollectionViewWaterfallLayout) is a `UICollectionViewLayout` specialization that enables a Pintrest-style layout of collection items.

#### Authentication
Authentication uses the common OAuth approach of presenting a `UIWebView` for user to authenticate and authorize, then "hooking" the redirect to grab an access token. See `AuthViewController` for details.

#### State
`State` is a simple abstraction to persist/retrieve data between "sessions" in the app. `State` uses `SAMKeychain` for secure storage of access token received during authentication (to avoid re-authenticating each time app is launched). 

_NOTE `State` would also abstract `NSUserDefaults`; this is not currently implemented._

#### Transceiver
`Transceiver` hides the details of service interactions. `Transceiver` is not concerned with the interpretation (parsing) of the service payload inside the service response, but rather unwraps the payload from within the service response and handles (or propagates) errors that occur while interacting w/ the service.

`Transceiver` has a single shared instance and performs service requests asynchronously via `NSURLSession`, then calls `success` (or `failure`) block from background worker thread(s). This approach allows further processing of service responses to occur on background threads, but requires callers to dispatch to main thread when necessary. For this reason most calls to `Transceiver` should be made from `Model` abstraction rather than directly from presentation code.

_NOTE it may be preferable to have a subset of calls that are intended to be called from presentation code directly which **do** callback on the main thread._

All calls to `Transceiver` return an `NSURLSessionTask` instance which can be used to cancel the request. 

_NOTE it would be best to abstract the details of NSURLSessionTask behind some type of TransceiverHandle object which **has** an NSURLSessionTask._

#### Model

`Model` provides several strongly-typed objects that represent objects returned from Instagram service calls. `Model` relies on `JSONModel` to abstract the details of parsing JSON and mapping JSON properties to their corresponding object properties (greatly simplifying the implementation of `Model`).

One pattern that is somewhat unique is the use of strongly-typed IDs; this allows type checks on calls that pass an ID param. For example:
 `- (NSURLSessionDataTask *)requestMediaById:(MediaId *)mediaId success:(void(^)(id<MediaObject>))success failure:(void(^)(NSError *))failure;`

Instagram media objects appear to be of (at least) two types: Image, Video. The `MediaObject` protocol abstracts the notion of an Instragram media object. Two concrete types represent objects for Image and Video, namely `ImageMediaObject` and `VideoMediaObject`, respectively.

_NOTE InstaMe doesn't currently support video media so `VideoMediaObject` is not implemented for expediency._

`User` represents a user object (surprise) while `ImageObject` represents an image asset, namely, its size (`width`, `height`) and its source (`url`).

`Model` exposes several `requestX` methods which retrieve up-to-date instances (or collections of instances) of model objects and callback on the main thread. These calls return an `NSURLSessionTask` that allows a given request to be cancelled.
 
_NOTE same comment about `NSURLSessionTask` abstraction._

_NOTE there is currently no cache support in `Model`, but it would be trivial to persist the most recent JSON data from a given `requestX` method in `State` and restore this upon app launch to ensure that there is at least some (albeit possibly old) data to allow the app to show something when offline or on slow networks. The topic of caching and cache aging is somewhat complex, however, and communicating the age of data to the user is often nontrivial, so caching is not implemented._

_NOTE `Model` is intended to be immutable which greatly simplifies threading concerns. When `Model` changes occur, an event would be emitted and a new instance must be retrieved which contains the changes. Another approach is to support change sets that can be applied to a given model instance; applying a change set yields a new, immutable model instance._

#### View Model

In order to keep the presentation decoupled from the `Model` (as `Model` objects are tightly coupled to service responses) there is a view model which has a `Model` object to be presented in the UI. `ImagePresentation` has an `ImageMediaObject` and exposes only the required data to be presented in an `ImageCell` in the list view. 

Having the `ImagePresentation` abstraction allows the UI to be developed w/o connecting w/ the service or even fully modeling the data objects. This abstraction also allows mocking presentation data for both early UI development as well as UI testing. This abstraction also insulates the presentation from changes that may occur in the `Model` objects as service responses evolve.

#### Controllers
The controllers are relatively straightforward, though one aspect bears explaining. Since iOS shows `LaunchScreen.storyboard` while app is launching (and **no** logic can be run), it is helpful to have `SplashViewController` be the initial view controller and to replicate what is shown during launch. Once `SplashViewController` has been presented, the logic for whether to authenticate or show the list can be performed and the UI can smoothly transition from launch UI to the next UI state. `SplashViewController` also provides a simple fallback point if ever a service call fails for lack of authentication or authorization; simply teardown whatever UI is being shown and allow `SplashViewController` to take the user through authX.

_NOTE in a more complicated app where authentication challenges are frequent and may happen as a result of **any** operation, it makes more sense to let authentication challenge presentation happen **above** the current UI rather than tearing down the current UI (which will destroy the user's current task and lose the user's current location in the UI)._

### Next Steps

* Features:
  * Zoom support, like/unlike, media stats, etc in detail view
  * Video support (`Model` could support `VideoMediaObject` which adheres to `MediaObject` protocol, then add heterogeneous list parsing support (currently `requestXMedia` expect homogeneous collections of `ImageMediaObject`)
  * Media upload support
  * Media comment support
  * Tag search
* Improve error handling (ex. add reachability and consider network state, improve logic for showing error to user, map underlying errors to (localized) error messaging, etc)
* Offline support (ex. cache last known good data, allow interaction w/ offline data, batch pending requests to be executed when app goes online, etc)
* Add dynamic collection change support (i.e. when a new media object is added to the model it should be animated into the collection; this requires `Model` change set support; otherwise old/new model must be compared to determine changes)
* Add comments (I don't typically invest in comments until _after_ the code has coalesced somewhat, and even then I typically only comment public interfaces; code should largely explain itself w/ only `GOTCHA`, `TODO`, or `FIXME` comments to aid the reader through the tricky bits)
* Add empty support (i.e. show something when there are no results, ex. call to action to upload images or alter location or search terms)
* Add mock support
  * `Transceiver` can be mocked by creating a `Transceiver` protocol and implementing a `MockTransceiver` that returns static JSON for each response or uses Apiary or like service
  * `ImagePresentation` objects can be mocked by creating a `MockImagePresentation` specialization and hand-coding a bunch of these to exercise the UI
* Add analytics via `Tracker` abstraction that hides details of GA or Fabric or Flurry
* Add proper logging via `Logger` abstraction that hides details of `CocoaLumberjack` and adds notion of "channels" (in addition to log levels) to allow enabling/disabling log channels at runtime
* Add DbC (Design by Contract) and replace `@throw` uses in the code (I tried to use [this](https://github.com/brynbellomy/ObjC-DesignByContract) but it didn't go well)
* Add tests
  * `Model` needs tests to ensure parsed JSON yields expected objects which allow access to proper properties
  * `Transceiver` needs tests w/ test Instagram users that has known, static dataset