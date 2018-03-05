//
//  Bluetooth_connection.swift
//  PAQ
//
//  Created by Karan Sunil on 2/26/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class Bluetooth_connection: UIViewController,UITableViewDelegate {
    @IBOutlet weak var table_view: UITableView!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "previous_page"){
            stopBLEScan()
            let destination = segue.destination as! BLE_signals
        }
        
    }
    
    var peripherals:[CBPeripheral] = []
    var centralManager: CBCentralManager?
    var alarmPeripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print(centralManager)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        scanBLE()
        //stopBLEScan()
    }
    
    func scanBLE(){
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
        
    }
    
    func stopBLEScan(){
        centralManager?.stopScan()
        print("Scan stopped")
    }
    
    func getAlarm(alarms: NSManagedObject) -> String{
        var totalAlarmString = ""
        var ID = extractID(id: String((alarms as! NSManagedObject).value(forKeyPath: "id") as! Int))
        var time = extractTime(time: String((alarms as! NSManagedObject).value(forKeyPath: "time") as! String!))
        var days = extractDays(days: (alarms as! NSManagedObject).value(forKeyPath: "days") as? Array<Bool> ?? [])
        
        var misc = String((alarms as! NSManagedObject).value(forKeyPath: "duration") as! Int!) +
            String((alarms as! NSManagedObject).value(forKeyPath: "snoozes") as! Int!) +
            String((alarms as! NSManagedObject).value(forKeyPath: "intensity") as! Int!) +
            String((alarms as! NSManagedObject).value(forKeyPath: "length") as! Int!)
        
        
        var active = extractActive(active: (alarms as! NSManagedObject).value(forKeyPath: "active") as! Bool!)
        //order of alarm string
        totalAlarmString = ID + time + days + misc + active
        return totalAlarmString
    }
    
    func extractID(id: String) -> String {
        var newId = id
        //adds missing 0s if the Id value is too low
        if(id.count == 1){
            newId = "00" + id
        }
        else if(id.count == 2){
            newId = "0" + id
        }
        return newId
    }
    
    //converts time to 24 hour format HHmm
    func extractTime(time: String) -> String {
        print(time + "\n")
        let dateAsString = time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)
        
        dateFormatter.dateFormat = "HHmm"
        let date24 = dateFormatter.string(from: date!)
        print(String(date24))
        return String(date24)
    }
    
    //takes active days in forms of 0 and 1 and converts them
    //from binary to decimal
    // Ex: 0000111 (Fri, Sat, Sun alarm) converts to a value of 7
    func extractDays(days: [Bool]) -> String{
        var dayPower = Float(6)
        var daysToDec = 0
        for day in days{
            if(day){
                daysToDec += Int(powf(2, dayPower))
            }
            dayPower -= 1
        }
        
        if(daysToDec < 10){
            return "00" + String(daysToDec)
        }
        else if(daysToDec < 100){
            return "0" + String(daysToDec)
        }
        return String(daysToDec)
    }
    
    func extractActive(active: Bool) -> String{
        if(active){
            return "1"
        }
        return "0"
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

extension Bluetooth_connection: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return peripherals.count
    }
    
    //loops through alarms array to add cells to tableview
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath)
        let device = peripherals[indexPath.row]
        cell.textLabel?.text = device.name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = peripherals[indexPath.row]
        centralManager?.connect(device, options: nil)
        //stopBLEScan()
    }
    
}

extension Bluetooth_connection: CBCentralManagerDelegate{
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        alarmPeripheral = peripheral
        alarmPeripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!peripherals.contains(peripheral) && peripheral.name != nil){
            peripherals.append(peripheral)
        }
        self.table_view.reloadData()
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("central.state is unknown")
        case .resetting:
            print("central.state is resetting")
        case .unsupported:
            print("central.state is unsupported")
        case .unauthorized:
            print("central.state is unauthorized")
        case .poweredOff:
            print("central.state is poweredOff")
        case .poweredOn:
            print("central.state is poweredOn")
            centralManager?.scanForPeripherals(withServices: nil)
        }
    }
}

extension Bluetooth_connection: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                             didModifyServices invalidatedServices: [CBService]){
        print("DID MODIFY SERVICES")
        print(peripheral)
        print(invalidatedServices)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueForCharacteristic descriptor: CBDescriptor, error: Error?) {
        print("Error: ")
        print(error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            //if characteristic.uuid == CBUUID(string: "00001532-1212-EFDE-1523-785FEABCD123") {
            //print(characteristic)
            
            //SENDING INTEGERS
            //let value: UInt8 = 75
            //let data = Data(bytes: [value])
            
            let helloWorld = "Hello world\n"
            
            //Get all existing alarms
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmList")
            var totalAlarmString = ""
            do{
                let allAlarms = try context.fetch(request)
                
                //MAYBE CHECK IF ALARM IS ACTIVE
                //loop through alarms
                for alarms in allAlarms{
                    //convert alarm info into a string
                    totalAlarmString = getAlarm(alarms: alarms as! NSManagedObject)
                    //convert alarm string to data type that is sendable
                    let dataToSend = totalAlarmString.data(using: String.Encoding.utf8)
                    //send data to arduino
                    peripheral.writeValue(dataToSend!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
            } catch {
                print("Could not fetch")
            }
            
            /*
            print(totalAlarmString)
            let fullString = "Goodbye World!"
            let dataToSend = helloWorld.data(using: String.Encoding.utf8)
            let secData = fullString.data(using: String.Encoding.utf8) */
            
            
            //characteristic.setValue(dataToSend, forKeyPath: "00001532-1212-EFDE-1523-785FEABCD123")
            //characteristic = CBMutableCharacteristic
            //peripheral.setNotifyValue(true, for: characteristic)
            //peripheral.writeValue(dataToSend!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            //peripheral.writeValue(secData!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            
            print(characteristic)
            
            //}
        }
        print(peripheral)
    }
}
