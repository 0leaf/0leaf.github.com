---
title: Ch3 - Planning by Dynamic Programming
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Reinforcement Learning
tag:
  - Reinforcement Learning, Dynamic Programming, Policy Iteration, Value Iteration
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: Reinforcement Learning
article_tag2: Policy Iteration
article_tag3: Value Iteration
article_section: section
meta_keywords: Reinforcement Learning, Machine Learning, Dynamic Programming, Policy Iteration, Value Iteration
last_modified_at: "2020-05-16 16:59:00 +0800"
---

강화학습과 관련된 Dynamic Programming, Policy Iteration, Value Iteration 등에 대해 설명합니다.

# 0. 시작하기 전에

![image](https://user-images.githubusercontent.com/79149004/118390080-2ba4b280-b668-11eb-8098-8de7ffa44b58.png){: .align-center width="800" height="200"}

정리할 내용을 그림으로 표현해봤습니다. 슬슬 용어와 개념들이 헷갈리기 시작합니다. 이번 챕터에서는 Dynamic Programming 이라는 방법으로 MDP 환경에서 Planning 방법으로 문제를 해결하는 과정을 다루도록 하겠습니다.

# 1. Dynamic Programming

## [개념] What is Dynamic Programming

지금 단계에서 Learning을 설명하기 위해 Dynamic Programming을 짚고 넘어가려고 하는것은 아닙니다.

[Dynamic Progrmming](https://ko.wikipedia.org/wiki/%EB%8F%99%EC%A0%81_%EA%B3%84%ED%9A%8D%EB%B2%95)은 Planning의 방식으로 MDP 환경에서 발생할 수 있는 많은 경우의 수를 비교적 빠른 시간으로 해결할 수 있는 방법 중에 하나입니다.

Dynamic Programming은 알고리즘 문제에서도 자주 다루는데, 복잡한 문제를 부분적으로 나누어 계산한 뒤 중복되는 부분 문제들은 이미 계산한 결과로 대체하는 방식(Memoization)을 통해 빠르게 계산할 수 있습니다.

유명한 문제로 피보나치 수열의 n번째 수를 찾는 문제를 재귀적으로도 풀 수 있고, 동적계획법 방법으로도 풀 수 있는데 실제 연산하게 되는 과정을 살펴보면 이해가 빠를 것 같습니다.

**재귀 풀이 방식**

```python
def fibo(i):
    if i == 1 or i == 2:
        return 1
    else:
        return fibo(i - 1) + fibo(i - 2)
```

**재귀 수행 과정**

![recursive](https://user-images.githubusercontent.com/79149004/118390109-60186e80-b668-11eb-8026-64787bb4dd97.gif){: .align-center}

**동적계획법 풀이 방식**

```python
fiboMemo = {}
def fibo(i):
    if i == 1 or i == 2:
        return 1
    else:
        if i not in fiboMemo:
            fiboMemo[i] = fibo(i - 1) + fibo(i - 2)
        return fiboMemo[i]
```

**동적계획법 수행 과정**

![dynamicprogramming](https://user-images.githubusercontent.com/79149004/118390116-6c9cc700-b668-11eb-81ed-e32699970905.gif){: .align-center}

MDP는 Dynamic Programming의 특성으로 설명된 Optimal substructre와 Overlapping subproblems를 만족하는 환경이므로 Dynamic Programming으로 문제를 해결할 수 있습니다.

무언가를 Dynamic Progrmming 방법으로 계산한다는 것은 이해했는데, MDP는 어떻게 푸냐고 생각되신다면 아래 과정을 거치면서 풀어 낼 수 있습니다. (value function을 구하는 공식을 DP로 계산한다는 의미입니다.)

- **Prediction** → value function
- **Control** → optimal value function + optimal policy

먼저 **Prediction** 과정에서는 현재 설정된 policy 기준(최초에는 랜덤) 으로 각 state에서 얻을 수 있는 return 값들을 바탕으로 state value function을 계산 합니다. 이 과정에서 state value function을 현재 policy를 바탕으로 반복해서 구하게 되면 **더이상 값이 변경되지 않는 true state value function**을 얻을 수 있습니다.

그 다음 **Control** 과정에서는 Prediction 에서 구해진 state value function을 바탕으로 어떤 action을 취했을때 최적인지를 판단할 수 있는 **action value function를 기반으로 optimal value function과 optimal policy**를 구하게 됩니다.

value function을 구하는데 있어 Dynamic Programming 기법을 사용하고, Prediction과 Control을 반복해서 수행하는 것을 Iteration 기법이라고 합니다.

# 2. Policy Iteration

## [예제] Policy Iteration

![image](https://user-images.githubusercontent.com/79149004/118390136-7de5d380-b668-11eb-81e7-d097a5c491e7.png){: .align-center width="450" height="450"}

개념을 보기 전에, 예제를 먼저 보시는게 이해가 빠를 것 같아서 [stanford에서 정말 말 잘 만든 Grid world의 샘플](https://cs.stanford.edu/people/karpathy/reinforcejs/gridworld_dp.html)을 바탕으로 설명드리도록 하겠습니다.

환경은 보시는 것처럼 각 상태의 reward를 볼 수 있는 MDP 환경이고, 초기 policy은 화살표 모양을 봐서 랜덤으로 설정되어 있음을 알 수 있습니다. 또한 각 네모 칸의 숫자는 state value function의 state별 값으로 볼 수 있습니다.

## [개념] Iterative Policy Evaluation

policy는 수학적으로 따지면 특정 상태에서 어떤 행동을 할건지에 대한 조건부 확률로 표현될 수 있습니다. 만약 임의의 상태에서 어떤 행동을 해야할지에 대한 Policy 가 있다면 이를 평가하는 방법에 대해서 알아보고자 합니다.

![image](https://user-images.githubusercontent.com/79149004/118390148-86d6a500-b668-11eb-9245-9ee974e3602d.png){: .align-center width="550" height="250"}

![image](https://user-images.githubusercontent.com/79149004/118390153-8d651c80-b668-11eb-8546-e4cfc3b4d218.png){: .align-center width="450" height="350"}

policy를 평가하려면 결국 각 상태에 대한 value function을 구해야 알 수 있습니다. 이 과정을 bellman equation을 통해 iterative한 방식으로 구할 수 있습니다. 다음 에제에서 그 과정을 살펴봅니다.

![May-16-2021 15-52-54-min](https://user-images.githubusercontent.com/79149004/118390467-2ba5b200-b66a-11eb-8e4b-fb88b63dd827.gif){: .align-center width="450" height="450"}

예제 설명 때 말씀드린 것 처럼 초기 policy는 random 이었습니다.

이 random policy가 얼마나 좋은지 state value function을 반복해서 구하는 과정을 진행합니다.

일정 단계 이후로는 각 state value function 값들이 변경되지 않고 수렴하는 것을 알 수 있습니다. 수렴하게 된 state value function을 true value function이라고 합니다.

이후 policy Improve 과정을 거쳐 optimal value function을 구하는 것이 Iteration의 최종 목표입니다.

## [개념] How to Improve a Policy

처음 주어진 random policy로 부터 각 state들의 true value function을 evaluation 과정을 거쳐서 구할 수 있었습니다.

이 true value function으로 부터 policy를 Imporve 할 수 있습니다. 말이 어려워 보이지만 다음 state들 중 가장 큰 value를 Action을 선택하는 greedy 방법을 쓰면 다음과 같이 policy가 업데이트 됩니다.

![May-16-2021 16-03-39-min](https://user-images.githubusercontent.com/79149004/118390471-2d6f7580-b66a-11eb-8f13-efb06328e9c3.gif){: .align-center width="450" height="450"}

## [개념] Policy Iteration

반복하는 과정은 앞에서 이미 설명드린 Policy Evaluation 과 Improvement 두 단계로 나눌 수 있습니다.

- Policy Evaluation

  각 상태 s에서 각 action들을 통해 value function을 계산하는 과정을 말합니다.

- Policy Improvement

  각 상태 s에서 각 action들 중에 가장 큰 값의 action을 선택하고 반영하는 과정을 말합니다.

그리고 이러한 두 과정을 반복는 policy iteration을 수행하면 optimal policy를 얻을 수 있게 됩니다.

![image](https://user-images.githubusercontent.com/79149004/118390500-5bed5080-b66a-11eb-8178-ff3e2d793d64.png){: .align-center width="500"}

Policy Evalutaion과 Policy Improvement 과정을 반복하는 과정을 아래 그림으로 확인하시면 위 내용이 조금 더 와닿으실 것 같습니다. 원래 true state value function을 구하고 improve를 해야하는데, 중간에 생략한 부분이 있으니 참고만 해주시기 바랍니다.

![May-16-2021 16-12-57-min](https://user-images.githubusercontent.com/79149004/118390473-2f393900-b66a-11eb-949c-ea88c760f127.gif){: .align-center width="450" height="450"}

맨 마지막에 나온 value function과, policy가 optimal 한 결과입니다. 즉 어떤 상태에 갑자기 떨어지더라도 화살표 방향대로 움직이면 최적의 결과를 얻을 수 있다는 것을 의미 합니다.

# 3. Value Iteration

## [개념] Principle of Optimality

![image](https://user-images.githubusercontent.com/79149004/118390518-7c1d0f80-b66a-11eb-9383-d4f09fce6174.png){: .align-center width="550" height="350"}

## [개념] Deterministic Value Iteration

![image](https://user-images.githubusercontent.com/79149004/118390523-82ab8700-b66a-11eb-857b-c409ca5779dd.png){: .align-center width="550" height="280"}

Policy Iteration과 Value Iteration의 가장 큰 차이점은 **Value Iteration은 bellman optimality equation을 이용해 state value function을 구한다는 점**입니다. 즉 각 state에서 가능한 모든 policy 들의 확률과 reward를 곱해서 value function을 구했던 Policy Iteration과 달리 Value Iteration은 각 상태에서 선택 가능한 policy 중에서 가장 큰 값만 남깁니다.

## [개념] Value Iteration

반복하는 과정이 Evaluation에 Improvement가 포함된 것 처럼 동작합니다.

Evaluation 과정에서 각 state에서 취할 수 있는 policy의 reward중 가장 큰 값만 남기는데, 이 이야기는 iteration 단계마다 policy를 택했다는 의미와 유사합니다. 그리고 그 iteration 끝에는 optimal value function과 optimal policy를 얻어 낼 수 있습니다.

![May-16-2021 16-30-29-min](https://user-images.githubusercontent.com/79149004/118390474-306a6600-b66a-11eb-9e47-68e3a4e8953d.gif){: .align-center width="450" height="450"}

![image](https://user-images.githubusercontent.com/79149004/118390535-935bfd00-b66a-11eb-9ef6-ac654fd81314.png){: .align-center width="550" height="300"}

# Reference

[davidsilver.uk/teaching/](http://davidsilver.uk/teaching/)

[https://cs.stanford.edu/people/karpathy/reinforcejs/gridworld_dp.html](https://cs.stanford.edu/people/karpathy/reinforcejs/gridworld_dp.html)
