//
//  ViewController.swift
//  Project 5 - Word Scramble
//
//  Created by Shana Pougatsch on 8/29/20.
//  Copyright © 2020 Shana Pougatsch. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    //MARK: - Properties

    var allWords = [String]()
    var usedWords = [String]()
    
    //MARK: - View management
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(startGame))
       
        // this code carefully checks for and unwraps the contents of our start file, then converts it to an array. When it has finished, allWords will contain 12,000+ strings for our game
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
         startGame()
    }
        //MARK: - Methods, closure, check answers, submit
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField ()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        // Check if the word can be made from the given letters
        if isPossible(word: lowerAnswer) {
            // Check if it has already been used
            if isOriginal(word: lowerAnswer) {
                // Check if it is an English word
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    // If all passes, add the word to the usedWords array and insert new row in tableview
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showErrorMessage("Word not recognized", withMessage: "You can't just make them up, ya know!")
                }
            } else {
                showErrorMessage("Word already used", withMessage: "Be more original!")
            }
        } else {
            guard let title = title?.lowercased() else { return }
            showErrorMessage("Word not possible", withMessage: "You can't spell that word from \(title.lowercased())")
        }
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        guard word.count >= 3 else { return false }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
        
    func showErrorMessage (_ title: String, withMessage: String) {
        let ac = UIAlertController(title: title, message: withMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    //MARK: - Table View
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return usedWords.count
       }
           
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
           cell.textLabel?.text = usedWords[indexPath.row]
           
        return cell
       }
}







