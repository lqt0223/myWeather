//
//  OptionViewController.swift
//  myWeather
//
//  Created by lqt0223 on 2016/12/17.
//  Copyright © 2016年 lqt0223. All rights reserved.
//

import UIKit

class OptionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    var searchBar = UISearchBar()
    var searchResults: [String] = []
    var tableViewMode = 0 // 0 for added cities, 1 for search result
    //switches for option
//    var hideWeather = UISwitch()

    let viewController = UIApplication.shared.keyWindow?.rootViewController as! ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar = self.view.subviews.last?.subviews.first?.subviews.first?.subviews.last?.subviews.first?.subviews.first as! UISearchBar
        searchBar.delegate = self
//        hideWeather = tableView.cellForRow(at: IndexPath(row: 1, section: 2))?.contentView.subviews.last as! UISwitch
//        hideWeather.setOn(userOption["hideWeather"] as! Bool, animated: true)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        searchBar.resignFirstResponder()
    }
    
    //when typing in search, fetch the data from city.db
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0){
            let db = SQLiteDB.sharedInstance
            let results = db.query(sql: "select * from city where name like '\(searchText)%'")
            searchResults.removeAll()
            for row in results{
                searchResults.append(row["name"] as! String)
            }
            tableViewMode = 1
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }else{
            tableViewMode = 0
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    //when scroll the tableview, the keyboard have to dismiss
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        searchBar.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell")!
        let cityCell = tableView.dequeueReusableCell(withIdentifier: "cityCell")!
        let sectionCell = tableView.dequeueReusableCell(withIdentifier: "sectionCell")!
        let switchCell = tableView.dequeueReusableCell(withIdentifier: "switchCell")!
        switchCell.selectionStyle = UITableViewCellSelectionStyle.none //!

        if(indexPath.section == 0){
            return searchCell
        }else if(indexPath.section == 1){
            if(tableViewMode == 1 && indexPath.row < searchResults.count){
                cityCell.textLabel?.text = searchResults[indexPath.row]
                if(cityList.contains((cityCell.textLabel?.text)!)){
                    cityCell.textLabel?.text?.append(" （已添加）")
                }
                return cityCell
            }else{
                cityCell.textLabel?.text = cityList[indexPath.row]
                if(indexPath.row == 0){
                    cityCell.textLabel?.text?.append(" ➢")
                }
                return cityCell
            }
        }else{
            if(indexPath.row == 0){
                (sectionCell.subviews.first?.subviews.first as! UILabel).text = "选项"
                //add a white line to separate
                let whiteLineView = UIView(frame: sectionCell.frame)
                whiteLineView.backgroundColor = UIColor.white
                whiteLineView.frame.size.width -= 20
                whiteLineView.center = sectionCell.center
                whiteLineView.frame.origin.y += (whiteLineView.frame.size.height - 0.5)
                whiteLineView.frame.size.height = 0.5
                sectionCell.addSubview(whiteLineView)
                return sectionCell
            }else{
                if(indexPath.row == 1){
                    switchCell.textLabel?.text = "示例选项"
                }
                return switchCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        searchBar.resignFirstResponder()
        
        if(tableViewMode == 0){
            let i = indexPath.row
            viewController.jumpTo(index: i)
            self.dismiss(animated: true, completion: nil)
        }else{
            var city = tableView.cellForRow(at: indexPath)?.textLabel?.text
            if(city?.contains(" （已添加）"))!{
                city = city?.substring(to: (city?.index((city?.endIndex)!, offsetBy: -6))!)
            }
            if(!cityList.contains(city!)){
                cityList.append(city!)
                // dismiss the optionViewController and add city
                viewController.addNewCity(city!)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        cityList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        viewController.removeCity(indexPath.row)
        
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row != 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0 && indexPath.section == 2){
            return 30.0
        }else{
            return 44.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else if(section == 1){
            if(tableViewMode == 0){
                return cityList.count
            }else{
                return searchResults.count
            }
        }else{
            return 2
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
//        viewController.setWeatherHidden(option: self.hideWeather.isOn)
//        userOption.updateValue(self.hideWeather.isOn, forKey: "hideWeather")
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

