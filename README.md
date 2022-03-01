# RxSwiftPractice
### RxSwift
* 조합 가능하고 재사용 가능한 문법을 제공한다.
* 선언형이므로 정의를 변경하는 것이 아니라 operator를 통해 데이터만 변경한다.
* 따라서 Rx를 사용한 코드는 이해하기 쉽고 간결하다. 또한 상태를 저장하기 보다는 앱을 단방향 데이터 흐름으로 모델링하기 때문에 안정적이다.
### Observable<T>
* Rx 코드의 기반이다.
* T 형태의 데이터 snapshot을 전달할 수 있는 일련의 이벤트를 비동기적으로 생성하는 기능을 한다.
* 하나 이상의 observers가 실시간으로 어떤 이벤트에 반응한다.
* 이벤트 형태
	* next : 최신 또는 다음 데이터를 전달한다.
	* complete : 성공적으로 일련의 이벤트를 종료시킨다. 즉 observable이 성공적으로 자신의 생명주기를 완료해서 추가적으로 이벤트를 더이상 생성하지 않을 것을 의미한다.
	* error : observable이 에러를 발생시켜서 추가적으로 이벤트를 생성하지 않을 것을 의미한다. 따라서 에러와 함께 완전 종료된다.
  ```swift
  enum Event<Element> {
      case next(Element) 
      case error(Swift.Error) // swift의 에러를 감싸서 내보냄
      case completed 
  }
  ```
### trait
* Single, Maybe, Completable을 합쳐서 trait 이라고 하는데, 이 세가지는 일반적인 Observable 보다 좁은 범위의 Observable로 선택적 사용이 가능하다. (좁은 범위의 Observable을 사용하면 가독성을 높일 수 있다.)
#### Single
* success 또는 error 이벤트를 한번만 방출한다.
* success는 next 이벤트와 complete 이벤트를 합친 것과 같다.
* 파일 저장, 파일 다운로드, 디스크에서의 데이터 로딩과 같이 기본적으로 값을 산출하는 비동기적 연산에 사용된다.
* success 혹은 error 중 정확히 하나의 이벤트를 방출하는 연산자를 랩핑할 때 유용하다.
* Observable 뒤에 as Single을 붙여 바꾼다.
#### Maybe
* Single과 비슷하지만, 유일하게 다른 것은 성공적으로 complete 되더라도 아무런 값을 방출하지 않는 completed를 갖는다는 것이다.
* Observable 뒤에 as Maybe를 붙여 바꾼다.
#### Completable
* completed 또는 error 만을 방출한다.
* Observable을 completable로 바꿀 수 없다.
  * Observable은 각 요소를 방출할 수 있는데 Completable은 completed 또는 error 만을 방출하기 때문에 각 요소를 방출한 이상 이것을 Completable로 바꿀 수는 없다.
* Completable create를 통해 생성할 수 있다.

	
