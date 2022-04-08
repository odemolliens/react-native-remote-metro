class RemoteMetro: NSObject, QrCodeScannerControllerDelegate {
    var qrViewController: QrCodeScannerController?
    var options:  [UIApplication.LaunchOptionsKey : Any]?
    var moduleName: String
    var mainViewController: UIViewController?
    var window: UIWindow?

    
    override init() {
        self.moduleName = "RemoteMetro"
        self.options = nil
    }

    init(moduleName: String, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.moduleName = moduleName
        self.options = launchOptions
    }
    
    func injectRootViewController(){
        let rootViewController = UIViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
        self.mainViewController = rootViewController
    }

    func injectQrCodeController(){
         let mainStoryboard:UIStoryboard = UIStoryboard(name: "QrCodeScanner", bundle: nil)
        let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "QrCodeScannerController") as! QrCodeScannerController
        qrViewController=rootViewController
        qrViewController?.delegate = self
        
        self.mainViewController?.addChild(rootViewController)
        rootViewController.view.frame = UIScreen.main.bounds
        self.mainViewController?.view.addSubview(rootViewController.view)
    }
    
    func injectRCTView(newHostURL: URL?){
        var jsCodeLocation: URL
        
        if let newHostURL = newHostURL {
            jsCodeLocation = newHostURL
        } else {
            jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackResource:nil)
        }
        
        let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: self.moduleName, initialProperties: nil, launchOptions: self.options)
         
        // Force black background at launch
        rootView.contentView.backgroundColor = UIColor.black
        self.mainViewController?.view = rootView
        self.window?.rootViewController = self.mainViewController
        self.window?.makeKeyAndVisible()
      }
    
    func loadAfterScanning(url: URL) {
        qrViewController?.view.removeFromSuperview()
        self.injectRCTView(newHostURL: url)
    }
    
    func computeHostURL(newHost: String) -> URL {
        var jsCodeLocation: URL

        jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackResource:nil)
         
        let ipPath = Bundle.main.path(forResource: "ip", ofType: "txt")
         
        if let ipPath = ipPath {
          do {
            let ipGuess = try String(contentsOfFile: ipPath, encoding: .utf8).trimmingCharacters(
            in: CharacterSet.newlines)
           
            var replaceUrl: String = String(describing: jsCodeLocation)
            replaceUrl = replaceUrl.replacingOccurrences(of: ipGuess, with: newHost)
              replaceUrl = replaceUrl.replacingOccurrences(of: ":8081", with: "")
            jsCodeLocation = URL(string:String(describing: replaceUrl))!
          } catch {
          }
        }
        
        return jsCodeLocation
    }
    
}
