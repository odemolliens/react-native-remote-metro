# react-native-remote-metro

A tool to scan a QR code containing a metro bundler URL, and load the bundle from it
This lib is meant to be used from the native code, before React load the JS code.
It will handle showing a QRCode reader and switching to the application view after it has loaded.

## Installation

```sh
npm install react-native-remote-metro
```

## Usage

_Currently only for iOS_

### IOS

Inside your AppDelegate :

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // ...


        #if RCT_DEBUG // To prevent this code from being shipped in production environment.

            var remoteMetro: RemoteMetro = RemoteMetro()

            remoteMetro.injectRootViewController()
            remoteMetro.moduleName = "myApp"
            remoteMetro.options = launchOptions
            remoteMetro.injectQrCodeController()
        #endif

        // ...

    }
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
