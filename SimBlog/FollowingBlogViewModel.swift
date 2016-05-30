//
//  FollowingBlogViewModel.swift
//  SimBlog
//
//  Created by 松下慶大 on 2016/05/09.
//  Copyright © 2016年 matsushita keita. All rights reserved.
//

import UIKit

class FollowingBlogViewModel: NSObject, UITableViewDataSource {
    var tableView: UITableView!
    var viewController: FollowingBlogViewController!
    var page = 1
    let currentUser = CurrentUser.sharedInstance
    var blogCell: BlogCell!
    
    func didLoad(tableView: UITableView, viewController: FollowingBlogViewController) {
        currentUser.getFollowingBlogsInBackground(page) { 
            tableView.reloadData()
        }
        self.viewController = viewController
        self.tableView = tableView
        tableView.dataSource = self
        tableView.registerCell("BlogCell")
        tableView.registerCell("MoreItemsCell")
    }
    
    func willAppear() {
        insertNewBlogToRow(tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentUser.numberOfFollowingBlogs
        } else {
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BlogCell", forIndexPath: indexPath) as! BlogCell
            cell.fillWith(currentUser.followingBlogAtPosition(indexPath.row))
            self.blogCell = cell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreItemsCell", forIndexPath: indexPath) as! MoreItemsCell
            return cell
        }
        
    }
    
    func loadMoreItems() {
        page = page + 1
        currentUser.getFollowingBlogsInBackground(page) { 
            self.insertTopRow(self.tableView)
        }
    }
    
    
    // MARK Table View Private
    private func insertTopRow(tableView: UITableView) {
        let differenceIndex = currentUser.numberOfFollowingBlogs - tableView.numberOfRowsInSection(0)
        if differenceIndex > 0 {
            for _ in 1...differenceIndex {
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: currentUser.numberOfFollowingBlogs - 1, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
    
    private func insertNewBlogToRow(tableView: UITableView) {
        print("====")
        print(currentUser.numberOfFollowingBlogs)
        print(tableView.numberOfRowsInSection(0))
        let differenceIndex = currentUser.numberOfFollowingBlogs - tableView.numberOfRowsInSection(0)
        if differenceIndex > 0 {
            for _ in 1...differenceIndex {
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
            }
        }
    }

}
