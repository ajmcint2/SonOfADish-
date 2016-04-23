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
    
    @IBOutlet weak var sort_seg_control: UIBarButtonItem!
    @IBOutlet weak var filter_seg_control: UISegmentedControl!
    var pass: Restaurant? = nil

    
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var dataViewController: NSFetchedResultsController = NSFetchedResultsController()
    
    var deleteIndexPath: NSIndexPath? = nil
    
    // added
    var sort_by_name: Bool = true
    var sort_by_rating: Bool = false
    var filter_sit_in: Bool = false
    var filter_fast_food: Bool = false
    var toggle_sort: Bool = true
    // end added
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //style nav bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 45.0/255.0, green: 140.0/255.0, blue: 255.0/255.0, alpha: 1.0);
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.toolbar.hidden = false;
        
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
        
        if(sort_by_name) {
            let sortDescripter = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescripter]
        }
        else if(sort_by_rating) {
            let sortDescripter = NSSortDescriptor(key: "rating", ascending: false)
            fetchRequest.sortDescriptors = [sortDescripter]
        }
        else if(filter_sit_in) {
            let sortDescripter = NSSortDescriptor(key: "type", ascending: false)
            fetchRequest.sortDescriptors = [sortDescripter]
        }
        else if(filter_fast_food) {
            let sortDescripter = NSSortDescriptor(key: "type", ascending: true)
            fetchRequest.sortDescriptors = [sortDescripter]
        }

        
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
        
        if(filter_sit_in && restaurant.type == "Fast Food") {
            cell.name.enabled = false
            cell.userInteractionEnabled = false
            cell.rating.enabled = false
            cell.img.backgroundColor = UIColor.clearColor()
        }
        else if(filter_fast_food && restaurant.type == "Sit In") {
            cell.name.enabled = false
            cell.userInteractionEnabled = false
            cell.rating.enabled = false
            cell.img.backgroundColor = UIColor.clearColor()
        }
        else {
            // Re-enable
            cell.name.enabled = true
            cell.userInteractionEnabled = true
            cell.rating.enabled = true
        }
        
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
    
    
    @IBAction func filter(sender: UISegmentedControl) {
        switch filter_seg_control.selectedSegmentIndex {
        case 0:
            // call function
            filter_fast_food = false
            filter_sit_in = false
            sort(false)
            return;
        case 1:
            // call function
            sort_by_rating = false;
            sort_by_name = false;
            filter_fast_food = false;
            filter_sit_in = true;
            break;
        case 2:
            // call function
            sort_by_rating = false;
            sort_by_name = false;
            filter_fast_food = true;
            filter_sit_in = false;
            break;
        default:
            break;
        }
        
        // re-fetch results
        dataViewController = getFetchResultsController()
        dataViewController.delegate = self
        do {
            try dataViewController.performFetch()
        } catch {
            print("An error occurred")
        }
        self.tableView.reloadData()
    }
    
    @IBAction func sort_pressed(sender: UIBarButtonItem) {
        sort(true)
        filter_seg_control.selectedSegmentIndex = 0
    }
    
    func sort(toggle: Bool) {
        if(toggle) {
            if(toggle_sort) {
                sort_by_name = false
                sort_by_rating = true
                toggle_sort = false
                filter_sit_in = false
                filter_fast_food = false
            }
            else {
                sort_by_name = true
                sort_by_rating = false
                toggle_sort = true
                filter_fast_food = false
                filter_sit_in = false
            }
        }
        else {
            if(toggle_sort) {
                sort_by_name = true;
            }
            else {
                sort_by_rating = true;
            }
            filter_fast_food = false
            filter_sit_in = false
        }
        
        
        // re-fetch results
        dataViewController = getFetchResultsController()
        dataViewController.delegate = self
        do {
            try dataViewController.performFetch()
        } catch {
            print("An error occurred")
        }
        self.tableView.reloadData()
    }


}

