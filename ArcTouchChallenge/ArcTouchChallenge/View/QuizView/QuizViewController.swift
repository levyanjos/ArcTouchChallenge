//
//  QuizViewController.swift
//  ArcTouchChallenge
//
//  Created by Levy Cristian on 17/12/19.
//  Copyright © 2019 Levy Cristian. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    let viewModel: QuizViewModel = QuizViewModel()
    
    lazy var quizView: QuizView = {
        let view = QuizView()
        view.keywordsTableView.dataSource = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = quizView
        viewModel.loadQuiz()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        quizView.footerView.quizButton.addTarget(viewModel, action: #selector(viewModel.didTapQuizButton), for: .touchUpInside)
        
        quizView.quizTextField.addTarget(viewModel, action: #selector(viewModel.textFieldDidChange(_:)), for: .editingChanged)
        
        viewModel.isLoading = { [weak self] loading in
            self?.quizView.isLoading = loading
        }
        
        viewModel.errorLoadingData = { [weak self] erro in
            self?.showAlert("error", message: erro.localizedDescription, button: "Try again", handler: { [weak self] _ in
                self?.viewModel.loadQuiz()
            })
        }
        
        viewModel.updateTitleWithQuestion = { [weak self] question in
            self?.quizView.titleLabel.text = question
        }
        
        //Timer Bidings
        viewModel.updateUIWithCurrentTimer = { [weak self] timer in
            self?.quizView.footerView.timerLabel.text = timer
            self?.quizView.footerView.quizButton.title = self?.viewModel.buttonTitle
        }
        
        viewModel.updatedUIWitCurrenthCounterValue = { [weak self] counter in
            self?.quizView.quizTextField.text = ""
            self?.quizView.footerView.counterLabel.text = counter
            self?.quizView.keywordsTableView.reloadData()
        }
        
        viewModel.didFinishQuiz = { [unowned self] isWinner in
            self.quizView.quizTextField.endEditing(true)

            if isWinner {
                self.showAlert("Congratulations",
                               message: "Good job! You found all the answers on time. Keep up with the great work.",
                               button: "Play Again") { [weak self] (_) in
                                self?.viewModel.didTapQuizButton()
                }
            } else {
                self.showAlert("Time finished",
                                message: "Sorry, time is up! You got \(self.viewModel.numberOfHits) out of \(self.viewModel.numberOfAnswers) answers.", button: "Try Again", handler:
                    { [weak self] (_) in
                        self?.viewModel.didTapQuizButton()
                })
            }
        }
    }
}

extension QuizViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        guard let cellViewModel = viewModel.getCellViewModel(for: indexPath) else { return UITableViewCell() }
        cell.textLabel?.text = cellViewModel.keywordText
        return cell
    }
}
