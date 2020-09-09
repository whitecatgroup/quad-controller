//
//  kUtils.swift
//

import UIKit
import CoreLocation

typealias kCallback = ()->()
typealias kCallbackWithState = (Bool)->()
typealias kCallbackWithStateAndData = (Bool, [AnyObject])->()
typealias kCallbackWithResult = ()->(Bool)
typealias kCallBackWithParams = ([Any?])->()
typealias kCallBackWithParamsAndResult = ([Any?]) -> Bool

extension UIView
{
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView?
    {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

public extension NSDate
{
    public class func ISOStringFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.stringFromDate(date).stringByAppendingString("Z")
    }
    
    public class func dateFromISOString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.dateFromString(string)!
    }
}

extension UIImage
{
    func scaleImage(scaledToSize size: CGSize) -> UIImage!
    {
        //avoid redundant drawing
        if (CGSizeEqualToSize(self.size, size))
        {
            return self
        }
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //draw
        self.drawInRect(CGRectMake(0.0, 0.0, size.width, size.height))
        
        //capture resultant image
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //return image
        return image
    }
}

extension Character
{
    func isNumber() -> Bool
    {
        let nums = "0123456789"
        
        for (var i: Int = 0; i < 10; ++i)
        {
            if (self == nums[i])
            {
                return true
            }
        }
        
        return false
    }
}

extension String
{
    
    func writeToDocumentsDir(filename: String)
    {
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(filename);
            
            //writing
            do {
                kLog("Saving file to documents dir: " + path)
                try self.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                kLog("Failed to write file to documents dir: " + path)
            }
        }
    }
    
    func contains(char: Character) -> Bool
    {
        for (var i = 0; i < self.characters.count; ++i)
        {
            if (self[i] == char)
            {
                return true
            }
        }
        
        return false
    }
    
    func contains(other: String) -> Bool
    {
        var start = startIndex
        
        repeat {
            let subString = self[Range(start: start++, end: endIndex)]
            if subString.hasPrefix(other)
            {
                return true
            }
            
        } while (start != endIndex)
        
        return false
    }
    
    func containsIgnoreCase(other: String) -> Bool
    {
        var start = startIndex
        
        repeat {
            let subString = self[Range(start: start++, end: endIndex)].lowercaseString
            if subString.hasPrefix(other.lowercaseString)
            {
                return true
            }
            
        } while (start != endIndex)
        
        return false
    }
    
    // MARK: - sub String
    func substringToIndex(index: Int) -> String
    {
        return self.substringToIndex(self.startIndex.advancedBy(index))
    }
    
    func substringFromIndex(index: Int) -> String
    {
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
    
    func substringWithRange(range: Range <Int>) -> String
    {
        let start = self.startIndex.advancedBy(range.startIndex)
        let end = self.startIndex.advancedBy(range.endIndex)
        return self.substringWithRange(start ..< end)
    }
    
    subscript(index: Int) -> Character
    {
            return self[self.startIndex.advancedBy(index)]
    }
    
    subscript(range: Range <Int>) -> String
    {
            let start = self.startIndex.advancedBy(range.startIndex)
            let end = self.startIndex.advancedBy(range.endIndex)
            return self[start ..< end]
    }
    
    // MARK: - replace
    func replaceCharactersInRange(range: Range <Int>, withString: String!) -> String
    {
        let result: NSMutableString = NSMutableString(string: self)
        result.replaceCharactersInRange(NSRange(range), withString: withString)
        return result as String
    }
    
    // MARK: find characted in the string
    public func indexOfCharacter(char: Character) -> Int {
        if let idx = self.characters.indexOf(char)
        {
            return self.startIndex.distanceTo(idx)
        }
        return -1
    }
    
    // MARK: Base64 encode
    func base64Encoded() -> String
    {
        let plainData = dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData!.base64EncodedDataWithOptions(NSDataBase64EncodingOptions())
        let encoded = NSString(data: base64String, encoding: NSUTF8StringEncoding)
       return encoded as! String
    }
    
    // MARK: Base64 Decode
    func base64Decoded() -> String
    {
        let decodedData = NSData(base64EncodedString: self, options:NSDataBase64DecodingOptions(rawValue: 0))
        let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding)
        return decodedString as! String
    }
    
    func isDecimal() -> Bool
    {
        let regex = try! NSRegularExpression(pattern: ".*[^0-9].*", options: [])
        return (regex.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) == nil)
    }
}

internal enum kDeviceType
{
    case iPhone4, iPhone5, iPhone6, iPhone6Plus, iPad, iPadRetina, Unknow
    
