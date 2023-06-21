# Rails action cable with devise
# 1. ActionCable?
https://guides.rubyonrails.org/action_cable_overview.html

Action Cable은 WebSocket을 나머지 Rails 애플리케이션과 원활하게 통합한다. 
이를 통해 실시간 기능을 나머지 Rails 애플리케이션과 동일한 스타일 및 형식으로 Ruby로 작성하면서도 성능과 확장성을 유지할 수 있다. 
클라이언트 측 JavaScript 프레임워크와 서버 측 Ruby 프레임워크를 모두 제공하는 풀스택 제품이다. 
Active Record 또는 선택한 ORM으로 작성된 전체 도메인 모델에 액세스할 수 있다.

<br>

# 2. 용어
액션 케이블은 HTTP request-response 프로토콜 대신 WebSocket을 사용한다. 액션 케이블과 웹소켓 모두 익숙하지 않은 용어가 몇 가지 있다:

## 2.1 Connections(연결)
Connection은 클라이언트-서버 관계의 기초 형성한다. 
단일 Action Cable 서버는 여러 연결 인스턴스를 처리할 수 있다. 
WebSocket 연결당 하나의 연결 인스턴스가 있다. 
한 사용자가 여러 브라우저 탭 또는 장치를 사용하는 경우 애플리케이션에 여러 개의 웹소켓이 열려 있을 수 있다.

## 2.2 Consumers(소비자)
웹소켓 연결의 클라이언트를 Consumer(소비자)라고 한다. 
액션 케이블에서 컨슈머는 클라이언트 측 자바스크립트 프레임워크에 의해 생성된다.

## 2.3 Channels(채널)
각 소비자는 차례로 여러 채널을 구독할 수 있다. 
각 채널은 일반적인 MVC 설정에서 컨트롤러가 하는 일과 유사하게 논리적 작업 단위를 캡슐화한다. 
예를 들어 ChatChannel과 ApparencesChannel 있을 수 있으며, 
Consumer는 이 두 채널 중 하나 또는 둘 다에 가입할 수 있다.
최소한 소비자는 하나의 채널을 구독하고 있어야 한다.

## 2.4 Subscribers(구독자)
Consumer가 채널에 가입하면 Subscriber 역할을 한다. 
구독자와 채널 사이의 연결을 놀랍게도 구독(Subscription)이라고 한다. 
소비자는 특정 채널의 구독자 역할을 여러 번 수행할 수 있다. 예를 들어, 소비자는 동시에 여러 개의 채팅방을 구독할 수 있다.
(그리고 실제 사용자는 연결에 열려 있는 탭/기기당 한 명씩 여러 명의 소비자를 보유할 수 있다는 점을 기억하세요).

## 2.5 Pub/Sub
Pub/Sub 또는 게시-구독은 정보 발신자(publisher 게시자)가 개별 수신자를 지정하지 않고 
추상적인 수신자 클래스(구독자)에게 데이터를 전송하는 메시지 큐 패러다임을 말한다. 
Action Cable 은 이 방식을 사용하여 서버와 여러 클라이언트 간에 통신한다.

## 2.6 BroadCast(방송)
BroadCast은 broadcaster에 의해 방송 내용이 해당 이름의 BroadCast을 스트리밍하는 채널 가입자(Subscribers)에게 직접 전송되는 pub/sub link이다. 
각 채널은 0개 이상의 생방송을 스트리밍할 수 있다.

<br>

# Server-side
## 3.1 Connections
서버가 수락한 모든 웹소켓에 대해 connection 객체가 인스턴스화된다.
이 객체는 이 객체에서 생성되는 모든 채널 subscriptions의 부모가 된다. 
연결 자체는 인증 및 권한 부여 이외의 특정 애플리케이션 로직을 처리하지 않는다. 
웹소켓 연결의 클라이언트를 연결 소비자(connection consumer)라고 한다. 
개별 사용자는 열려 있는 브라우저 탭, 창 또는 장치당 하나의 소비자-연결(consumer-connection) 쌍을 만든다.

연결은 `ActionCable::Connection::Base`를 확장하는 `ApplicationCable::Connection`의 인스턴스이다. 
`ApplicationCable::Connection`에서는 들어오는 연결에 권한을 부여하고 사용자를 식별할 수 있는 경우 연결을 설정한다.
```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # if verified_user = User.find_by(id: cookies.signed[:user_id])
      if(verified_user = env['warden'].user)
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
```

