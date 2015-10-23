import UIKit
import CoreBluetooth
class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    @IBOutlet weak var tableView: UITableView!
    //Add Device
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    
    //Store All Bluetooth Device Around
    var deviceList:NSMutableArray = NSMutableArray()
    //UUID of Service and Characteristic
    let kServiceUUID = [CBUUID(string:"2220")]
    let kCharacteristicUUID = [CBUUID(string:"2221")]
    
    //  ******Shuoqi - global variables  *******************************************************************************
    var timer = NSTimer()
    var indexOfRowFromArduinoDataFile: Int = 1
    var totalNumberOfRowInFile: Int = 0
    var timerInitialization : Int = 0
    var arduinoDataInString: [String] = ["0"]
    //  ****************************************************************************************************************
    
    
    
    //  ******Shuoqi- colorButtons *************************************************************************************
    @IBOutlet weak var colorButton1: CustomDrawnCircleView!
    @IBOutlet weak var colorButton2: CustomDrawnCircleView!
    @IBOutlet weak var colorButton3: CustomDrawnCircleView!
    @IBOutlet weak var colorButton4: CustomDrawnCircleView!
    @IBOutlet weak var colorButton5: CustomDrawnCircleView!
    @IBOutlet weak var startButton: UIButton!
    
    //  ****************************************************************************************************************
    override
    
    
    func viewDidLoad() {
        super.viewDidLoad()
        //Create A Central Manager
        self.manager = CBCentralManager(delegate: self, queue: nil)
        
        // NOTICE: To run the project, enter the the file location as a string down below!!!!
        let fileLocation: String = "/Users/xuehanyu/Downloads/RunRiteApp-master/data.txt"
        
//        arduinoDataInString = readArduinoDataFromFile(fileLocation)
        
        
        //  ******Shuoqi - initialize the color of the colorButtons *********************************************************
        colorButton1.fillColor = UIColor.whiteColor()
        colorButton2.fillColor = UIColor.whiteColor()
        colorButton3.fillColor = UIColor.whiteColor()
        colorButton4.fillColor = UIColor.whiteColor()
        colorButton5.fillColor = UIColor.whiteColor()
    }
    //  ****************************************************************************************************************
    
    //  ******Shuoqi - read data from file *******************************************************************************
    func readArduinoDataFromFile(fileLocation: String) -> [String]{
        
        // Read in the data from the file.
        //  Remember to enter the location of your test file.
        let location = NSString(string: fileLocation).stringByExpandingTildeInPath
        let fileContent = try? NSString(contentsOfFile: location, encoding: NSUTF8StringEncoding)
        
        
        // Convert the read-in data from NSString to String
        let fileContentString = fileContent as! String
        // Seperate each number by filtering the comma.However, the data sorting process is still not complete.
        // We still need to get rid of "\n" and "\r"
        let intermediateArray = fileContentString.componentsSeparatedByString(",")
        
        // Create two new arrays
        var receptor: [String] = ["0"]  // receptor array is used to temporarily store the two numbers sandwitching /n and /r
        var copycat: [String] = ["0"]   // copycat array takes in the two numbers by inserting them to the original fileContentString Array
        var arduinoDataInString: [String] = ["0"]
        // Initialize copycat array
        copycat[0] = intermediateArray[0]
        
        // Using for loop to get the string type array (copycat) free from the unwanted string "\r\n".
        for i in 2...intermediateArray.count {
            receptor = intermediateArray[i-1].componentsSeparatedByString("\r\n")
            if receptor.count == 2 {    // If there is the string "\r\n"" sandwiched between two numbers, then receptor will receive two entries, one for each number on either side of "\r\n"
                copycat.append(receptor[0])
                copycat.append(receptor[1])
            }else{                      // If there "\r\n" is not sandwiched between numbers, then the copycat array can directly append the number from the corresponding entry in the intermediateArray.
                copycat.append(intermediateArray[i-1])
            }
        }
        
        arduinoDataInString = copycat
        totalNumberOfRowInFile = Int(copycat.count/5)
        
        for i in 1...copycat.count{
            arduinoDataInString[i-1] = copycat[i-1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        
        return arduinoDataInString
        
    }
    //  ****************************************************************************************************************
    
    
    
    
    
    //  ******Shuoqi - initialize timer when pressing the startButton **************************************************
    
    @IBAction func startButton(sender: UIButton) {
        // Press the start button, the timer will start, refresing the color every 0.2 second.
        timer = NSTimer(timeInterval: 0.1, target: self, selector: "countUp", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
    }
    //  ****************************************************************************************************************
    
    
    //  ******Shuoqi - createRandomColor (Useless right now) ***********************************************************
    func createRGBColor() -> UIColor{
        //            read in the files here.
        
        let myRed = CGFloat(Float((arc4random_uniform(255) + 1))/255)
        let myGreen = CGFloat(Float((arc4random_uniform(255) + 1))/255)
        let myBlue = CGFloat(Float((arc4random_uniform(255) + 1))/255)
        
        let myRandomColor = UIColor(
            red:myRed,
            green:myGreen,
            blue:myBlue,
            alpha:1.0)
        
        print("red is \(myRed), green is \(myGreen), and blue is \(myBlue).")
        
        return myRandomColor
    }
    //  ****************************************************************************************************************
    
    //  ********Shuoqi - Create timer loop *****************************************************************************
    func countUp() {
        
        // Every time func countUP is called, the global variable indexOfRowFromArduinoDataFile increase by one
        indexOfRowFromArduinoDataFile += 1
        
        // When reaching to the end row of the file, jump back to the first row and go through the data again
        if indexOfRowFromArduinoDataFile >= totalNumberOfRowInFile {
            indexOfRowFromArduinoDataFile = 0
        }
        
        // Print out the row that the program is currently pulling data from
        print(indexOfRowFromArduinoDataFile)
        
        // Call func changeButtonColor
        changeButtonColor(arduinoDataInString, rowNumber: indexOfRowFromArduinoDataFile)
        
    }
    
    
    //  ******Shuoqi - Change the fill in Color of the circles according to the data. ************************************
    
    func changeButtonColor(rawDataFromFile: [String], rowNumber: Int){
        
        
        
        // Assign a weired initial number to the dataValueOfButtons variables so that if something goes wrong we can check it out.
        
        var dataValueOfButton1: Int = 2222
        var dataValueOfButton2: Int = 2222
        var dataValueOfButton3: Int = 2222
        var dataValueOfButton4: Int = 2222
        var dataValueOfButton5: Int = 2222
        
        // Use k as the increment in the followng for loop.
        var k:Int = 1
        
        
        
        for i in (((rowNumber - 1) * 5) + 1)...(rowNumber * 5){
            
            if k == 1 {
                dataValueOfButton1 = Int(rawDataFromFile[i-1])!  // Convert the strings in the rawDataFile to number
                
            }else if k == 2 {
                dataValueOfButton2 = Int(rawDataFromFile[i-1])!  // Convert the strings in the rawDataFile to number
                
            }else if k == 3 {
                dataValueOfButton3 = Int(rawDataFromFile[i-1])!  // Convert the strings in the rawDataFile to number
            }
            else if k == 4 {
                dataValueOfButton4 = Int(rawDataFromFile[i-1])!  // Convert the strings in the rawDataFile to number
            }
            else if k == 5 {
                dataValueOfButton5 = Int(rawDataFromFile[i-1])!  // Convert the strings in the rawDataFile to number
            }else{
                print("Error when assigning number to dataValueOfButton: The loop circles more than 5 times and the value of k exceeds 5. Check the first switch statment in the func changeButtonColor")
            }
            k = k+1  // Increase k by one.
            
        }
        
        // Print out the Data value for convenience
        print("button1: \(dataValueOfButton1), button2: \(dataValueOfButton2),button3: \(dataValueOfButton3),button4: \(dataValueOfButton4),button5: \(dataValueOfButton5)")
        
        // Show the actual data values on the color buttons.
        colorButton1.setTitle("\(dataValueOfButton1)", forState: .Normal)
        colorButton2.setTitle("\(dataValueOfButton2)", forState: .Normal)
        colorButton3.setTitle("\(dataValueOfButton3)", forState: .Normal)
        colorButton4.setTitle("\(dataValueOfButton4)", forState: .Normal)
        colorButton5.setTitle("\(dataValueOfButton5)", forState: .Normal)
        
        // The following code is not needed, only to give useful information when an error occur
        if dataValueOfButton1 == 2222 && dataValueOfButton2 == 2222 {
            print("Error when asssigning numbers to the dataValueOfButtonk variables. Check the for loop in func changeButtonColor")
        }
        
        
        // Using variables to store the RGB colors returned in tuple by the function determineRGBColorAccordingtoData
        for j in 1...5{
            
            switch j{
            case 1:
                var rgbOfButton1 = determineRGBColorAccordingtoData(dataValueOfButton1)
                
                let newColorButton1 = UIColor(
                    red:rgbOfButton1.red,
                    green:rgbOfButton1.green,
                    blue:rgbOfButton1.blue,
                    alpha:1.0)
                
                colorButton1.fillColor = newColorButton1
                colorButton1.setNeedsDisplay()
                
            case 2:
                var rgbOfButton2 = determineRGBColorAccordingtoData(dataValueOfButton2)
                
                let newColorButton2 = UIColor(
                    red:rgbOfButton2.red,
                    green:rgbOfButton2.green,
                    blue:rgbOfButton2.blue,
                    alpha:1.0)
                
                colorButton2.fillColor = newColorButton2
                colorButton2.setNeedsDisplay()
                
            case 3:
                var rgbOfButton3 = determineRGBColorAccordingtoData(dataValueOfButton3)
                
                let newColorButton3 = UIColor(
                    red:rgbOfButton3.red,
                    green:rgbOfButton3.green,
                    blue:rgbOfButton3.blue,
                    alpha:1.0)
                
                colorButton3.fillColor = newColorButton3
                colorButton3.setNeedsDisplay()
                
            case 4:
                var rgbOfButton4 = determineRGBColorAccordingtoData(dataValueOfButton4)
                
                let newColorButton4 = UIColor(
                    red:rgbOfButton4.red,
                    green:rgbOfButton4.green,
                    blue:rgbOfButton4.blue,
                    alpha:1.0)
                
                colorButton4.fillColor = newColorButton4
                colorButton4.setNeedsDisplay()
                
            case 5:
                var rgbOfButton5 = determineRGBColorAccordingtoData(dataValueOfButton5)
                
                let newColorButton5 = UIColor(
                    red:rgbOfButton5.red,
                    green:rgbOfButton5.green,
                    blue:rgbOfButton5.blue,
                    alpha:1.0)
                
                colorButton5.fillColor = newColorButton5
                colorButton5.setNeedsDisplay()
            default:
                print("Error happen in the switch statement in thefunction changeButtonColor: a button with number other than 1,2,3,4,5 is specified")
                
            }
        }
    }
    //  ****************************************************************************************************************
    
    //  ***********Shuoqi -  fetch data from the file and calcualte the desirable RGB value*****************************
    func determineRGBColorAccordingtoData(dataValue: Int) ->  (red: CGFloat, green: CGFloat, blue: CGFloat) {
        // deep blue is 0 deep red is 100
        // 0 -> 50 Blue 50 -> 100 red
        // timer every 0.1 second return a tuple so the five circles can independently change color.
        // red(r:255 does not change; g = b = 30) <- (very red) to (r:255 does not change; g = b = 255) <- almost white
        // blue(b: 255 does not change, r=g=90) <- (pretty blue) to (b: 255 does not change, r=g=255) <- (almost white)
        
        // Determine whether to show color blue or red depending on the actual value of the data.
        // If the value of data is smaller than 50, show blue; if bigger than 50, then show red.
        // Assumption: data value from Arduino range from 0 to 100
        var blueOrRed: String
        
        // Initialize the variables
        var red: CGFloat = 255
        var green: CGFloat = 255
        var blue: CGFloat = 255
        
        // Determine actual RGB color based on the range
        if dataValue <= 49 {
            blueOrRed = "blue"
        }else{
            blueOrRed = "red"
        }
        
        switch blueOrRed{
        case "blue": // Notice that I choose only a color range of desirable red and blue. So I have to make extra calculation accordingly.
            red = CGFloat(Float((dataValue * ((255 - 90)/50)) + 90) / Float(255))
            green = red
            blue = CGFloat(255/255)
        case "red":
            red = CGFloat(255/255)
            green = CGFloat(Float(((dataValue - 50) * ((255 - 30)/50)) + 30) / Float(255))
            blue = green
        default:
            print("error happen in the switch statement in the function determineRGBColorAccording to Data: the variable dataValue is either blue or red.")
        }
        
        return(red, green, blue)
        
    }
    //  ****************************************************************************************************************
    
    
    
    
    
    //@HanyuX
    //Check Whether the Device Support Bluetooth
    func centralManagerDidUpdateState(central: CBCentralManager){
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            //Scan All Bluetooth Around
            //If the first parameter of scanForPeripheralsWithServices is nill, that means scan all devices, otherwise other device with kServiceUUID
            //CBCentralManagerScanOptionAllowDuplicatesKey is true means scan device that have same name
            self.manager.scanForPeripheralsWithServices(kServiceUUID, options:[CBCentralManagerScanOptionAllowDuplicatesKey:false])
            print("Bluetooth Open, Start Scan")
        case CBCentralManagerState.Unauthorized:
            print("The Application Has No Right To Use Bluetooth")
        case CBCentralManagerState.PoweredOff:
            print("Bluetooth is closed")
        default :
            print("Central Device Has no Change")
        }
    }
    
    //@HanyuX
    //When Get Device Which We Are Looking For, Stop Scanning
    //The Data Is Stored in advertisementData. Can Use SBAdertisementData To Get The Data.
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
        print(peripheral.description);
        if(!self.deviceList.containsObject(peripheral)){
            self.deviceList.addObject(peripheral)
            self.manager.connectPeripheral(peripheral, options: nil)
        }
        //         self.tableView.reloadData()
    }
    
    //@HanyuX
    //Success To Connect. Start to Scan Service.
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral){
        //Stop Scanning
        self.manager.stopScan()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.peripheral.discoverServices(kServiceUUID)
    }
    
    //@HanyuX
    //Connect Fail
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!){
        print("(error)Fail To Connect Device")
    }
    
    //Scan Characteriscts For A Service
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        if error != nil {
            print("(error) Characteristics")
            return
        }
        var i:Int = 0
        for service in peripheral.services! {      //@han insert '!' here
            print("Find Service:" + service.description)
            i++
            peripheral.discoverCharacteristics(kCharacteristicUUID, forService: service as! CBService)
        }
    }
    
    //@HanyuX
    //Find Characteristics
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!){
        //
        print("Find Services with Chracteristics:" + service.description)
        if (error != nil){
            print("(error) Characteristics")
            return
        }
        
        for  characteristic in service.characteristics!  {
            //Get All Characteriscs. Some are Notify, Some Only Can Be Read, Some For Write                    print("Service:" + peripheral.name! + " ; Characteristics:" + characteristic.UUID.description);
            self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
        }
    }
    
    //@HanyuX
    //No Matter The Data Is For Read Or Notify, Get Them From This Function.
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!,error: NSError!){
        if(error != nil){
            print("(error) Data")
            return
        }
        var dataValue: [Int8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        var data: [Int8] = [0,0,0,0,0];
        characteristic.value!.getBytes(&dataValue, range:NSRange(location: 0, length: 20)) //@han intert !
        var now = 0;
        var strTemp : String = ""
        for index in 0...19{
            if(now >= 5) {   break; }
            if(dataValue[index] == Int8(58)){
                arduinoDataInString.append(strTemp);
                ++now;
                strTemp = ""
            }else{
                strTemp += String(Character(UnicodeScalar(UInt32(dataValue[index]))));
                dataValue[index] -= Int8(48);
                data[now] = data[now]*Int8(10) + dataValue[index];                
            }
        }
        print(data)
        ++totalNumberOfRowInFile;
    }
    
    //@HanyuX
    //Get Information From Bluetooth.
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!){
        if error != nil {
            print("(error) Information ")
        }
        //If Is not The Characteristics We Need
        if characteristic.UUID.isEqual(kCharacteristicUUID) {
            return
        }
        //Start
        if characteristic.isNotifying {
            print("Start Information")
            peripheral.readValueForCharacteristic(characteristic)
        }
        else
        {
            //Stop
            //Disconnect
            self.manager.cancelPeripheralConnection(self.peripheral)
        }
    }
    
    //@HanyuX
    //Write Data
    func writeValue(serviceUUID: String, characteristicUUID: String, peripheral: CBPeripheral!, data: NSData!){
        peripheral.writeValue(data, forCharacteristic: self.writeCharacteristic, type: CBCharacteristicWriteType.WithResponse)
    }
    
    //@HanyuX
    //Chech Whether Write Success
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!){
        if(error != nil){
            print("Fail:(error)")
        }
        else
        {
            print("Success")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView)->Int {
        //#warning Potentially incomplete method implementation.
        //Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)->Int {
        //#warning Incomplete method implementation.
        //Return the number of rows in the section.
        return self.deviceList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
            //PCell
            let cell = tableView.dequeueReusableCellWithIdentifier("FhrCell", forIndexPath: indexPath) as!UITableViewCell
            var device:CBPeripheral=self.deviceList.objectAtIndex(indexPath.row) as! CBPeripheral
            //Title
            cell.textLabel?.text = device.name
            //SubTitle
            cell.detailTextLabel?.text = device.identifier.UUIDString
            return cell
    }
}