//
//  FollowersViewController.swift
//  GitTest
//
//  Created by admin on 5/7/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController, SetupViewController {

    @IBOutlet var tableView:UITableView!
    @IBOutlet var activityIndicatior:UIActivityIndicatorView!
    
    var userFollowersLogin:String?
    
    private var topRefreshControl:UIRefreshControl!
    
    private lazy var followersViewModel:FollowersViewModel = {
        return FollowersViewModel(from:self.userFollowersLogin)
    }()
    
    private let tableViewCellHeight:CGFloat = 100.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }
    
    func setupView() {
        topRefreshControl = UIRefreshControl()
        topRefreshControl.addTarget(self, action: #selector(loadMoreUsers), for: .valueChanged)
        tableView.refreshControl = topRefreshControl
    }
    
    func setupViewModel() {
        
        followersViewModel.updateLoadingClosure = { isLoading in
            if !isLoading {
                DispatchQueue.main.async { [weak self] in
                    self?.topRefreshControl.endRefreshing()
                    self?.activityIndicatior.stopAnimating()
                    self?.activityIndicatior.isHidden = true
                }
            }
        }
        
        followersViewModel.showAlertClosure = {
            DispatchQueue.main.async { [weak self] in
                if let message = self?.followersViewModel.alertMessage {
                    self?.showAlert(message: message)
                }
            }
        }
        
        followersViewModel.updateFollowersCountClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        followersViewModel.fetchFollowers()
    }
    
    @objc func loadMoreUsers() {
        if followersViewModel.followersCount == 0 {
            followersViewModel.fetchFollowers()
        } else {
            topRefreshControl.endRefreshing()
        }
    }

    
}

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followersViewModel.followersCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellView = Bundle.main.loadNibNamed(String(describing: UserTableViewCell.self), owner: self, options: nil)?.first as? UserTableViewCell else {
            return UITableViewCell()
        }
        let userForRow = self.followersViewModel.getFollower(for: indexPath.row)
        cellView.configureCell(user: userForRow)
        
        return cellView
    }
    
}
