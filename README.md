# DG Gist
### *It`s about Leave your comment to contribute...*

##### Available on: 

[![qOIdva.th.png](https://iili.io/qOIdva.th.png)](https://freeimage.host/br)

## Description

Leave your comment in the community, with this application it is possible through incredible resources and a pleasant and intuitive interface to send comments in a Gist hosted on GitHub. All of this in an innovative way through a QRCode is from the camera of your iPhone.
And yes, you can identify yourself using your existing GitHub login.

## Installation

This project uses cocoapods as a dependency manager. You must have it previously installed, just run the command on your Mac terminal $ sudo gem install cocoapods 

```bash
$ sudo gem install
```
After open PodFile in your Xcode project directory and make sure it looks like this:

```bash
# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
inhibit_all_warnings!

target 'GistApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	pod 'Alamofire', '~> 5.2'
	pod 'Kingfisher', '~> 6.0'
	pod 'lottie-ios'
	pod 'TransitionButton'
  # Pods for GistApp

end
```
Now you can install the dependencies in your project:

```bash
$ pod install
```

Now you can clean and rebuild your project, all previously imported dependencies must work.

Very Important
:   target plataform is 12.0 above

## Usage samples
![alt-text](https://github.com/ianfagundes84/dggistapp/blob/main/launching.gif?raw=true)

## Support

Please feel confortable to send a message on email ianfag@icloud.com

## Project status

Completed Project.

## Contributing

Suggestions, doubts and complaints are welcome contributions in order to make the application functional and intuitive for the user.


