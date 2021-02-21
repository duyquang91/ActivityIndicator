import XCTest
import Combine
@testable import ActivityIndicator

final class ActivityIndicatorTests: XCTestCase {
    
    private var disposeBag = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        disposeBag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = Set<AnyCancellable>()
    }
    
    func testActivityIndicator() {
        var internalDisposeBag = Set<AnyCancellable>()
        var resultCount = 0
        var loadingState = [Bool]()
        let activityIndicator = ActivityIndicator()
        let expectation = XCTestExpectation()
        let requestAction = PassthroughSubject<Void, Never>()
        
        activityIndicator.loading
            .handleEvents(receiveCancel: {
                XCTAssertEqual(loadingState, [false, true, false])
                expectation.fulfill()
            })
            .sink(receiveValue: { value in
                print(value ? "Loading ..." : "Finished")
                loadingState.append(value)
            })
            .store(in: &internalDisposeBag)
        
        requestAction
            .flatMap { Just("API calling").delay(for: .seconds(Int.random(in: 1...3)), scheduler: RunLoop.main) .trackActivity(activityIndicator)
            }.handleEvents(receiveCompletion: { _ in
                XCTAssertEqual(resultCount, 3)
                internalDisposeBag = Set<AnyCancellable>()
            })
            .sink { string in
                resultCount += 1
                print(string)
                if resultCount == 3 { requestAction.send(completion: .finished) }
            }
            .store(in: &disposeBag)
        
        requestAction.send(())
        requestAction.send(())
        requestAction.send(())
        
        wait(for: [expectation], timeout: 5000)
    }
    
    static var allTests = [
        ("testExample", testActivityIndicator),
    ]
}
