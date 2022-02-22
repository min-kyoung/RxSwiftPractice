import UIKit
import RxSwift
import Dispatch

// obsrvable은 실제로는 sequence 정의일 뿐, 즉 subscribe 구독되기 전에는 아무런 이벤트도 내보내지 않는 그저 정의일 뿐이다.
// 따라서 표현한대로 작동되는지 확인하기 위해서는 반드시 subscribe가 필요하다.

print("---Just---")
Observable<Int>.just(1) // just : 하나의 요소를 포함하는 observable sequence
    .subscribe(onNext: {
        print($0)
    })

print("---Of(1)---")
Observable<Int>.of(1, 2, 3, 4, 5) // of : 하나 이상의 이벤트를 넣을 수 있음
    .subscribe(onNext: {
        print($0)
    })

print("---Of(2)---")
Observable.of([1, 2, 3, 4, 5]) // observable은 타입 추론을 통해서 obsrvable sequence를 생성하므로 어떠한 array 전체를 of 연산자 안에 넣으면 하나의 array를 내보내는 observable이 됨 => 하나의 array 만을 방출할 것이기 때문에 사실상 Observable.just([1, 2, 3, 4, 5])와 동일
    .subscribe(onNext: {
        print($0)
    })

print("---From---")
Observable.from([1, 2, 3, 4, 5]) // array 형태의 어떠한 element를 전달해주면 from 연산자는 of와 달리 자동적으로 자기가 받은 array 속의 element들을 하나씩 꺼내서 방출, 따라서 from 연산자는 오직 array만 취하게 되고 array 안의 요소들을 하나씩 방출하는 형태로 observable sequence를 만들게 됨
    .subscribe(onNext: {
        print($0)
    })

print("-----subscribe(1)-----")
Observable.of(1, 2, 3)
    .subscribe {
        print($0) // 어떠한 이벤트에 어떠한 값이 쌓여서 오고, completed가 발생했는지 여부를 다 보여줌
    }

print("-----subscribe(2)-----")
Observable.of(1, 2, 3)
    .subscribe {
        if let element = $0.element {
            print(element) // onNext를 사용한 것처럼 element 값만 방출
        }
    }

print("-----subscribe(3)-----")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0) // onNext를 통한 element만 방충
    })

print("-----empty(1)-----")
Observable.empty() // 요소를 하나도 가지지 않은 count 0의 observable
    .subscribe {
        print($0)
    }

print("-----empty(2)-----")
Observable<Void>.empty() // empty는 가지고 있는 요소가 없기 때문에 observable이 타입 추론을 할 수가 없음. 따라서 타입을 명시적으로 표시해줌
    .subscribe {
        print($0) // completed가 표현됨
    }

print("-----never-----")
Observable.never()
    .debug("never")
    .subscribe( // 아무런 값도 방출하지 않음
        onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        }
    )

print("-----range-----")
Observable.range(start: 1, count: 9) // 어떤 범위에 있는 array를 start부터 count 크기 만큼의 값을 갖도록 만들어줌
    .subscribe(onNext: {
        print("2 * \($0) = \(2*$0)")
    })

print("-----dispose-----")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    .dispose() // observable의 subscribe을 취소하여 observable을 최종적으로 종료시킴

print("-----disposeBag-----")
// 먼저 disposeBag을 만들고 observable을 선언함. 그리고 subscribe로부터 방출된 return 값을 disposeBag에 추가
// observable에 대해서 구독을 하고 있을 때, 이것을 즉시 disposeBag에 추가함. disposeBag은 이것을 가지고 있다가 자신이 할당해제할 때 모든 구독에 대해서 dispose를 날림
let disposeBag = DisposeBag()
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag) // disposeBag은 disposables를 가지고 있음. disposable은 disposeBag이 할당하려고 할 때 마다 dispose를 호출함

// disposBag을 subscribe에 추가하거나 수동적으로 dispose를 호출하는 것을 빼먹는다면 observable이 끝나지 않기 때문에 메모리 누수가 일어날 것

print("-----create(1)-----")
// observable을 받아서 disposable로 리턴시켜줌
Observable.create { observer -> Disposable in
    observer.onNext(1)
    observer.onCompleted()
    observer.onNext(2) // 위의 onCompledted 이벤트를 통해서 observable이 종료되었기 때문에 그 다음에 있는 onNext 이벤트는 방출되지 않음
    
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

print("-----create(2)-----")
enum MyError: Error {
    case anError
}

Observable<Int>.create { observer -> Disposable in
    observer.onNext(1)
    observer.onError(MyError.anError) // error는 error를 방출한 다음 observable을 종료시키기 때문에 error 단에서 observable이 종료되었고, 그 아래 onCompleted와 onNext는 종료된 observable에서 발생했기 때문에 더이상 방출되지 않는다.
    observer.onCompleted()
    observer.onNext(2)
    
    return Disposables.create()
}
.subscribe(
    onNext: {
        print($0)
    },
    onError: {
        print($0.localizedDescription)
    },
    onCompleted: {
        print("completed")
    } ,
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

// subscribe를 기다리는 observable을 만드는 대신에 각 suberscribe에게 새롭게 observable 항목을 제공하는 observable factory를 만드는 방식
print("-----deferred(1)-----")
Observable.deferred {
    Observable.of(1, 2, 3) // observable을 감싸는 observable
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

print("-----deferred(2)-----")
var 뒤집기: Bool = false

let factory: Observable<String> = Observable.deferred {
    뒤집기 = !뒤집기
    
    if 뒤집기 {
        return Observable.of("A")
    } else {
        return Observable.of("B")
    }
}

for _ in 0...3 {
    factory.subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
}


