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
import GoogleMaps

/*
* This file handles all backend communications. 
* I will burry all the properties in the beginning of this file as well
*/
class BackendConnector {
	//need a structure for each card

	var ref: DatabaseReference! //Database Reference

	var storage: Storage!

	var cardsShown = [Int]() // Values of cards shown so far

	//var nextCard: NSDictionary! // Next Card
    var curCard: CardToPresent!
    var nxtCard: CardToPresent!

    //var nextrefImage: UIImage! // Next Image to be displayed
    
    var firstCard: Bool! // See if it is the first card or not

    //var myCost: String! // Current Cost Displayed

    //var addressLoc: String! // Current Address

    //var restNumber: String! // Current number of the restaurant TODO

    //var rstLoc: CLLocationCoordinate2D!
    
    //var nxtLoc: CLLocationCoordinate2D!

    var curLoc: CLLocationCoordinate2D!

	func initialize() {
        print("Initing the connector and all!")
        self.curCard = CardToPresent();
		self.nxtCard = CardToPresent();
		self.firstCard = true;
		storage = Storage.storage();
        ref = Database.database().reference();
    }



	func greet(person: String) -> String {
    	let greeting = "Hello, " + person + "!"
    	return greeting
	}

	func printMessagesForUser() -> Void {
        let dict = ["user":"larry"]
	    if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
	    	//let urlString = "http://dev.fuefinance.com:5000/test" //"http://dev.fuefinance.com:5000/api/get_message"
            let urlString = "http://dev.fuefinance.com:5000/api/get_message"
            let url = NSURL(string: urlString)!
		    let request = NSMutableURLRequest(url: url as URL)
		    request.httpMethod = "POST"
		    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		    request.httpBody = jsonData

		    let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
		        print("Responding....")
                print(data)
                print(response)
                print(error)
                
                if error != nil{
                    print("Printing an error.....")
		           print(error?.localizedDescription)
		           return
		        }

		        do {
		            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    print("My json is: ")
                    print(json)
                    let myList = String(describing: json!["messages"]!)
                    print(myList)
                    if (myList == "test1") {
                        print("It worked")
                    }
                    //print(myList.first)
                    
                } catch let error as NSError {
                     print(error)
                }
            }
            task.resume()
		}
		
	    
	}


}

struct CardToPresent {
	var foodImage: UIImage! // Image
	var descrip: String! // Name of Food
	var cal: String! // Calories
	var cost: Double! // Cost
	var restTime: Int! // Time to get there
	var restPos: CLLocationCoordinate2D! // Location of restaurant
	var restName: String! // Restaurant name
	var restAddress: String! // Restaurant address
	var restNumber: String! // Restaurant Number
	
	init() {
        restTime = 7
	}
	mutating func  unloadDict(dbDict: NSDictionary) {
       
        descrip = dbDict["description"] as? String ?? ""
        cal = dbDict["calories"] as? String ?? ""
        cost = dbDict["price"] as? Double ?? 0.0
        restName = dbDict["name"] as? String ?? ""
        restNumber = "4176934622"
        restAddress = dbDict["location"] as? String ?? ""
        
	}
}

enum Direction {
    case None
    case Right
    case Left
    case Up
    case Down
}
    
