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

class ViewController_Buy: UIViewController, UIGestureRecognizerDelegate {
    
    var myConnector: BackendConnector! // Backend Connector for REST API as well as variable container for between views. 

    fileprivate var card: PresenterCard! // Main card
    fileprivate var botCard: Card! // Very bottom label with back button
    fileprivate var topCard: Card! // Very top that says On its way. 

    /// Conent area.
    fileprivate var presenterView: UIImageView! // Main image
    fileprivate var numAndCostLabel: UILabel! // Num and Cost at bottom
    
    fileprivate var wholeView: View! // Wrapper for card.
    
    /// Bottom Bar views.
    fileprivate var bottomBar: Bar! // Bottom bar for card
    fileprivate var dateLabel: UILabel! // Label for going back
    fileprivate var backLabel: UILabel! // Go back at center bottom
    
    fileprivate var boxLabel: UILabel! // Box it (not because of beta0
    
    fileprivate var onwayLabel: UILabel! // On its way label

    var originalPoint: CGPoint?
    var heightOfScreen: Double!
    
    /// Toolbar views.
    fileprivate var toolbar: Toolbar! // Toolbar for information on food. 
    
    internal fileprivate(set) var leftPanGesture: UIPanGestureRecognizer?

    internal fileprivate(set) var tapGestureCall: UITapGestureRecognizer?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        heightOfScreen = Double(UIScreen.main.bounds.height)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_Pic_new.png")!);
        
        preparebackLabel()
        preparePresenterView()
        prepareDateLabel()        
        prepareToolbar()
        preparenumAndCostLabel()
        preparePresenterCard()
        prepareTopMenu()
        prepareBotMenu()

        self.presenterView.image = self.myConnector.curCard.foodImage
        numAndCostLabel.text = self.myConnector.curCard.restNumber + "                         " + String(self.myConnector.curCard.cost);
        toolbar.detail = "          " + self.myConnector.curCard.restAddress;
    }

    fileprivate func preparePresenterView() {
        presenterView = UIImageView()
        presenterView.image = UIImage(named: "pattern")?.resize(toWidth: view.width)
        presenterView.contentMode = .scaleAspectFill
    }

    fileprivate func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "Thonburi", size: 14.0)
        dateLabel.textColor = Color.blueGrey.base
        dateLabel.textAlignment = .center
        dateLabel.text = "3.2 miles"
    }

    fileprivate func preparebackLabel() {
        backLabel = UILabel()
        backLabel.font = UIFont(name: "Thonburi", size: 14.0)
        //backLabel.font = UbuntuFont.bold(with: 20)
        backLabel.textColor = Color.white
        backLabel.textAlignment = .center
        backLabel.text = "Hungry?"
        view.layout(backLabel).top(5).left(20).right(20)
    }
    
    fileprivate func prepareToolbar() {
        toolbar = Toolbar()
        
        toolbar.title = "Congrats! Good Choice"
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.font = UIFont(name: "Thonburi", size: 20.0)
        
        toolbar.detail = "      Bacon Cheese Burger"
        toolbar.detailLabel.textAlignment = .left
        toolbar.detailLabel.font = UIFont(name: "Thonburi", size: 14.0)
        
        toolbar.detailLabel.textColor = Color.blueGrey.base
    }
    
    fileprivate func preparenumAndCostLabel() {
        numAndCostLabel = UILabel()
        numAndCostLabel.numberOfLines = 1
        numAndCostLabel.text = "417-693-4622"
        numAndCostLabel.font = UIFont(name: "Thonburi", size: 14.0);
    }
    
    fileprivate func prepareBottomBar() {
        bottomBar = Bar(centerViews: [dateLabel])
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        print("Default triggered for GestureRecognizer");
        //numAndCostLabel.text="fat cow";
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
                swipeDirection(s: .Up);
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
        if (s == .Left) {
            //Go Back
            let myScreen = ViewController_2ndScreen();
            myScreen.myConnector = self.myConnector
            present(myScreen, animated: true)

        } else if (s == .Right) {
            //No idea
            
        } else if (s == .Up) {
            //order it, have a popup come up and then say thank you.
            
        } else {
            //ignore this
        }
        
        if (s == .Left || s == .Right) {
            if s == .Left {
                let myScreen = ViewController_2ndScreen();
                myScreen.myConnector = self.myConnector
                
                present(myScreen, animated: true)

            }
            
        } else if (s == .Up) {
            numAndCostLabel.text = "TestingThisMadness";
            self.resetViewPositionAndTransformations();
        }
    }
    
    
    
    
    private func resetViewPositionAndTransformations() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.card.center = self.originalPoint!
            self.card.transform = CGAffineTransform(rotationAngle: 0)
        })
    }
    
    func preparePresenterCard() {
        
        wholeView = View()
        
        //Create Card
        card = PresenterCard()
        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .wideRectangle2
        card.presenterView = presenterView
        card.contentView = numAndCostLabel
        card.contentViewEdgeInsetsPreset = .square3
        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        card.cornerRadiusPreset = .cornerRadius4        
        print("Attaching gesture recognizer!");
        //numAndCostLabel.text="round 1";
        wholeView.layout(card).horizontally().center();
        leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragged))
        
        view.addGestureRecognizer(leftPanGesture!)
        view.layout(wholeView).horizontally(left:20,right:20).center()
    }
    
    fileprivate func prepareTopMenu() {
        //***TopCard
        topCard = Card()
        topCard.bottomBar = Bar()
        topCard.bottomBar?.backgroundColor = Color.lightGreen.base
        onwayLabel = UILabel()
        onwayLabel.text = "On its way!"
        onwayLabel.textAlignment = .center
        topCard.bottomBar?.centerViews = [onwayLabel];

        topCard.cornerRadiusPreset = .cornerRadius4
        view.layout(topCard).top(30).height(50).horizontally(left: 20, right: 20)
    }
    
    fileprivate func prepareBotMenu() {
        
        //Now add each one.
        
        backLabel = UILabel()
        backLabel.numberOfLines = 1
        backLabel.text = "Back"
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
        
        botCard.bottomBar?.centerViews = [iconBackImage]
        botCard.cornerRadiusPreset = .cornerRadius4

        view.layout(botCard).bottom().height(100).horizontally(left: 20, right: 20).center()
        
    }

    func buttonSwipe(sender: UITapGestureRecognizer) {
        present(ViewController(), animated: true)
    }
}