    func getDeviceName() -> String
    {
        switch self
        {
        case .iPhone4: return "iPhone 4"
        case .iPhone5: return "iPhone 5"
        case .iPhone6: return "iPhone 6"
        case .iPhone6Plus: return "iPhone 6 Plus"
        case .iPad: return "iPad"
        case .iPadRetina: return "iPad Retina"
        default: return "Unknow"
        }
    }
    
    // relatively to iPhone 5
    func getRatio() -> CGFloat
    {
        switch self
        {
        case .iPhone4: return 0.5
        case .iPhone5: return 1.0
        case .iPhone6: return 0.5
        case .iPhone6Plus: return 0.5
        case .iPad: return 0.05
        case .iPadRetina: return 0.1
        default: return 1.0
        }
    }
}

private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
    /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
    /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
    /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone 6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
    /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
    /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
    /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
    /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
    /* iPad Air 2 */      "iPad5,1": "iPad Air 2", "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
    /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad Mini", "iPad4,5": "iPad Mini", "iPad4,6": "iPad Mini",
    /* iPad Mini 3 */     "iPad4,7": "iPad Mini", "iPad4,8": "iPad Mini", "iPad4,9": "iPad Mini",
    /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]


func kGetDeviceType(ScreenBounds size: CGRect) -> kDeviceType
{
    if ((size.width == 320) && (size.height == 480)) || ((size.height == 320) && (size.width == 480))
    {
        return kDeviceType.iPhone4
    } else if ((size.width == 320) && (size.height == 568)) || ((size.height == 320) && (size.width == 568)) {
        return kDeviceType.iPhone5
    } else if ((size.width == 768) && (size.height == 1024)) || ((size.height == 768) && (size.width == 1024)) {
        return kDeviceType.iPad
    } else if ((size.width == 1536) && (size.height == 2048)) || ((size.height == 1536) && (size.width == 2048)) {
        return kDeviceType.iPadRetina
    } else {
        return kDeviceType.Unknow
    }
}

var kNumberFormatter: NSNumberFormatter
{
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    return formatter
}

var kCurrencyFormatter: NSNumberFormatter
{
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    return formatter
}

var kDateFormatter: NSDateFormatter
{
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .MediumStyle
    return formatter
}

func kIsFileExists(FileName f: String) -> Bool
{
    let paths = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
    
    let getFilePath = paths.URLByAppendingPathComponent(f)
    
    let checkValidation = NSFileManager.defaultManager()
    
    return checkValidation.fileExistsAtPath(getFilePath.path!)
}

func kApplicationDocumentsDirectory() -> NSURL
{
    var documentsDirectory:String?
    var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
    if paths.count > 0 {
        if let pathString = paths[0] as? NSString {
            documentsDirectory = pathString as String
        }
    }
    
    return NSURL(string: documentsDirectory!)!
}

func kLog(message: String)
{
    //#if DEBUG
    print(/*NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .LongStyle), ": " + */message)
    //#endif
    
}

func kSegue(fromView: UIViewController, toView: String)
{
    fromView.performSegueWithIdentifier(toView, sender: fromView)
}

func kNavigate(fromView: UIViewController, toView: String, animated: Bool = true)
{
    let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let vc: UIViewController = sb.instantiateViewControllerWithIdentifier(toView) 
    fromView.presentViewController(vc, animated: animated, completion: nil)
}

func kShowMessage(Title t: String, Text t2: String, Delegate: AnyObject!)
{
    let alert = UIAlertView()
    
    alert.title = t
    alert.message = t2
    alert.addButtonWithTitle("OK")
    alert.cancelButtonIndex = 0
    alert.delegate = Delegate
    alert.show()
}

func kShowMessageAndPopBack(Title t: String, Text t2: String, ViewController: UIViewController!, animated: Bool = true)
{
    kShowMessage(Title: t, Text: t2, Delegate: ViewController.navigationController)
    
    ViewController.navigationController?.popToRootViewControllerAnimated(animated)
}

func kBoolToString(b: Bool) -> String
{
    return b ? "true" : "false"
}

func kStringToBool(b: String) -> Bool
{
    return (b == "true") ? true : false
}

func kStringToInt(s: String) -> Int
{
    return Int(s)!
}

func kBoolToInt(b: Bool) -> Int
{
    return b ? 1 : 0
}

func kIntToBool( b: Int ) -> Bool
{
    return (b == 1) ? true : false
}

func kIntToString(x: Int) -> String
{
    return NSString(format: "%i", x) as String
}

