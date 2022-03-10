import RxSwift
import RxCocoa
import UIKit
import PlaygroundSupport

let disposeBag = DisposeBag()

print("-----replay-----")
let say = PublishSubject<String>()
let person = say.replay(2)

person.connect()

say.onNext("hello")
say.onNext("hi") // 구독 전 과거의 요소들도 버퍼의 개수만큼 최신 순서대로 받을 수 있음

person
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

say.onNext("bye") // 버퍼의 크기와 관계 없이 구독한 이후 이벤트는 방출됨

print("-----replayAll-----")
let game = PublishSubject<String>()
let player = game.replayAll()

player.connect()

// player이 구독한 시점 이전의 어떠한 값이라도 갯수 제한 없이 나타낼 수 있음
game.onNext("승")
game.onNext("패")

player
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----buffer-----")
let source = PublishSubject<String>()

var count = 0
var timer = DispatchSource.makeTimerSource() // 특정시간마다 함수를 작동시킴

timer.schedule(deadline: .now() + 2, repeating: .seconds(1))
timer.setEventHandler {
    count += 1
    source.onNext("\(count)")
}
timer.resume()

// buffer 연산자는 소스에서 받을 것이 없으면 일정 간격으로 빈 array를 방출

source
    .buffer(
        timeSpan: .seconds(2), // 2초 간격
        count: 2, // 최대 2개를 넘어가지 않는 array
        scheduler: MainScheduler.instance
    )
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

//print("-----window-----")
//// buffer와 다른 점은 buffer는 array를 방출하지만 window는 observable을 방출한다는 점
//
//// 최대 1개의 observable을 만들 시간을 2초로 제한
//let maxObservable = 1
//let makeTime = RxTimeInterval.seconds(2)
//
//let window = PublishSubject<String>()
//
//var windowCount = 0
//let windowTimeSource = DispatchSource.makeTimerSource()
//windowTimeSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
//windowTimeSource.setEventHandler {
//    windowCount += 1
//    window.onNext("\(windowCount)")
//}
//windowTimeSource.resume()
//
//window
//    .window(
//        timeSpan: makeTime,
//        count: maxObservable,
//        scheduler: MainScheduler.instance
//    )
//    // window는 obervable을 내뱉기 때문에 flatMap을 통해 확인
//    .flatMap { windowObservable -> Observable<(index: Int, element: String)> in
//        return windowObservable.enumerated()
//    }
//    .subscribe(onNext: {
//        print("\($0.index)번째 observable의 요소 \($0.element)")
//    })
//    .disposed(by: disposeBag)
//
//print("-----delaySubscription-----")
//let delaySource = PublishSubject<String>()
//
//var delayCount = 0
//let delayTimeSource = DispatchSource.makeTimerSource()
//delayTimeSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
//delayTimeSource.setEventHandler {
//    delayCount += 1
//    delaySource.onNext("\(delayCount)")
//}
//delayTimeSource.resume()
//
//delaySource
//    // delaySource가 이벤트를 방출시킬 때, 2초 정도 delay (즉, 구독을 천천히)
//    .delaySubscription(.seconds(2), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

//print("-----daley-----")
//// 전체 시퀀스를 요소의 방출을 설정한 시간만큼 뒤로 미룸
//
//let delaySubject = PublishSubject<Int>()
//
//var delayCount = 0
//let delayTimeSource = DispatchSource.makeTimerSource()
//delayTimeSource.schedule(deadline: .now(), repeating: .seconds(1))
//delayTimeSource.setEventHandler {
//    delayCount += 1
//    delaySubject.onNext(delayCount)
//}
//delayTimeSource.resume()
//
//// 이벤트는 계속해서 방출되는 것처럼 보이나, 3초가 지난 시점부터 실제로 구독이 시작되고 실제로 이벤트를 방출함
//
//delaySubject
//    .delay(.seconds(3), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

//print("-----interval-----")
//Observable<Int>
//    .interval(.seconds(3), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

//print("-----timer-----")
//Observable<Int>
//    .timer(
//        .seconds(5), // 5초가 지난 후 (dueTime : 구독한 후 첫번째 값 사이의 시간)
//        period: .seconds(2), // 2초 간격으로
//        scheduler: MainScheduler.instance
//    )
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

//print("----------timeout----------")
//let notPushError = UIButton(type: .system)
//notPushError.setTitle("push", for: .normal)
//notPushError.sizeToFit()
//
//PlaygroundPage.current.liveView = notPushError
//
//notPushError.rx.tap
//    .do(onNext: {
//        print("tap")
//    })
//    // 아무런 이벤트가 발생하지 않은 채로ㅜ정해진 시간(5초)을 초과하게 되면 에러를 발생시키고 observable을 종료시킴
//    .timeout(.seconds(5), scheduler: MainScheduler.instance)
//    .subscribe {
//        print($0)
//    }
//    .disposed(by: disposeBag)
