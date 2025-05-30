//
//  SubscriptionProduct.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation
import StoreKit

struct SubscriptionProduct {
    static let monthlySubscriptionID = "de.synkmedia.FlowMode.monthly"
    
    let id: String
    let displayName: String
    let description: String
    let price: Decimal
    let priceFormatted: String
    let product: Product?
    
    init(product: Product) {
        self.id = product.id
        self.displayName = product.displayName
        self.description = product.description
        self.price = product.price
        self.priceFormatted = product.displayPrice
        self.product = product
    }
    
    // Mock product for development/testing
    static let mockMonthlySubscription = SubscriptionProduct(
        id: monthlySubscriptionID,
        displayName: "FlowMode Premium",
        description: "Unlock all premium features",
        price: Decimal(2.99),
        priceFormatted: "€2.99",
        product: nil
    )
    
    private init(id: String, displayName: String, description: String, price: Decimal, priceFormatted: String, product: Product?) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.price = price
        self.priceFormatted = priceFormatted
        self.product = product
    }
}

enum SubscriptionError: Error, LocalizedError {
    case productNotFound
    case purchaseFailed
    case restoreFailed
    case verificationFailed
    case userCancelled
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Subscription product not found"
        case .purchaseFailed:
            return "Purchase failed"
        case .restoreFailed:
            return "Failed to restore purchases"
        case .verificationFailed:
            return "Purchase verification failed"
        case .userCancelled:
            return "Purchase was cancelled"
        }
    }
}