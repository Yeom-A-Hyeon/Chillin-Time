//
//  ViewController.swift
//  ChillinTime_Kiosk
//
//  Created by 배지해 on 4/3/24.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var bestBtn: UIButton!
    @IBOutlet weak var coffeeBtn: UIButton!
    @IBOutlet weak var smoothieBtn: UIButton!
    @IBOutlet weak var adeBtn: UIButton!
    @IBOutlet weak var teaBtn: UIButton!
    @IBOutlet weak var dessertBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cartNumLabel: UILabel!
    @IBOutlet weak var totalNumLabel: UILabel!
    
    
    // 카테고리 버튼
    lazy var categories = [bestBtn, coffeeBtn, smoothieBtn, adeBtn, teaBtn, dessertBtn]
    
    
    // 메뉴 데이터 ( 베스트 메뉴판으로 초기화 )
    var menuData: [MenuData] = MenuData.bestMenu
    var cartDataManager = CartDataManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 카테고리 배경색 설정
        setBackColor()
        
        // 컬렉션 뷰 설정
        setCollectionView()
        
        // 테이블 뷰 설정
        setTableView()
        
        // cart 라벨 하이라이트 설정
        setCartLabelHighlight()
        
        // cart label 설정
        setCartLabel()
        
    }

    
    // 버튼 선택 시 category 변경 ( 카테고리 버튼 연결 )
    @IBAction func reloadBeverages(_ sender: UIButton) {
        
        changeBackColor(button: sender)
        
        if let buttonName = sender.titleLabel?.text {
            
            // 메뉴 데이터 변경
            changeMenuData(buttonName)
        }
        
        // 데이터 수정할 때마다 cell reload
        menuCollectionView.reloadData()
    }

    
    // 처음 화면 로드 시 버튼 컬러 변경
    func setBackColor() {
        changeBackColor(button: bestBtn)
    }
    
    
    // cart에 담긴 총 합과 cart에 담긴 총 개수 글자 하이라이트 세팅
    func setCartLabelHighlight() {
        highlightNumbers(inLabel: cartNumLabel)
        highlightNumbers(inLabel: totalNumLabel)
    }
    
    
    // cart label 설정
    func setCartLabel() {
        
        let cartNum: Int = cartDataManager.countCartData()
        let totalPrice: Int = cartDataManager.countTotal()
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let totalPriceResult = numberFormatter.string(from: NSNumber(value:totalPrice))!
    
        cartNumLabel.text = "\(cartNum)개"
        totalNumLabel.text = "\(totalPriceResult)원"
    }
    
    
    // cart에 담긴 총 합과 cart에 담긴 총 개수 글자 하이라이트 구현
    func highlightNumbers(inLabel label: UILabel) {
        
        guard let text = label.text else { return }
        let attributedText = NSMutableAttributedString(string: text)
        
        // 문자열 내 숫자부분 색상 및 볼드처리
        for (index, character) in text.enumerated() {
            
            if character.isNumber || character == ","  {
                
                let range = NSRange(location: index,
                                    length: 1)
                
                attributedText.addAttribute(.foregroundColor,
                                            value: UIColor.red,
                                            range: range)
                
                attributedText.addAttribute(.font,
                                            value: UIFont.systemFont(ofSize: 16, weight: .bold),
                                            range: range)
            }
        }
        
        label.attributedText = attributedText
    }
    
    
    // 배경 컬러 변경 구현
    private func changeBackColor(button: UIButton) {
        let maskPath = UIBezierPath(roundedRect: button.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 10, height: 10))
        
        
        // 메뉴 탭 바 버튼 둥글게
        let maskLayer = CAShapeLayer()
        maskLayer.frame = button.bounds
        maskLayer.path = maskPath.cgPath
        button.layer.mask = maskLayer
        
        
        // 버튼의 배경 색상과 컬러 변경
        categories.forEach {
            $0?.backgroundColor = UIColor(red: 128/255, green: 202/255, blue: 255/255, alpha: 1)
            $0?.tintColor = .white
            
        }
        
        
        // 버튼의 배경 색상과 컬러 설정
        button.backgroundColor = .white
        button.tintColor = UIColor(red: 43/255, green: 167/255, blue: 255/255, alpha: 1)
        
    }
    
    
    // 버튼 이름에 따른 cartData값 변경 함수
    func changeMenuData(_ buttonName: String) {
        
        switch buttonName {
        case "베스트" :
            menuData = MenuData.bestMenu
        case "커피" :
            menuData = MenuData.coffeeMenu
        case "스무디" :
            menuData = MenuData.smoothieMenu
        case "에이드" :
            menuData = MenuData.adeMenu
        case "차" :
            menuData = MenuData.teaMenu
        case "디저트" :
            menuData = MenuData.dessertMenu
        default:
            menuData = MenuData.bestMenu
        }
        
        
        
        
    }
    
    
    
    
}



extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    // collectionView setting
    func setCollectionView() {
        menuCollectionView.dataSource = self
        menuCollectionView.delegate = self
    }
    
    
    // collectionView cell 개수
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return menuData.count
    }
    
    
    // collectionView와 cell 연결 / menuData 전달
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as? MenuListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setConfigue(menuData[indexPath.row])
        
        return cell
    }

    
    // collectionView 선택시 cart에 추가
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        cartDataManager.addCartData(name: menuData[indexPath.row].name, price: menuData[indexPath.row].price)
        
        cartTableView.reloadData()
        
        setCartLabel()
    }
    
    
    // collectionView의 view 사이즈 설정
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 170, height: 170)
    }
    
    
    // collectionView의 행 간격 설정
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 17
    }
    
    
    
}



extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    // tableView setting
    func setTableView() {
        
        cartTableView.dataSource = self
        cartTableView.delegate = self
    }
    
    
    // tableview Cell 수
    func tableView(_ tableView: UITableView, 
                   numberOfRowsInSection section: Int) -> Int {
        
        return cartDataManager.getCartData().count
    }
    
    
    // tableview와 cell 연결
    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as? CartListTableViewCell else {
            return UITableViewCell()
        }
        
        
        let cartData = cartDataManager.getCartData()
        
        
        // data 삭제 수행
        cell.deleteButtonAction = {
            
            self.cartDataManager.deleteCartData(indexPath)
            self.cartTableView.reloadData()
            self.setCartLabel()
        }
        
        
        // data 업데이트 수행
        cell.updateCartNumAction = {
            
            self.cartDataManager.updateCartNum(indexPath, cell.orderAmount)
            self.cartTableView.reloadData()
            self.setCartLabel()
        }
        
        
        // cell에 데이터 표시
        if !cartData.isEmpty {
            cell.selectedLabel.text = cartData[indexPath.row].cartName
            cell.countLabel.text = String(cartData[indexPath.row].cartNum)
        }
        
        
        return cell
    }
}
