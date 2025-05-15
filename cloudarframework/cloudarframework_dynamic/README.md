# cloudarframework_dynamic

CloudAR is a ar tool library in Swift.

## Features

- AR
- BIM

### Configuration framework

First thing to use CloudAR sdk is to configure the following framework

- CloudAR.framework
- StreamSdk.framework

### Import  CloudAR

```
import CloudAR
```





#### AR

After importing framework, you can use ARModelController class  as subController to show ar view and to position. In this version, only scan position func is enabled

##### EnterPosition

Calling following function  *enterPosition*(). you can scan specific qrcode, downloading from vanjian's ourbim website, to locate current position in engine

```swift
ARModelController.enterPosition(positionType: VJARPositionType)
```

When clicking comfirm position button, ARModelController will to show view automatically, then you can inherit VJARPositionProtocol to listen position finish event.

##### Protocol

- ARPositionProtocol

  this protocol has two func <u>handleConfirmPosition()</u>  and  handleConfirmPosition() whick is used for listen confirm and cancle event when position

  ```swift
  func handleConfirmPosition(type: CloudAR.car_ARPositionType) {}
  func handleCanclePosition() {}
  ```

- CloudXRConnectProtocol

  this protocol is used to listen connection state with cloudxr. Only establish connection with cloudxr, u can request ar model load

  ```
  func notifyConnect(connected: Bool) {}
  ```

  

#### Agreement

Some datastruct info

