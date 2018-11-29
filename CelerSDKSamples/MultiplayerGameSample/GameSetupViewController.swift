//
//  GameSetupViewController.swift
//  CelerSDKSamples
//
//  Created by Jinyao Li on 10/23/18.
//

import UIKit
import Celer

class GameSetupViewController: UIViewController {
  
  private var groupClient: CelerGroupClient? = nil
  private var stake: String = "0"
  
  private lazy var createGameButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("CREATE GAME", for: .normal)
    button.addTarget(self, action: #selector(createGame), for: .touchUpInside)
    return button
  }()
  
  private let textView = UITextView()
  
  private lazy var joinGameButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("JOIN GAME", for: .normal)
    button.addTarget(self, action: #selector(joinGame), for: .touchUpInside)
    return button
  }()
  
  private let codeLabel = UILabel()
  private let codeTextField = UITextField()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    [textView, createGameButton, codeLabel, codeTextField, joinGameButton].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    
    joinGameButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -320).isActive = true
    codeTextField.bottomAnchor.constraint(equalTo: joinGameButton.topAnchor, constant: -20).isActive = true
    codeLabel.bottomAnchor.constraint(equalTo: codeTextField.topAnchor, constant: -20).isActive = true
    createGameButton.bottomAnchor.constraint(equalTo: codeLabel.topAnchor, constant: -20).isActive = true
    
    codeLabel.text = "JoinCode: XXXXXX"
    codeTextField.placeholder = "Input Join Code"
    
    groupClient = CelerGroupClient(serverAdress: "group-test-priv.celer.app:10001", keystoreJSON: KeyStoreHelper.shared.getKeyStoreString(), password: KeyStoreHelper.shared.getPassword()) { error in
      DispatchQueue.main.async {
        self.textView.text?.append(contentsOf: "\nError: \(error.localizedDescription)")
      }
    }
    groupClient?.delegate = self
  }
  
  @objc private func createGame() {
    groupClient?.createGameFrom(userAddress: KeyStoreHelper.shared.getAccountAddress(), withStake: "1") { error in
      DispatchQueue.main.async {
        self.textView.text?.append(contentsOf: "\nError: \(error.localizedDescription)")
      }
    }
  }
  
  @objc private func joinGame() {
    guard let codeText = codeTextField.text, !codeText.isEmpty, let code = Int(codeText), code < 1000000 else {
      self.textView.text?.append(contentsOf: "\n JoinGame parameter is not correct, codeText: \(codeTextField.text)")
      return
    }
    
    groupClient?.joinGame(userAddress: KeyStoreHelper.shared.getAccountAddress(), withGameCode: code, withStake: stake) { error in
      self.textView.text?.append(contentsOf: "\n\(error.localizedDescription)")
    }
  }
}

extension GameSetupViewController: CelerGroupClientCallback {
  func onSuccess(_ response: CelerGroupResponse) {
    
    if (response.getUsers().components(separatedBy: ",").count == 2) {
      DispatchQueue.main.async {
        let gameVC = GameViewController()
        gameVC.groupResponse = response
        self.navigationController?.pushViewController(gameVC, animated: true)
      }
    } else {
      DispatchQueue.main.async {
        self.stake = response.getStake()
        self.codeLabel.text = "JoinCode: \(response.getGameCode())"
        self.textView.text?.append(contentsOf: "\nReceive group response")
      }
    }
  }
  
  func onFailure(_ error: Error, _ description: String) {
    DispatchQueue.main.async {
      self.textView.text?.append(contentsOf: "Error: \(error.localizedDescription)\nDescription: \(description)")
    }
  }
}

