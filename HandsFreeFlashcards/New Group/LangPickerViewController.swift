//
//  LangPickerViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 8/8/19.
//  Copyright © 2019 Lexie Kemp. All rights reserved.
//

import UIKit

class LangPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var langs: [String] = []
    var newSetVC: NewSetViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        langs = langCodeDict.keys.sorted()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return commonLangs.count
        }
        return langs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "langCell") else {
            fatalError("langCell cannot be dequeued")
        }
        if indexPath.section == 0 {
            cell.textLabel?.text = commonLangs[indexPath.row]
        }
        else if indexPath.section == 1 {
             cell.textLabel?.text = langs[indexPath.row]
        }
        return cell
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
