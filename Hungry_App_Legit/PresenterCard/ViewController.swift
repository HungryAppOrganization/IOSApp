/*
 *  #######
 *  # ### #
 *  ### # #
 *      # #        Hungry LLC 
 *      ###        IOS Swift Application
 *                      v1 1/5/2018
 *      ###        John Peurifoy
 */

import UIKit
import Material
import Firebase
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Utility Variables for swiping

    var myConnector: BackendConnector! // Backend Connector for REST API as well as variable container for between views. 
    
    var locationManager: CLLocationManager! // Location Manager

    // UI Variables

    fileprivate var cardWrapperView: View! // Wrapper for the card. 

    fileprivate var card: PresenterCard! // Main Card
    
    fileprivate var presenterView: UIImageView! // Center of the Card

    fileprivate var detailsView: UILabel! // Bottom Bar (above distance)
    
    fileprivate var bottomBar: Bar! // Bottom Bar with distance.
    
    fileprivate var distanceLabel: UILabel! // Distance Label

    fileprivate var toolbar: Toolbar!

    var originalPoint: CGPoint?

    /// Toolbar views.
    
    internal fileprivate(set) var leftPanGesture: UIPanGestureRecognizer?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Initialization of Variables
        self.myConnector = BackendConnector()
        self.myConnector.initialize()
        // Create Cards
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        // UI Setup

        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_Pic_new.png")!);

        preparedistanceLabel()
        preparePresenterView()
        prepareToolbar()
        preparedetailsView()
        prepareBottomBar()
        preparePresenterCard()
        originalPoint = card.center

        // Transition in to start. 
        
        self.card.alpha = 0.0
        UIView.animate(withDuration: 0.5 , delay: 1.0, animations: { () -> Void in
            self.card.alpha = 1.0
            self.card.center = self.originalPoint!
            self.card.transform = CGAffineTransform(rotationAngle: 0)
        })
        
        // And do the next card. 
        
        newCard()
        
        
        
    }
    /*
    * This method sets and returns the lat/lng positions. 
    * Address is address to get the lat/lng of. immed is if it should update the immedaite card, or if it should just do the next card. 
    */

    func forwardGeocoding(address: String,immed: Bool){
        
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks?[0]
                let coordinate = (placemark?.location)?.coordinate
                let deliverTime = self.getDistance(x1: Float(coordinate!.latitude),y1:Float(coordinate!.longitude),x2: Float(self.myConnector.curLoc.latitude),y2: Float(self.myConnector.curLoc.longitude))
                if (immed) {
                    self.myConnector.curCard.restPos = coordinate!
                    self.myConnector.curCard.restTime = deliverTime
                } else {
                    self.myConnector.curCard.restTime = self.myConnector.nxtCard.restTime
                    self.myConnector.nxtCard.restPos = coordinate!
                    self.myConnector.nxtCard.restTime = deliverTime
                }
                
            }
        })
    }

    /*
    * Updates and keeps track of the current user position. 
    */

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
            self.myConnector.curLoc = locValue
        }
    }


    /*
    * Gets the time between two lat/long cordinates. 
    */

    func getDistance(x1: Float, y1: Float, x2: Float, y2: Float) -> Int {
        let time = Int(2.0 + ((y1-y2)*(y1-y2) + (x1-x2)*(x1-x2)).squareRoot()*150.0);
        return time
    }

    /*
    * Top Toolbar. 
    */
    
    fileprivate func prepareToolbar() {
        toolbar = Toolbar()
        toolbar.title = "Hungry?"
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.font = UIFont(name: "Thonburi", size: 20.0)
        toolbar.detail = "      "
        toolbar.detailLabel.textAlignment = .left
        toolbar.detailLabel.font = UIFont(name: "Thonburi", size: 14.0)
        toolbar.detailLabel.textColor = Color.blueGrey.base
    }

    /*
    * This is where the image is
    */

    fileprivate func preparePresenterView() {
        presenterView = UIImageView()
        presenterView.image = UIImage(named: "pattern")?.resize(toWidth: view.width)
        presenterView.contentMode = .scaleAspectFill
    }

    /*
    * Bottom to show details
    */
    
    fileprivate func preparedetailsView() {
        detailsView = UILabel()
        detailsView.numberOfLines = 3
        detailsView.text = "Swipe \n \n To"
        detailsView.textAlignment = .center
        detailsView.textColor = Color.blueGrey.base
        detailsView.font = UIFont(name: "Thonburi", size: 14.0);
    }

    /*
    * Distance label at the bottom. 
    */
    
    fileprivate func preparedistanceLabel() {
        distanceLabel = UILabel()
        distanceLabel.font = UIFont(name: "Thonburi", size: 14.0)
        distanceLabel.textColor = Color.blueGrey.base
        distanceLabel.textAlignment = .center
        distanceLabel.text = "Continue..."
    }

    /*
    * Bottom Bar
    */
    
    fileprivate func prepareBottomBar() {
        bottomBar = Bar(centerViews: [distanceLabel])
    }

    /***** Card Initialization Methods *****/

    func populateCard(storage: Storage) {

        // See if all cards have been shown, if so reset this. 
        if myConnector.cardsShown.count >= 39 {
            myConnector.cardsShown = [Int]()
        }
        
        if self.myConnector.firstCard {
            // If the first card, we should pull and populate the immediate card. 
            self.myConnector.firstCard = false

        } else {
            detailsView.textColor = Color.black
            // If it is just a normal card, this is called each time you swipe.  
            print("Next Card!")
            // First get the card populated and all. 
            self.myConnector.curCard = self.myConnector.nxtCard
            unpackCardToUI(card:self.myConnector.curCard)
            self.presenterView.image = self.myConnector.curCard.foodImage;
            // Change address as well 

        }

        //Now pull the next card.

        var myNum2 = 0;
    
        while true {
            myNum2 = Int(arc4random_uniform(40) + 1);
            if (!myConnector.cardsShown.contains(myNum2)) {
                myConnector.cardsShown.append(myNum2)
                break
            }
        }

        pullFromDBAndPopulateCard(foodId: myNum2, immed: false)

    }

    /*
    * This method pulls from the DB and populates the next card with the corresponding information. It also does the second pull to gather the picture for the stored card. 
    * Note this method has the similar immed feature where it loads this directly onto the display if needed. 
    */

    func pullFromDBAndPopulateCard(foodId: Int,immed: Bool) {
        myConnector.ref.child("foods").child(String(foodId)).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            // This unloads the dict and puts everthing into it. 
            if (immed) {
                self.myConnector.curCard.unloadDict(dbDict: value!)
            } else {
                self.myConnector.nxtCard.unloadDict(dbDict: value!)
            }

            let imageLink = value!["foodPic"] as? String ?? ""
            let completeImageLink = "gs://transproject-adc23.appspot.com/HungryLogos/" + imageLink
            let gsReferenceImage = self.myConnector.storage.reference(forURL: completeImageLink)
            gsReferenceImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error pulling")
                } else {
                    let image = UIImage(data: data!)?.resize(toWidth:  self.view.width)
                    if immed {
                        self.myConnector.curCard.foodImage = image;
                        self.presenterView.image = image;
                        
                    } else {
                        self.myConnector.nxtCard.foodImage = image;
                    }
                    
                }
            }

            if (immed) {
                self.unpackCardToUI(card: self.myConnector.curCard)
                self.forwardGeocoding(address: self.myConnector.curCard.restAddress,immed: immed)
            } else {
                self.forwardGeocoding(address: self.myConnector.nxtCard.restAddress,immed: immed)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    /*
    * This unpacks a card and populates the current thing
    */

    func unpackCardToUI(card: CardToPresent) {
        self.toolbar.title = card.descrip
        self.toolbar.detail = "       " +  card.restName
        self.detailsView.text = "" + String(card.cost) + "\n\n" + String(card.cal) + " Calories";
        self.distanceLabel.text = String(self.myConnector.curCard.restTime) + " mins"

    }

    func newCard() {
        populateCard(storage: myConnector.storage)
        resetViewPositionAndTransformations()
    }
    
    
    private func resetViewPositionAndTransformations() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.card.center = self.originalPoint!
            self.card.transform = CGAffineTransform(rotationAngle: 0)
        })
    }

    /*
    * UI Setup
    */
    
    func preparePresenterCard() {

        cardWrapperView = View()
        card = PresenterCard()
        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .wideRectangle2
        card.presenterView = presenterView        
        card.contentView = detailsView
        card.contentViewEdgeInsetsPreset = .square3
        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        card.cornerRadiusPreset = .cornerRadius4
        cardWrapperView.layout(card).horizontally().center();

        leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragged))
        view.addGestureRecognizer(leftPanGesture!)
        view.layout(cardWrapperView).horizontally(left:20,right:20).center()
    }

    
    /*********** Event Handlers **********/

    /*
    * Swiping gesture handling
    */

    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        let distance = gestureRecognizer.translation(in: card);
        switch gestureRecognizer.state {
            
            case .began:
                // Have a place to come back to.
                originalPoint = card.center
            
            case .changed:
                // Handle Swiping
                let rotationPercentage = min(distance.x/(view.width/2), 1);
                let rotationAngle = (CGFloat(2*3.14/16)*rotationPercentage);
                card.transform = CGAffineTransform(rotationAngle: rotationAngle)
                card.center = CGPoint(x:originalPoint!.x + distance.x,y: originalPoint!.y + distance.y)
            case .ended:
                // Get the next card. 
                if abs(distance.x) > card.width/8 {
                    print("Swipping the optin!");
                    swipeDirection(s: distance.x > 0 ? .Right : .Left)
                } else if abs(distance.y) > card.height/8 {
                    print("Swipping up");
                    swipeDirection(s: distance.y > 0 ? .Down : .Up)
                } else {
                    resetViewPositionAndTransformations()
                }
            default:
                break
        }
    }
    
    func swipeDirection(s: Direction) {
        if s == .None {
            return
        }
        var parentWidth = view.frame.size.width
        if (s == .Left || s == .Right) {
            parentWidth *= 1.2 // Sensitivity to swiping
            if s == .Left {
                parentWidth *= -1.0
            } else if s == .Right {
                parentWidth *= 2.0
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.card.center.x = 1.0*(self.card.frame.origin.x + parentWidth)
            }, completion: {
                success in
                if s == .Right {
                    self.swipedRight();
                } else if s == .Left {
                    self.swipedLeft();
                }
                
            })
        } else if (s == .Up) {
            
            let myScreen = ViewController_2ndScreen();
            myScreen.myConnector = self.myConnector;
            present(myScreen, animated: true)
        } else {
            resetViewPositionAndTransformations()
        }
    }
    
    func swipedRight() {
        //Reload the card.
        newCard();
    }
    
    func swipedLeft() {
        //Reload the card.
        newCard();
    }


}


