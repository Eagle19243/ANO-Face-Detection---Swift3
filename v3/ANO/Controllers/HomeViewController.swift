//
//  HomeViewController.swift
//  ANO
//
//  Created by Jacob May on 1/5/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit

class HomeViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var aryViewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        aryViewControllers = [
            (self.storyboard?.instantiateViewController(withIdentifier: String(describing: MessageViewController.self)))!,
            (self.storyboard?.instantiateViewController(withIdentifier: String(describing: CameraViewController.self)))!,
            (self.storyboard?.instantiateViewController(withIdentifier: String(describing: EventsViewController.self)))!
        ]
        
        self.dataSource = self
        self.setViewControllers([aryViewControllers[1]], direction: .forward, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let nIndex = aryViewControllers.index(of: viewController)
        if nIndex == 0 {
            return nil
        } else {
            return aryViewControllers[nIndex! - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nIndex = aryViewControllers.index(of: viewController)
        if nIndex == aryViewControllers.count - 1 {
            return nil
        } else {
            return aryViewControllers[nIndex! + 1]
        }
    }    
}
