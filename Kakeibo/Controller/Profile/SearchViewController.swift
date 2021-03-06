//
//  CollectionViewController.swift
//  shareKakeibo
//
//  Created by nishimaru on 2021/10/26.
//  Copyright © 2021 nishimaru. All rights reserved.
//
import UIKit
import SDWebImage

protocol CollectionDeligate {
    func SendArray(selectedUserImageArray:[String],userIDArray: [String],userNameArray: [String])
}

class SearchViewController: UIViewController {
    
    
    var collectionDeligate:CollectionDeligate?
    
    @IBOutlet weak var decideButton: UIButton!
    @IBOutlet weak var searchUserTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var loadDBModel = LoadDBModel()
    var selectedUserImageArray = [String]() //profile画像のURLが入る
    var userIDArray = [String]()
    var userNameArray = [String]()
    //    var imageArray = ["person","person.fill","pencil","trash","person"]
    var userSearchSets = [UserSearchSets]()
    
    let nothingLabel = UILabel()
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decideButton.layer.cornerRadius = 5
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.layer.masksToBounds = false
        tableView.isScrollEnabled = false
        tableView.layer.shadowOffset = CGSize(width: 0, height: 1)
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowRadius = 1
        tableView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        loadDBModel.loadOKDelegate = self
        
        searchUserTextField.delegate = self
        
        view.addSubview(nothingLabel)
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        nothingLabel.text = "検索結果がありません"
        nothingLabel.textAlignment = .center
        nothingLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        nothingLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 50).isActive = true
        nothingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nothingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nothingLabel.isHidden = true
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    @IBAction func decideButton(_ sender: Any) {
        collectionDeligate?.SendArray(selectedUserImageArray: selectedUserImageArray, userIDArray: userIDArray, userNameArray: userNameArray)
        print(selectedUserImageArray)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchUserButton(_ sender: Any) {
        if searchUserTextField.text == ""{
            nothingLabel.isHidden = false
            return
        }
        activityIndicatorView.startAnimating()
        nothingLabel.isHidden = true
        loadDBModel.loadUserSearch(email: searchUserTextField.text!, activityIndicatorView: activityIndicatorView)
        searchUserTextField.text = ""
    }
    
    
}
// MARK: - CollectionView
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userIDArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.profileImage!.sd_setImage(with: URL(string: selectedUserImageArray[indexPath.row]), completed: nil)
        cell.deleteButton!.addTarget(self, action: #selector(tapDeleteButton(_:)), for: .touchUpInside)
        cell.userNameLabel.text = userNameArray[indexPath.row]
        print("daigoitemAt")
        print(cell.deleteButton.tag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @objc func tapDeleteButton(_ sender:UIButton){
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        print(indexPath?.row)
        selectedUserImageArray.remove(at: indexPath!.row)
        userIDArray.remove(at: indexPath!.row)
        userNameArray.remove(at: indexPath!.row)
        collectionView.deleteItems(at: [IndexPath(item: indexPath!.row, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    
}

// MARK: - TableView
extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSearchSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let profileImage = cell.contentView.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        profileImage.sd_setImage(with: URL(string: userSearchSets[indexPath.row].profileImage), completed: nil)
        profileImage.layer.cornerRadius = 30
        userNameLabel.text = userSearchSets[indexPath.row].userName
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        nothingLabel.isHidden = true
        selectedUserImageArray.append(userSearchSets[indexPath.row].profileImage)
        userIDArray.append(userSearchSets[indexPath.row].userID)
        userNameArray.append(userSearchSets[indexPath.row].userName)
        userSearchSets.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if userSearchSets.count == 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.tableView.alpha = 0
            }, completion:  { _ in
                self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                
            }, completion:  { _ in
                self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
            })
        }
        
        
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    
}

// MARK: - LoadOKDelegate
extension SearchViewController: LoadOKDelegate{
    
    func loadUserSearch_OK() {
        var loadUserSearchSets = loadDBModel.userSearchSets
        for userID in userIDArray{
            loadUserSearchSets.removeAll(where: {$0.userID == userID})
        }
        userSearchSets = loadUserSearchSets
        
        if userSearchSets.count == 0{
            nothingLabel.isHidden = false
            
            self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
            tableView.reloadData()
            activityIndicatorView.stopAnimating()
        }else{
            nothingLabel.isHidden = true
            UIView.animate(withDuration: 0.1, animations: {
                self.tableView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.tableView.alpha = 1
            }, completion:  { _ in
                //            self.tableView.isHidden = false
                self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
                self.tableView.reloadData()
                self.activityIndicatorView.stopAnimating()
            })
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension SearchViewController:UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(searchUserTextField.text)
        print(textField.text)
        print(string)
        print(textField.text! + string)
        print("")
        if string == "" && textField.text != ""{
            if textField.text?.count == 1{
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.tableView.alpha = 0
                }, completion:  { _ in
                    self.userSearchSets = []
                    self.nothingLabel.isHidden = false
                    self.tableView.reloadData()
                    self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
                })
                
            }else{
                var removeText = textField.text
                removeText?.removeLast()
                print(removeText)
                loadDBModel.loadUserSearch(email: removeText!, activityIndicatorView: activityIndicatorView)
            }
        }else if string != "" && textField.text != ""{
            loadDBModel.loadUserSearch(email: textField.text! + string, activityIndicatorView: activityIndicatorView)
        }else if string != "" && textField.text == ""{
            loadDBModel.loadUserSearch(email: string, activityIndicatorView: activityIndicatorView)
        }else if string == "" && textField.text == ""{
            
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.tableView.alpha = 0
            }, completion:  { _ in
                self.userSearchSets = []
                self.nothingLabel.isHidden = false
                self.tableView.reloadData()
                self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
            })
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

