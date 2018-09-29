//
//  ManualStudyViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 7/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit
import CoreData

class ManualStudyViewController: RootViewController {
    
    var studySets:[Set]?
    var firstChoiceIndex = 1
    var secondChoiceIndex = 2
    var thirdChoiceIndex:Int?
    var sortChoiceIndex:Int?
    
    var cards = [Card]()
    var sideOneSet = [(term: String, langID: String)]()
    var sideTwoSet = [(term: String, langID: String)]()
    var sideThreeSet = [(term: String, langID: String)]()
    var useSideThree = false
    var currentSide = 1 {
        didSet {
            switch currentSide {
            case 1:
                sideIndex = firstChoiceIndex - 1
            case 2:
                sideIndex = secondChoiceIndex - 1
            case 3:
                sideIndex = thirdChoiceIndex! - 1
            default:
                return
            }
        }
    }
    var sideIndex = 0
    
    var currentCardIndex = 0 {
        didSet {
            progressLabel.text = "\(currentCardIndex+1)/\(sideOneSet.count)"
        }
    }

    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var wordLabel : UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var studyInfoLabel: UILabel!
    @IBOutlet weak var cardViewConstraint: NSLayoutConstraint!
    
    @IBAction func onePressed(_ sender: UIButton) {
        addStudyInfo(rating: 1)
    }
    @IBAction func twoPressed(_ sender: UIButton) {
        addStudyInfo(rating: 2)
    }
    @IBAction func threePressed(_ sender: UIButton) {
        addStudyInfo(rating: 3)
    }
    @IBAction func fourPressed(_ sender: UIButton) {
        addStudyInfo(rating: 4)
    }
    private func addStudyInfo(rating: Int64) {
        let currentCard = cards[currentCardIndex]
        guard let side = Side.side(card:currentCard, index:(Int64(sideIndex)), inManagedObjectContext: managedObjectContext!) else {
            errorAlert(message: "Could not save rating")
            return
        }
        guard let studyInfo = StudyInfo.addStudyInfo(rating: rating, date: NSDate(), inManagedObjectContext: managedObjectContext!) else {
            errorAlert(message: "Could not save rating")
            return
        }
        side.addToStudyInfo(studyInfo)
        goToNextCard()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        wordLabel.text = ""
        cardViewConstraint.constant = self.view.frame.width/2 - self.cardView.frame.width/2
        self.view.layoutIfNeeded()
        getCards()
        setGestureRecognizers()
    }
    
