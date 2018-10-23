//
//  JoinCelerViewController.swift
//  CelerSDKSamples
//
//  Created by Jinyao Li on 10/23/18.
//

import UIKit
import Celer

class JoinCelerViewController: UIViewController {
  
  private var client: CelerClient? = nil
  
  let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
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
  
  private lazy var startMatchingButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Let's play", for: .normal)
    button.addTarget(self, action: #selector(startMatching), for: .touchUpInside)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    [textView, createWalletButton, fuelWalletButton, createCelerClientButton, joinCelerButton, startMatchingButton].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    startMatchingButton.isHidden = true
    
    createWalletButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
    fuelWalletButton.topAnchor.constraint(equalTo: createWalletButton.bottomAnchor, constant: 20).isActive = true
    createCelerClientButton.topAnchor.constraint(equalTo: fuelWalletButton.bottomAnchor, constant: 20).isActive = true
    joinCelerButton.topAnchor.constraint(equalTo: createCelerClientButton.bottomAnchor, constant: 20).isActive = true
    textView.topAnchor.constraint(equalTo: joinCelerButton.bottomAnchor, constant: 20).isActive = true
    textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    textView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    startMatchingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
  }
  
  @objc private func createNewWallet() {
    _ = KeyStoreHelper.shared.getKeyStoreString(userType: .Player1)
    textView.text.append(contentsOf: "Create wallet successlly with address: \(KeyStoreHelper.shared.getAccountAddress(userType: .Player1))")
  }
  
  @objc private func fuelWallet() {
    KeyStoreHelper.shared.fuelTheAccount(userType: .Player1) { [weak self] result in
      DispatchQueue.main.async {
        self?.textView.text.append(contentsOf: "\n\nFuel wallet result: \(result)")
      }
    }
  }
  
  @objc private func createCelerClient() {
    let (result, client) = KeyStoreHelper.shared.getCelerClient()
    self.client = client
    textView.text.append(contentsOf: result)
  }
  
  @objc private func joinCeler() {
    guard let client = client else {
      textView.text.append(contentsOf: "\n\nCreate new celer client then retry joining celer.")
      return
    }
    
    do {
      try client.joinCeler(basedOnToken: "0x0", providing: "500000000000000000", requiring: "500000000000000000")
      textView.text.append(contentsOf: "\n\nJoin celer successfully with balance: \(client.getAvailableBalance())")
      startMatchingButton.isHidden = false
    } catch {
      textView.text.append(contentsOf: "\n\n\(error.localizedDescription)")
    }
  }
  
  @objc private func startMatching() {
    let gameSetupViewController = GameSetupViewController()
    navigationController?.pushViewController(gameSetupViewController, animated: true)
  }
}