### identified_by
여기서 identified_by는 나중에 특정 연결을 찾는 데 사용할 수 있는 연결 식별자를 지정한다. 
식별자로 표시된 모든 항목은 connection 연결에서 만들어진 모든 채널 인스턴스에 동일한 이름의 delegate를 자동으로 생성한다.


<br>

## 3.2 Channels
채널은 일반적인 MVC 설정에서 컨트롤러가 하는 것과 유사하게 논리적 작업 단위를 캡슐화한다. 
기본적으로 Rails는 채널 간의 공유 로직을 캡슐화하기 위해 상위 ApplicationCable::Channel 클래스(ActionCable::Channel::Base를 확장)를 생성한다.

```ruby
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def get_user_data
    data = {
      id: current_user.id,
      email: current_user.email,
      username: current_user.email.split('@')[0],
    }

    ActionCable.server.broadcast "room_channel", { data: data }
  end
end
```

<br>

# Client-side
## 4.1 Connections

### 4.1.1 connect-consumer
소비자는 자신의 측에 연결 인스턴스가 필요하다. 
이는 Rails에서 기본적으로 생성되는 다음 JavaScript를 사용하여 설정할 수 있다:
```javascript
// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()

```

이렇게 하면 기본적으로 서버의 /cable에 연결할 소비자가 준비된다. 
관심 있는 구독을 하나 이상 지정할 때까지 연결이 설정되지 않는다.


<br>

### 4.1.2 subscribers
소비자는 특정 채널에 대한 구독을 생성하여 구독자가 된다:
```javascript
// app/javascript/channels/room_channel.js
import consumer from "channels/consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  }
});
```

이렇게 하면 구독이 생성되지만 수신된 데이터에 응답하는 데 필요한 기능은 나중에 설명한다.

소비자는 특정 채널의 구독자 역할을 여러 번 수행할 수 있다. 예를 들어, 소비자는 동시에 여러 채팅방을 구독할 수 있다:

<br>

# 5. Client-Server Interactions
## 5.1 Streams
스트림은 채널이 게시된 콘텐츠(생방송)를 구독자에게 라우팅하는 메커니즘을 제공한다. 
예를 들어, 다음 코드는 :room_id 매개변수의 값이 "1"인 경우 stream_from을 사용하여 room_1_channel Room이라는 이름의 생방송을 구독한다:
```ruby
# app/channels/room_channel.rb
class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room_id]}_channel"
  end
end 
```

그런 다음 Rails 애플리케이션의 다른 곳에서 broadcast를 호출하여 해당 방으로 브로드캐스트할 수 있다:
```ruby
# app/channels/room_channel.rb
def get_user_data
    data = {
      id: current_user.id,
      email: current_user.email,
      username: current_user.email.split('@')[0],
    }
    
    ActionCable.server.broadcast "room_channel", { data: data }
end
```

<br>

## 5.2 Broadcasting
Broadcasting은 퍼블리셔가 전송하는 모든 내용이 해당 이름의 방송을 스트리밍하는 채널 구독자에게 직접 라우팅되는 pub/sub link이다. 
각 채널은 0개 이상의 생방송을 스트리밍할 수 있다.

Broadcasting은 순전히 온라인 대기열이며 시간에 따라 달라진다.
Consumer 소비자가 스트리밍 중(특정 채널에 가입되어 있지 않은 경우)이 아니라면 나중에 연결해도 해당 생방송을 볼 수 없다.


<br>

## 5.3 Subscriptions
소비자가 채널에 가입하면 구독자 역할을 하게 된다. 
이 연결을 구독이라고 합니다. 
그런 다음 수신 메시지는 케이블 소비자가 보낸 식별자를 기반으로 이러한 채널 구독으로 라우팅된다.
- createActionCableChannel: 채널을 생성하고 구독한다.
  - server: stream_from "room_#{params[:room_id]}_channel"
  - client: {channel: "RoomChannel", room_id: roomId}
```javascript
import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer";

// Connects to data-controller="room"
export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus!");
    let roomId = this.element.dataset.roomId;
    this.sub = this.createActionCableChannel(roomId);

    console.log(this.sub)
  }

  createActionCableChannel(roomId) {
    return consumer.subscriptions.create(
        {channel: "RoomChannel", room_id: roomId}, {
      connected() {
        // Called when the subscription is ready for use on the server
        this.perform("get_user_data");
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        console.log(data.data.email);
      }
    });

  }
}
```


# refs
- https://www.youtube.com/watch?v=EpMWkX5t0dk&ab_channel=Deanin