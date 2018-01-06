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
import FontAwesome_swift
import GoogleMaps
import CoreLocation
import AddressBookUI


class ViewController_2ndScreen: UIViewController, UIGestureRecognizerDelegate  {
   
    // Utility Variables for swiping

    var myConnector: BackendConnector! // Backend Connector for REST API as well as variable container for between views. 

    // UI Variables 

    /// Conent area.
    fileprivate var mapView: GMSMapView? // The map
    fileprivate var costLabel: UILabel! // For cost
    fileprivate var timeLabel: UILabel! // For Time
    
    /// Bottom Bar views.
    fileprivate var bottomBar: Bar! // Bar for very bottom. 
    fileprivate var blankLabel: UILabel! // For blank in top right.
    fileprivate var rideLabel: UILabel! // For the get a ride. 
    fileprivate var boxLabel: UILabel! //For the Box thing
    fileprivate var deliverLabel: UILabel! // Deliver label
    
    /// Toolbar views.
    fileprivate var toolbar: Toolbar! // Top toolbar for rest/food name

    fileprivate var card: Card! // Main card
    fileprivate var botCard: Card! // Bottom card/menu
    fileprivate var topCard: Card! // Top card/menu
    
    // Variables 

    var originalPoint: CGPoint?
    var heightOfScreen: Double!

    // Event Handlers 
    
    internal fileprivate(set) var leftPanGesture: UIPanGestureRecognizer? // Swiping

    internal fileprivate(set) var tapGesture: UITapGestureRecognizer? // Taping the map

    internal fileprivate(set) var tapGestureCall: UITapGestureRecognizer? // Tapping Call
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Initialization of Variables
        
        heightOfScreen = Double(UIScreen.main.bounds.height)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_Pic_new.png")!);
        
        prepareblankLabel()
        prepareToolbar()
        prepareBottomBar()
        preparePresenterCard()
        prepareTopMenu()
        prepareBotMenu()

