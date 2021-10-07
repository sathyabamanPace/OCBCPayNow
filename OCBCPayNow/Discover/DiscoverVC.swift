//
//  DiscoverVC.swift
//  OCBCPayNow
//
//  Created by admin on 7/10/21.
//

import UIKit
import PaceNowBank
import Cloudinary

class DiscoverVC: UIViewController {
    let apiManager: PaceAPIManager!
    var categories = [List]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    let headerId = "headerId"
    let arrImages = ["image1", "image2", "image3", "image4", "image5", "image6"]
    let categoryHeaderId = "categoryHeaderId"
    var cloudinary :CLDCloudinary! = nil
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(StoreCell.self, forCellWithReuseIdentifier: StoreCell.reuseIdentifer)
        cv.register(CategoryHeaderView.self, forSupplementaryViewOfKind: categoryHeaderId, withReuseIdentifier: headerId)
        return cv
    }()
    
    init(apiManager: PaceAPIManager){
        self.apiManager = apiManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCloudinary()
        view.backgroundColor = .white
        title = "Discover"
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        getcategoryList()
    }
    
    func configureCloudinary(){
        let config = CLDConfiguration(cloudName: "dbmodrpfx", apiKey: "532266695622617")
        cloudinary = CLDCloudinary(configuration: config)
    }
    
    private func getcategoryList(){
        apiManager.store_getStoreCategoryList(completion: {
            result, error in
            if let error = error {
                print("DEBUG: failed to get category list: \(error)")
                return
            }

            guard let categoryList: [List] = result?.list else { return }
            self.categories = categoryList
            
        })
    }
    
    //MARK: - Helper Method
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            switch sectionNumber {
                case 0: return self.firstLayoutSection()
                case 1: return self.secondLayoutSection()
                default: return self.thirdLayoutSection()
            }
        }
    }
    
    private func firstLayoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 15
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalWidth(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 2)
       
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    private func secondLayoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(200))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 15, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(500))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
       
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.leading = 15

        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment: .top)
        ]
        
        return section
    }
    
    private func thirdLayoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 15
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalWidth(1))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 2)
       
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .continuous
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment: .top)
        ]
        section.contentInsets.leading = 15
        return section
    }
    
}

extension DiscoverVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0: return categories.count
            case 1: return categories.count
            default: return categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCell.reuseIdentifer, for: indexPath) as! StoreCell
        
        switch indexPath.section {
            case 0:
            cell.configure(withImageName: "pace", title: "")
            case 1:
            cell.configure(withImage: UIImage(named: "pace")!, title: "")
                cloudinary.createDownloader().fetchImage(categories[indexPath.row].previewImageURL , completionHandler:  { responseImage, error in
                    if let error = error {
                        print("error downloading: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            cell.configure(withImage: responseImage!, title: self.categories[indexPath.row].title)
                        }
                    }
                })
            default:
                cloudinary.createDownloader().fetchImage(categories[indexPath.row].previewImageURL , completionHandler:  { responseImage, error in
                    if let error = error {
                        print("error downloading: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            cell.configure(withImage: responseImage!)
                        }
                    }
                })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CategoryHeaderView
        
        switch indexPath.section {
            case 1: header.label.text = "Categories"
            case 2: header.label.text = "Feature Stores"
            default: break
        }
        return header
    }

}

extension DiscoverVC: UICollectionViewDelegate {
    
}
