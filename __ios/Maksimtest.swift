@objc(Maksimtest)
class Maksimtest: NSObject {

  @objc(multiply:withB:withResolver:withRejecter:)
  func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    //print("123123123");
    resolve(a*b)
  }
}
