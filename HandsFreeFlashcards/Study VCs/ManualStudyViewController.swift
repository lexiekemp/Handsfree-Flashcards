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
    var currentCardIndex = 0 {
        didSet {
            progressLabel.text = "\(currentCardIndex+1)/\(cards.count)"
        }
    }
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var wordLabel : UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        wordLabel.text = ""
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
                for num in 0..<cards.count {
                    numArray.append(num)
                }
                numArray = numArray.shuffled()
                progressLabel.text = "\(currentCardIndex+1)/\(cards.count)"
                showCardSide(1)
            }
        }
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
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            if currentCardIndex <= 0 { return }
            currentCardIndex -= 1
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.cardView.frame.origin.x = self.view.frame.width
            }, completion: { [weak self] finish in
                if self == nil { return }
                self!.cardView.frame.origin.x = -self!.cardView.frame.width
                self!.showCardSide(1)
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self!.cardView.frame.origin.x = self!.view.frame.width/2 - self!.cardView.frame.width/2
                }, completion: nil
                )
            })
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            if currentCardIndex >= (cards.count - 1) { return }
            currentCardIndex += 1
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.cardView.frame.origin.x = -self.cardView.frame.width
            }, completion: { [weak self] finish in
                if self == nil { return }
                self!.cardView.frame.origin.x = self!.view.frame.width
                self!.showCardSide(1)
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self!.cardView.frame.origin.x = self!.view.frame.width/2 - self!.cardView.frame.width/2
                }, completion: nil
                )
            })
        }
    }

}
