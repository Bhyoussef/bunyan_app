# update_checker

Flutter plugin to check updates for android and ios 


## Getting Started

Add this to pubspec.yaml

```dart
dependencies:
  update_checker: ^0.0.1
```

### Usage

```dart
 void initState() {
    super.initState();
    var checker = UpdateChecker(); // create an object from UpdateChecker

    //check your OS if android pass the play store URL and so do iOS
    if (Platform.isIOS) {
      checker.checkForUpdates("YOUR_APP_STORE_URL").then((value) => {
            // if value is true you can show a dialog to redirect user to app store to perform update
          });
    } else if (Platform.isAndroid) {
      checker
          .checkForUpdates(
            "YOUR_PLAY_STORE_URL",
          )
          .then((value) => {
                // if value is true you can show a dialog to redirect user to play store to perform update
              });
    }
  }
```
### Contributing 

We Accept the following contributions
* Reporting issues
* bug fixing

## Maintainers
developer.ahmedhamdy@gmail.com

