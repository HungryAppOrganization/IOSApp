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
import Firebase



var ref: DatabaseReference!
var storage: Storage!

class ViewController: UIViewController {
    fileprivate var card: PresenterCard!
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
    
    /// Bottom Bar views.
    fileprivate var bottomBar: Bar!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var dateLabel: UILabel!
    fileprivate var dateLabel2: UILabel!
    fileprivate var favoriteButton: IconButton!
    fileprivate var shareButton: IconButton!
    var originalPoint: CGPoint?
    var myCost: String!


    var curCard: NSDictionary!
    var nextCard: NSDictionary!

    
    var nextrefImage: UIImage!
    
    var cardNum: Double!
    
    var myInts = [Int]()

    var ref: DatabaseReference!
    


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
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_Pic_new.png")!);
        
        prepareDateLabel2()
        
        preparePresenterView()
        prepareDateFormatter()
        prepareDateLabel()
        //prepareFavoriteButton()
        //prepareShareButton()
        //prepareMoreButton()
        prepareToolbar()
        prepareContentView()
        prepareBottomBar()
        preparePresenterCard()
        originalPoint = card.center
        self.cardNum = 0;
        storage = Storage.storage()
        ref = Database.database().reference()
        self.card.alpha = 0.0
        UIView.animate(withDuration: 0.5 , delay: 1.0, animations: { () -> Void in
            self.card.alpha = 1.0
            self.card.center = self.originalPoint!
            self.card.transform = CGAffineTransform(rotationAngle: 0)
        })
        
        
        newCard()
        
        
        
    }
}

extension ViewController {
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
        dateLabel2.font = UIFont(name: "Thonburi", size: 18.0)
        //dateLabel2.font = UbuntuFont.bold(with: 20)
        dateLabel2.textColor = Color.white
        dateLabel2.textAlignment = .center
        dateLabel2.text = ""
        view.layout(dateLabel2).top(10).left(20).right(20)
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
        contentView.numberOfLines = 3
        contentView.text = " $6.03 + Tax \n\n 1000 Calories"
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
        if (s == .Left || s == .Right) {
            if s == .Left {
                parentWidth *= -1
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.card.center.x = self.card.frame.origin.x + parentWidth
            }, completion: {
                success in
                if s == .Right {
                    self.swipedRight();
                    //self.resetViewPositionAndTransformations();
                } else if s == .Left {
                    self.swipedLeft();
                    //self.resetViewPositionAndTransformations();
                }
                
            })
        } else if (s == .Up) {
            print("Swipe up");
            let myScreen = ViewController_2ndScreen();
            myScreen.phoneNum = "417-693-4622";
            myScreen.foodName = toolbar.title;
            myScreen.locationName = toolbar.detail;
            myScreen.addressName = toolbar.detail;
            myScreen.foodCost = myCost;
            myScreen.foodPic = self.presenterView.image;
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
    func populateCard(storage: Storage) {
        var myNum = Int(0);
        if myInts.count >= 39 {
            myInts = [Int]()
        }
        
        if self.cardNum <= 0 {
            print("First Card!")
            //pull the first.
            while true {
                myNum = Int(arc4random_uniform(40) + 1);
                if (!myInts.contains(myNum)) {
                    myInts.append(myNum)
                    break
                }
            }
            ref.child("foods").child(String(myNum)).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    self.nextCard = value;
                    let imageLink = value["foodPic"] as? String ?? ""
                    let completeImageLink = "gs://transproject-adc23.appspot.com/HungryLogos/" + imageLink
                    let gsReferenceImage = storage.reference(forURL: completeImageLink)
                    gsReferenceImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                        } else {
                            let image = UIImage(data: data!)?.resize(toWidth: self.view.width)
                            self.presenterView.image = image;
                            let description = value["description"] as? String ?? ""
                            let cal = value["calories"] as? String ?? ""
                            let cost = value["price"] as? String ?? ""
                            let restName = value["name"] as? String ?? ""
                            self.toolbar.title = description
                            self.toolbar.detail = "       " +  restName
                            self.contentView.text = "" + cost + "\n\n" + cal + " Calories";
                            self.myCost = cost;
                        }
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
            self.cardNum = 1;
        } else {
            print("Next Card!")
            let value = nextCard!
            self.presenterView.image = nextrefImage;
            
            let description = value["description"] as? String ?? ""
            let cal = value["calories"] as? String ?? ""
            let cost = value["price"] as? String ?? ""
            let restName = value["name"] as? String ?? ""
            self.toolbar.title = description
            self.toolbar.detail = "       " + restName
            self.contentView.text = "" + cost + "\n\n" + cal + " Calories";
            self.myCost = cost;
        }

        //Now pull the next card.

        var myNum2 = 0;
    
        while true {
            myNum2 = Int(arc4random_uniform(40) + 1);
            if (!myInts.contains(myNum2)) {
                myInts.append(myNum2)
                break
            }
        }

        ref.child("foods").child(String(myNum2)).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.nextCard = value;
            let imageLink = value["foodPic"] as? String ?? ""
            let completeImageLink = "gs://transproject-adc23.appspot.com/HungryLogos/" + imageLink
            let gsReferenceImage = storage.reference(forURL: completeImageLink)
            gsReferenceImage.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error")
                } else {
                    let image = UIImage(data: data!)?.resize(toWidth: self.view.width)
                    //self.presenterView.image = image
                    self.nextrefImage = image;
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }


    func newCard() {
        populateCard(storage: storage)
        resetViewPositionAndTransformations()
    }
    
    
    private func resetViewPositionAndTransformations() {
        UIView.animate(withDuration: 0.01, animations: { () -> Void in
            self.card.center = self.originalPoint!
            self.card.transform = CGAffineTransform(rotationAngle: 0)
        })
    }
    
    func preparePresenterCard() {

        wholeView = View()
        
        
        
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
        //wholeView.addTarget(self,action: #selector(dragged))
        //fabButton.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)
        
        //wholeView.addGestureRecognizer(UIPanGestureRecognizer(target: wholeView, action: #selector(dragged)))
        
        //wholeView!.delegate = self
        //wholeView!.cancelsTouchesInView = false
        
        leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragged))
        //leftPanGesture?.delegate = self
        //leftPanGesture!.cancelsTouchesInView = false
        view.addGestureRecognizer(leftPanGesture!)
        
        
        
        view.layout(wholeView).horizontally(left:20,right:20).center()
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

extension ViewController {
    
    //fileprivate func handleNextButton() {
    //    navigationController?.pushViewController(TransitionViewController(), animated: true)
    //}
}

