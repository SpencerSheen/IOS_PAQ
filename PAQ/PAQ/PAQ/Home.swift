//
//  Home.swift
//  PAQ
//
//  Created by Karan Sunil on 2/6/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreData


class Home: UIViewController{

    //contains data from all alarms
    var alarms: [NSManagedObject] = []
    
    //index used to send data to TableViewCell for the alarm toggle
    var index = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        index = 0
        
        //CLEARS ALL EXISTING DATA
        /*
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
        */
        // Do any additional setup after loading the view.
        tableView.allowsSelectionDuringEditing = true
        
    }
    

    
    //Final part of sending data (hopefully)
    /*func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: characteristicIdentifier) {
                let value: UInt8 = 75
                let data = Data(bytes: [value])
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }*/
    
    //segue sends information to ViewController, for editing alarms
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue"{
            var alarmController = segue.destination as! ViewController
            alarmController.edit = true
            alarmController.index = tableView.indexPathForSelectedRow!.row
        }
    }
   
    
    //retrieves data from coredata
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "AlarmList")
        
        //3
        do {
            alarms = try managedContext.fetch(fetchRequest)
            //print(alarms.capacity)
            //self.alarmTable.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension Home: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return alarms.count
    }
    
    //loops through alarms array to add cells to tableview
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let alarm = alarms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        //print(index)
        
        //set time/day/toggle value based on alarm data
        cell.setAlarmLabel(alarm: alarm)
        cell.setDayLabel(alarm: alarm)
        cell.setToggle(alarm: alarm)
        
        //index used to send data to TableViewCell for the alarm toggle
        cell.setIndex(index: index)
        index = index + 1
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        index = 0;
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // DELETES ON LEFT SWIPE
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == UITableViewCellEditingStyle.delete
//        {
//            guard let appDelegate =
//                UIApplication.shared.delegate as? AppDelegate else {
//                    return
//            }
//
//            let managedContext = appDelegate.persistentContainer.viewContext
//            managedContext.delete(alarms[indexPath.row])
//            do{
//                try managedContext.save()
//                print("deleting item from context")
//            } catch let error as NSError {
//                print("Could not save \(error), \(error.userInfo)")
//            }
//            print("deleting item")
//            self.alarms.remove(at: indexPath.row)
//            self.tableView.reloadData()
//        }
//    }
    
    // Limit swipe so that it requires user to press delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete", handler: { (
            action, sourceView, completionHandler) in
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(self.alarms[indexPath.row])
            do{
                try managedContext.save()
                print("deleting item from context")
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            print("deleting item")
            self.alarms.remove(at: indexPath.row)
            self.index = 0
            // delete the table view row
            tableView.reloadData()
            completionHandler(true)
        })
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
}
