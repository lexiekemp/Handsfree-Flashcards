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
    
    var cards = [Card]()
    var numArray = [Int]()
    var sideOneSet = [(term: String, langID: String)]()
    var sideTwoSet = [(term: String, langID: String)]()
    var sideThreeSet = [(term: String, langID: String)]()
    var useSideThree = false
    var currentSide = 1
    var currentCardIndex = 0
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var wordLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordLabel.text = ""
        getCards()
        setGestureRecognizers()
    }
    
    private func getCards() {
        if (studySets == nil) {
            print("studySets is nil")
            return
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(completionHandler: { (context:NSManagedObjectContext) in
            DispatchQueue.main.async {
                self.managedObjectContext = context
                for studySet in self.studySets! {
                    if studySet.setName != nil, self.managedObjectContext != nil {
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Card")
                        request.predicate = NSPredicate(format: "parentSet.setName = %@", studySet.setName!)
                        if let fetchedCards = (try? self.managedObjectContext!.fetch(request)) as? [Card] {
                            self.cards = fetchedCards
                        }
                    }
                    if (self.cards.isEmpty) {
                        self.wordLabel.text = "Please choose a nonempty study set."
                        return
                    }
                    for card in self.cards {
                        switch self.firstChoiceIndex {
                        case 1:
                            if card.sideOne != nil, studySet.sideOneLangID != nil {
                                self.sideOneSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                            }
                        case 2:
                            if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                                self.sideOneSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                            }
                        case 3:
                            if card.sideThree != nil, studySet.sideThreeLangID != nil {
                                self.sideOneSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                            }
                        default:
                            print("invalid firstChoiceIndex")
                        }
                        switch self.secondChoiceIndex {
                        case 1:
                            if card.sideOne != nil, studySet.sideOneLangID != nil {
                                self.sideTwoSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                            }
                        case 2:
                            if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                                self.sideTwoSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                            }
                        case 3:
                            if card.sideThree != nil, studySet.sideThreeLangID != nil {
                                self.sideTwoSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                            }
                        default:
                            print("invalid firstChoiceIndex")
                        }
                        if self.thirdChoiceIndex != nil {
                            self.useSideThree = true
                            switch self.thirdChoiceIndex {
                            case 1?:
                                if card.sideOne != nil, studySet.sideOneLangID != nil {
                                    self.sideThreeSet.append((term: card.sideOne!, langID: studySet.sideOneLangID!))
                                }
                            case 2?:
                                if card.sideTwo != nil, studySet.sideTwoLangID != nil {
                                    self.sideThreeSet.append((term: card.sideTwo!, langID: studySet.sideTwoLangID!))
                                }
                            case 3?:
                                if card.sideThree != nil, studySet.sideThreeLangID != nil {
                                    self.sideThreeSet.append((term: card.sideThree!, langID: studySet.sideThreeLangID!))
                                }
                            default:
                                print("invalid firstChoiceIndex")
                            }
                        }
                    }
                    for num in 0..<self.cards.count {
                        self.numArray.append(num)
                    }
                }
            }
        })
        
        //numArray = numArray.shuffled() //swift 4.2
    }
    private func setGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.flipCard))
        cardView.addGestureRecognizer(tapRecognizer)
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.changeCard))
        self.view.addGestureRecognizer(swipeRecognizer)
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
    }
    @objc func flipCard(gesture: UITapGestureRecognizer) {
        UIView.transition(from: cardView, to: cardView, duration: 0.5, options: .transitionFlipFromRight, completion: nil)
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
    @objc func changeCard(gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.cardView.frame.origin.x = 0
            }
        self.cardView.frame.origin.x = self.view.frame.width
        UIView.animate(withDuration: 0.5) {
            self.cardView.center = self.view.center
        }
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            if currentCardIndex > 0 {
                currentCardIndex -= 1
                showCardSide(1)
            }
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            if currentCardIndex < (cards.count - 1) {
                currentCardIndex += 1
                showCardSide(1)
            }
        }
    }

}
