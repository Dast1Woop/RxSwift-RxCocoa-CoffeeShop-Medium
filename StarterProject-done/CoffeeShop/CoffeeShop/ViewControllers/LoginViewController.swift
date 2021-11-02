//
//  LoginViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 23.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
  @IBOutlet private weak var emailTextfield: UITextField!
  @IBOutlet private weak var passwordTextfield: UITextField!
  @IBOutlet private weak var logInButton: UIButton!
    
    private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let obsEmail = emailTextfield
        .rx
        .text
        //Transforms control property of type String? into control property of type String.
        .orEmpty
        //Returns an Observable that emits the first and the latest item emitted by the source Observable during sequential time windows of a specified duration.
        .throttle(0.5, scheduler: MainScheduler.instance)
        .map { str in
            self.validateEmail(with: str)
        }
        .debug("email valid", trimOutput: true)
        .share()
    
    obsEmail.subscribe { event in
        print(event)
    }.disposed(by: disposeBag)
    
    let obsPassword = passwordTextfield
        .rx
        .text
        .orEmpty
        .throttle(0.5, scheduler: MainScheduler.instance)
        .map{
            $0.count > 6
        }
        .share()
        .debug("obsPassword valid", trimOutput: true)


    let obsLoginValid = Observable.combineLatest(obsEmail, obsPassword).map { $0 && $1
    }
    .debug("login valid", trimOutput: true)
    
    _ = obsLoginValid.bind(to: logInButton.rx.isEnabled).disposed(by: disposeBag)
  }
    
    private func validateEmail(with email: String) -> Bool {
      let emailPattern = "[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]{2,64})+\\.[A-Za-z]{2,64}"
      let predicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)

      return predicate.evaluate(with: email)
    }
  
  @IBAction private func logInButtonPressed() {
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let initialViewController = mainStoryboard.instantiateInitialViewController()!
    
    UIApplication.changeRoot(with: initialViewController)
  }
}
