//
//  UserViewController.swift
//  GitTest
//
//  Created by admin on 5/7/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit

protocol SetupViewController {
    func setupView();
    func setupViewModel();
}

class UserViewController: UIViewController, SetupViewController {

    @IBOutlet var tableView:UITableView!
    @IBOutlet var activityIndicatior:UIActivityIndicatorView!
    
    var topRefreshControl:UIRefreshControl!
    
    lazy var usersViewModel:UsersViewModel = {
        return UsersViewModel()
    }()
    
    let tableViewCellHeight:CGFloat = 100.0;
    
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
        usersViewModel.updateLoadingClosure = { loading in
            if !loading {
                DispatchQueue.main.async { [weak self] in
                    self?.topRefreshControl.endRefreshing()
                    self?.activityIndicatior.stopAnimating()
                    self?.activityIndicatior.isHidden = true
                    self?.tableView.isHidden = false
                }
            }
        }
        
        usersViewModel.showAlertClosure = {
            DispatchQueue.main.async { [weak self] in
                if let message = self?.usersViewModel.alertMessage {
                    self?.showAlert(message: message)
                }
            }
        }
        
        usersViewModel.updateUsersCountClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        usersViewModel.fetchMoreUsers()
    }
    
    @objc func loadMoreUsers() {
        if usersViewModel.usersCount == 0 {
            usersViewModel.fetchMoreUsers()
        } else {
            topRefreshControl.endRefreshing()
        }
    }

}

extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: String(describing: FollowersViewController.self), sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersViewModel.usersCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellView = Bundle.main.loadNibNamed(String(describing: UserTableViewCell.self), owner: self, options: nil)?.first as? UserTableViewCell else {
            return UITableViewCell()
        }
        let userForRow = self.usersViewModel.getUser(for: indexPath.row)
        cellView.configureCell(user: userForRow)
        
        if indexPath.row > usersViewModel.usersCount - tableView.visibleCells.count + 1 {
            usersViewModel.fetchMoreUsers()
        }
        
        return cellView
    }
}

extension UserViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FollowersViewController, let index = sender as? IndexPath {
            controller.userFollowersLogin = usersViewModel.getUser(for: index.row).login
        }
    }
}

extension UIViewController {
    func showAlert(message: String ) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
