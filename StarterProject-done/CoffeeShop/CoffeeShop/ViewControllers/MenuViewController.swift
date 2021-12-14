//
//  MenuViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 23.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let disposebag = DisposeBag()

class MenuViewController: BaseViewController {
  
  @IBOutlet private weak var tableView: UITableView!
  
  private lazy var shoppingCartButton: BadgeBarButtonItem = {
    let button = BadgeBarButtonItem(image: "cart_menu_icon", badgeText: nil, target: self, action: #selector(shoppingCartButtonPressed))
    
    button!.badgeButton!.tintColor = Colors.brown
    
    return button!
  }()
  
  private lazy var coffees: BehaviorRelay<[Coffee]> = {
    let espresso = Coffee(name: "Espresso", icon: "espresso", price: 4.5)
    let cappuccino = Coffee(name: "Cappuccino", icon: "cappuccino", price: 11)
    let macciato = Coffee(name: "Macciato", icon: "macciato", price: 13)
    let mocha = Coffee(name: "Mocha", icon: "mocha", price: 8.5)
    let latte = Coffee(name: "Latte", icon: "latte", price: 7.5)
    
    return .init(value:[espresso, cappuccino, macciato, mocha, latte])
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = shoppingCartButton
    
    configureTableView()
    
    coffees.asDriver(onErrorJustReturn: []).drive(tableView
                .rx
                .items(cellIdentifier: "coffeeCell", cellType: CoffeeCell.self)){row,element,cell in
            cell.configure(with: element)
        }
        .disposed(by: disposebag)
    
    tableView
        .rx
        .modelSelected(Coffee.self)
        .subscribe(onNext:{
            [unowned self]
            coffee in

            //⚠️：不是 prepareForSegue
            self.performSegue(withIdentifier: "OrderCofeeSegue", sender: coffee)

//            self.prepare(for: UIStoryboardSegue.init(identifier: "OrderCofeeSegue", source: self, destination: OrderCoffeeViewController.init()), sender: coffee)

            if let path = self.tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: path, animated: true)
            }
        })
        
        //单个 subscribe {， 括号内元素类型是 event，后面跟 onError 等其他参数时，方法其实已经变了，此时 subscribe { 里元素类型不是 event，是传递的值
//        .subscribe { item in
//            print(item)
//        }
        .disposed(by: disposebag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let totalOrderCount = ShoppingCart.shared.getTotalCount()
    totalOrderCount.subscribe(onNext:{
         [unowned self]
        item in
        self.shoppingCartButton.badgeText = item > 0 ? "\(item)" : ""
    }).disposed(by: disposebag)
  }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        let espresso = Coffee(name: "Mt-Espresso", icon: "espresso", price: 4.5)
        let cappuccino = Coffee(name: "Mt-Cappuccino", icon: "cappuccino", price: 11)
        
        coffees.accept([espresso, cappuccino])
    }
  
  private func configureTableView() {
    
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    
    tableView.rowHeight = 104
  }
  
  @objc private func shoppingCartButtonPressed() {
    performSegue(withIdentifier: "ShowCartSegue", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let coffee = sender as? Coffee else { return }
    
    if segue.identifier == "OrderCofeeSegue" {
      if let viewController = segue.destination as? OrderCoffeeViewController {
        viewController.coffee = coffee
        viewController.title = coffee.name
      }
    }
  }
}

