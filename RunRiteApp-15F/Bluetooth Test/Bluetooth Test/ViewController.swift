



import UIKit
import CoreBluetooth
class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    @IBOutlet weak var tableView: UITableView!
    //添加属性
        var manager: CBCentralManager!
        var peripheral: CBPeripheral!
        var writeCharacteristic: CBCharacteristic!
    
    //保存收到的蓝牙设备
        var deviceList:NSMutableArray = NSMutableArray()
    //服务和特征的UUID
        let kServiceUUID = [CBUUID(string:"2220")]
        let kCharacteristicUUID = [CBUUID(string:"2221")]
    
    //  ******Shuoqi - global variables  *******************************************************************************
    var timer = NSTimer()
    var indexOfRowFromArduinoDataFile: Int = 1
    var totalNumberOfRowInFile: Int = 0
    var timerInitialization : Int = 0
    var arduinoDataInString: [String] = ["0"]
    var ifPaused: Bool = true
    var timerSpeedRate: Float = 1
    
    //  ******Shuoqi- colorButtons *************************************************************************************
    @IBOutlet weak var colorButton1: CustomDrawnCircleView!
    @IBOutlet weak var colorButton2: CustomDrawnCircleView!
    @IBOutlet weak var colorButton3: CustomDrawnCircleView!
    @IBOutlet weak var colorButton4: CustomDrawnCircleView!
    @IBOutlet weak var colorButton5: CustomDrawnCircleView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sliderControl: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var speedStepperLabel: UILabel!
    @IBOutlet weak var stepperControl: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()
        //创建一个中央对象
        self.manager = CBCentralManager(delegate: self, queue: nil)
        
        // NOTICE: To run the project, enter the the file location as a string down below!!!!
        // The following lines of code are blocked out because we are reading the data from a class instead
        