        originalPoint = card.center
        toolbar.title = myConnector.curCard.descrip;
        toolbar.detail = "          " + myConnector.curCard.restName;
        costLabel.text=String(myConnector.curCard.cost)
        
    }
    
    fileprivate func prepareblankLabel() {
        blankLabel = UILabel()
        blankLabel.font = UIFont(name: "Thonburi", size: 14.0)
        blankLabel.textColor = Color.white
        blankLabel.textAlignment = .center
        blankLabel.text = ""
        view.layout(blankLabel).top(5).left(20).right(20)
    }
    
    
    fileprivate func prepareToolbar() {
        toolbar = Toolbar()
        
        toolbar.title = "Bacon Cheese Burger"
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.font = UIFont(name: "Thonburi", size: 20.0)
        toolbar.detail = "      Arby's"
        toolbar.detailLabel.textAlignment = .left
        toolbar.detailLabel.font = UIFont(name: "Thonburi", size: 14.0)
        toolbar.detailLabel.textColor = Color.blueGrey.base
    }
    
   
    fileprivate func prepareBottomBar() {

        bottomBar = Bar()
        timeLabel = UILabel()
        timeLabel.numberOfLines = 1
        timeLabel.text = String(self.myConnector.curCard.restTime) + " mins"
        timeLabel.textAlignment = .center;
        timeLabel.font = UIFont(name: "Thonburi", size: 14.0);
        costLabel = UILabel()
        costLabel.numberOfLines = 1
        costLabel.text = "Right"
        costLabel.font = UIFont(name: "Thonburi", size: 14.0);

        let backImage = UIImage.fontAwesomeIcon(code: "fa-phone", textColor: UIColor.blue, size: CGSize(width: 30, height: 30))
        
        let iconBackImage = IconButton(image: backImage)

        tapGestureCall = UITapGestureRecognizer(target: self, action: #selector(buttonTapPhone))
        
        tapGestureCall?.delegate = self
        
        iconBackImage.addGestureRecognizer(tapGestureCall!)
        iconBackImage.isUserInteractionEnabled = true

        bottomBar.leftViews = [iconBackImage]
        bottomBar.centerViews = [timeLabel]
        bottomBar.rightViews = [costLabel]
        
        bottomBar.contentView.cornerRadiusPreset = .cornerRadius4

    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        let distance = gestureRecognizer.translation(in: card);
        switch gestureRecognizer.state {
            
            case .began:
                originalPoint = card.center
            
            case .changed:
                let rotationPercentage = min(distance.x/(view.width/2), 1);
                let rotationAngle = (CGFloat(2*3.14/16)*rotationPercentage);
                
                card.transform = CGAffineTransform(rotationAngle: rotationAngle)
                card.center = CGPoint(x:originalPoint!.x + distance.x,y: originalPoint!.y + distance.y)
            case .ended:
                if abs(distance.x) > card.width/4 {
                    print("Swipping the optin!");
                    swipeDirection(s: distance.x > 0 ? .Right : .Left)
                } else if abs(distance.y) > card.height/4 {
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
        if s == .Left {
            let myScreen = ViewController();
            myScreen.myConnector = self.myConnector;
            present(myScreen, animated: true)
            //Because it will nuke it. 
            myScreen.myConnector = self.myConnector;
            myScreen.newCard()
            
        }
        if s == .Right {
            resetViewPositionAndTransformations()
        }
        if (s == .Up) {
            
            let myScreen = ViewController_Buy();
            myScreen.myConnector = self.myConnector;
            present(myScreen, animated: true)
        }
    }
    
    private func resetViewPositionAndTransformations() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.card.center = self.originalPoint!
            self.card.transform = CGAffineTransform(rotationAngle: 0)
        })
    }

    /*
    * Tap the map
    */
    
    func buttonTapped(sender: UITapGestureRecognizer) {
        let curLat = self.myConnector.curLoc.latitude
        let curLng = self.myConnector.curLoc.longitude
        let latPos = self.myConnector.curCard.restPos.latitude
        let longPos = self.myConnector.curCard.restPos.longitude
        if (sender.state == .ended) {
            let directionsURL = "http://maps.apple.com/?saddr=" + "\(String(curLat))"+"," + "\(String(curLng))"+"&daddr="+"\(String(latPos))"+","+"\(String(longPos))";
            guard let url = URL(string: directionsURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }
        
    }

    /*
    * Tap the call
    */
    

    func buttonTapPhone(sender: UITapGestureRecognizer) {
        let phoneNumber = self.myConnector.curCard.restNumber
        if let url = URL(string: "telprompt:\(phoneNumber)") {
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
          }
        }
    }

    /*
    * Tap the back button. 
    */

    func buttonSwipe(sender: UITapGestureRecognizer) {
        present(ViewController(), animated: true)
    }




    func preparePresenterCard() {

        //Create Card

        card = Card()
        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .wideRectangle2
        card.contentViewEdgeInsetsPreset = .square3        
        card.cornerRadiusPreset = .cornerRadius4
        leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragged))
        view.addGestureRecognizer(leftPanGesture!)
        let curLat = self.myConnector.curLoc.latitude
        let curLng = self.myConnector.curLoc.longitude
        let latPos = self.myConnector.curCard.restPos.latitude
        let longPos = self.myConnector.curCard.restPos.longitude

        let camPosLat = (curLat+latPos)/2.0
        let camPosLong = (curLng + longPos)/2.0

        let mapSize = heightOfScreen - 350.0

        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: mapSize, height: mapSize), camera: GMSCameraPosition.camera(withLatitude: camPosLat, longitude: camPosLong, zoom: 10.5))

        mapView?.settings.scrollGestures = false
        mapView?.settings.zoomGestures = false

        mapView?.isMyLocationEnabled = true


        let smarker = GMSMarker()
        print("Placing markers....")
        smarker.position = CLLocationCoordinate2D(latitude: curLat, longitude: curLng)
        smarker.title = "Lavale"
        smarker.snippet = "Maharshtra"
        smarker.map = mapView

        let dmarker = GMSMarker()
        dmarker.position = CLLocationCoordinate2D(latitude: latPos, longitude: longPos)
        dmarker.title = "restaurant"
        dmarker.snippet = "rest"
        dmarker.map = mapView


        tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        
        tapGesture?.delegate = self
        
        mapView?.addGestureRecognizer(tapGesture!)
        mapView?.settings.setAllGesturesEnabled(false)
        
        card.contentView = mapView
        card.contentView?.isUserInteractionEnabled = true

        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        card.isUserInteractionEnabled = true

        view.layout(card).horizontally(left: 20, right: 20).center().top(60).bottom(40)

    }

    fileprivate func prepareTopMenu() {
        //***TopCard
        topCard = Card()
        topCard.bottomBar = Bar()
        topCard.bottomBar?.backgroundColor = Color.lightGreen.base
        deliverLabel = UILabel()
        deliverLabel.text = "Deliver"
        let deliverImage = UIImage.fontAwesomeIcon(code: "fa-arrow-up", textColor: UIColor.black, size: CGSize(width: 30, height: 30))

        topCard.bottomBar?.leftViews = [IconButton(image: deliverImage, tintColor: Color.red.base)]
        topCard.bottomBar?.rightViews = [deliverLabel]
        topCard.cornerRadiusPreset = .cornerRadius4
        
        view.layout(topCard).top(30).horizontally(left: 20, right: 20).height(30)//.height(50).center()
    }

    fileprivate func prepareBotMenu() {
        
        //Now add each one.
        let notLongLabel = UILabel()
        notLongLabel.numberOfLines = 1
        notLongLabel.text = "Hungry? Not for long"
        notLongLabel.font = UIFont(name: "Arial", size: 17)

        rideLabel = UILabel()
        rideLabel.numberOfLines = 1
        rideLabel.text = "Ride"
        rideLabel.text = ""
        boxLabel = UILabel()
        boxLabel.text = "Box"
        
        botCard = Card()
        botCard.bottomBar = Bar()
        let backImage = UIImage.fontAwesomeIcon(code: "fa-angle-double-left", textColor: UIColor.black, size: CGSize(width: 30, height: 30))

        let iconBackImage = IconButton(image: backImage)

        tapGestureCall = UITapGestureRecognizer(target: self, action: #selector(buttonSwipe))
        
        tapGestureCall?.delegate = self
        
        iconBackImage.addGestureRecognizer(tapGestureCall!)
        iconBackImage.isUserInteractionEnabled = true

        let rideImage = UIImage.fontAwesomeIcon(name: .automobile, textColor: UIColor.black, size: CGSize(width: 30, height: 30))

        botCard.bottomBar?.leftViews = [rideLabel,iconBackImage]
        botCard.bottomBar?.rightViews = [notLongLabel,rideLabel]
        //For Beta Comment out these lines. 
        //botCard.bottomBar?.leftViews = [IconButton(image: rideImage, tintColor: Color.red.base),rideLabel]
        //botCard.bottomBar?.rightViews = [IconButton(image: Icon.star, tintColor: Color.red.base),boxLabel]
        botCard.cornerRadiusPreset = .cornerRadius4

        view.layout(botCard).bottom().horizontally(left: 20, right: 20).height(100)//.center()

    }
}

