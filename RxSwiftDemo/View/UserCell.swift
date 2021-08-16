//
//  UserCell.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 16/08/21.
//

import UIKit

class UserCell: UITableViewCell {
    
    static let starTintColor = UIColor(red: 212/255, green: 163/255, blue: 50/255, alpha: 1.0)
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet var userImage: UIImageView!
    
    func configureCell(userDetail: UserDetailModel) {
        userName.text = userDetail.userData.first_name ?? ""
        if let userImageUrl = userDetail.userData.avatar{
            if let url = URL(string: userImageUrl){
                userImage.load(url: url)
                //userImage.frame = CGRect(x: 0, y: 0, width: 150, height: 100)
            }
        }
        if userDetail.isFavorite.value {
            favoriteImage.image = UIImage(systemName: "star.fill")?.withTintColor(UserCell.starTintColor)
        } else {
            favoriteImage.image = UIImage(systemName: "star")?.withTintColor(UserCell.starTintColor)
        }
    }
    
    override func awakeFromNib() {
          super.awakeFromNib()
       }
}
