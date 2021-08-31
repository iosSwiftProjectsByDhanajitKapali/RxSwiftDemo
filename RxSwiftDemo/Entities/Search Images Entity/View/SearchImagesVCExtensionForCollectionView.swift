//
//  SearchImagesVCExtensionForCollectionView.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 31/08/21.
//

import UIKit

//MARK: - UICollectionView Delegates
extension SearchImagesVC : UICollectionViewDelegate{
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let height = scrollView.frame.size.height
//            let contentYoffset = scrollView.contentOffset.y
//            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//            if distanceFromBottom < height {
//                print(" you reached end of the table")
//            }
//    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("lol")
        let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < height {
                print(" you reached end of the table")
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == imagesArray.value.count-1 ) {
            print(imagesArray.value.count-1)
            //it's your last cell
            print("last cell")
            //Load more data & reload your collection view
            //searchImagesViewModelInstance.getMoreImages(withName: searchQuery)
        }
    }
    
}