    private func getCards() {
        if (studySets == nil) {
            print("studySets is nil")
            return
        }
        
        if managedObjectContext != nil {
            for studySet in studySets! {
                if studySet.setName != nil {
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Card")
                    request.predicate = NSPredicate(format: "parentSet.setName = %@", studySet.setName!)
                    if let fetchedCards = (try? managedObjectContext!.fetch(request)) as? [Card] {
                        cards = fetchedCards
                    }
                }
                if (cards.isEmpty) {
                    wordLabel.text = "Please choose a nonempty study set."
                    return
                }
                cards.shuffle()
                for card in cards {
                    switch firstChoiceIndex {
                    case 1:
                        if card.sideOne != nil, studySet.sideOneLangID != nil {
                            sideOneSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                        }
                    case 2:
                        if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                            sideOneSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                        }
                    case 3:
                        if card.sideThree != nil, studySet.sideThreeLangID != nil {
                            sideOneSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                        }
                    default:
                        print("invalid firstChoiceIndex")
                    }
                    switch secondChoiceIndex {
                    case 1:
                        if card.sideOne != nil, studySet.sideOneLangID != nil {
                            sideTwoSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                        }
                    case 2:
                        if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                            sideTwoSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                        }
                    case 3:
                        if card.sideThree != nil, studySet.sideThreeLangID != nil {
                            sideTwoSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                        }
                    default:
                        print("invalid firstChoiceIndex")
                    }
                    if thirdChoiceIndex != nil {
                        useSideThree = true
                        switch thirdChoiceIndex {
                        case 1?:
                            if card.sideOne != nil, studySet.sideOneLangID != nil {
                                sideThreeSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                            }
                        case 2?:
                            if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                                sideThreeSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                            }
                        case 3?:
                            if card.sideThree != nil, studySet.sideThreeLangID != nil {
                                sideThreeSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                            }
                        default:
                            print("invalid firstChoiceIndex")
                        }
                    }
                }
            }
        }
        currentCardIndex = 0
        showCardSide(1)
    }
    private func setGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.flipCard))
        cardView.addGestureRecognizer(tapRecognizer)
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.changeCard))
        leftSwipeRecognizer.direction = .left
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.changeCard))
        rightSwipeRecognizer.direction = .right
        self.cardView.addGestureRecognizer(leftSwipeRecognizer)
        self.cardView.addGestureRecognizer(rightSwipeRecognizer)
        self.view.addGestureRecognizer(leftSwipeRecognizer)
        self.view.addGestureRecognizer(rightSwipeRecognizer)
    }
    private func getLastStudyInfo() -> StudyInfo? {
        let currentCard = cards[currentCardIndex]
        guard let side = Side.side(card:currentCard, index:(Int64(sideIndex)), inManagedObjectContext: managedObjectContext!) else {
            return nil
        }
        if let lastStudyInfo = StudyInfo.studyInfoByDate(side: side, inManagedObjectContext: managedObjectContext!).first {
            return lastStudyInfo
        }
        return nil
    }
    
    private func showCardSide(_ side: Int){
        switch side {
        case 1:
            wordLabel.text = sideOneSet[currentCardIndex].term
            currentSide = 1
        case 2:
            wordLabel.text = sideTwoSet[currentCardIndex].term
            currentSide = 2
        case 3:
            wordLabel.text = sideThreeSet[currentCardIndex].term
            currentSide = 3
        default:
            return;
        }
        if let lastStudyInfo = getLastStudyInfo(), lastStudyInfo.date != nil {
            studyInfoLabel.text = "\(lastStudyInfo.date!) - \(lastStudyInfo.rating)"
        }
        else {
            studyInfoLabel.text = "no rating"
        }
    }
    @objc func flipCard(gesture: UITapGestureRecognizer) {
        UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: nil)
        switch currentSide {
        case 1:
            showCardSide(2)
        case 2:
            if (useSideThree) {
                showCardSide(3)
            }
            else {
                showCardSide(1)
            }
        case 3:
            showCardSide(1)
        default:
            return;
        }
    }
    private func goToNextCard() {
        if currentCardIndex >= (sideOneSet.count - 1) { return }
        currentCardIndex += 1
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.cardViewConstraint.constant = -self.cardView.frame.width
            self.view.layoutIfNeeded()
        }, completion: { [weak self] finish in
            if self == nil { return }
            
            self!.cardViewConstraint.constant = self!.view.frame.width
            self!.view.layoutIfNeeded()
            self!.showCardSide(1)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self!.cardViewConstraint.constant = self!.view.frame.width/2 - self!.cardView.frame.width/2
                self!.view.layoutIfNeeded()
            }, completion: nil
            )}
        )
    }
    private func goToPreviousCard() {
        if currentCardIndex <= 0 { return }
        currentCardIndex -= 1
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.cardViewConstraint.constant = self.view.frame.width
            self.view.layoutIfNeeded()
        }, completion: { [weak self] finish in
            if self == nil { return }
            
            self!.cardViewConstraint.constant = -self!.cardView.frame.width
            self!.view.layoutIfNeeded()
            self!.showCardSide(1)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self!.cardViewConstraint.constant = self!.view.frame.width/2 - self!.cardView.frame.width/2
                self!.view.layoutIfNeeded()
            }, completion: nil
            )
        })
    }
    @objc func changeCard(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            goToPreviousCard()
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            goToNextCard()
        }
    }
}
