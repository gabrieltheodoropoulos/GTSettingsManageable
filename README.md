# GTSettingsManageable

`GTSettingsManageable` is a *Swift protocol*. Custom types that are meant to handle in-app settings and configuration should adopt it and use the provided methods to load, update, delete and perform other operations on settings.

Original settings should exist as a property list file in the app bundle, otherwise the adopting type's properties should come with initial, default values.

Settings file is stored in the Caches directory of the app and it's a *property list (plist)* file.


## Requirements

* The adopting custom type **must conform to** `Codable` protocol.
* Minimum required iOS version: 12.0.

## Integrating GTSettingsManageable

To integrate `GTSettingsManageable` into your projects follow the next steps:

1. Copy the repository URL to GitHub (it can be found by clicking on the *Clone or Download* button).
2. Open your project in Xcode.
3. Go to menu **File > Swift Packages > Add Package Dependency...**.
4. Paste the URL, select the package when it appears and click Next.
5. In the *Rules* leave the default option selected (*Up to Next Major*) and click Next.
6. Finally select the *GTSettingsManageable* package and select the *Target* to add to; click Finish.

## Available API

```
- load()
- loadUsingSettingsFile()
- update()
- delete()
- reset()
- settingsURL()
- toDictionary()
- describeSettings()
```

Read the documentation of each method for more information and details.

## Other Notes

More than one settings files can co-exist to an app. See the `settingsURL()` method's documentation for more information about *naming*. Also, it's recommended to:

1. Use a *singleton class* as the custom type to represent settings. Using a shared instance app-wide makes accessing settings easier, it leads to reduced amount of code, and prevents from potential problems in comparison to having multiple instances of the settings type.
2. *Load* settings in the *AppDelegate* right after the application's launch.

`GTSettingsManageable` is written in Swift 5.1.

Want to learn more? Read my [tutorial at AppCoda](https://www.appcoda.com/swift-protocols-app-configuration/) where I'm building `GTSettingsManageable` protocol step by step.

## License

`GTSettingsManageable` is provided under the [MIT license](https://opensource.org/licenses/MIT) by [Gabriel Theodoropoulos](https://gtiapps.com).