func kIntToString(x: Int32) -> String
{
    return NSString(format: "%i", x) as String
}

func kFloatToString(x: Float) -> String
{
    return NSString(format: "%f", x) as String
}

func kCurrencyToString(x: Double) -> String
{
    return NSString(format: "%.2f", x) as String
}

func kShortFloatToString(x: Double) -> String
{
    return NSString(format: "%.1f", x) as String
}

func kStringToFloat(s: String) -> Double
{
    return (s as NSString).doubleValue
}

func kGetPrimaryColor() -> UIColor
{
    return UIColor(red: 120/255, green: 220/255, blue: 254/255, alpha: 1.0)
}

func kGetCharCode(Char: Character) -> Int
{
    let characterString = String(Char)
    let scalars = characterString.unicodeScalars
    
    return Int(scalars[scalars.startIndex].value)
}

func kLoadTextFile(FileName f: String) -> String?
{
    let path = kApplicationDocumentsDirectory().path! + "/" + f
    var s: String?
    //reading
    do {
        s = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
    catch {/* error handling here */}
    return s
}

func kDistance(from from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance
{
    let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
    return from.distanceFromLocation(to)
}

func kIntInRange(value: Int, min: Int, max: Int) -> Bool
{
    return ((value >= min) && (value <= max))
}

func kFloatInRange(value: Float, min: Float, max: Float) -> Bool
{
    return ((value >= min) && (value <= max))
}

func kRandomStringWithLength (len : Int, charset: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> NSString
{
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i = 0; i < len; ++i)
    {
        let length = UInt32 (charset.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", charset.characterAtIndex(Int(rand)))
    }
    
    return randomString
}

// Makes button's corners rounded
func kRoundButton(button: UIButton, color: UIColor = kGetPrimaryColor(), radius: CGFloat = 5.0)
{
    button.layer.borderWidth = 1.0
    button.layer.cornerRadius = radius
    button.layer.borderColor = color.CGColor
    button.clipsToBounds = true
}

// Makes image's corners rounded
func kRoundImage(image: UIImageView, ratio: CGFloat = 2.0)
{
    image.layer.cornerRadius = image.frame.width / ratio
    image.clipsToBounds = true
}

func kGetIOS() -> Float
{
    return (UIDevice.currentDevice().systemVersion as NSString).floatValue
}

func kGetDayOfWeek(todayDate: NSDate)->Int
{
    var day = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: todayDate).weekday - 2
    
    if (day < 0)
    {
        day = 7 + day
    }
    
    return day
}

func kCallNumber(number: String)
{
    UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + number)!)
}

func kIsDateLater(laterDate: NSDate, earlierDate: NSDate) -> Bool
{
    return (laterDate.compare(earlierDate) == NSComparisonResult.OrderedDescending)
}

func kGetTimeFromDate(date: NSDate) -> String
{
    let timeFormatter = NSDateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    
    return timeFormatter.stringFromDate(date)
}

func kGetDateFromDate(date: NSDate) -> String
{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd MMM, yyyy"
    
    return dateFormatter.stringFromDate(date)
}

func kDeleteFile(filename: String)
{
    if (kIsFileExists(FileName: filename))
    {
        let paths = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        
        let getFilePath = paths.URLByAppendingPathComponent(filename)
        
        let manager = NSFileManager.defaultManager()
        
        do {
            try manager.removeItemAtPath(getFilePath.path!)
        } catch _ {
        }
    }
}

func kPopBackMultiply(controller: UIViewController, count: Int)
{
    let viewControllers: [UIViewController] = controller.navigationController!.viewControllers ;
    controller.navigationController!.popToViewController(viewControllers[viewControllers.count - count], animated: true);
}

func kGetNiceRed() -> UIColor
{
    return UIColor(red: 215/255, green: 0.0, blue: 0.0, alpha: 1.0)
}

func kGetNiceGreen() -> UIColor
{
    return UIColor(red: 0.0, green: 128/255, blue: 0.0, alpha: 1.0)
}

func kGetNiceBlue() -> UIColor
{
    return UIColor(red: 0, green: 128/255, blue: 1.0, alpha: 1.0)
}

func kCompareLocations(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> Bool
{
    return (a.latitude == b.latitude) && (a.longitude == b.longitude)
}

func kRenderImageToColorView(view: UIView, image: UIImage) -> UIColor
{
    UIGraphicsBeginImageContext(view.frame.size);
    image.drawInRect(view.bounds)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIColor(patternImage: image)
}
