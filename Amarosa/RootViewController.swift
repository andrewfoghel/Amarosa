//
//  RootViewController.swift
//  Amarosa
//
//  Created by Andrew Foghel on 7/13/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    lazy var viewControllerList:[UIViewController] = {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = storyBoard.instantiateViewController(withIdentifier: "profile")
        let vc2 = storyBoard.instantiateViewController(withIdentifier: "camera")
        let vc3 = storyBoard.instantiateViewController(withIdentifier: "loveStory")
        
        return[vc1,vc2,vc3]
        
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.dataSource = self
        
        self.setViewControllers([viewControllerList[1]], direction: .forward, animated: true, completion: nil)
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handlePagination), userInfo: nil, repeats: true)
    }
    
    func handlePagination(){
        if isDrawable == false{
            self.dataSource = self
        }else{
            self.dataSource = nil
        }
        
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else{return nil}
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else{ return nil }
        
        guard viewControllerList.count >= previousIndex else {return nil}
        
        return viewControllerList[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else {return nil}
        
        guard viewControllerList.count > nextIndex else {return nil}
        
        
        
        return viewControllerList[nextIndex]
    }
    
}

