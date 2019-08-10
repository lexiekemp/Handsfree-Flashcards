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
    var sideIndex: Int?
    var sectionCount = 2
    @IBOutlet weak var langTextField: UITextField!
    @IBOutlet weak var langTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        langs = langCodeDict.keys.sorted()
        langTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        langTableView.delegate = self
        langTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        langs = langCodeDict.keys.sorted()
        sectionCount = 2
        langTableView.reloadData()
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text?.lowercased(), text != "" {
            sectionCount = 1
            langs = langs.filter { $0.lowercased().starts(with: text) }
        }
        else {
            sectionCount = 2
            langs = langCodeDict.keys.sorted()
        }
        // let results = dict.flatMap { (key, value) in key.lowercased().contains("o") ? value : nil }
        langTableView.reloadData()
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && sectionCount == 2 {
            return commonLangs.count
        }
        return langs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "langCell") else {
            fatalError("langCell cannot be dequeued")
        }
        if indexPath.section == 0 && sectionCount == 2 {
            cell.textLabel?.text = commonLangs[indexPath.row]
            return cell
        }
        cell.textLabel?.text = langs[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let index = sideIndex else { return }
        if indexPath.section == 0 && sectionCount == 2 {
            newSetVC?.cellSideInfo[index].language = commonLangs[indexPath.row]
        }
        else {
            newSetVC?.cellSideInfo[index].language = langs[indexPath.row]
        }
        navigationController?.popViewController(animated: true)
    }
}
