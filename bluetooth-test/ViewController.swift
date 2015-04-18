//
//  ViewController.swift
//  bluetooth-test
//
//  Created by Stuart Robinson on 18/04/2015.
//  Copyright (c) 2015 SJR Development. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    let IRTemperatureServiceUUID = CBUUID(string: "89C31B01-5D82-5680-9626-C30219C94FAF")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager!) {

        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            self.statusLabel.text = "Searching for BLE Devices"
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            println("Bluetooth switched off or not initialized")
        }
    }
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        let deviceName = "SensorTag"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            self.statusLabel.text = "Sensor Tag Found"
            
            // Stop scanning
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            self.statusLabel.text = nameOfDeviceFound
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        self.statusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.statusLabel.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }


}

