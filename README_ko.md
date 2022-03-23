<img src="https://user-images.githubusercontent.com/3011832/154659440-d206a01e-a6bd-47a0-8428-5357799816de.png" alt="SwiftLayout Logo" height="180" />

*Yesterday never dies*

**A swifty way to use UIKit**

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fioskrew%2FSwiftLayout%2Fbadge%3Ftype%3Dswift-versions)](https://github.com/ioskrew/SwiftLayout)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fioskrew%2FSwiftLayout%2Fbadge%3Ftype%3Dplatforms)](https://github.com/ioskrew/SwiftLayout)



```swift
@LayoutBuilder var layout: some Layout {
  contentView {
    firstNameLabel.anchors {
      Anchors(.leading)
      Anchors.vertical()
    }
    if showMiddleName {
      middleNameLabel.anchors {
        Anchors(.leading).equalTo(firstNameLabel, attribute: .trailing)
				Anchors.veritcal()
      }
    }
    secondNameLabel.anchors {
      if showMiddleName {
        Anchors(.leading).equalTo(middleNameLabel.trailingAnchor)
      } else {
        Anchors(.leading).equalTo(firstNameLabel.trailingAnchor)
      }
      Anchors.vertical()
    }
  }
}
```

<img src="https://user-images.githubusercontent.com/3011832/157275626-c5f5672f-0a4a-4f45-8800-5ea3871c9dac.png" alt="thateasy" style="zoom:25%;" />

# 필요조건

- iOS 13+
- Swift 5.4+

# 설치

**SwiftLayout**은 현재 **SPM**만 지원합니다.

```swift
dependencies: [
  .package(url: "https://github.com/ioskrew/SwiftLayout", from: "2.0.1"),
],
```

# 주요기능

-  `addSubview` 와 `removeFromSuperview`을 DSL로 대체
-  `NSLayoutConstraint`, `NSLayoutAnchor` 설정을 DSL로 대체
- view와 constraint에 대한 선택적 갱신 가능
-  `if else`, `swift case`, `for` 등 조건문, 반복문을 통한 view, constraint 설정이 가능
- 값의 변경을 통한 layout 개신을 자동으로 할 수 있게 도와주는 propertyWrapper 제공
- constraint의 연결을 돕는 다양한 API 제공

# 사용법

## `LayoutBuilder`

**LayoutBuilder**는 UIView 계층을 설정을 위한 DSL 빌더입니다. 이를 통해서 superview에 대한 subview의 추가를 간단하고 가시적으로 할 수 있습니다.

```swift
@LayoutBuilder var layout: some Layout {
  view {
    subview {
      subsubview
      subsub2view
    }
  }
}
```

위의 코드는 아래의 코드와 동일합니다.

```swift
view.addSubview(subview)
subview.addSubview(subsubview)
subview.addSubview(subsub2view)
```

## `AnchorsBuilder`

**AnchorsBuilder** 은 뷰와 뷰간에 autolayout constraint의 생성을 돕는  `Anchors` 타입에 대한 DSL 빌더입니다. Layout의 함수인 anchors 안에서 주로 사용됩니다.

### `Anchors`

 **Anchors** 는 NSLayoutConstraint를 생성할 수 있으며, 해당 객체에 필요한 여러 속성값을 가질 수 있습니다.

> NSLayoutConstraint 요약
>
> - first: Item1 and attribute1
> - second: item2 and attribute2
> - relation: relation(=, >=, <=), constant, multiplier
>

제약 조건은 다음의 표현 체계로 나타낼 수 있습니다.
>Item1.attribute1 [= | >= | <= ] multiplier x item2.attribute2 + constant

[여기](https://developer.apple.com/documentation/uikit/nslayoutconstraint)에서 상세한 정보를 알 수 있습니다.

- 생성자에서는  `NSLayoutConstraint.Attribute`을 variadic이나 배열로 받습니다

  ```swift
  Anchors(.top, .bottom, ...)
  ```

- equalTo와 같은 관계 함수를 통해서 두번째 아이템(NSLayoutConstraint.secondItem, secondAttribute)을 설정할 수 있습니다

  ```swift
  superview {
    selfview.anchors {
      Anchors(.top).equalTo(superview, attribute: .top, constant: 10)
    }
  }
  ```

  이는 다음과 같이 표현할 수 있습니다

  ```
  selfview.top = superview.top + 10
  ```

- 관계 함수를 생략할 경우 두번째 아이템은 자동으로 해당 뷰의 슈퍼뷰로 설정됩니다

  ```swift
  superview {
    selfview.anchors {
      Anchors(.top, .bottom, ...)
    }
  }
  ```

  이는 다음과 같이 표현할 수 있습니다

  ```
  selfview.top = superview.top
  selfview.bottom = superview.bottom
  ...
  ```

  또한, 추가적으로 constraint등을 다음과 같이 설정할 수 있습니다

  ```swift
  Anchors(.top).setConstraint(10)
  ```

- 너비와 높이와 같은 속성은 두번째 아이템을 설정하지 않을 경우 자기 자신이 됩니다.

  ```swift
  superview {
    selfview.anchors {
      Anchors(.width, .height).equalTo(constraint: 10) // only for selfview
    }
  }
  ```
  
  이는 다음과 동일합니다
  
  ```
  selfview.width = 10
  selfview.height = 10
  ```

### `LayoutBuilder` + `AnchorsBuilder`

*드디어, 합체*

이제 LayoutBuilder와 AnchorsBuilder를 결합하여 하위 뷰를 추가하고, 오토레이아웃을 생성해서 뷰에 적용할 수 있습니다.

-  `anchors` 함수를 호출한 후에 subview를 추가하기 위해새는 `sublayout`함수가 필요합니다

  ```swift
  @LayoutBuilder func layout() -> some Layout {
    superview {
      selfview.anchors {
        Anchors.allSides()
      }.sublayout {
        subview.anchors {
          Anchors.allSides()
        }
      }
    } 
  }
  ```

- 혹시 sublayout 함수을 쓰기 귀찮나요? 나눠쓰면 됩니다

  ```swift
  @LayoutBuilder func layout() -> some Layout {
    superview {
      selfview.anchors {
        Anchors.allSides()
      }
    }
    selfview {
      subview.anchors {
        Anchors.allSides()
      }
    }
  }
  ```

### `active` and `finalActive`

`LayoutBuilder`, `AnchorsBuilder` 타입들은 실제 작업을 하기 위한 정보를 가지고 있을 뿐입니다. addSubview와 constraint의 적용을 위해서는 아래의 함수를 호출할 필요가 있습니다.

- 다이나믹한 업데이트 작업이 필요없다면, `Layout` 프로토콜의 `finalActive` 함수를 호출해서 즉시 뷰 계층과 오토레이아웃을 생성할 수 있습니다.
- `finalActive`은 addSubview와 오토레이아웃의 활성화 작업을 끝낸후 아무것도 반환하지 않습니다.
  
  ```swift
  @LayoutBuilder func layout() -> some Layout {
    superview {
      selfview.anchors {
        Anchors(.top)
      }
    }
  }
  
  init() {
  	layout().finalActive()
  }
  ```
  
- 화면 갱신과 관련한 여러 기능이 필요할 경우 `Layout` 프로토콜의 `active` 함수를 호출할 수 있습니다. 갱신에 필요한 정보를 담고있는 객체인 `Activation`을 반환합니다.

  ```swift
  @LayoutBuilder func layout() -> some Layout {
    superview {
      selfview.anchors {
        if someCondition {
          Anchors(.bottom)
        } else {
        	Anchors(.top)
        }
      }
    }
  }
  
  var activation: Activation
  
  init() {
    activation = layout().active()
  }
  
  func someUpdate() {
    activation = layout().update(fromActivation: activation)
  }

### `Layoutable`

`Layoutable` 은 **SwiftLayout**에서 **SwiftLayout**의 `View`가 하는 역할과 비슷한 역할을 일부 담당하고 있습니다.

이 프로토콜을 구현하려면 다음과 같이 코드를 구현해야합니다.

- `var activation: Activation?`

- `@LayoutBuilder var layout: some Layout { ... }`: @LayoutBuilder may not required.

  ```swift
  class SomeView: UIView, Layoutable {
    var activation: Activation?
    @LayoutBuilder var layout: some Layout {
      self {
        ...
      }
    }
    
    init(frame: CGRect) {
      super.init(frame: frame)
      updateLayout() // call active or update of Layout
    }
  }
  ```

#### `LayoutProperty`

SwiftLayout의 빌더들은 DSL을 구현하며, 그 덕에 사용자는 if, switch case 등등을 구현할 수 있습니다.

다만, 상태 변화를 view의 레이아웃에 반영하기 위해서는 `Layoutable`의 `sl`프로퍼티에서 필요한 시점에 `updateLayout`함수를 직접 호출해야 합니다.

```swift
var showMiddleName: Bool = false {
  didSet {
    self.sl.updateLayout()
  }
}

var layout: some Layout {
  self {
    firstNameLabel
    if showMiddleName {
      middleNameLabel
    }
    lastNameLabel
  }
}
```

- 만약 **showMiddleName** 이 false인 경우, **middleNameLabel**은 superview에 더해지지 않거나 이미 더해진 상태라면 superview로부터 제거됩니다.

- 이럴 경우 `LayoutProperty`를 사용하면 직접 updateLayout을 호출하지 않고 해당 값의 변경에 따라 자동으로 호출하게 됩니다.

  ```swift
  @LayoutProeprty var showMiddleName: Bool = false // change value call updateLayout of Layoutable
  
  var layout: some Layout {
    self {
      firstNameLabel
      if showMiddleName {
        middleNameLabel
      }
      lastNameLabel
    }
  }
  ```

### animations

 `Layoutable`의 오토레이아웃을 변경한 경우 애니메이션을 시작할 수 있습니다. 방법은 다음과 같이 간단합니다.

-  `UIView`의 animation 블럭 안에서 `updateLayout` 을 layoutIfNeededForcefully 매개변수를 true로 호출해주세요.

```swift
final class PreviewView: UIView, LayoutBuilding {
  var capTop = true {
    didSet {
      // start animation for change constraints
      UIView.animate(withDuration: 1.0) {
        self.updateLayout(layoutIfNeededForcefully: true)
      }
    }
  }
    
  let cap = UIButton()
  let shoe = UIButton()
  let title = UILabel()
    
  var top: UIButton { capTop ? cap : shoe }
  var bottom: UIButton { capTop ? shoe : cap }
    
  var activation: Activation?
    
  var layout: some Layout {
    self {
      top.anchors {
        Anchors.cap()
      }
      bottom.anchors {
        Anchors(.top).equalTo(top.bottomAnchor)
        Anchors(.height).equalTo(top)
        Anchors.shoe()
      }
      title.config { label in
        label.text = "Top Title"
        UIView.transition(with: label, duration: 1.0, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
          label.textColor = self.capTop ? .black : .yellow
        }, completion: nil)
      }.anchors {
        Anchors(.centerX, .centerY).equalTo(top)
      }
      UILabel().config { label in
        label.text = "Bottom Title"
        label.textColor = capTop ? .yellow : .black
      }.identifying("title.bottom").anchors {
        Anchors(.centerX, .centerY).equalTo(bottom)
      }
    }
  }
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    initViews()
  }
    
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initViews()
  }
    
  func initViews() {
    cap.backgroundColor = .yellow
    shoe.backgroundColor = .black
    cap.addAction(.init(handler: { [weak self] _ in
      self?.capTop.toggle()
    }), for: .touchUpInside)
    shoe.addAction(.init(handler: { [weak self] _ in
      self?.capTop.toggle()
    }), for: .touchUpInside)
    self.accessibilityIdentifier = "root"
    updateIdentifiers(rootObject: self)
    updateLayout()
  }
    
}
```



[![animation in update layout](https://user-images.githubusercontent.com/3011832/156908073-d4089c26-928f-41d9-961b-8b04d7dcde37.png)](https://user-images.githubusercontent.com/3011832/156908065-8d6bcebd-553b-490b-903b-6e375d4c97a3.mp4)

## 그 외의 유용한 기능들

### UIView의 `config(_:)`

Layout안에서 뷰의 속성을 설정할 수 있습니다.

```swift
contentView {
  nameLabel.config { label in 
    label.text = "Hello"
    label.textColor = .black
  }.anchors {
    Anchors.allSides()
  }
}
```

###  of `UIView` 와 `Layout`의 `identifying`

 `accessibilityIdentifier`을 설정하고 view reference 대신 해당 문자열을 이용할 수 있습니다.

```swift
contentView {
  nameLabel.identifying("name").anchors {
    Anchors.cap()
  }
  ageLabel.anchors {
    Anchors(.top).equalTo("name", attribute: .bottom)
    Anchors.shoe()
  }
}
```

- 디버깅의 관점에서 보면 identifying을 설정한 경우 NSLayoutConstraint의 description에 해당 문자열이 함께 출력됩니다.

### SwiftLayoutPrinter

xib혹은 UIKit으로 직접 구현되어 있는 뷰를 SwiftLayout으로 마이그레이션하게 될 때 유용하게 사용할 수 있는 유틸리티 객체입니다.

- UIView의 계층과 오토레이아웃 관계를 SwiftLayout의 문법으로 출력해줍니다.

  ```swift
  let contentView: UIView
  let firstNameLabel: UILabel
  contentView.addSubview(firstNameLabel)
  ```

- SwiftLayoutPrinter는 소스안에서는 물론 디버그 콘솔에서 사용할 수 있습니다.

  > (lldb) po SwiftLayoutPrinter(contentView)

  ```swift
  // 별도의 identifiying 설정이 없는 경우 주소값:View타입의 형태로 뷰를 표시합니다.
  0x01234567890:UIView { // contentView
    0x01234567891:UILabel // firstNameLabel
  }
  ```

- 다음과 같은 매개변수 설정을 통해 view의 label를 쉽게 출력할 수 있습니다.

  ```swift
  class SomeView {
    let root: UIView // subview of SomeView
    let child: UIView // subview of root
    let friend: UIView // subview of root
  }
  let someView = SomeView()
  ```

  > po SwiftLayoutPrinter(someView, tags: [someView: "SomeView"]).print(.nameOnly)

  ```swift
  SomeView {
    root {
      child
      friend
    }
  }
  ```
  

<img src="https://user-images.githubusercontent.com/3011832/157275626-c5f5672f-0a4a-4f45-8800-5ea3871c9dac.png" alt="thateasy" style="zoom:25%;" />

# credits

- oozoofrog([@oozoofrog](https://twitter.com/oozoofrog))
- gmlwhdtjd([gmlwhdtjd](https://github.com/gmlwhdtjd))