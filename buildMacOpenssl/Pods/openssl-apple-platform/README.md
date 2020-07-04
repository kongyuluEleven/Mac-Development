# openssl

It is powered by [openssl-apple](https://github.com/Jiar/openssl-apple).

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build openssl.

To integrate openssl into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

target '<Your iOS Target Name>' do
  platform :ios, '8.0'
  pod 'openssl-apple-platform', '1.0.2r'
end

target 'Your macOS Target Name' do
  platform :osx, '10.10'
  pod 'openssl-apple-platform', '1.0.2r'
end

target 'Your tvOS Target Name' do
  platform :tvos, '9.0'
  pod 'openssl-apple-platform', '1.0.2r'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate openssl into your project manually. Drag the specified platform `openssl.framework` in frameworks folder into your project directly.

## Usege

- Swift

```Swift
import openssl

func testRSA() {
  if let rsa = RSA_generate_key(1024, UInt(RSA_F4), nil, nil) {
      print("RSA's bits is: \(BN_num_bits(rsa.pointee.n))")
  }
}
```

- Objective-C

```Objective-C
#import <openssl/openssl.h>

- (void)testRSA {
    RSA* rsa = RSA_generate_key(1024, RSA_F4, nil, nil);
    NSLog(@"RSA's bits is: %d", BN_num_bits(rsa->n));
}
```

## Support

### archs

| platform | archs |
| ------ | ------ |
| iOS | arm64, arm64e, armv7, armv7s, x86_64, i386 |
| macOS | x86_64 |
| tvOS | arm64, x86_64 |

### mini version

| platform | mini version |
| ------ | ------ |
| iOS | 8.0 |
| macOS | 10.10 |
| tvOS | 9.0 |

## License

openssl is released under the Apache-2.0 license. See LICENSE for details.