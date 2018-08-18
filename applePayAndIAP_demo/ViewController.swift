//
//  ViewController.swift
//  applePayAndIAP_demo
//
//  Created by Edwin on 2018/8/18.
//  Copyright © 2018 Edwin. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController,PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    

    var purchaseRequest:PKPaymentRequest!
    
    var SupportedCard:[PKPaymentNetwork]?
    
    var PaymentButton:UIButton = {
        let a = UIButton()
        a.setTitle("Pay the order", for: UIControlState.normal)
        a.setTitleColor(UIColor.black, for: UIControlState.normal)
        return a
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupPaymentButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupPaymentButton(){
        PaymentButton.frame = CGRect(origin: view.center, size: CGSize(width: 200, height: 100))
        PaymentButton.addTarget(self, action: #selector(hanldePayment), for: UIControlEvents.touchUpInside)
    }
    
    @objc func hanldePayment(){
        //check for os system for payment
        if !PKPaymentAuthorizationViewController.canMakePayments(){
            print("error,don't support apple pay!")
            return
        }
        //check for card support
        if #available(iOS 9.2, *){
            SupportedCard?.append(PKPaymentNetwork.chinaUnionPay)
            
        }
        SupportedCard?.append(PKPaymentNetwork.amex)
        
        SupportedCard?.append(PKPaymentNetwork.visa)
        SupportedCard?.append(PKPaymentNetwork.masterCard)
        
        //check for device
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedCard!){
            print("error,device don't support cards like visa mastercard and amex")
            return
        }
        
        purchaseRequest = PKPaymentRequest()
        purchaseRequest.countryCode = "CA"
        purchaseRequest.currencyCode = "CAD"
        purchaseRequest.merchantCapabilities = .capability3DS
        purchaseRequest.merchantIdentifier = "merchant.com.Edwin.merchantDemo"
        purchaseRequest.supportedNetworks = SupportedCard!
        
        let item1 = PKPaymentSummaryItem(label: "麻婆豆腐", amount: 7.99)
        let item2 = PKPaymentSummaryItem(label: "上海汤汁小笼包", amount: 10.99)
        let item3 = PKPaymentSummaryItem(label: "宫保鸡丁", amount: 8.99)
        
        purchaseRequest.paymentSummaryItems = [item1,item2,item3]
        
        let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: purchaseRequest)
        paymentVC?.delegate = self
        present(paymentVC!, animated: true, completion: nil)
    }

}

