//
//  Bluetooth_connection.swift
//  PAQ
//
//  Created by Karan Sunil on 2/26/18.
//  Copyright © 2018 PAQ. All rights reserved.
//

import UIKit
import CoreBluetooth

class Bluetooth_connection: UIViewController,UITableViewDelegate {
    var peripherals:[CBPeripheral] = []
    var centralManager: CBCentralManager?

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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        //print(peripheral)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scanBLE()
    }
    
    func scanBLE(){
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.stopBLEScan()
        }
    }
    
    func stopBLEScan(){
        centralManager?.stopScan()
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
    }

}

extension Bluetooth_connection: CBCentralManagerDelegate{
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    

    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager?.scanForPeripherals(withServices: nil)
        }
    }
}


