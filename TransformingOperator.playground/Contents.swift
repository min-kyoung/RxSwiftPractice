import RxSwift

let disposeBag = DisposeBag()

print("-----toArray-----")
// observable에 독립적 요소들을 array로 만들 수 있는 가장 편리한 방법
Observable.of("A", "B", "C")
    .toArray() // Single<[String]> : Single로 만들어지고 array로 내뱉음
    .subscribe(onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----map-----")
Observable.of(Date())
    .map { date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("-----flatMap-----")
protocol player {
    var score: BehaviorSubject<Int> { get }
}

struct archer: player {
    var score: BehaviorSubject<Int>
}

let teamKorea = archer(score: BehaviorSubject<Int>(value: 10))
let teamAmerican = archer(score: BehaviorSubject<Int>(value: 8))

let game = PublishSubject<player>()

// flatMap을 통해서 두개의 중첩된 Observable 속에 element를 뽑아낼 수 있음
game
    .flatMap { player in
        player.score
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// game이 player를 받아서 player가 가지고 있는 score에 해당하는 것만 이벤트로 뺄 수 있음
game.onNext(teamKorea)
teamKorea.score.onNext(10)

game.onNext(teamAmerican)
teamAmerican.score.onNext(9)

print("-----flatMapLatest-----")
struct shooting: player {
    var score: BehaviorSubject<Int>
}

let teamSeoul = shooting(score: BehaviorSubject<Int>(value: 7)) // sequence1
let teamJeju = shooting(score: BehaviorSubject<Int>(value: 6)) // sequence2

let sportsGame = PublishSubject<player>()

// 가장 최신의 값만을 확인하고 싶을 때 사용
sportsGame
    .flatMapLatest { player in
        player.score
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

sportsGame.onNext(teamSeoul) // sportsGame이 teamSeoul만을 가지고 있을 때는
teamSeoul.score.onNext(9) // 서울이 계속해서 최신의 값을 나타내도 이 sequence가 최신의 값이기 때문에 계속해서 teamSeoul의 값을 보여줌

sportsGame.onNext(teamJeju) // 새로운 sequence인 teamJeju가 발생한 이후부터는 teamSeoul이 해제됨
teamSeoul.score.onNext(10) // 이미 위에서 onNext로 최신의 값인 9를 방출했기 때문에 변경된 값인 이 10점은 무시됨
teamJeju.score.onNext(8)

print("-----materialize and dematerialize-----")
// observable을 observsble의 이벤트로 변환을 해야할 경우가 생길 수 있다.
// 보통 observable 속성을 가진 observable 항목을 제어할 수 없고 외부적으로 observable이 종료되는 것을 방지하기 위해 error 이벤트를 처리하고 싶을 때 사용한다.
enum error: Error {
    case foul
}

struct runner: player {
    var score: BehaviorSubject<Int>
}

let person1 = runner(score: BehaviorSubject<Int>(value: 0))
let person2 = runner(score: BehaviorSubject<Int>(value: 1))

let track = BehaviorSubject<player>(value: person1)

track
    .flatMapLatest { player in
        player.score
            .materialize() // 이벤트와 이벤트가 가지고 있는 element를 포함하여 방출
    }
    .filter {
        guard let error = $0.error else {
            return true // 에러가 없을 경우 통과
        }
        print(error) // 에러가 발생했을 경우 에러를 표시하고 필터를 벗어나지 않도록 함
        return false
    }
    .dematerialize() // 원래의 방식으로 방출
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

person1.score.onNext(1)
person1.score.onError(error.foul)
person1.score.onNext(1) // person2에 대한 값이 나왔기 때문에 flatMapLatest가 무시
track.onNext(person2)

print("===== 예시) 전화번호 11자리 =====")
// 숫자로 11자리를 입력하면 전화번호 형식으로 변형해서 방출하는 observable 생성
let input = PublishSubject<Int?>()
let list: [Int] = [1]

input
    .flatMap {
        $0 == nil
            ? Observable.empty()
            : Observable.just($0)
    }
    .map { $0! }
    .skip(while: { $0 != 0 }) // 0이 아니라면 스킵
    .take(11) // 11자리로 받음
    .toArray() // 받은 숫자를 배열로 묶음
    .asObservable() // toArray는 Single 방식이기 때문에 다시 observable로 변환
    .map {
        $0.map { "\($0)" } // Int 값을 String 값으로 변환
    }
    .map { numbers in
        var numberList = numbers
        numberList.insert("-", at: 3) // 3번째 인덱스에 String '-'을 추가 (010- )
        numberList.insert("-", at: 8) // 8번째 인덱스에 String '-'을 추가 (010-0000- )
        let number = numberList.reduce(" ", +) // 각각의 String을 더함
        return number
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

input.onNext(10)
input.onNext(0)
input.onNext(nil)
input.onNext(1)
input.onNext(0)
input.onNext(1)
input.onNext(2)
input.onNext(3)
input.onNext(nil)
input.onNext(4)
input.onNext(5)
input.onNext(6)
input.onNext(7)
input.onNext(8)
input.onNext(9)
input.onNext(0)


