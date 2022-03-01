import RxSwift
import os
import Dispatch

let disposeBag = DisposeBag()

enum TraitsError: Error {
    case single
    case maybe
    case completable
}

print("-----Single(1)-----")
Single<String>.just("single")
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("error : \($0)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

print("-----Single(2)-----")
Observable<String>
    .create { observer -> Disposable in
        observer.onError(TraitsError.single)
        return Disposables.create()
    }
    .asSingle()
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("error : \($0.localizedDescription)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

print("-----Single(3)-----")
struct SomeJSON: Decodable {
    let name: String
}

enum JSONError: Error {
    case decodingError
}

let json1 = """
    {"name":"min"}
    """

let json2 = """
    {"my_name":"kyoung"}
    """

func decode(json: String) -> Single<SomeJSON> {
    Single<SomeJSON>.create { observer -> Disposable in
        guard let data = json.data(using: .utf8),
              let json = try? JSONDecoder().decode(SomeJSON.self, from: data) else {
            observer(.failure(JSONError.decodingError))
            return Disposables.create()
        }
        
        observer(.success(json))
        return Disposables.create()
    }
}

decode(json: json1)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
    }
    .disposed(by: disposeBag)

decode(json: json2)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
    }
    .disposed(by: disposeBag)

print("-----Maybe(1)-----")
Maybe<String>.just("maybe")
    .subscribe(
        onSuccess: {
            print($0)
        },
        onError: {
            print($0)
        },
        onCompleted: {
            print("completed")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

print("-----Maybe(2)-----")
Observable<String>.create { observer -> Disposable in
    observer.onError(TraitsError.maybe)
    return Disposables.create()
} // String의 Observable sequence
.asMaybe() // String인데 MaybeTrait을 가지게 됨
.subscribe(
    onSuccess: {
        print("성공 : \($0)")
    },
    onError: {
        print("에러 : \($0)")
    },
    onCompleted: {
        print("completed")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

print("-----Completable(1)-----")
// completable을 사용하고 싶다면 create를 이용한다.
Completable.create { observer -> Disposable in
    observer(.error(TraitsError.completable))
    return Disposables.create()
}
.subscribe(
    onCompleted: {
        print("completed")
    },
    onError: {
        print("error : \($0)")
        },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

print("-----Completable(2)-----")
Completable.create { observer -> Disposable in
    observer(.completed)
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)
