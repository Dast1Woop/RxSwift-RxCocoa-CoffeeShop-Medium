//
//  ShoppingCart.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 25.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ShoppingCart {
  
  static let shared = ShoppingCart()
  
    var coffeesRelay: BehaviorRelay<[Coffee: Int]> = .init(value: [:])
  
  private init() {}
  
  func addCoffee(_ coffee: Coffee, withCount count: Int) {
    var coffeesDic = coffeesRelay.value
    if let currentCount = coffeesDic[coffee] {
        coffeesDic[coffee] = currentCount + count
    } else {
        coffeesDic[coffee] = count
    }
    
    coffeesRelay.accept(coffeesDic)
  }
  
  func removeCoffee(_ coffee: Coffee) {
    var coffeesDic = coffeesRelay.value
    coffeesDic[coffee] = nil
    coffeesRelay.accept(coffeesDic)
  }
  
  func getTotalCost() -> Observable<Float> {
//    return coffees.reduce(Float(0)) { $0 + ($1.key.price * Float($1.value)) }
    return coffeesRelay.map { dic in
        dic.reduce(0.0) { res, elementDic in
            return res + elementDic.key.price * Float(elementDic.value)
        }
    }

  }
  
  func getTotalCount() -> Observable<Int> {
    return
        
//    reduce 后闭包 参数类型 就是 调用对象信号里的对象类型，此处类型是 字典数组，不是里面的单个元素，因此必须先进行 map，再对 map里对象进行reduce
//        coffeesRelay.reduce(0) {
//        res, dicArr:[Coffee : Int] in
//    }
    
        coffeesRelay.map { dicArr in
            dicArr.reduce(0) { res, dic in
            res + dic.value
        }
    }
  }
  
  func getCartItems() -> Observable<[CartItem]> {
    return coffeesRelay.map { dicArr in
        dicArr.map { dic in
            CartItem.init(coffee: dic.key
                          , count: dic.value)
        }
    }
    
//    return coffees.map { CartItem(coffee: $0.key, count: $0.value) }
  }
}
