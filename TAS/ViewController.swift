//
//  ViewController.swift
//  TAS Group Project
//
//  Created by Alex McIntosh on 3/22/16.
//  Copyright © 2016 Alex McIntosh. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var pass: Restaurant? = nil

    
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var dataViewController: NSFetchedResultsController = NSFetchedResultsController()
    
    var deleteIndexPath: NSIndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //style nav bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 45.0/255.0, green: 140.0/255.0, blue: 255.0/255.0, alpha: 1.0);
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //fetch core data
        dataViewController = getFetchResultsController()
        dataViewController.delegate = self
        do {
            try dataViewController.performFetch()
        }
        catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getFetchResultsController() -> NSFetchedResultsController {
        dataViewController = NSFetchedResultsController(fetchRequest: listFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return dataViewController
        
    }
    
    func listFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Restaurant")
        let sortDescripter = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescripter]
        
        return fetchRequest
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections  = dataViewController.sections?.count
        return numberOfSections!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = dataViewController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    /*
     * Insert cell
     */
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("restaurant", forIndexPath: indexPath) as! RestaurantTableViewCell
        let restaurant = dataViewController.objectAtIndexPath(indexPath) as! Restaurant
        

        //set cell label
        cell.name.text = restaurant.name
        var rating: String = ""
        
        for (var i = 0; i < restaurant.rating; i = i+1){
            rating = rating + "😋" + " "
        }
        cell.rating.text = rating
        //check if image is available and set image
        if UIImage(data: restaurant.img) != nil {
            cell.img.image = UIImage(data: (restaurant.img))!
        }
        
        cell.img.contentMode = .ScaleAspectFill
        cell.img.layer.masksToBounds = true
                
        return cell
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    /*
     * Allows editing or deletion of cell
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            deleteIndexPath = indexPath
            let restaurantToDelete = dataViewController.objectAtIndexPath(indexPath) as! Restaurant
            confirmDelete(restaurantToDelete)
        }
        
    }
    
    /*
     * Confirm with user to delete cell
     */
    func confirmDelete(restaurant: Restaurant) {
        
        let alert = UIAlertController(title: "Delete Restaurant", message: "Are you sure you want to permanently delete \(restaurant.name)?", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteRestaurant)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteRestaurant)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    /*
     * Delete cell from table
     */
    func handleDeleteRestaurant(alertAction: UIAlertAction!) -> Void {
        
        if let indexPath = deleteIndexPath {
            
            let restToDelete = dataViewController.objectAtIndexPath(indexPath) as! Restaurant
            context.deleteObject(restToDelete)
            do {
                try context.save()
            }
            catch {
                print(error)
            }
            
        }
        
    }
    
    /*
     * Cancel delete of cell
     */
    func cancelDeleteRestaurant(alertAction: UIAlertAction!) {
        deleteIndexPath = nil
        print("Canceled delete")
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "info"{
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let dest: RestaurantViewController =  segue.destinationViewController as! RestaurantViewController
            let row = dataViewController.objectAtIndexPath(indexPath!) as! Restaurant
            dest.restaurant = row
        }
    }


}

