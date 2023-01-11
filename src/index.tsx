import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-maksimtest' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const Maksimtest = NativeModules.Maksimtest
  ? NativeModules.Maksimtest
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

//export default Maksimtest;

export function multiply(a: number, b: number): Promise<Array<number>> {
  return Maksimtest.multiply(a, b);
}
export function multiply2(s:string): Promise<string> {
  return Maksimtest.multiply2(s);
}
