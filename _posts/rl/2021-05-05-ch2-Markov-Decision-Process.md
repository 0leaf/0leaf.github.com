---
title: Ch2 - Markov Decision Process
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Reinforcement Learning
tag:
  - Reinforcement Learning, MDP, MRP
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: RL
article_tag2: ML
article_tag3: 강화학습
article_section: section
meta_keywords: Reinforcement Learning, Machine Learning, MDP, MRP, Bellman equation
last_modified_at: "2020-05-05 19:35:00 +0800"
---

강화학습과 관련된 Markov state, MRP, MDP, Bellman equation 등에 대해 설명합니다.

# 1. Markov Process

## [개념] Markov Property (Markov State)

**Definition**

![image](https://user-images.githubusercontent.com/79149004/117127801-8a03a280-add7-11eb-8aaa-3ce4fdf9a014.png){: .align-center width="500"}

[마르코프 성질](https://ko.wikipedia.org/wiki/%EB%A7%88%EB%A5%B4%EC%BD%94%ED%94%84_%ED%99%95%EB%A5%A0_%EA%B3%BC%EC%A0%95)은 과거와 현재 상태가 주어졌을 때의 미래 상태의 조건부 확률 분포가 과거 상태와는 독립적으로 현재 상태에 의해서만 결정된다는 것을 뜻합니다.

쉽게 이야기하면 과거의 정보와 상관 없이 현재 상태의 정보만으로도 미래 상태를 판단할 수 있다는 성질을 의미합니다.
Markov Chain은 아래 항목들로 구성될 수 있으며, 아래 정보를 바탕으로 제한된 environment를 표현할 수 있습니다.

```jsx
S(상태), P(상태 변환 확률)
```

현재 상태는 과거의 모든 정보를 포함하고 있다고 볼 수 있습니다.

## [용어] State Transition Matrix (상태 변환 확률 P)

상태 변환 확률이란 에이전트가 **상태 s에서 행동 a를 했을때 다른 상태 s'에 도달할 확률을 의미합니다. 여기서 2차원 Matrix 형태로 상태 간 도달할 확률을 표현할 수 있습니다.**

![image](https://user-images.githubusercontent.com/79149004/117127830-9425a100-add7-11eb-9c38-d8cdbef2621c.png){: .align-center width="300"}

< 상태변환 확률의 확률 표현 >

![image](https://user-images.githubusercontent.com/79149004/117127845-9851be80-add7-11eb-9369-4a2aa5420b61.png){: .align-center width="300"}

< 상태 변환 확률의 Matrix 표현 >

2차원 Matrix로 표현할 경우 결국 Matrix의 총 합은 1이 됩니다.

## [예제] Student Markov Chain Transition Matrix

![image](https://user-images.githubusercontent.com/79149004/117127864-9ee03600-add7-11eb-8177-3ef9e858233f.png){: .align-center width="550"}

위 예제는 David silver 교수님 강의자료에 포함된 예제인데 학생이 수업을 듣고 Pass 하는 과정에 대한 Markov Chain 입니다. S와 P로 구성된 Markov Chain 은 위와 같이 표현될 수 있습니다.

Time series에 따른 에피소드가 다음과 같이 생길 수 있습니다.

        t1    t2     t3     t4    t5     t6

ep1. c1 c2 c3 pass sleep

ep2. c1 c2 c3 pub c3 pass

...

epn. c1 c2 sleep

# 2. Markov Reward Process

## [개념] Markov Reward Process

**Definition**

![image](https://user-images.githubusercontent.com/79149004/117127949-bcad9b00-add7-11eb-9361-89e731368477.png){: .align-center width="500"}

- MRP는 envoironment를 설명하기 위한 개념중 하나이며, Morkov Property의 구성요소인 S, P에서 **R과 r이 추가된 개념**을 의미합니다.

Markov Reward Process은 아래 항목들로 구성될 수 있으며, Morkov Property의 구성요소인 S, P에서 **R과 r이 추가된 개념** 으로 조금 확장된 environment를 표현할 수 있습니다.

즉 Markov Reward Process의 environment는 상태간 천이 확률을 아는 것 뿐만 아니라 각 상태의 Reward 정보를 포함한 개념입니다. 따라서 현재 상태에서 다른 상태로 이동할때 확률과 보상 값을 함께 판단 기준으로 포함시키게 됩니다.

```jsx
S(상태), R(보상함수), P(상태 변환 확률), r(감가율)
```

## [예제] Student MRP

![image](https://user-images.githubusercontent.com/79149004/117127962-c1724f00-add7-11eb-9dce-564ab47f9177.png){: .align-center width="500"}

S와 P로 구성된 Markov Chain에서 붉은색으로 표시된 R이 추가되어 있음을 알 수 있습니다. 각 상태마다 R을 갖고 있는 환경을 의미하며, 각 상태의 보상 정보로부터 보상 함수를 구성할 수 있으며 이러한 환경에서 이후 다룰 Retrun을 계산할 수 있습니다.

## [용어] Discount Factor (감가율 r)

감가율은 에이전트가 현재 상태 기준에서 판단을 내리는데, 먼 미래에 대한 가치를 높이거나 반대로 가까운 미래의 가치를 높이는 등의 역할을 할 수 있습니다.

만약 감가율 r이 1에 가까운 값을 갖는다면 미래의 값들이 가중치를 크게 받고, 0에 가까운 값을 갖는다면 현재의 값들이 가중치를 크게 받습니다.

감가율은 이 외에도 수학적인 수렴성을 위해서도 그 의미를 갖습니다.

$$\gamma \in [0,1]$$

$$\gamma^{k-1}R_{t+k}$$

## [용어] Return

**Definition**

![image](https://user-images.githubusercontent.com/79149004/117127980-c7683000-add7-11eb-94a9-92730b6b96e9.png){: .align-center width="500"}

Return은 시간 t에서 이후에 발생할 수 있는 모든 Reward를 discount factor 와 합한 것을 의미합니다.

위 MRP에서 들었던 예제중에 생성된 Episode 하나를 들어보겠습니다.

        t1    t2     t3     t4    t5     t6     t7

..

ep2. C1 C2 C3 pub C3 pass sleep

...

만약 위 ep2의 예제가 있고 discount factor가 0.5 라 가정하면

**G3** 의 return은

2.5 = (+1) [pub] +

         (-2) * (0.5) [C3]  +

         (+10) * (0.25) [pass] +

         (+0) * (0.125) [sleep]

가 됨을 알 수 있습니다.

같은 방식으로 강의자료에서 **각 에피소드마다 G1을 계산한 내용을 확인**하시면 이해가 빠를 것 같습니다.

![image](https://user-images.githubusercontent.com/79149004/117128002-cd5e1100-add7-11eb-9f28-028aff0e0c18.png){: .align-center width="550"}

## [용어] MRP Value Function

**Definition**

![image](https://user-images.githubusercontent.com/79149004/117128011-d18a2e80-add7-11eb-95bf-c37b06a05965.png){: .align-center width="500"}
Value Function은 중요한 개념입니다. 이후에도 반복적으로 언급될 부분이라 위 정의 내용으로만 짚고 넘어가면 MRP에서의 Value Function은 특정 상태의 Return **기댓값** 입니다.

즉 그 상태로부터 시작해서 종료 상태까지의 Reward와 discount factor를 곱한 합의 값을 각 상태마다 구하는 것을 의미합니다.

한 상태에서 두개 이상의 상태로 뻗어나갈 수 있는 경우나 사이클이 생기는 경우 수렴성에 대한 의문을 가질 수 있습니다. 다시 말해서 생성될 에피소드의 시나리오가 무한으로 발생할 수 있습니다.

Return 기대값의 수렴성에 대한 부분은 바로 다룰 개념인 Bellman equation을 알아야 이해할 수 있습니다.

## [예제] Student MRP Returns

![image](https://user-images.githubusercontent.com/79149004/117128027-d5b64c00-add7-11eb-9429-0f829167417a.png){: .align-center width="500"}

위 예제의 빨간색 부분이 각 상태에 따른 Value Function 결과 값이라고 볼 수 있습니다.

예를들어 v(c1) = -5.0이 됩니다.

지금 학습한 순서대로 라면 빨간색이 어떻게 계산된건지 이해 안가는게 당연합니다.

episode들을 샘플링 해서 계산해야 겠다고 생각할텐데, 이 환경은 sampling이 무한대로 가능하기 때문에 retrun을 계산하려면 무언가 수렴성에 대한 증명이 필요하기 때문입니다.

이 수렴성은 Bellman Equation을 통해서 확인이 가능합니다.

## [개념] Bellman Equation for MRP

MRP에서의 Value Function 정의는 v(s) = E[Gt | St = s] 였습니다.

이는 다음과 같은 Bellman Equation 과정으로 변환이 가능합니다.

![image](https://user-images.githubusercontent.com/79149004/117128038-da7b0000-add7-11eb-948d-38168d9bf615.png){: .align-center width="400"}

이렇게 되면 MRP Value Function v(s)는 Rt+1, rv(St+1) 두 부분으로 의미상 나뉘어 질 수 있습니다.

![image](https://user-images.githubusercontent.com/79149004/117128060-e2d33b00-add7-11eb-841f-240d0ebfaf74.png){: .align-center width="400"}
위 과정은 Bellman Equation에 따라 정리된 Value Function의 [기댓값을 계산](https://ko.wikipedia.org/wiki/%EA%B8%B0%EB%8C%93%EA%B0%92)하기 위해 식을 재정립 하는 과정을 의미하는데요, 각 상태는 이산 확률 분포를 따른볼 수 있으므로 이산 확률 변수의 기대값을 구하는 방법에 따라 식을 변형할 수 있습니다.

![image](https://user-images.githubusercontent.com/79149004/117128086-e9fa4900-add7-11eb-9acb-e352367686d4.png){: .align-center width="400"}

![image](https://user-images.githubusercontent.com/79149004/117128144-fed6dc80-add7-11eb-9b98-bc7c0bb2c905.png){: .align-center width="200"}

또한 위 식 처럼 Matrix로 변형해서 표현하게 되면 linear equation으로 표현될 수 있는데 할 수 있습니다. v를 하기 위해 식을 변환하면 아래의 결과를 얻을 수 있습니다.

![image](https://user-images.githubusercontent.com/79149004/117128167-039b9080-add8-11eb-983d-8944241a2b78.png){: .align-center width="200"}

# 3. Markov Decision Processes

## [개념] MDP (Markov Decision Process)

**Definition**

![image](https://user-images.githubusercontent.com/79149004/117128189-08f8db00-add8-11eb-9426-18475fedfc80.png){: .align-center width="500"}

- Markov Decision Process 는 일반적으로 강화학습에서 Fully Observable 한 environment에 대한 내용을 설명하는 개념이며 굉장히 중요한 개념입니다.

  Fully Observable하다는 것은 모든 state의 정보들을 직관적으로 알 수 있는 visible 한 환경을 이야기합니다. 복잡한 설명보다 이해를 돕기 위한 예시를 가지고 말씀드리겠습니다.

  아래는 스타크래프트의 맵 화면인데 정찰을 가지 않은 경우 상대방의 상태를 알 수 없습니다.

  ![image](https://user-images.githubusercontent.com/79149004/117128208-0eeebc00-add8-11eb-818f-a714bb6caf02.png){: .align-center width="200"}

 <center>< Partially observable ></center>

만약 치트키를 써서 맵을 켜버리면 항상 상대방의 상태를 확인할 수 있습니다.

![image](https://user-images.githubusercontent.com/79149004/117128224-144c0680-add8-11eb-916f-50b14c93239e.png){: .align-center width="200"}

  <center>< Fully observable ></center>

MDP의 구성요소는 다음과 같습니다.

```jsx
S(상태), A(행동), R(보상함수), P(상태 변환 확률), r(감가율)
```

Markov Decision Process는 Markov state와 Markov Reward Process 보다 더 많은 것을 포함하는 environment를 표현할 수 있습니다. MRP에서 A 에 해당하는 Action set이 추가 구성으로 포함되는데, 이 구성의 추가로 Action과 Policy의 개념에 대한 이해가 필요합니다.

## [개념] Markov Decision Process Policy

**Definition**

![image](https://user-images.githubusercontent.com/79149004/117128238-1a41e780-add8-11eb-82cf-ea8330d9c27e.png){: .align-center width="500"}

policy는 agent의 action과 깊은 연관이 있습니다. markov state의 특징과 맞물려 과거 history 정보와 무관하게 임의의 state에서 어떤 action을 취하는게 제일 효율적인지에 대한 결과를 알려줍니다. 이를 구성하기 위해선 Action에 대한 Value function이 구성되어야 특정 state에서 어떤 action을 하는 것이 좋은지에 대한 policy를 뽑아낼 수 있습니다.

## [개념] Markov Decision Process Value Function

**Definition - state value function**

![image](https://user-images.githubusercontent.com/79149004/117128253-1f9f3200-add8-11eb-9103-c670ea7ab24c.png){: .align-center width="500"}

state value function은 MRP의 value function과 유사합니다. 다만 policy의 의미가 포함되어 있는 것이 차이인데, 임의의 state s에서 action과 관계 없이 state만으로 value function을 계산하는 것은 동일하나 이 value function을 이용하여 임의의 state에서의 policy를 도출해 내서 사용하겠다는 의미가 있습니다.

**Definition - action value function**

![image](https://user-images.githubusercontent.com/79149004/117128295-2d54b780-add8-11eb-8c20-2c51c666b7c3.png){: .align-center width="500"}

action value function은 어떤 action을 했을때 얻어지는 value function의 값을 구하고 이 값을 바탕으로 임의의 상태에서 어떤 action을 하는 것이 최적인지를 도출해 낼 수 있습니다. 그리고 이 a최적의 action은 policy의 의미를 갖습니다.

## [개념] Markov Decision Process Bellman Expectation Equation

MRP 과정에서 봤던 Bellman Equatoin과 과정에 따라 아래와 같이 식이 정리됩니다.

하지만 Action Value Function에 대한 Bellman Equation은 Bellman Expectation Equation이라고 부르며 Action의 정보가 포함되어 식이 약간 더 복잡해보입니다.

![image](https://user-images.githubusercontent.com/79149004/117128307-334a9880-add8-11eb-9058-4b89c4e982d7.png){: .align-center width="400"}

![image](https://user-images.githubusercontent.com/79149004/117128310-36de1f80-add8-11eb-8d49-93f06ce3f42d.png){: .align-center width="500"}

## [개념] Bellman Expectation Equation for V

![image](https://user-images.githubusercontent.com/79149004/117128335-3e9dc400-add8-11eb-86f8-0f36537a2212.png){: .align-center width="410"}

State Value Function에 대한 Bellman Expectation은 위와 같이 표현됩니다. 위 그림인 backup diagram을 보면 검은 점이 가운데 있는데, 각 action에 대한 상태 합을 의미한다고 볼 수 있습니다.

## [개념] Bellman Expectation Equation for Q

![image](https://user-images.githubusercontent.com/79149004/117128350-43627800-add8-11eb-9baf-c525cbd06eb5.png){: .align-center width="410"}

Action Value Function에 대한 Bellman Expectation은 위와 같이 표현됩니다. 위 그림인 backup diagram을 보면 검은 점이 마지막에 있는데, 각 action에 대한 return을 각각 계산한다는 의미로 볼 수 있습니다.

## [개념] Optimal Value Function

**Definition - optimal state value function**

![image](https://user-images.githubusercontent.com/79149004/117128372-49f0ef80-add8-11eb-897e-f500e793e429.png){: .align-center width="500"}

**Definition - optimal action value function**

![image](https://user-images.githubusercontent.com/79149004/117128394-4eb5a380-add8-11eb-90a4-1a2e70fe342f.png){: .align-center width="500"}

위 두 개념은 state/action value function으로 임의의 상태에서 greedy하게 가장 큰 state/action을 policy로 선택하는 것을 의미합니다. 또한 MDP를 푼다 라는 의미는 이 optiaml value function을 구한다는 의미를 갖습니다.

## [개념] Optimal Policy Function

**Definition**

![image](https://user-images.githubusercontent.com/79149004/117128411-537a5780-add8-11eb-9c7c-9a6ab86beaeb.png){: .align-center width="500"}

![image](https://user-images.githubusercontent.com/79149004/117128427-583f0b80-add8-11eb-8349-cf4cebb15fc5.png){: .align-center width="500"}

optimal policy function에 대한 정의를 설명합니다.

결국 MDP에서 optimal value function을 구하게되면 그 value function이 max값을 greedy 하게 취하는 것을 불러 Optimal Policy Function이라고 함을 표현하고 있습니다.

![image](https://user-images.githubusercontent.com/79149004/117128442-5d03bf80-add8-11eb-8fa9-f5dcc2a2d8cd.png){: .align-center width="350"}

## [개념] Bellman Optimality Equation for V

![image](https://user-images.githubusercontent.com/79149004/117128455-62f9a080-add8-11eb-881d-53d7eb1af4ad.png){: .align-center width="400"}

State Value Function에 대한 Bellman Optimality 는 위와 같이 표현됩니다. 위 그림인 backup diagram을 보면 호가 하나 추가되어 있는데 state 기반으로 구한 value function 중 max가 되는 것을 선택하여 함수로 구성하는 것을 의미합니다.

## [개념] Bellman Optimality Equation for Q

![image](https://user-images.githubusercontent.com/79149004/117128467-6725be00-add8-11eb-9073-c05b3e7316fe.png){: .align-center width="400"}

Action Value Function에 대한 Bellman Optimality 는 위와 같이 표현됩니다. 위 그림인 backup diagram을 보면 호가 양쪽 state로 갈라지며 그려져 있는데 action 기반으로 구한 value function 중 max가 되는 것을 선택하여 함수로 구성하는 것을 의미합니다.

# Reference

[davidsilver.uk/teaching/](http://davidsilver.uk/teaching/)
