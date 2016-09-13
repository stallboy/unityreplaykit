# Replaykit for unity

## Setting

* add Privacy - Microphone Usage Description，Privacy - Camera Usage Descriptiion to info.plist
* add ReplayKit.framework to Build Phases / Link Binary With Libraries
* set Deployment Target 10.0

## Bugs

* tested on ios10 beta, build on xcode8 GM

* can not see cameraPreviewView because RPScreenRecorder.cameraPreviewView == nil

  ​