# ActivityIndicator
![](https://img.shields.io/badge/iOS-13.0%2B-blue) ![](https://img.shields.io/badge/macOS-10.15%2B-blue) ![](https://img.shields.io/badge/watchOS-6.0%2B-blue) ![](https://img.shields.io/badge/tvOS-13.0%2B-blue) ![](https://img.shields.io/badge/Test%20coverage-82.3%25-brightgreen)

Combine version of [RxSwift/ActivityIndicator](https://github.com/ReactiveX/RxSwift/blob/main/RxExample/RxExample/Services/ActivityIndicator.swift) that help us to track the loading state of all publisher, particularly in network request publishers.
## Usage
### Tracking loading states of publishers
Let's declare an instance of **ActivityIndicator** wherever you want to handle the requests (ex: ViewModel):
```swift
let activityIndicator = ActivityIndicator()

/// Recommend to expose the loading state only
var loadingPublisher: AnyPublisher<Bool, Never> {
    activityIndicator.loading.eraseToAnyPublisher()
}
```
Then use the `trackActivity` operator to track the state of request publishers:
```swift
refreshTokenPublisher.trackActivity(activityIndicator)
getUserInfoPublisher.trackActivity(activityIndicator)
```
Now you can handle the loading state on the View component:
```swift
viewModel.loadingPublisher
         .sink { isLoading in
            self.showHUD(isLoading)
         }
```

### Collecting error of publishers in one place
Let's declare an instance of **ErrorIndicator** wherever you want to handle the error of publisher requests (ex: ViewModel):
```swift
let errorIndicator = ErrorIndicator()

/// Recommend to expose the errors only
var errorPublisher: AnyPublisher<Error, Never> {
    errorIndicator.errors.eraseToAnyPublisher()
}
```
Then use the `trackError` operator to track the state of request publishers:
```swift
refreshTokenPublisher.trackError(errorIndicator)
// Can track loading together
getUserInfoPublisher.trackActivity(activityIndicator)
                    .trackError(errorIndicator)
```
Now you can handle the errors in one place such as in the View component:
```swift
viewModel.errorPublisher
         .sink { error in
            self.showErrorPopup(error)
         }
```

## Installation
### Swift Package manager

```
dependencies: [
    .package(url: "https://github.com/duyquang91/ActivityIndicator.git", from: "1.0")
]
```
### How about Cocoapod or Carthage?
The source code is very simple, feel free to copy into your project 🤗

## Distribution
Pull requests are welcome 🤗

## License
Copyright by @duyquang91

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

