//
//  ViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var client: YelpClient!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        println("this shit")
        performSegueWithIdentifier("filterSegue", sender: nil)
    }
    
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    let yelpConsumerKey = "9z3pgZ0FDNJ06CufhMoQtA"
    let yelpConsumerSecret = "q8uh8XlKijlbIBfMmDzs5PDKo40"
    let yelpToken = "UnISrs6j3L-sxOtT8FIj1UzM0XrvZBFB"
    let yelpTokenSecret = "xeuW8tj8A2KttRYhc4X-QegeF4E"
    
    var yelpBusinesses: NSMutableArray
    var offset: UInt8
    
    required init(coder aDecoder: NSCoder) {
        self.offset = 0
        self.yelpBusinesses = NSMutableArray();
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchText.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.filterButton.layer.borderColor = UIColor.blackColor().CGColor
        self.filterButton.layer.borderWidth = 0.5;
        self.filterButton.layer.cornerRadius = 5;
        
        self.mapButton.layer.borderColor = UIColor.blackColor().CGColor
        self.mapButton.layer.borderWidth = 0.5;
        self.mapButton.layer.cornerRadius = 5;

        
        self.client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        getNewResults()
        textField.resignFirstResponder()
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func getNewResults() {
        self.client.searchWithTerm(self.searchText.text,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                self.yelpBusinesses.addObjectsFromArray(response["businesses"] as NSArray)
                self.offset += self.yelpBusinesses.count
                self.tableView.reloadData()
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.yelpBusinesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let resultDictionary = self.yelpBusinesses[indexPath.row] as NSDictionary
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as SearchTableViewCell
        cell.nameLabel?.text = "\(indexPath.row + 1). " + (resultDictionary["name"] as NSString)
        cell.reviewLabel?.text = (resultDictionary["review_count"] as NSNumber).stringValue + " Reviews"
        cell.addressLabel?.text = (resultDictionary["location"]!["address"] as NSArray).lastObject as NSString
        cell.categoriesLabel?.text = ((resultDictionary["categories"]!as NSArray).firstObject as NSArray).firstObject as NSString
        println(resultDictionary)
        cell.sizeToFit()
        
        cell.previewImage?.setImageWithURLRequest(
            NSURLRequest(URL: NSURL(string: resultDictionary["image_url"] as NSString)),
            placeholderImage: UIImage(),
            success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                cell.previewImage?.image = image
                UIView.animateWithDuration(0.5, animations: {
                    cell.previewImage.alpha = 1.0
                    cell.previewImage.layer.masksToBounds = true
                    cell.previewImage.layer.cornerRadius = 5
                    
                })
            },
            failure: nil
        )
        
        cell.reviewImage?.setImageWithURLRequest(
            NSURLRequest(URL: NSURL(string: resultDictionary["rating_img_url"] as NSString)),
            placeholderImage: UIImage(),
            success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                cell.reviewImage?.image = image
                UIView.animateWithDuration(0.5, animations: {
                    cell.reviewImage.alpha = 1.0
                })
            },
            failure: nil
        )
        
        return cell
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row >= self.yelpBusinesses.count - 1) {
            getNewResults()
        }
    }
}

