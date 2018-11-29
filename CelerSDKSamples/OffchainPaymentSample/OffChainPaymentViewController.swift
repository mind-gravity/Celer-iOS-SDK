//
//  OffChainPaymentViewController.swift
//  Celer Network
//
//  Created by Jinyao Li on 11/29/18.
//  Copyright (c) 2018, Celer Network. All rights reserved.
//

import UIKit

final class OffChainPaymentViewController: UIViewController {

  // MARK: - Constants
  
  // MARK: - Variables
  
  private let clientSideDepositAmount = "5"
  private let serverSideDepositAmount = "15"

  // MARK: - View Components
  
  
  private let textView = UITextView()
  
  private lazy var createWalletButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("STEP 1: CREATE WALLET", for: .normal)
    button.addTarget(self, action: #selector(createNewWallet), for: .touchUpInside)
    return button
  }()
  
  private lazy var fuelWalletButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("STEP 2: GET TOKEN FROM FAUCET", for: .normal)
    button.addTarget(self, action: #selector(fuelWallet), for: .touchUpInside)
    return button
  }()
  
  private lazy var createCelerClientButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("STEP 3: CREATE CELER CLIENT", for: .normal)
    button.addTarget(self, action: #selector(createCelerClient), for: .touchUpInside)
    return button
  }()
  
  private lazy var joinCelerButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("STEP 4: JOIN CELER", for: .normal)
    button.addTarget(self, action: #selector(joinCeler), for: .touchUpInside)
    return button
  }()
  
  private lazy var checkBalanceButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("STEP 5: Check Balance", for: .normal)
    button.addTarget(self, action: #selector(checkBalance), for: .touchUpInside)
    return button
  }()
  
  private lazy var sendPaymentButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("STEP 6: Send Payment", for: .normal)
    button.addTarget(self, action: #selector(sendPayment), for: .touchUpInside)
    return button
  }()

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    [textView, createWalletButton, fuelWalletButton, createCelerClientButton, joinCelerButton, checkBalanceButton, sendPaymentButton].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    sendPaymentButton.isHidden = true
    
    createWalletButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
    fuelWalletButton.topAnchor.constraint(equalTo: createWalletButton.bottomAnchor, constant: 20).isActive = true
    createCelerClientButton.topAnchor.constraint(equalTo: fuelWalletButton.bottomAnchor, constant: 20).isActive = true
    joinCelerButton.topAnchor.constraint(equalTo: createCelerClientButton.bottomAnchor, constant: 20).isActive = true
    checkBalanceButton.topAnchor.constraint(equalTo: joinCelerButton.bottomAnchor, constant: 20).isActive = true
    textView.topAnchor.constraint(equalTo: checkBalanceButton.bottomAnchor, constant: 20).isActive = true
    textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    textView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    sendPaymentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
  }

  // MARK: - View Lifecycle

  // MARK: - View Value Assignments
  
  // MARK: - Layout

  // MARK: - UI Interaction
  
  private func showLog(log: String) {
    DispatchQueue.main.async {
      self.textView.text.append(contentsOf: "\(log)\n")
      let bottom = NSMakeRange(self.textView.text.count - 1, 1)
      self.textView.scrollRangeToVisible(bottom)
    }
  }

  // MARK: - User Interaction
  
  @objc private func createNewWallet() {
    showLog(log: KeyStoreHelper.shared.getAccountAddress())
  }
  
  @objc private func fuelWallet() {
    FaucetHelper.shared.sendToken(to: KeyStoreHelper.shared.getAccountAddress(),
                                  from: "http://54.188.217.246:3008/donate/") { result in
                                    switch result {
                                    case .failure(let message):
                                      self.showLog(log: "Fuel failed: \(message)")
                                    case .success(let message):
                                      self.showLog(log: message)
                                    }
    }
  }
  
  @objc private func createCelerClient() {
    showLog(log: CelerClientAPIHelper.shared.initCelerClient(keyStoreString: KeyStoreHelper.shared.getKeyStoreString(),
                                                             password: KeyStoreHelper.shared.getPassword()))
    
  }
  
  @objc private func joinCeler() {
    showLog(log: CelerClientAPIHelper.shared.joinCeler(clientSideDepositAmount: clientSideDepositAmount,
                                                       serverSideDepositAmount: serverSideDepositAmount))
  }
  
  @objc private func checkBalance() {
    let (balanceLog, shouldHideSendPaymentButton) = CelerClientAPIHelper.shared.checkBalance()
    showLog(log: balanceLog)
    sendPaymentButton.isHidden = shouldHideSendPaymentButton
  }
  
  @objc private func sendPayment() {
    showLog(log: CelerClientAPIHelper.shared.sendPayment(receiverAddress: "0x200082086aa9f3341678927e7fc441196a222ac1",
                                                         transferAmount: "1"))
  }

  // MARK: - Controller Logic

  // MARK: - Listeners

  // MARK: - Helpers

}

// MARK: - Delegate
