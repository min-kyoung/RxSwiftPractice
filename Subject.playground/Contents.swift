import RxSwift

let disposeBag = DisposeBag()

print("-----publishSubject-----")
let publishSubject = PublishSubject<String>()

// subject는 observerbla이자 observer이므로 observer의 특성을 가진다.
// 즉, 이벤트를 내뱉을 수 있으머 구독을 해야 의미가 있다.
publishSubject.onNext("1. publish subject ") // subscribe 전이기 때문에 방출 X
    
let publish1 = publishSubject
    .subscribe(onNext: {
        print("publish1 : \($0)")
    })

publishSubject.onNext("2. onNext")
publishSubject.on(.next("3. on(next)"))

publish1.dispose()

// 세가지 이벤트를 방출한 후 구독 시작
let publish2 = publishSubject
    .subscribe(onNext: {
        print("publish2 : \($0)")
    })

publishSubject.onNext("4. onNext ")
publishSubject.onCompleted()

publishSubject.onNext("5. publish2 onCompleted 후 onNext") // 이미 completed 되었기 때문에 방출 X

publish2.dispose()

// 이미 completed된 이후 구독을 시작하고, 구독 이후 onNext
publishSubject
    .subscribe {
        print("publish3 :", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

publishSubject.onNext("6. publish3") // 이미 completed된 observer이기 때문에 방출 X

print("-----behaviorSubject-----")
enum SubjectError: Error {
    case error1
}

let behaviorSubject = BehaviorSubject<String>(value: "초기값") // BehaviorSubject는 반드시 초기값을 가짐

behaviorSubject.onNext("1. 첫번째 값")

behaviorSubject.subscribe {
    print("첫번째 구독 :", $0.element ?? $0) // 구독을 시작하기 직전의 값을 전달해주기 때문에 "초기값"이 아닌 "첫번째 값"을 방출함
}
.disposed(by: disposeBag)

// behaviorSubject.onError(SubjectError.error1)

behaviorSubject.subscribe {
    print("두번째 구독 :", $0.element ?? $0) // 구독을 시작하기 직전에 에러 이벤트가 발생했기 때문에 에러를 그대로 가져옴
}
.disposed(by: disposeBag)

// behaviorSubject의 특징 중 하나가 value 값을 뽑아낼 수 있다는 것
let value = try? behaviorSubject.value()
print(value) // 가장 최신의 onNext 값인 "첫번째 값"을 방출함

print("-----replaySubject-----")
let replaySubject = ReplaySubject<String>.create(bufferSize: 2) // 버퍼 사이즈 선언

replaySubject.onNext("1. onNext")
replaySubject.onNext("2. onNext")
replaySubject.onNext("3. onNext")

replaySubject.subscribe {
    print("첫번째 구독 :", $0.element ?? $0) // 두 개의 이벤트를 가져옴 (버퍼 값 2)
}
.disposed(by: disposeBag)

replaySubject.subscribe {
    print("두번째 구독 :", $0.element ?? $0) // 두 개의 이벤트를 가져옴 (버퍼 값 2)
}
.disposed(by: disposeBag)

replaySubject.onNext("4. onNext")
replaySubject.onError(SubjectError.error1)
replaySubject.dispose()

replaySubject.subscribe {
    print("세번째 구독 :", $0.element ?? $0) // dispose 후 구독했기 때문에 RxSwift 에러 발생
}
.disposed(by: disposeBag)


