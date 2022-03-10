# RxSwiftPractice
## RxSwift
* 조합 가능하고 재사용 가능한 문법을 제공한다.
* 선언형이므로 정의를 변경하는 것이 아니라 operator를 통해 데이터만 변경한다.
* 따라서 Rx를 사용한 코드는 이해하기 쉽고 간결하다. 또한 상태를 저장하기 보다는 앱을 단방향 데이터 흐름으로 모델링하기 때문에 안정적이다.
## Observable
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
### traits
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
	
### Subject
* 앱 개발에서는 실시간으로 Observable에 새로운 값을 수동으로 추가하고 subsciber에게 방출하도록 하는 것이 필요하다. 다시 말해 Observable이자 Observer가 필요한 것인데 이것을 Subject라고 부른다.
#### PublishSubject 
* 빈 상태로 시작하여 새로운 값 만을 subscriber애 방출한다.
* 구독된 순간 새로운 이벤트 수신을 알리고 싶을 때 유용하다.
* 구독을 멈추거나 completed, error 이벤트를 통해서 subject가 완전히 종료될 때까지 계속된다.
#### BehaviorSubject
* 마지막 next 이벤트를 새로운 구독자에게 반복하는 것으로,  하나의 초기값을 가진 상태로 시작하여 새로운 subscriber애게 초기값 또는 최신값을 방출한다.
#### ReplaySubject
* subject를 생성할 때, 특정 크기까지 방출하는 최신 요소를 일시적으로 버퍼로 둔다. 그 후 버퍼로 둔 것들을 버퍼 사이즈 만큼의 값들을 유지하면서 새로운 subscriber에게 방출한다.

## Operator
* Observable의 이벤트를 입력받아서 결과로 출력하는 연산자이다.
* 다양한 형태로 값을 걸러내거나, 변환하거나 합친다.
#### Filtering Operator
* next 이벤트를 통해 받아오는 값을 선택적으로 취할 수 있다. 
#### Transforming Operator
* Observable에서 방출된 값들을 다른 형태로 바꿔 변형된 값으로 방출한다.
#### Combining Operator
* Filtering, Transforming Operator와 시퀀스의 출력값을 핸들링해서 결과로 방출한다는 점은 동일하나 다수의 시퀀스를 조합한다는 점에서 다르다.
#### Time Based Operator
* 시간에 따라 시퀀스의 이벤트 방출이나 구독을 제어한다.
