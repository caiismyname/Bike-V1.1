//
//  WorkoutDetailViewController.swift
//  Bike V1.1
//
//  Created by David Cai on 7/18/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class WorkoutDetailViewController: UIViewController {
    
    var thisWorkout: workoutClass?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = thisWorkout?.type
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
