//
//  SubscriptionService.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var subscriptionStatus: SubscriptionStatus = SubscriptionStatus()
    @Published var availableProducts: [SubscriptionProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSubscriptionStatus()
        startTransactionListener()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        guard availableProducts.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let products = try await Product.products(for: [SubscriptionProduct.monthlySubscriptionID])
            
            let subscriptionProducts = products.map { SubscriptionProduct(product: $0) }
            
            await MainActor.run {
                self.availableProducts = subscriptionProducts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                self.isLoading = false
                // Use mock product for development
                self.availableProducts = [SubscriptionProduct.mockMonthlySubscription]
            }
        }
    }
    
    // MARK: - Trial Management
    
    func startTrial() {
        let newStatus = SubscriptionStatus(
            state: .trial,
            trialStartDate: Date(),
            subscriptionStartDate: nil,
            expirationDate: nil
        )
        
        subscriptionStatus = newStatus
        saveSubscriptionStatus()
    }
    
    var canStartTrial: Bool {
        return subscriptionStatus.state == .notStarted
    }
    
    // MARK: - Purchase Management
    
    func purchase(product: SubscriptionProduct) async throws {
        guard let storeKitProduct = product.product else {
            throw SubscriptionError.productNotFound
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await storeKitProduct.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateSubscriptionStatus()
                await transaction.finish()
                
            case .userCancelled:
                throw SubscriptionError.userCancelled
                
            case .pending:
                // Handle pending transactions (parental controls, etc.)
                break
                
            @unknown default:
                throw SubscriptionError.purchaseFailed
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    // MARK: - Transaction Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Subscription Status Management
    
    private func updateSubscriptionStatus() async {
        var hasActiveSubscription = false
        var latestExpirationDate: Date?
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productID == SubscriptionProduct.monthlySubscriptionID {
                    hasActiveSubscription = true
                    latestExpirationDate = transaction.expirationDate
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        await MainActor.run {
            if hasActiveSubscription {
                self.subscriptionStatus = SubscriptionStatus(
                    state: .active,
                    trialStartDate: self.subscriptionStatus.trialStartDate,
                    subscriptionStartDate: Date(),
                    expirationDate: latestExpirationDate
                )
            } else {
                // No active subscription, check trial status
                self.updateTrialStatus()
            }
            
            self.saveSubscriptionStatus()
        }
    }
    
    private func updateTrialStatus() {
        if subscriptionStatus.state == .trial && !subscriptionStatus.isTrialActive {
            subscriptionStatus = SubscriptionStatus(
                state: .expired,
                trialStartDate: subscriptionStatus.trialStartDate,
                subscriptionStartDate: nil,
                expirationDate: nil
            )
        }
    }
    
    // MARK: - Transaction Listener
    
    private func startTransactionListener() {
        updateListenerTask = Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    private func loadSubscriptionStatus() {
        if let data = UserDefaults.standard.data(forKey: "SubscriptionStatus"),
           let status = try? JSONDecoder().decode(SubscriptionStatus.self, from: data) {
            subscriptionStatus = status
        }
    }
    
    private func saveSubscriptionStatus() {
        if let data = try? JSONEncoder().encode(subscriptionStatus) {
            UserDefaults.standard.set(data, forKey: "SubscriptionStatus")
        }
    }
}