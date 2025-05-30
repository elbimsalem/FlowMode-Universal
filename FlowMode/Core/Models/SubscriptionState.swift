//
//  SubscriptionState.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation

enum SubscriptionState: String, CaseIterable, Codable {
    case trial = "trial"
    case active = "active" 
    case expired = "expired"
    case notStarted = "not_started"
    
    var displayName: String {
        switch self {
        case .trial:
            return "Free Trial"
        case .active:
            return "Premium"
        case .expired:
            return "Expired"
        case .notStarted:
            return "Free"
        }
    }
    
    var isActive: Bool {
        return self == .trial || self == .active
    }
}

struct SubscriptionStatus: Codable {
    let state: SubscriptionState
    let trialStartDate: Date?
    let subscriptionStartDate: Date?
    let expirationDate: Date?
    
    init(state: SubscriptionState = .notStarted, 
         trialStartDate: Date? = nil,
         subscriptionStartDate: Date? = nil,
         expirationDate: Date? = nil) {
        self.state = state
        self.trialStartDate = trialStartDate
        self.subscriptionStartDate = subscriptionStartDate
        self.expirationDate = expirationDate
    }
    
    var isTrialActive: Bool {
        guard state == .trial,
              let startDate = trialStartDate else { return false }
        
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        return Date() < trialEndDate
    }
    
    var trialDaysRemaining: Int {
        guard let startDate = trialStartDate else { return 0 }
        
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: trialEndDate).day ?? 0
        return max(0, daysRemaining)
    }
    
    var isSubscriptionActive: Bool {
        guard state == .active,
              let expirationDate = expirationDate else { return false }
        
        return Date() < expirationDate
    }
    
    var hasActiveAccess: Bool {
        return isTrialActive || isSubscriptionActive
    }
}

