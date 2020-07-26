//
//  ViewController.swift
//  Covid 19 Tracker
//
//  Created by Rajesh Thangaraj on 24/06/20.
//  Copyright © 2020 Rajesh Thangaraj. All rights reserved.
//

import UIKit


// MARK: - StateData
struct StateData: Codable {
    let casesTimeSeries: [CasesTimeSery]
    let statewise: [Statewise]
    let tested: [Tested]

    enum CodingKeys: String, CodingKey {
        case casesTimeSeries = "cases_time_series"
        case statewise, tested
    }
}

// MARK: - CasesTimeSery
struct CasesTimeSery: Codable {
    let dailyconfirmed, dailydeceased, dailyrecovered, date: String
    let totalconfirmed, totaldeceased, totalrecovered: String
}

// MARK: - Statewise
struct Statewise: Codable {
    let active, confirmed, deaths, deltaconfirmed: String
    let deltadeaths, deltarecovered, lastupdatedtime, migratedother: String
    let recovered, state, statecode, statenotes: String
    
    
    
    
    func desctiption() -> String {
        
        let fromFormat = DateFormatter()
        fromFormat.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let toFormat = DateFormatter()
             toFormat.dateFormat = "dd MMM yyyy"
        
        return "Tamilnadu Covid-19 update 🦠 for " + toFormat.string(from: fromFormat.date(from: lastupdatedtime)!) + " Confirmed Today - " + deltaconfirmed + ", Recovered Today - " + deltarecovered + ", Deaths Today - " + deltadeaths + ", Total confirmed - " + confirmed + ", Active - " + active + ", Total deaths - " + deaths + "\n\n\nApp Link - https://ledbanner.page.link/share \nTamilnadu Covid-19 update 🦠 for " + toFormat.string(from: fromFormat.date(from: lastupdatedtime)!) + "\nConfirmed Today - " + deltaconfirmed + "\nRecovered Today - " + deltarecovered + "\nDeaths Today - " + deltadeaths + "\nTotal confirmed - " + confirmed + "\nActive - " + active + "\nTotal deaths - " + deaths + "\nSource - https://www.covid19india.org/\n\n"
        
    }
}

// MARK: - Tested
struct Tested: Codable {
    let individualstestedperconfirmedcase, positivecasesfromsamplesreported, samplereportedtoday: String
    let source: String
    let source1: String
    let testpositivityrate, testsconductedbyprivatelabs, testsperconfirmedcase, testspermillion: String
    let totalindividualstested, totalpositivecases, totalsamplestested, updatetimestamp: String
}


class ViewController: UIViewController {

    @IBOutlet weak var textview: UITextView!
    var districWiseDict: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadAction("")
    }

    @IBAction func reloadAction(_ sender: Any) {
        self.textview.text = ""
        
        var request = URLRequest(url: URL(string: "https://api.covid19india.org/data.json")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    self.textview.text = error?.localizedDescription
                    return
                }
                let stateData = try? JSONDecoder().decode(StateData.self, from: data)
                if let statewise = stateData?.statewise {
                    for item in statewise {
                        if item.statecode == "TN" {
                            self.addText(text: item.desctiption())
                        }
                    }
                }
                
            }
        }.resume()
        navigationItem.leftBarButtonItem?.isEnabled = false
        var districtWiseRequest = URLRequest(url: URL(string: "https://api.covid19india.org/state_district_wise.json")!,timeoutInterval: Double.infinity)
        districtWiseRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: districtWiseRequest) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    return
                }
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.districWiseDict = dict;
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    @IBAction func districtWiseAction(_ sender: Any) {
        if let districWiseDict = districWiseDict {
         self.alertController(title: "Choose value", actions: districWiseDict)
        }
    }

    
    
    func alertController(title: String, actions: [String: Any]) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let sortedKeys = Array(actions.keys).sorted(by: <)
        for actionTitle in sortedKeys {
            alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action) in
                if let actionTitle = action.title {
                    if let dict = actions[actionTitle] as? [String: Any] {
                        self.alertController(title: actionTitle, actions: dict)
                    } else {
                        self.addText(text: self.districtData(district: title, dict: actions))
                    }
                }
                
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    func addText(text: String) {
        self.textview.text = "\n\n" + text + "\n\n" + self.textview.text
    }
    
    func districtData(district: String, dict: [String: Any]) -> String {
        if let delta = dict["delta"] as? [String: Any] {
            var returnString = district + " Covid-19 update 🦠 \nConfirmed Today - " + asString(number: delta["confirmed"])
            returnString = returnString + "\nRecovered Today - " + asString(number: delta["recovered"])
            returnString = returnString + "\nDeaths Today - " + asString(number: delta["deceased"])
            returnString = returnString + "\nTotal confirmed - " + asString(number: dict["confirmed"])
            returnString = returnString + "\nActive - " + asString(number: dict["active"])
            returnString = returnString + "\nTotal deaths - " + asString(number: dict["deceased"])
            returnString = returnString + "\nSource - https://www.covid19india.org/\n\n"
            return returnString
        } else {
            return "---"
        }
    }
    
    func asString(number: Any?) -> String {
        if let number = number as? Int {
            return String(number)
        }
        return ""
    }
    
}

