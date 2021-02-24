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
    
    func testErrorIndicator() {
        enum TestError: Error {
            case error
        }
        
        var errors = [Error]()
        let errorIndicator = ErrorIndicator()
        
        let relay1 = PassthroughSubject<Int, Error>()
        let relay2 = PassthroughSubject<Int, Error>()
        let relay3 = PassthroughSubject<Int, Error>()
        
        relay1.trackError(errorIndicator)
            .sink { value in
                print(value)
            }
        
        relay2.trackError(errorIndicator)
            .sink { value in
                print(value)
            }
        
        relay3.trackError(errorIndicator)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTAssertEqual(errors.count, 3)
                default:
                    break
                }
            }, receiveValue: { value in
                print(value)
            })

        errorIndicator.errors
            .sink { error in
                errors.append(error)
            }
        
        relay1.send(completion: .failure(TestError.error))
        relay2.send(completion: .failure(TestError.error))
        relay3.send(completion: .failure(TestError.error))

    }
    
    static var allTests = [
        ("testActivityIndicator", testActivityIndicator), ("testErrorIndicator", testErrorIndicator)
    ]
}
