//
//  RestaurantViewController.swift
//  TAS Group Project
//
//  Created by Alex McIntosh on 3/22/16.
//  Copyright © 2016 Alex McIntosh. All rights reserved.
//

import UIKit
import MapKit

class RestaurantViewController: UIViewController {

    var restaurant: Restaurant? = nil
    var talbeIndex: NSIndexPath? = nil
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var segBtn: UISegmentedControl!
    
    //indicators for which is selected
    @IBOutlet weak var picLine: UILabel!
    @IBOutlet weak var mapLine: UILabel!
    
    @IBOutlet weak var imageFrame: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //style nav bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 45.0/255.0, green: 140.0/255.0, blue: 255.0/255.0, alpha: 1.0);
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        //set view from object
        if restaurant != nil {
            self.nameLabel.text = restaurant?.name
            self.addressLabel.text = restaurant?.address
            self.typeLabel.text = restaurant?.type
            if restaurant?.img != nil {
                self.imageView.image = UIImage(data: (restaurant?.img)!)!
                self.imageView.contentMode = .ScaleAspectFill
                self.imageView.clipsToBounds = true
                self.imageView.hidden = true
            }
            var rating: String = ""
            for (var i = 0; i < restaurant!.rating; i = i+1){
                rating = rating + "😋" + " "
            }
            self.ratingLabel.text = rating
            
            searchForLocation((restaurant?.address)!)
        }
        
        self.picLine.hidden = true;
        
        //style labels with dropshadow
        imageFrame.layer.shadowOffset = CGSize(width: 3, height: 3)
        imageFrame.layer.shadowOpacity = 0.2
        imageFrame.layer.shadowRadius = 1
        
        addressLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        addressLabel.layer.shadowOpacity = 0.2
        addressLabel.layer.shadowRadius = 1
               
        segBtn.layer.shadowOffset = CGSize(width: 3, height: 3)
        segBtn.layer.shadowOpacity = 0.2
        segBtn.layer.shadowRadius = 1
        
        ratingLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        ratingLabel.layer.shadowOpacity = 0.2
        ratingLabel.layer.shadowRadius = 1
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentChange(sender: AnyObject) {
        switch segBtn.selectedSegmentIndex {
        case 0: //hide image picker, show map
            print("Looking at map. Image hidden.")
            self.imageView.hidden = true
            self.mapView.hidden = false;
            self.picLine.hidden = true;
            self.mapLine.hidden = false
            self.addressLabel.text = restaurant?.address
        case 1: //hide map, show image picker
            print("Looking at image. Map hidden.")
            self.imageView.hidden = false
            self.mapView.hidden = true;
            self.mapLine.hidden = true
            self.picLine.hidden = false
            self.addressLabel.text = restaurant?.food
        default:
            print("An error occured")
        }
    }

    func searchForLocation(sender: AnyObject){
        let geoCoder = CLGeocoder()
        
        let place = sender as! NSString
        geoCoder.geocodeAddressString(place as String, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if let placemark = placemarks?[0] {
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: placemark.location!.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                var ani = MKPointAnnotation()
                ani.coordinate = placemark.location!.coordinate
                ani.title = self.restaurant?.name
                
                self.mapView.addAnnotation(ani)
            }
        })

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
