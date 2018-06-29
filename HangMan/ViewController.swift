//
//  ViewController.swift
//  HangMan
//
//  Created by Catalin Palade on 27/06/2018.
//  Copyright © 2018 Catalin Palade. All rights reserved.
//

import GameplayKit
import UIKit

class ViewController: UIViewController {

    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var mistakesLabel: UILabel!
    @IBOutlet var displayWordLabel: UITextField!
    @IBOutlet var usedLetterLabel: UITextField!
    @IBOutlet var levelLabel: UILabel! //no installed
    @IBOutlet var hintOutlet: UIButton!
    @IBOutlet var imageOutlet: UIImageView!
    
    var letterButtons = [UIButton]()
    var allWords = [String]()
    var currentWord = ""
    var currentLetter = ""
    var usedLetters = [String]()
    var displayUsedLetters = "" {
        didSet {
            usedLetterLabel.text! = displayUsedLetters
        }
    }
    var displayWord = "" {
        didSet {
            displayWordLabel.text! = displayWord
        }
    }
    var mistakes = 0 {
        didSet {
            mistakesLabel.text! = "Mistakes: \(mistakes)"
            let image = UIImage(named:"stage\(mistakes).png")
            imageOutlet.image = image
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text! = "Score: \(score)"
        }
    }
    var level = 1 {
        didSet {
            levelLabel.text! = "Level: \(level)"
        }
    }
    var hint = 5 {
        didSet {
            hintOutlet.setTitle("Hint(\(hint))", for: .normal)
        }
    }
    
    @IBAction func hintButton(_ sender: UIButton) {
        getHint()
    }
    @IBAction func newWordButton(_ sender: UIButton) {
        resetDisplay()
        startGame()
        score = 0
        hint = 5
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readFile()
        initButtons()
        startGame()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //init buttons
    func initButtons() {
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
    }
    @objc func letterTapped(btn: UIButton) {
        //when a button it tapped
        currentLetter = btn.currentTitle!
        displayUsedLetters += currentLetter + ", "
        usedLetters.append(currentLetter)
        btn.isEnabled = false
        
        checkLetter()
    }
    //check the letter if it is in the word
    func checkLetter() {
        var newWord = ""
        if !currentWord.contains(currentLetter) {
            mistakes += 1
        }
        for letter in currentWord {
            let strLetter = String(letter)
            
            if usedLetters.contains(strLetter) {
                newWord += strLetter
            } else {
                newWord += "_ "
            }
        }
        displayWord = newWord
        statusGame()
        print(newWord)
    }
    //check the status of the game
    //game over at 7 mistakes
    //win if complete, score += 1
    func statusGame() {
        let displayWordNoWhiteSpaces = displayWord.replacingOccurrences(of: " ", with: "")
        if currentWord == displayWordNoWhiteSpaces {
            showWin()
            print("Win")
            score += 1
        } else if mistakes == 7 {
            showGameOver()
            score = 0
            hint = 5
            print("Game Over")
        }
    }
    
    //read the file of words and save them in an array
    func readFile() {
        if let filePath = Bundle.main.path(forResource: "words", ofType: "txt") {
            if let file = try? String(contentsOfFile: filePath) {
                allWords = file.components(separatedBy: "\n")
            } else {
                allWords = loadDefaultWords()
            }
        } else {
            allWords = loadDefaultWords()
        }
    }
    //if the file reading fails loadDefaultWords
    func loadDefaultWords() -> [String] {
        print("Error in reading the file! Load default words.")
        return ["SARCASM", "SATISFY", "TREND", "EMBLEM"]
    }
    //shuffle the list of words and play the first one in _ _ _ _
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        currentWord = allWords[0]
        for _ in currentWord {
            displayWord += "_ "
        }
        let image = UIImage(named:"stage0.png")
        imageOutlet.image = image
        print(currentWord)
    }
    //reset display
    func resetDisplay() {
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! mistakes should not reset for a new word
        mistakes = 0
        displayWord = ""
        displayUsedLetters = ""
        usedLetters = []
        //enable all buttons
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.isEnabled = true
        }
    }
    //alert for game over
    func showGameOver() {
        let ac = UIAlertController(title: "Game Over",
                                   message: "Try again",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: newGame))
        present(ac, animated: true)
    }
    func newGame(action: UIAlertAction) {
        resetDisplay()
        startGame()
    }
    //alert for win
    func showWin() {
        let ac = UIAlertController(title: "Congratulation",
                                   message: "You have guessed \"\(currentWord.lowercased())\". Have another one 😊",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: newGame))
        present(ac, animated: true)
    }
    //get a hint - show to user a letter
    func getHint() {
        if hint != 0 {
            for letter in currentWord {
                let strLetter = String(letter)
                if !usedLetters.contains(strLetter) {
                    showHint(with: strLetter)
                    hint -= 1
                    print(strLetter)
                    return
                }
            }
        } else {
            showNoMoreHint()
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!! score and hint should not reset for win
            score = 0
            hint = 5
        }
        
    }
    //alert for hint
    func showHint(with letter: String) {
        let ac = UIAlertController(title: "Hint",
                                   message: "You should try \" \(letter) \"",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Thank you!", style: .default))
        present(ac, animated: true)
    }
    //alert for no more hints
    func showNoMoreHint() {
        let ac = UIAlertController(title: "Sorry",
                                   message: "You have used all your hints.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .cancel))
        ac.addAction(UIAlertAction(title: "Play again", style: .default, handler: newGame))
        present(ac, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

