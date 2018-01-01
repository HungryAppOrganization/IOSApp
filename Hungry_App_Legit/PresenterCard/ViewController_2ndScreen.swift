/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material
import FontAwesome_swift

class ViewController_2ndScreen: UIViewController {
    fileprivate var card: PresenterCard!
    fileprivate var card2: Card!
    fileprivate var card3: Card!
    //Question is what do we need:
    //var text: 
    //var text: Int!
    //var 

    var text: String!

    var phoneNum: String!
    var foodName: String!
    var locationName: String!
    var addressName: String!
    var foodCost: String!

    var foodPic: UIImage!

    var originalPoint: CGPoint?
    
    enum Direction {
        case None
        case Right
        case Left
        case Up
        case Down
    }
    
    
    /// Conent area.
    fileprivate var presenterView: UIImageView!
    fileprivate var contentView: UILabel!
    
    fileprivate var wholeView: View!
    fileprivate var botView: View!
    
    
    /// Bottom Bar views.
    fileprivate var bottomBar: Bar!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var dateLabel: UILabel!
    fileprivate var dateLabel2: UILabel!
    fileprivate var dateLabel3: UILabel!
    fileprivate var dateLabel4: UILabel!
    fileprivate var dateLabel5: UILabel!
    
    fileprivate var dateLabel6: UILabel!
    fileprivate var dateLabel7: UILabel!
    
    fileprivate var favoriteButton: IconButton!
    fileprivate var shareButton: IconButton!

    
    /// Toolbar views.
    fileprivate var toolbar: Toolbar!
    fileprivate var moreButton: IconButton!
    
    internal fileprivate(set) var leftPanGesture: UIPanGestureRecognizer?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = Color.grey.lighten5
        print("running")
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_Pic_new.png")!);
        
        prepareDateLabel2()
        
        preparePresenterView()
        prepareDateFormatter()
        prepareDateLabel()
        print("through dateLabel")
        //prepareFavoriteButton()
        //prepareShareButton()
        //prepareMoreButton()
        prepareToolbar()
        print("through toolbar")
        prepareContentView()
        //prepareBottomBar()
        preparePresenterCard()
        print("through presenter card")
        prepareTopMenu()
        print("through top menu")
        prepareBotMenu()
        print("through menus")
        
        originalPoint = card.center
        print("locked center")
        newCard()
        //contentView.text = text;
        contentView.text = phoneNum + "                         " + foodCost;
        toolbar.title = foodName;
        toolbar.detail = "          " + addressName;
        //self.presenterView.image = foodPic;


        
    }
}

extension ViewController_2ndScreen {
    fileprivate func preparePresenterView() {
        presenterView = UIImageView()
        presenterView.image = UIImage(named: "pattern")?.resize(toWidth: view.width)
        presenterView.contentMode = .scaleAspectFill
    }
    
