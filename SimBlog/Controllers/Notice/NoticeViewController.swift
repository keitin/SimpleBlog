//
//  NoticeViewController.swift
//  SimBlog
//
//  Created by 松下慶大 on 2016/05/14.
//  Copyright © 2016年 matsushita keita. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController, UITableViewDelegate, NoticeCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    let noticeViewModel = NoticeViewModel()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noticeViewModel.didLoad(tableView, viewController: self)
        tableView.delegate = self
        
        refreshControl = UIRefreshControl.loadingItems(self, selector: #selector(NoticeViewController.pullAndload))
        self.tableView.addSubview(refreshControl)
        
        let tabbarC = self.tabBarController as! InitialTabBarController
        tabbarC.hideBadge()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        noticeViewModel.willLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 65
        } else {
            return 50
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            noticeViewModel.loadMoreItems()
        }
    }
    
    //MARK: Notice Cell Delegate
    func didTapBlogImageView(blog: Blog) {
        let showBlogVC = UIStoryboard.viewControllerWith("Blog", identifier: "ShowBlogViewController") as! ShowBlogViewController
        showBlogVC.blog = blog
        self.navigationController?.pushViewController(showBlogVC, animated: true)
    }
    
    func didTapUserImageView(user: User) {
        let showUserVC = UIStoryboard.viewControllerWith("User", identifier: "ShowUserViewController") as! ShowUserViewController
        showUserVC.selectedUser = user
        navigationController?.pushViewController(showUserVC, animated: true)
    }
    
    //MARK: Refresh Control Data
    func pullAndload() {
        self.noticeViewModel.reloadItems { 
            self.refreshControl.endRefreshing()
        }
    }
    

}
