//
//  ContentVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 07/05/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WowonderMessengerSDK

var ContentViewControllerVC = R.storyboard.story.contentVC()

class ContentVC: UIViewController {
    
    var pageViewController : UIPageViewController?
    var pages: [GetStoriesModel.Story] = []
    var currentIndex : Int = 0
    
    var refreshStories: (() -> Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        pageViewController = R.storyboard.story.pageViewController()
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        
        let startingViewController: ShowStoryVC = viewControllerAtIndex(index: currentIndex)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = view.bounds
        
        startingViewController.refreshStories = {
        }
        
        addChild(pageViewController!)
        view.addSubview(pageViewController!.view)
        view.sendSubviewToBack(pageViewController!.view)
        pageViewController!.didMove(toParent: self)
        
        print(self.pages)

    }
  
    func viewControllerAtIndex(index: Int) -> ShowStoryVC? {
        
        if pages.count == 0 || index >= pages.count {
            return nil
        }
       
        let vc = R.storyboard.story.showStoryVC()
        vc?.refreshStories =  {
//            self.refreshStories!()
        }
        vc!.pageIndex = index
        vc!.items = self.pages
        currentIndex = index
    
        return vc
    }
    
    func goNextPage(fowardTo position: Int) {
        print("Position : \(position)")
        print("Item Count : \(self.pages.count)")
        let startingViewController: ShowStoryVC = viewControllerAtIndex(index: position) ?? ShowStoryVC()
        let viewControllers = [startingViewController]
//        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: true, completion: nil)
    }
    
    
}
extension ContentVC : UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ShowStoryVC).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ShowStoryVC).pageIndex
        if index == NSNotFound {
            return nil
        }
        index += 1
        if (index == pages.count) {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }
    
    
}