    fileprivate func prepareDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    fileprivate func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "Thonburi", size: 14.0)
        dateLabel.textColor = Color.blueGrey.base
        dateLabel.textAlignment = .center
        dateLabel.text = "3.2 miles"
    }
    fileprivate func prepareDateLabel2() {
        dateLabel2 = UILabel()
        dateLabel2.font = UIFont(name: "Thonburi", size: 14.0)
        //dateLabel2.font = UbuntuFont.bold(with: 20)
        dateLabel2.textColor = Color.white
        dateLabel2.textAlignment = .center
        dateLabel2.text = ""
        view.layout(dateLabel2).top(5).left(20).right(20)
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
    
    fileprivate func prepareContentView() {
        contentView = UILabel()
        contentView.numberOfLines = 1
        contentView.text = "417-693-4622"
        contentView.font = UIFont(name: "Thonburi", size: 14.0);
    }
    
    fileprivate func prepareBottomBar() {
        bottomBar = Bar(centerViews: [dateLabel])
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        print("Default triggered for GestureRecognizer");
        //contentView.text="fat cow";
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
                //var newDirection: Direction
                //newDirection = distance < 0 ? .Left : .Right
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
                //print("Default triggered for GestureRecognizer")
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
            present(ViewController(), animated: true)
        } else if (s == .Right) {
            //No idea
            resetViewPositionAndTransformations();
            //present(ViewController(), animated: true)
            
        } else if (s == .Up) {
            //order it, have a popup come up and then say thank you.
            let myScreen = ViewController_Buy()
            myScreen.phoneNum = self.phoneNum;
            myScreen.foodName = self.foodName;
            myScreen.locationName = self.locationName;
            myScreen.addressName = self.locationName;
            myScreen.foodCost = self.foodCost;
            myScreen.foodPic = self.foodPic;

            present(myScreen, animated: true)

            
        } else {
            //ignore this
            resetViewPositionAndTransformations();
            //present(ViewController(), animated: true)
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
    func newCard() {
        let myNum = Int(arc4random_uniform(4) + 1);
        
        dateLabel.text = "Testing";//"4.5 miles"
        toolbar.title = "Bacon Cheese Burger";
        toolbar.detail = "         Red Lobster";
        contentView.text = "417-693-4622                        $14.03";//" $8.13 + Tax \n\n 3000 Calories"
        //lastly, the picture.
        presenterView.image = UIImage(named: "map.png")?.resize(toWidth: view.width)
        //Insert the other stuff whenever we get connection back.
        
        
        //presenterView.image = UIImage(named: "pattern")?.resize(toWidth: view.width)
        
        UIView.animate(withDuration: 0.01, animations: { () -> Void in
            self.card.center = self.originalPoint!
            self.card.transform = CGAffineTransform(rotationAngle: 0)
        })
        
        
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
        card.contentView = contentView
        card.contentViewEdgeInsetsPreset = .square3
        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        
        print("Attaching gesture recognizer!");
        //contentView.text="round 1";
        wholeView.layout(card).horizontally().center();
        leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragged))
        
        view.addGestureRecognizer(leftPanGesture!)
        view.layout(wholeView).horizontally(left:20,right:20).center()
    }

    fileprivate func prepareTopMenu() {
        //***TopCard
        card3 = Card()
        card3.bottomBar = Bar()
        card3.bottomBar?.backgroundColor = Color.lightGreen.base
        dateLabel7 = UILabel()
        dateLabel7.text = "Deliver"
        let deliverImage = UIImage.fontAwesomeIcon(code: "fa-arrow-up", textColor: UIColor.black, size: CGSize(width: 30, height: 30))

        card3.bottomBar?.leftViews = [IconButton(image: deliverImage, tintColor: Color.red.base)]
        card3.bottomBar?.rightViews = [dateLabel7]
        
        view.layout(card3).top(30).horizontally(left: 20, right: 20)//.height(50).center()
    }

    fileprivate func prepareBotMenu() {
        
        //***Bottom Part
        botView = View();
        
        //Now add each one.
        dateLabel2 = UILabel()
        dateLabel2.numberOfLines = 1
        dateLabel2.text = "Back"
        dateLabel3 = UILabel()
        dateLabel3.numberOfLines = 1
        dateLabel3.text = "Ride"
        dateLabel4 = UILabel()
        dateLabel4.text = "Box"
        dateLabel5 = UILabel()
        dateLabel5.text = ">"
        
        card2 = Card()
        card2.bottomBar = Bar()
        let backImage = UIImage.fontAwesomeIcon(code: "fa-angle-double-left", textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        let rideImage = UIImage.fontAwesomeIcon(name: .automobile, textColor: UIColor.black, size: CGSize(width: 30, height: 30))

        card2.bottomBar?.centerViews = [IconButton(image: backImage),dateLabel2]
        card2.bottomBar?.leftViews = [IconButton(image: rideImage, tintColor: Color.red.base),dateLabel3]
        card2.bottomBar?.rightViews = [IconButton(image: Icon.star, tintColor: Color.red.base),dateLabel4]
        view.layout(card2).bottom().horizontally(left: 20, right: 20).height(100)//.center()

    }
    
    
/*
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRectMake(100, 80, 30, 30))
        button.backgroundColor = UIColor.redColor()
        button.addTarget(self, action: #selector(pressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
    }
    
    func pressed(sender: UIButton) { //As ozgur says, ditch the !, it is not needed here :)
        print("button pressed")
    }
 */
}

extension ViewController_2ndScreen {
    
    //fileprivate func handleNextButton() {
    //    navigationController?.pushViewController(TransitionViewController(), animated: true)
    //}
}

