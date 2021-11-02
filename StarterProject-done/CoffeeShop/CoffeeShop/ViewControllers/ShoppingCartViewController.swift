//
//  ShoppingCartViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 25.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let bag = DisposeBag()
class ShoppingCartViewController: BaseViewController {
  
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var totalPriceLabel: UILabel!
  
  var cartItems: [CartItem] = []
    
//  var totalPrice: Float = 0 {
//    didSet {
//      if viewIfLoaded != nil {
//        totalPriceLabel.text = CurrencyFormatter.turkishLirasFormatter.string(from: totalPrice)
//      }
//    }
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTableView()
    configData()
  }
  
  private func configData() {
    
    ShoppingCart.shared.getTotalCost()
        .subscribe(onNext:{
            // [unowned self]
            item in
            self.totalPriceLabel.text = "\(item)"
        })
        .disposed(by: bag)
  }
  
  private func removeCartItem(at row: Int) {
    guard row < cartItems.count else { return }
    
    ShoppingCart.shared.removeCoffee(cartItems[row].coffee)
  }
  
  private func configureTableView() {
  
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    
    tableView.rowHeight = 104
    ShoppingCart.shared.getCartItems().bind(to: tableView.rx.items(cellIdentifier: "cartCoffeeCell", cellType: CartCoffeeCell.self)){row,model,cell in
        cell.configure(with: model)
    }.disposed(by: bag)
    
    tableView.rx.modelDeleted(CartItem.self).map { model in
        ShoppingCart.shared.removeCoffee(model.coffee)
    }.subscribe()
    .disposed(by: bag)
  }
}

//extension ShoppingCartViewController: UITableViewDelegate {
//  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    return 104
//  }
//
//  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    return true
//  }
  
//  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//    return .delete
//  }
//
//  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//    if editingStyle == .delete {
//      removeCartItem(at: indexPath.row)
//      tableView.deleteRows(at: [indexPath], with: .fade)
//    }
//  }
//}

//extension ShoppingCartViewController: UITableViewDataSource {
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return cartItems.count
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    if let cell = tableView.dequeueReusableCell(withIdentifier: "cartCoffeeCell", for: indexPath) as? CartCoffeeCell {
//      cell.configure(with: cartItems[indexPath.row])
//
//      return cell
//    }
//
//    return UITableViewCell()
//  }
//}

