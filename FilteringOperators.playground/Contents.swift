import RxSwift

let disposeBag = DisposeBag()

print("-----ignoreElements-----")
let igElements = PublishSubject<String>()

igElements
    .ignoreElements()
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)

igElements.onNext("onNext") // ignoreElements는 next 이벤트를 무시하므로 방출 X

igElements.onCompleted() // completed나 error 와 같은 정지 이벤트는 허용

print("-----elementAt-----")
// 특정 인덱스를 방출
let elementAt = PublishSubject<String>()

elementAt
    .element(at: 2) // index = 2
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

elementAt.onNext("index 0")
elementAt.onNext("index 1") 
elementAt.onNext("index 2")
elementAt.onNext("index 3")

print("-----filter-----")
// 특정 조건대로 방출 가능
Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
    .filter { $0 % 2 == 0 } // 짝수만 방출
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----skip-----")
// 첫번째 요소부터 n번째 요소까지 무시할 수 있음
Observable.of("😀", "🥰", "🥲", "😎", "🥳", "😤")
    .skip(5) // 5개 스킵하고 그 다음 요소 방출
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----skipWhile-----")
// 스킵할 로직을 구성하고 해당 로직이 false가 났을 때부터 skip을 그만두고 방출
Observable.of("😀", "🥰", "🥲", "😎", "🥳", "😤", "🥶", "😷", "🤠")
    .skip(while: {
        $0 != "🥶" // 해당 이모지를 기준으로 해당 요소부터 방출
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----skipUntil-----")
// 다른 observable이 실행될 때까지 현재의 observable이 방출하는 모든 이벤트 무시
let skip = PublishSubject<String>()
let until = PublishSubject<String>()

skip // 현재 observable
    .skip(until: until) // 다른 observable
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

skip.onNext("😀")
skip.onNext("🥰")
until.onNext("until")
skip.onNext("🥲")

print("-----take-----")
// skip과 반대 개념, 어떤 요소를 취하고 싶을 사용하는 연산자
Observable.of("😀", "🥰", "🥲", "😎", "🥳")
    .take(3) // 첫번째부터 3번째까지 요소만 방출되고 그 뒤는 무시
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----takeWhile-----")
// 설정한 로직에서 true에 해당하는 값을 방출, false면 무시
Observable.of("😀", "🥰", "🥲", "😎", "🥳")
    .take(while: {
        $0 != "😎"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----enumerated-----")
Observable.of("😀", "🥰", "🥲", "😎", "🥳")
    .enumerated() // index와 element를 같이 표현함 => 방출된 요소의 index를 참고하고 싶을 때 사용
    .takeWhile {
        $0.index < 3 // index가 3이하일 때까지 계속 방출
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----takeUntil-----")
// 트리거가 되는 observable이 구독되기 전까지의 이벤트 값만 방출
let element = PublishSubject<String>()
let takeUntil = PublishSubject<String>()

element
    .take(until: takeUntil) // 트리거가 되는 observable
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

element.onNext("👻")
element.onNext("🤖")
takeUntil.onNext("끝")
element.onNext("🎃")

print("-----distinctUntilChanged-----")
// 연달아 같은 값이 이어질 때 중복된 값을 막아주는 역할
Observable.of("가", "가", "나", "나", "나", "나", "다", "다", "다", "라", "라", "가", "마", "마")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

