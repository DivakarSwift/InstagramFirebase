//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Will Wang on 11/23/18.
//  Copyright © 2018 Will Wang. All rights reserved.
//

import UIKit
import Firebase

struct User {
    let username: String
    let profileImageURL: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageURL = dictionary["profile_image"] as? String ?? ""
    }
}

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var user: User?
    let cellId = "cellId"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView.register(UserPhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        setupLogOutButton()
        
//        fetchPost()
        fetchOrderedPosts()
    }
    
    fileprivate func fetchOrderedPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postsRef = Database.database().reference().child("posts").child(uid)
        
        postsRef.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value else { return }
            let post = Post(dictionary: dictionary as! [String : Any])
            
            self.posts.append(post)
            
            self.collectionView.reloadData()
            
        }) { (error) in
            print("Failed to fetch posts", error)
        }
        
    }
    
    fileprivate func fetchPost() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postsRef = Database.database().reference().child("posts").child(uid)
        
        postsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String : Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String : Any] else { return }
                let post = Post(dictionary: dictionary)
                self.posts.append(post)
            })
            
            self.collectionView?.reloadData()
    
        }) { (error) in
            print("Failed to fetch posts", error)
        }
        
        
    }
    
    fileprivate func setupLogOutButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    
    @objc func handleLogOut() {

        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Log out failed, ", signOutErr)
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
            //triggers didSet in header's user variable
        header.user = self.user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserPhotoCell
        
            //triggers didSet in cell's posts variable
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
    fileprivate func fetchUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot.value ?? "")

            guard let dictionary = snapshot.value as? [String : Any] else { return }
            self.user = User(dictionary: dictionary)
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
        }
        
    }
    
    
}