//        let fileLocation: String = "/Users/Shuoqi/Desktop/RunRiteApp-master/400 mile data Heel Running 2.txt"
//        arduinoDataInString = readArduinoDataFromFile(fileLocation)
        
        let retrieveTempDataFromViewController = tempData()
        arduinoDataInString = retrieveTempDataFromViewController.data
        totalNumberOfRowInFile = (arduinoDataInString.count) / 5
        
        sliderControl.minimumValue = 1
        sliderControl.maximumValue = Float(totalNumberOfRowInFile)
        stepperControl.value = 10
        
        
     //  ******Shuoqi - initialize the color of the colorButtons *********************************************************
        colorButton1.fillColor = UIColor.whiteColor()
        colorButton2.fillColor = UIColor.whiteColor()
        colorButton3.fillColor = UIColor.whiteColor()
        colorButton4.fillColor = UIColor.whiteColor()
        colorButton5.fillColor = UIColor.whiteColor()
        
    }

    
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
    //  ******Shuoqi - initialize timer when pressing the startButton **************************************************

    @IBAction func startButton(sender: UIButton) {
        
        switch ifPaused{
        case true:
            initializeTimer()
            indexOfRowFromArduinoDataFile = Int(sliderControl.value)
            ifPaused = false
            startButton.setTitle("Pause", forState: UIControlState.Normal)
        case false:
            resetTimer()
            startButton.setTitle("Resume", forState: UIControlState.Normal)
            ifPaused = true
        }

    }
    
    func initializeTimer() {
        let timeLapse: Double = Double(0.1 * Double(timerSpeedRate))
        
        // Press the start button, the timer will start, refresing the color every 0.2 second.
        timer = NSTimer(timeInterval: timeLapse, target: self, selector: "countUp", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }


    @IBAction func stopButton(sender: UIButton) {
        resetTimer()
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        
        
       let sliderCurrentValue = Float(sender.value)
        
       let currentRowNumber = Int(sliderCurrentValue)
    
        sliderLabel.text = "Row: \(currentRowNumber )"
        
        retrieveDataAccordingToIndexOfRow(currentRowNumber)
        
        resetTimer()
        
        if ifPaused == false {
            startButton.setTitle("Resume", forState: UIControlState.Normal)
            ifPaused = true
        } else if ifPaused == true {
            ifPaused = false
            
        }
        
    }
    
    
    @IBAction func stepperChanged(sender: UIStepper) {
        
        let currentStepValue: Int = Int(sender.value)
        var speedRateDisplayedOnLabel: Float = 0
    
        
        if currentStepValue >= 1 && currentStepValue <= 9 {
            timerSpeedRate = 10 - Float(currentStepValue)
            speedRateDisplayedOnLabel =  Float(currentStepValue) * 0.1
        } else if currentStepValue > 10 && currentStepValue <= 20 {
            timerSpeedRate = 0.1 *  Float(10 - (currentStepValue - 10))
            speedRateDisplayedOnLabel =  Float(currentStepValue - 10)
        } else {
            timerSpeedRate = 1
            speedRateDisplayedOnLabel =  1
        }
        
  
        speedStepperLabel.text = "Speed x \(speedRateDisplayedOnLabel)"
//        speedStepperLabel.text = "rate: \(timerSpeedRate). display:\(speedRateDisplayedOnLabel)"
//
//        
        resetTimer()
        indexOfRowFromArduinoDataFile = Int(sliderControl.value)
        initializeTimer()
        
        
    }
    
    func resetTimer() {
        timer.invalidate()
        indexOfRowFromArduinoDataFile = 1
    }
    
    func retrieveDataAccordingToIndexOfRow(rowNumber: Int){
        
        changeButtonColor(arduinoDataInString, rowNumber: rowNumber)
        

           let dataValueOfButton1 = Int(arduinoDataInString[((rowNumber-1)*5)+0])!
           let dataValueOfButton2 = Int(arduinoDataInString[((rowNumber-1)*5)+1])!
           let dataValueOfButton3 = Int(arduinoDataInString[((rowNumber-1)*5)+2])!
           let dataValueOfButton4 = Int(arduinoDataInString[((rowNumber-1)*5)+3])!
           let dataValueOfButton5 = Int(arduinoDataInString[((rowNumber-1)*5)+4])!
        
        colorButton1.setTitle("\(dataValueOfButton1)", forState: .Normal)
        colorButton2.setTitle("\(dataValueOfButton2)", forState: .Normal)
        colorButton3.setTitle("\(dataValueOfButton3)", forState: .Normal)
        colorButton4.setTitle("\(dataValueOfButton4)", forState: .Normal)
        colorButton5.setTitle("\(dataValueOfButton5)", forState: .Normal)
        print(dataValueOfButton1)
        
        
    }
    
    
    
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
    
    //  ********Shuoqi - Create timer loop *****************************************************************************
    func countUp() {
        
        // Every time func countUP is called, the global variable indexOfRowFromArduinoDataFile increase by one
        indexOfRowFromArduinoDataFile += 1
        
        // When reaching to the end row of the file, jump back to the first row and go through the data again
        if indexOfRowFromArduinoDataFile >= totalNumberOfRowInFile {
            indexOfRowFromArduinoDataFile = 1
        }
        
        // Print out the row that the program is currently pulling data from
        print(indexOfRowFromArduinoDataFile)
        sliderLabel.text = "Row: \(indexOfRowFromArduinoDataFile)"
        sliderControl.value = Float(indexOfRowFromArduinoDataFile)
        
        
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
//        colorButton1.setTitle("\(dataValueOfButton1)", forState: .Normal)
//        colorButton2.setTitle("\(dataValueOfButton2)", forState: .Normal)
//        colorButton3.setTitle("\(dataValueOfButton3)", forState: .Normal)
//        colorButton4.setTitle("\(dataValueOfButton4)", forState: .Normal)
//        colorButton5.setTitle("\(dataValueOfButton5)", forState: .Normal)
        
                colorButton1.setTitle("", forState: .Normal)
                colorButton2.setTitle("", forState: .Normal)
                colorButton3.setTitle("", forState: .Normal)
                colorButton4.setTitle("", forState: .Normal)
                colorButton5.setTitle("", forState: .Normal)

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

    
    //检查运行这个App的设备是不是支持BLE。代理方法
    func centralManagerDidUpdateState(central: CBCentralManager){
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            //扫描周边蓝牙外设.
            //写nil表示扫描所有蓝牙外设，如果传上面的kServiceUUID,那么只能扫描出FFEO这个服务的外设。
            //CBCentralManagerScanOptionAllowDuplicatesKey为true表示允许扫到重名，false表示不扫描重名的。
            self.manager.scanForPeripheralsWithServices(kServiceUUID, options:[CBCentralManagerScanOptionAllowDuplicatesKey:false])
            print("Bluetooth Open, Start Scan")
        case CBCentralManagerState.Unauthorized:
            print("这个应用程序是无权使用蓝牙低功耗")
        case CBCentralManagerState.PoweredOff:
            print("蓝牙目前已关闭")
        default :
            print("中央管理器没有改变状态")
        }
    }

    //查到外设后，停止扫描，连接设备
    //广播、扫描的响应数据保存在advertisementData中，可以通过CBAdvertisementData 来访问它。
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
            print(peripheral.description);
            if(!self.deviceList.containsObject(peripheral)){
                    self.deviceList.addObject(peripheral)
                    self.manager.connectPeripheral(peripheral, options: nil)
            }
   //         self.tableView.reloadData()
    }

    //连接外设成功，开始发现服务
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral){
            //停止扫描外设
            self.manager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            self.peripheral.discoverServices(kServiceUUID)
    }

    //连接外设失败
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!){
            print("连接外设失败===(error)")
    }

    //请求周边去寻找它的服务所列出的特征
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
            if error != nil {
                    print("错误的服务特征:(error.localizedDescription)")
                    return
                }
            var i:Int = 0
            for service in peripheral.services! {      //@han insert '!' here
                print("Find Service:" + service.description)
                    i++
                    //发现给定格式的服务的特性
                    //
//                    if (service.UUID == kServiceUUID) {
//                        //
//                        peripheral.discoverCharacteristics(kCharacteristicUUID, forService: service as CBService)
//                        //
//                    }
                    peripheral.discoverCharacteristics(kCharacteristicUUID, forService: service as! CBService)
            }
    }

    //已搜索到Characteristics
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!){
            //
            print("Find Services with Chracteristics:" + service.description)
            if (error != nil){
                print("发现错误的特征：(error.localizedDescription)")
                    return
            }
        
            for  characteristic in service.characteristics!  {
                    //罗列出所有特性，看哪些是notify方式的，哪些是read方式的，哪些是可写入的。
                    print("Service:" + peripheral.name! + " ; Characteristics:" + characteristic.UUID.description);
                    //特征的值被更新，用setNotifyValue:forCharacteristic
//                    self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
                    self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    switch characteristic.UUID.description {
//                    case "FFE1" :
//                        //如果以通知的形式读取数据，则直接发到didUpdateValueForCharacteristic方法处理数据。
//                        self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    case "2A37" :
//                        //通知关闭，read方式接受数据。则先发送到didUpdateNotificationStateForCharacteristic方法，再通过readValueForCharacteristic发到didUpdateValueForCharacteristic方法处理数据。
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                    case "2A38" :
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                    case "Battery Level":
//                        self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    case "Manufacturer Name String":
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                    case "6E400003-B5A3-F393-E0A9-E50E24DCCA9E":
//                        self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
//                    case "6E400002-B5A3-F393-E0A9-E50E24DCCA9E":
//                        self.peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
//                        self.writeCharacteristic = characteristic as! CBCharacteristic
//                        let heartRate: NSString = "ZhuHai XY"
//                        let dataValue: NSData = heartRate.dataUsingEncoding(NSUTF8StringEncoding)!
//                        //写入数据
//                        self.writeValue(service.UUID.description, characteristicUUID: characteristic.UUID.description, peripheral: self.peripheral, data: dataValue)
//                    default :
//                        break
//                    }
            }
    }

    //获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!,error: NSError!){
            if(error != nil){
                print("发送数据错误的特性是：(characteristic.UUID)     错误信息：(error.localizedDescription)       错误数据：(characteristic.value)")
                    return
            }
            var dataValue: UInt8 = 0
            characteristic.value!.getBytes(&dataValue, range:NSRange(location: 0, length: 1)) //@han intert !
            print(dataValue)

        
//            switch characteristic.UUID.description {
//            case "FFE1":
//                print("=(characteristic.UUID)特征发来的数据是:(characteristic.value)=")
//            case "2A37":
//                print("=(characteristic.UUID.description):(characteristic.value)=")
//            case "2A38":
//                var dataValue: Int = 0
//                characteristic.value!.getBytes(&dataValue, range:NSRange(location: 0, length: 1)) //@han intert !
//                print("2A38的值为:(dataValue)")
//            case "Battery Level":
//                //如果发过来的是Byte值，在Objective-C中直接.getBytes就是Byte数组了，在swift目前就用这个方法处理吧！
//                var batteryLevel: Int = 0
//                characteristic.value!.getBytes(&batteryLevel, range:NSRange(location:0, length:1 )) //@han intert !
//                print("当前为你检测了(batteryLevel)秒")
//            case "Manufacturer Name String":
//                //如果发过来的是字符串，则用NSData和NSString转换函数
//                let manufacturerName: NSString = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
//                print("制造商名称为:(manufacturerName)")
//            case "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" :
//                print("=(characteristic.UUID)特征发来的数据是:(characteristic.value)=")
//            case "6E400002-B5A3-F393-E0A9-E50E24DCCA9E":
//                print("返回的数据是:(characteristic.value)")
//            default :
//                break
//            }
    }
    
    //这个是接收蓝牙通知，很少用。读取外设数据主要用上面那个方法didUpdateValueForCharacteristic。
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!){
            if error != nil {
                print("更改通知状态错误：(error.localizedDescription)")
            }
            print("收到的特性数据：(characteristic.value)")
            //如果它不是传输特性,退出.
            //
            if characteristic.UUID.isEqual(kCharacteristicUUID) {
                return
            }
            //开始通知
            if characteristic.isNotifying {
                print("开始的通知(characteristic)")
                    peripheral.readValueForCharacteristic(characteristic)
            }
            else
            {
                //通知已停止
                //所有外设断开
                print("通知(characteristic)已停止设备断开连接")
                self.manager.cancelPeripheralConnection(self.peripheral)
            }
    }
    
    //写入数据
        func writeValue(serviceUUID: String, characteristicUUID: String, peripheral: CBPeripheral!, data: NSData!){
            peripheral.writeValue(data, forCharacteristic: self.writeCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            print("手机向蓝牙发送的数据为:(data)")
        }
    
    //用于检测中心向外设写数据是否成功
        func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!){
            if(error != nil){
                 print("发送数据失败!error信息:(error)")
            }
            else
            {
                print("发送数据成功(characteristic)")
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
            //PCell,确定单元格的样式
            let cell = tableView.dequeueReusableCellWithIdentifier("FhrCell", forIndexPath: indexPath) as!UITableViewCell
            var device:CBPeripheral=self.deviceList.objectAtIndex(indexPath.row) as! CBPeripheral
            //主标题
                cell.textLabel?.text = device.name
            //副标题
                cell.detailTextLabel?.text = device.identifier.UUIDString
            return cell
    }
    


    
    
//    //通过选择来连接和断开外设
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if(self.peripheralList.containsObject(self.deviceList.objectAtIndex(indexPath.row))){
//                self.manager.cancelPeripheralConnection(self.deviceList.objectAtIndex(indexPath.row) as! CBPeripheral)
//                self.peripheralList.removeObject(self.deviceList.objectAtIndex(indexPath.row))
//                print("蓝牙已断开")
//        }
//        else
//        {
//                self.manager.connectPeripheral(self.deviceList.objectAtIndex(indexPath.row) as! CBPeripheral, options: nil)
//                self.peripheralList.addObject(self.deviceList.objectAtIndex(indexPath.row))
//                print("蓝牙已连接！ (self.peripheralList.count)")
//        }
//    }
}