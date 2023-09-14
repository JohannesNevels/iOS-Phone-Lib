//
//  LogViewController.swift
//  Phone Lib Example
//
//  Created by Johannes Nevels on 14/09/2023.
//

import UIKit

/* Using auto snapping of constraints due to habit / time restrictions, it's a wrapper to snap constraints so you have to write less code */
import SnapKit

class LogViewController: UIViewController {
    private let logTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LogTableViewCell.self, forCellReuseIdentifier: "LogTableViewCellIdentifier")
        return tableView
    }()
    
    private let logSearchController = UISearchController(searchResultsController: nil)
    private let defaults = UserDefaults.standard
    private var logsList = [String]() {
        didSet {
            logTableView.reloadData()
        }
    }
    private var filteredLogsList = [String]() {
        didSet {
            logTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addLogTableView()
        addLogSearchBar()
        
        // Prevent tableview going through tabbar
        edgesForExtendedLayout = [.top, .left, .right]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    // MARK: Actions
    func fetchData() {
        if let existingLogsList = defaults.array(forKey: "logs") as? [String] {
            logsList = existingLogsList
        }
    }
    
    // MARK: Subviews
    private func addLogTableView() {
        logTableView.delegate = self
        logTableView.dataSource = self
        view.addSubview(logTableView)
        logTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addLogSearchBar() {
        logSearchController.searchResultsUpdater = self
        logSearchController.obscuresBackgroundDuringPresentation = false
        logSearchController.searchBar.placeholder = "Search through logs"
        definesPresentationContext = true
        logTableView.tableHeaderView = logSearchController.searchBar
    }
}

// MARK: UITableViewDataSource & UITableViewDataSource
extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logSearchController.isActive ? filteredLogsList.count : logsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let logTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogTableViewCellIdentifier", for: indexPath) as! LogTableViewCell
        let text = logSearchController.isActive ? filteredLogsList[indexPath.row] : logsList[indexPath.row]
        logTableViewCell.textLabel?.text = text
        logTableViewCell.textLabel?.numberOfLines = 0;
        logTableViewCell.textLabel?.lineBreakMode = .byWordWrapping;
        return logTableViewCell
    }
}

extension LogViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
      guard let searchText = searchController.searchBar.text else {
          searchController.searchBar.resignFirstResponder()
          return
      }
      
      filteredLogsList = logsList.filter({ $0.lowercased().contains(searchText.lowercased())})
  }
}
