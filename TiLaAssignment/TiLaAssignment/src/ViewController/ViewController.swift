//
//  ViewController.swift
//  TiLaAssignment
//
//  Created by Gudisi, Sreekanth on 15/12/19.
//  Copyright © 2019 Gudisi, Sreekanth. All rights reserved.
//

import UIKit
import SwiftGoogleTranslate

class ViewController: UIViewController {
    
    // Class Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var frenchButton: UIButton!
    
    // Class Varibles
    var viewModel = ViewModel()

    var deafultImage = UIImage(named: "Empty-Image")
    var tableviewCellCount = 0
    var isFrenchSelected = false
    var fetchingMore = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call Initial Method
        initialMethod()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func frenchButtonTapped(_ sender: Any) {
        
        showActivityIndicator()
        print("Tapped frenchButton")
        isFrenchSelected = !isFrenchSelected
        if !isFrenchSelected  {
            frenchButton.setTitle("English", for: .normal)
            tableView.reloadData()
            print("isFrenchSelected true")
        } else {
            frenchButton.setTitle("French", for: .normal)
            tableView.reloadData()
            print("isFrenchSelected false")
        }
        hideActivityIndicator()
    }
}

// TableView
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }

    private func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {

            return viewModel.articlesArray.count
        } else if section == 1 && fetchingMore {

            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //pagination: load news items when it requires
        checkForLastCell(with: indexPath)
        //setup
        if isFrenchSelected == false {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
            let data = viewModel.articlesArray[indexPath.row]
            cell.urlToImage.image = deafultImage
            SwiftGoogleTranslate.shared.translate(data.title!, "fr", "en") { (text, error) in
                if let title = text {
                    DispatchQueue.main.async {
                        cell.titleLabel.text = title
                    }
                }
            }
            if data.author?.count == nil {
                cell.authorLabel.text = "Author name isn't avaiable"
            }else {
                cell.authorLabel.text = data.author
            }
            if data.descriptionString?.count == nil {
                cell.descriptionLabel.text = "Description isn't avaiable"
            } else {
                cell.descriptionLabel.text = data.descriptionString
            }
            print(data.title as Any)
            print(data.urlToImage as Any)
            return cell
        } else {

            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
            let data = viewModel.articlesArray[indexPath.row]
            cell.urlToImage.image = deafultImage
            cell.titleLabel.text = data.title
            if data.author?.count == nil {
                cell.authorLabel.text = "Author name isn't avaiable"
            }else {
                cell.authorLabel.text = data.author
            }
            if data.descriptionString?.count == nil {
                cell.descriptionLabel.text = "Description isn't avaiable"
            } else {
                cell.descriptionLabel.text = data.descriptionString
            }
            print(data.title as Any)
            print(data.urlToImage as Any)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        
        let tableViewData = viewModel.articlesArray[indexPath.row]
        if tableViewData.urlToImage?.count == nil {
            (cell as? TableViewCell)?.urlToImage.image = deafultImage
            print(indexPath.row)
            return
        } else {
            let encodedUrl = tableViewData.urlToImage!.encodedUrl()
            print(encodedUrl as Any)
            // Checking Cache
            if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]{
                if let path = dict[(encodedUrl!.absoluteString as NSString) as String] {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                        let img = UIImage(data: data)
                        // If cache is there, Loading into cell from Cache
                        (cell as? TableViewCell)?.urlToImage.image = img
                        return
                    }
                }
            }
            //lazy loading
            let session = URLSession.shared
            let imageURL = URL(string: tableViewData.urlToImage!)
            let task = session.dataTask(with: imageURL!) { (data, response, error) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    NSLog("cell number \(indexPath.row)")
                    if let image = UIImage(data: data!) {
                        // calling from API
                        (cell as? TableViewCell)?.urlToImage.image = image
                        // StoringImages into Cache
                        StorageImageViewController.storeImage(urlstring: (encodedUrl!.absoluteString as NSString) as String, img: image)
                    }
                }
            }
            task.resume()
        }
    }
}

//MARK:- Functions
extension ViewController {
    
    func initialMethod() {
        
        // isFrenchSelected
        isFrenchSelected = true
        
        // Navigation Title
        navigationItem.title = "Todays News"
        
        // Tableview Set Delegate And DataSource
        tableView.delegate = self
        tableView.dataSource = self

        // Call pageSetup
        pageSetup()
    }
    
    // Show Activity Indicator
    func showActivityIndicator() {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    // Hide Activity Indicator
    func hideActivityIndicator() {

        DispatchQueue.main.async {
            
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    // TableViewSetUp
    func tableViewSetup()  {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Checking Cell
    private func checkForLastCell(with indexPath:IndexPath) {
        if indexPath.row == (viewModel.articlesArray.count - 1) {
            if GlobalVariableInformation.instance().totalItems > viewModel.articlesArray.count {
                GlobalVariableInformation.instance().page += 1
                pageSetup()
            }
        }
    }
    
    // Initial page settings
    func pageSetup()  {
        
        showActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            self.tableViewSetup()
            // API calling from viewmodel class
            self.viewModel.getServicecall()
            self.closureSetUp()
            self.hideActivityIndicator()
        }
    }
    
    // Closure initialize
    func closureSetUp()  {
        viewModel.reloadList = { [weak self] ()  in
            ///UI chnages in main tread
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            }
        }
        viewModel.errorMessage = { [weak self] (message)  in
            DispatchQueue.main.async {
                print(message)
                self?.hideActivityIndicator()
            }
        }
    }
}
