//
//  ViewController.swift
//  NiceSpot
//
//  Created by Ludovic HENRY on 02/07/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("HELLO")
        SubscriptionManager.deleteSubscriptionsUD()
        let subscriptions = [Spot.Category.river, Spot.Category.beach]

        SubscriptionManager.subscribe(subscriptions: subscriptions) { result in
            switch result {
            case .success:
                print("Subscriptions saved")

                let resultSubsciptions = SubscriptionManager.getSubscriptionsUD()

                switch resultSubsciptions {
                case.failure(let error):
                    print(error.localizedDescription)
                case.success(let subscriptions):
                    for subscription in subscriptions {
                        print(subscription)
                    }

                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }

    }

}
