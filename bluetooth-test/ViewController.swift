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
    @IBOutlet weak var valLabel: UILabel!
    
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    let IRTemperatureServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let recieveUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    var tagCharacteristic : CBCharacteristic!
    
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
        
        let deviceName = "UART"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            self.statusLabel.text = "BLE board Found"
            
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
    
    // Check if the service discovered is a valid IR Temperature Service
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        self.statusLabel.text = "Looking at peripheral services"
        for service in peripheral.services {
            let thisService = service as CBService
            if service.UUID == IRTemperatureServiceUUID {
                self.statusLabel.text = "stu"
                // Discover characteristics of IR Temperature Service
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            // Uncomment to print list of UUIDs
            //println(thisService.UUID)
        }
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        // update status label
        self.statusLabel.text = "found some characteristics"
        
        // 0x01 data byte to enable sensor
    
        println(service.characteristics.count)
        self.tagCharacteristic = service.characteristics[0] as CBCharacteristic
        self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: service.characteristics[1] as CBCharacteristic)
        
        // check the uuid of each characteristic to find config and data characteristics
       /*
for charateristic in service.characteristics {
            self.tagCharacteristic = charateristic as CBCharacteristic
            // check for data characteristic
            self.statusLabel.text = self.tagCharacteristic.UUID.UUIDString
            
            
                // Enable Sensor Notification
               // self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
         
                // Enable Sensor
             //  self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
            var enableValue = 0x32
            let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
            self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: self.tagCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
            
        }
*/
        
    }
    
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        self.statusLabel.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    

    @IBAction func sendBlue(sender: AnyObject) {
        println("Attempting to send blue...")
        
        var enableValue2 = 0x31
        let enablyBytes2 = NSData(bytes: &enableValue2, length: sizeof(UInt8))
        self.sensorTagPeripheral.writeValue(enablyBytes2, forCharacteristic: self.tagCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    @IBAction func sendGreen(sender: AnyObject) {
        println("Attempting to send green...")
        
        var enableValue2 = 0x32
        let enablyBytes2 = NSData(bytes: &enableValue2, length: sizeof(UInt8))
        self.sensorTagPeripheral.writeValue(enablyBytes2, forCharacteristic: self.tagCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
 
    @IBAction func sendRed(sender: AnyObject) {
        println("Attempting to send red...")
        
        var enableValue2 = 0x33
        let enablyBytes2 = NSData(bytes: &enableValue2, length: sizeof(UInt8))
         self.sensorTagPeripheral.writeValue(enablyBytes2, forCharacteristic: self.tagCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
        
    }
    
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("got an update")
        
        self.statusLabel.text = characteristic.UUID.UUIDString
        
        if characteristic.UUID == recieveUUID {
            // Convert NSData to array of signed 16 bit values
            let dataBytes = characteristic.value
            println(dataBytes)
            
            
  
            //var out: NSInteger = 0
            //dataBytes.getBytes(&out, length: sizeof(NSInteger))
           // println(out) // ==> 2525
            
            
            var datastring = NSString(data: dataBytes, encoding:NSUTF8StringEncoding)
            println(datastring)
            // Display on the temp label
            self.valLabel.text = datastring
        }
    }
    
    func peripheral(peripheral: CBPeripheral!,
        didUpdateValueForDescriptor descriptor: CBDescriptor!,
        error: NSError!) {
            println("found data update desc")
    }
}

