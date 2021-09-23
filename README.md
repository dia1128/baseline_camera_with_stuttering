# VideoTagged


## Steps to install.
- Download VSCode. xCode and Android Studio 2019.
- Install Flutter and Dart.
    https://flutter.dev/docs/get-started/install
- Install the flutter plugin in android studio
- Install Git
- Install cocoapods
- Install emulator for android device on Visual Studio (for emulator testing).
- Install ios device emulator on xcode.
NOTE: Camera does not work on ios emulator. Emulator does not have that capability.
- Check Flutter doctor to make sure everything is installed.
- Running it on a physical device (ios)
    https://flutter.dev/docs/get-started/install/macos
    https://www.youtube.com/watch?v=Jn7o4Gy3F7Q&t=197s
- In ios directory
```
    pod install
```
- Navigate to https://nodejs.org/en/download/ to install node.js
- Install amplify cli
```
    sudo npm install -g @aws-amplify/cli
```


## Steps to Connect to another backend.
- Remove all connections with current backend
```
    amplify delete
```
- Setup a new amplify backend on AWS
- Pull the backend changes into your new project
- Install Storage
```
    amplify add storage
```
- Amplify will install Auth along with storage 
- Make sure to allow unautheticated logins to your app

## To run and build on a device: Android
- Get all the necessary dependencies. In the root directory run
```
    flutter pub get
```
- Copy the amplify configuration file from the lib folder on the current workstation and move it to the same folder on the new workstation
- Build the debug version for the connected device
```
    flutter run
```
To build the release version of the app on the connected device
```
    flutter run --release
```
- Alternatively you can run inside android studio by clicking the play button in the top bar 
- You can use features such as hot reloading when running the app on a device. Cmd + s will save any changes 
    you made and reload the app display without having to rerun the app.
    
## To run and build on a device: Iphone
- Get all the necessary dependencies. In the root directory run
```
    flutter pub get
```
- Copy the amplify configuration file from the lib folder on the current workstation and move it to the same folder on the new workstation
- Right click your project in Android studio and go to Flutter->Open IOS Module in Xcode
- Go to Runner->Targets->Signing and Capabilities and select the AILA lab account under "Team"
    If that is not an option, choose add an acount and sign in with the lab account. 
    Add a apple development certificate for your computer by clicking the + and choosing apple development
- Run the app through Xcode first to make sure everything is working, then you can run it throuhg Android Studio
- You can use features such as hot reloading when running the app on a device. Cmd + s will save any changes 
    you made and reload the app display without having to rerun the app.
 
## To build a release for the IOS app store
- See https://flutter.dev/docs/deployment/ios for in depth documentation about submitting to the appstore
- Open project in xcode 
- Check modify the version number/build number for the release in Runner->Targets->General
- In Signining and Capabilities, make sure the AILA lab development account is selected
    If not, follow the instructions above to sign into the account
- Go to Product->Archive, this will build the file for app store connect
- When the archive is finished, click on distrubute app. This will upload the archive to app store connect
    If this fails because you don't have the signing certificate, copy it from this machine. The certificate
    is currently located in the home directory.
- Go to appstore connect to submit the new build

## To build a release for the google play store
- See https://flutter.dev/docs/deployment/android for in depth documentation about submitting to the google play store
- Edit the pubspec.yaml file to increase the version number
- Commit project to github repository 
- Go to release workstation and pull the changes
- Create the bundle file
```
    flutter build appbundle
```
   The keystore file for signing should already be on both machines. On the macbook it is located in the home folder
    If you want to build the release on a new machine you need to transfer this keystore file to that machine.
    Then configure the location of that file in the key.properties. See "Reference the keystore from the app" in the flutter documentation
- Sign into the google play console with the lab account and choose the app
- Go to the production tab and choose create new release
- Upload the bundle file from [project]/build/app/outputs/bundle/release/app.aab
- Submit the release

## Troubleshooting : Error when building ios in Xcode
If you're sure you followed the steps correctly you may need to clean your workspace
```
    flutter clean
```
- If that doesn't work, run 
```
    flutter pub get
```
- In ios directory run
```
    pod install
```

## Troubleshooting: Iproxy cannot be verified
- Navigate to the directory containing the flutter SDK
```
    sudo xattr -d com.apple.quarantine flutter/bin/cache/artifacts/usbmuxd/iproxy
```

## Troubleshooting: pod install does not work
- Delete Podfile and Podfile.lock from ios folder and run command in project folder
```
    flutter build ios
```

## Troubleshooting: Unable to install Runner
This is due to your development profile not being trusted and verified
- Make sure your testing device is connected to the internet
- Navigate to settings->general->device management and choose your development profiel
- Trust and verify the development profile
