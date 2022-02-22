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
