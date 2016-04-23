//
//  AddViewController.swift
//  TAS Group Project
//
//  Created by Alex McIntosh on 3/22/16.
//  Copyright © 2016 Alex McIntosh. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class AddViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    var restaurant: Restaurant? = nil   //restaurant object
    var type: String? = nil //type to determine if restaurant is sit in or fast food
    var count = 1   //used for rating on scale 1 to 5
    
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var dataViewController: NSFetchedResultsController = NSFetchedResultsController()
    
    @IBOutlet weak var imageFrame: UILabel!
    @IBOutlet weak var segBtn: UISegmentedControl!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var foodField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var plusRatingBtn: UIButton!
    @IBOutlet weak var minusRatingBtn: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    //indicators for which is selected in segment
    @IBOutlet weak var fastFoodLine: UILabel!
    @IBOutlet weak var sitInLine: UILabel!
    
    //manager to request location
    let locManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    var address = NSDictionary()
    var addressString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //get coordinates of user
        self.locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            self.latitude = locManager.location!.coordinate.latitude
            self.longitude = locManager.location!.coordinate.longitude
            
            print("Lattitude: \(latitude)")
            print("Longitude: \(longitude)")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.callWebService()
            })
        }
        
        //style nav bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 45.0/255.0, green: 140.0/255.0, blue: 255.0/255.0, alpha: 1.0);
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                
        //style with dropshadow
        imageFrame.layer.shadowOffset = CGSize(width: 3, height: 3)
        imageFrame.layer.shadowOpacity = 0.2
        imageFrame.layer.shadowRadius = 1
        
        ratingLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        ratingLabel.layer.shadowOpacity = 0.2
        ratingLabel.layer.shadowRadius = 1
        
        segBtn.layer.shadowOffset = CGSize(width: 3, height: 3)
        segBtn.layer.shadowOpacity = 0.2
        segBtn.layer.shadowRadius = 1
        
        //style button
        self.addPhotoBtn.layer.cornerRadius = 18
        addPhotoBtn.layer.shadowOffset = CGSize(width: 3, height: 3)
        addPhotoBtn.layer.shadowOpacity = 0.2
        addPhotoBtn.layer.shadowRadius = 1
        
        //set initial rating to 1
        var rating = "😋"
        self.ratingLabel.text = rating
        
        //set initial type as sit in
        type = "Sit In"
        self.fastFoodLine.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.locationField.resignFirstResponder()
        self.foodField.resignFirstResponder()
        return true;
    }
    
    //change type of restaurant
    @IBAction func changeType(sender: AnyObject) {
        switch segBtn.selectedSegmentIndex {
        case 1:
            type = "Fast Food"
            self.sitInLine.hidden = true
            self.fastFoodLine.hidden = false
        default:
            type = "Sit In"
            self.sitInLine.hidden = false
            self.fastFoodLine.hidden = true
        }
        
        print(type!)
    }

    @IBAction func increaseRating(sender: AnyObject) {
        var rating = ""
        if count < 5{
            count = count + 1
            for (var i = 0; i < count; i += 1){
                rating = rating + "😋" + " "
            }
            self.ratingLabel.text = rating
        }
        print(count)
    }
    
    @IBAction func decreaseRating(sender: AnyObject) {
        var rating = ""
        if count > 1{
            count = count - 1
            for (var i = 0; i < count; i += 1){
                rating = rating + "😋" + " "
            }
            self.ratingLabel.text = rating
        }
        print(count)
    }
    
    
    
    
    
    /*
     * Inserts entity to core data or edits an entity
     */
    @IBAction func saveRestaurant(sender: AnyObject) {
        if restaurant == nil {
            let res = NSEntityDescription.entityForName("Restaurant", inManagedObjectContext: self.context)
            restaurant = Restaurant(entity: res!, insertIntoManagedObjectContext: self.context)
        }
        
        restaurant?.name = locationField.text!
        print(restaurant?.name)
        
        restaurant?.food = foodField.text!
        print(restaurant?.food)
        
        restaurant?.type = type!
        print(restaurant?.type)
        
        restaurant?.rating = count
        
        restaurant?.address = addressString
        
        if imageView.image != nil {
            let imgData = UIImageJPEGRepresentation(imageView.image!, 0.08)
            restaurant?.img = imgData!
        }
        
        do {
            try context.save()
        }
        catch {
            print(error)
        }
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //call webservice for address on current location
    func callWebService(){
        let urlString = "http://api.geonames.org/findNearestAddressJSON?lat=\(self.latitude)&lng=\(self.longitude)&username=ajmcint2"
        print(urlString)
        let url = NSURL(string: urlString)!
        let urlSession = NSURLSession.sharedSession()
        
        let jsonQuery = urlSession.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
            if error != nil {
                print(error!.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            if (err != nil) {
                print("JSON Error \(err!.localizedDescription)")
            }
            
            print(jsonResult)
            self.address = jsonResult["address"] as! NSDictionary
            
            //get json zipcode value
            let zip = self.address["postalcode"] as! String
            print(zip)
            
            let state = self.address["adminCode1"] as! String
            print(state)
            
            let city = self.address["placename"] as! String
            print(city)
            
            let streetNum = self.address["streetNumber"] as! String
            print(streetNum)
            
            let street = self.address["street"] as! String
            print(street)
            
            self.addressString = streetNum + " " + street + ", " + city + "," + " " + state + "  " + zip
            print(self.addressString)
            
        })
        
        jsonQuery.resume()

    }
    
    //cancels addition
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)   //send back to table view
    }
    
    //add photo to entry
    @IBAction func addPhoto(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.clipsToBounds = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
