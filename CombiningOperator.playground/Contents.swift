import RxSwift

let disposeBag = DisposeBag()

print("-----startWith-----")
// 현재 상태의 초기값이 필요할 때 사용
let customer = Observable<String>.of("😐", "🤗", "😪")

customer
    .enumerated()
    .map { index, element in
        element + "고객" + "\(index)"
    }
    // startWith의 위치와 관계없이 항상 먼저 방출됨
    .startWith("owner") // 동일하게 String 타입의 값이 들어가야 함
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("----concat(1)-----")
let customer2 = Observable<String>.of("😐", "🤗", "😪")
let owner = Observable<String>.of("teacher")

let line = Observable
    .concat([owner, customer2]) // Observable 2개를 array에 넣어서 concat으로 표현
    
line
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("----concat(2)-----")
owner
    .concat(customer2)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----concatMap-----")
// 각각의 시퀀스가 다음 시퀀스가 구독되기 전에 합쳐짐
let grade1: [String: Observable<String>] = [
    "1반": Observable.of("😐", "🤗", "😪"),
    "2반": Observable.of("😴", "😆")
]

Observable.of("1반", "2반")
    .concatMap { 반 in
        grade1[반] ?? .empty() // 두개의 시퀀스 append
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----merge(1)-----")
let 강북 = Observable.from(["강북구", "성북구", "동대문구", "종로구"])
let 강남 = Observable.from(["강남구", "강동구", "영등포구", "양천구"])

Observable.of(강북, 강남) // Observable을 감싸는 Observable
    .merge() // 순서를 보장하지 않고 섞여서 나옴
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----merge(2)-----")
Observable.of(강북, 강남)
    // maxConcurrent : 한번에 받아낼 observable의 수
    .merge(maxConcurrent: 1) // 1로 제한했기 때문에, 첫번째로 구독을 시작하게 될 observable이 끝날 때까지 동시에 다른 observable을 실행시키지 않음
    
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----combineLatest(1)-----")
// 여러 텍스트필드를 한번에 관찰하고 값을 결합하거나, 여러 소스들의 상태를 볼 때 주로 사용됨
let lastName = PublishSubject<String>()
let firstName = PublishSubject<String>()

let fullName = Observable
    .combineLatest(firstName, lastName) { firstName, lastName in
        firstName + lastName
    }

fullName
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

lastName.onNext("홍")
firstName.onNext("길동")
firstName.onNext("민경")
lastName.onNext("노") // 가장 마지막에 발생한 lastName과 결합
lastName.onNext("김")

print("-----combineLatest(2)-----")
let dateFormat = Observable<DateFormatter.Style>.of(.short, .long)
let todayDate = Observable<Date>.of(Date())

let todayFormat = Observable
    .combineLatest( // 최대 8개의 소스를 넣을 수 있음
        dateFormat,
        todayDate,
        resultSelector: { format, today -> String in
            let dateFomatter = DateFormatter()
            dateFomatter.dateStyle = format
            return dateFomatter.string(from: today)
        }
    )

todayFormat
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----zip-----")
enum judge {
    case win
    case lose
}

let game = Observable<judge>.of(.win, .win, .lose, .win, .lose)
let player = Observable<String>.of("korea", "america", "china", "japan", "france", "denmark")

let gameResult = Observable
    // game과 player 중 하나의 observable이 완료되면 zip 전체가 완료됨
    .zip(game, player) { result, keyPlayer in
        return keyPlayer + " 선수" + " \(result)"
    }

gameResult
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----withLatestFrom1-----")
let shooter = PublishSubject<Void>()
let runner = PublishSubject<String>()

shooter
    .withLatestFrom(runner) // 두번째 obervable
//    .distinctUntilChanged() // 얘를 사용하면 sample과 똑같이 사용할 수 있음
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// shooter가 반드시 이벤트를 발생해야 두번째인 runner의 이벤트로 나타날 수 있음 (그 중에서도 가장 최신의 값을 방출함)
runner.onNext("first run")
runner.onNext("second run")
runner.onNext("third run")

shooter.onNext(Void())
shooter.onNext(Void())

print("-----sample-----")
let start = PublishSubject<Void>()
let playerF1 = PublishSubject<String>()

playerF1
    .sample(start)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// withLatestFrom과 비슷하나 여러번 새로운 이벤트를 출력해도 한번만 방출한다.
playerF1.onNext("first start")
playerF1.onNext("second start")
playerF1.onNext("third start")

start.onNext(Void())
start.onNext(Void())

print("-----amb-----")
// 두가지 시퀀스를 받을 때, 어떤 것을 구독할지 애매모호할 때 사용
let bus1 = PublishSubject<String>()
let bus2 = PublishSubject<String>()

let busStop = bus1.amb(bus2) // 두가지 observable을 모두 구독하나, 이 중에서 어떤 것이든 요소를 먼저 방출하게 되면 나머지에 대해서는 더이상 구독하지 않음

busStop
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

bus2.onNext("버스2-승객0: 👩🏾‍💼") // bus2가 먼저 onNext를 이벤트를 방출했기 때문에
bus1.onNext("버스1-승객0: 🧑🏼‍💼") // bus1에 대한 구독을 보지 않음
bus1.onNext("버스1-승객1: 👨🏻‍💼")
bus2.onNext("버스2-승객1: 👩🏻‍💼")
bus1.onNext("버스1-승객1: 🧑🏻‍💼")
bus2.onNext("버스2-승객2: 👩🏼‍💼")

print("-----switchLatest-----")
let student1 = PublishSubject<String>()
let student2 = PublishSubject<String>()
let student3 = PublishSubject<String>()

let speak = PublishSubject<Observable<String>>()

// 소스 observable(여기서 speak)로 들어온 마지막 시퀀스의 아이템만 구독
let classroom = speak.switchLatest()
classroom
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

speak.onNext(student1) // 들어온 student1에 대한 이벤트만 방출하고 들어오지 않은 student2에 대한 이벤트는 무시
student1.onNext("학생1 : 1")
student2.onNext("학생2 : 1")

speak.onNext(student2) // 최신의 값이 student2가 됨 => student의 이벤트만 방출, 나머지 무시
student2.onNext("학생2 : 2")
student1.onNext("학생1 : 2")

speak.onNext(student3)
student2.onNext("학생2 : 3")
student1.onNext("학생1 : 3")
student3.onNext("학생3 : 1")

speak.onNext(student3)
student1.onNext("학생1 : 4")
student2.onNext("학생2 : 4")
student3.onNext("학생3 : 2")
student3.onNext("학생3 : 3")

print("----------reduce----------")
Observable.from((1...10))
    // 소스 observable의 값이 방출될 때마다 가공
    // observable이 완료되었을 때 결과값을 방출
    .reduce(0, accumulator: { summary, newValue in
        return summary + newValue
    }) // 방식 1
//    .reduce(0, accumulator: +) // 방식 2
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("----------scan----------")
Observable.from((1...10))
    // 매번 값이 들어올 때마다 변형된 현재 상태의 결과값을 방출
    // 따라서 reduce와 동일하게 작동하나 리턴값이 observable임
    .scan(0, accumulator: +)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
