---
title: ch1. Introduction to Reinforcement Learning
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Reinforcement Learning
tag:
  - Reinforcement Learning
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: tag1
article_tag2: tag2
article_tag3: tag3
article_section: section
meta_keywords: Reinforcement, Machine, Learning
last_modified_at: "2021-02-17 23:00:00 +0800"
---

# 1. The Reinforcement Learning Problem

## [개념] Sequential Decision Making

강화학습은 결정을 순차적으로 내려야 하는 문제에 적용된다. 순차적으로 행동을 결정한느 문제를 정의할 때 사용하는 방법이 MDP이다. MDP는 순차적 행동 결정 문제를 수학적으로 정의해서 에이전트가 순차적 행동 결정 문제에 접근할 수 있도록 한다.

- **Goal : future Reward**가 최대가 되는 **Action**을 선택
- Action은 장기간에 대한 선택이 될 수 있다.
- Reward는 즉시 반영되지 않고 지연될 수 있다.

**Description**

장기적인 Reward를 사용하는 것이 단기적인 Reward를 사용하는 것 보다 좋을 수 있다.

ex) 주식투자 : 단기간의 정보 보다 장기적인 정보의 Reward가 더 효율적일 수 있다.

순차적 행동 결정 문제의 구성요소는 State(상태), Action(행동), Reward(보상), Policy(정책)이 있다.

## [용어] Reward

**Definition (Reward Hypothesis)**

All goals can be described by the maximisation of expected
cumulative reward
강화학습의 목표는 축적된 reward의 최대값을 찾는 것으로 설명 될 수 있다.

강화학습은 Reward Hypothesis에 기초한다.

- Reward는 Scalar feedback ginal이다.

  ⇒ Vector 형태로 Reward를 주지 않고 계산된 형태인 Scalar 형태로 feedback을 준다.

- Aagent가 step t 에서 얼마나 잘 행동하는지를 보여주는 지표이다.
- Agent의 job은 누적 가능한 reward를 최대화 하는 것이다.

## [개념] History & State

**History**

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled.png)

**History**는 observations, rewards, actions의 순서들을 의미한다.

$$H_{t} = O_1,R_1,A_1,...,A_{t-1},O_t,R_t$$

즉 시간 t까지에 대한 모든 관측 가능한 변수들을 의미한다.

**State**

State는 다음에 발생할 일을 결정하는데 사용 되는 정보를 의미하며 정적인 요소들 뿐만 아니라 속도 등과 같은 동적인 요소도 상태로 표현할 수 있다.

$$S_{t}=f(H_t)$$

## [개념] Agent and Environment

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%201.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%201.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%202.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%202.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%203.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%203.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%204.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%204.png)

## [용어] Environment State

**Environment state** is the environment's private representation.
⇒ Agent에서 Environment state의 정보를 보기 어려운 private 정보

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%205.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%205.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%206.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%206.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%207.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%207.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%208.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%208.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%209.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%209.png)

## [용어] Agent State

**Agent state** is the agent's internal representation.

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2010.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2010.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2011.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2011.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2012.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2012.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2013.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2013.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2014.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2014.png)

## [용어] Markov state

**Definition**

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2015.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2015.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2016.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2016.png)

Information state (a.k.a Markov state) 는 history로부터 모든 유요한 정보들을 모두 포함한다.

- Once the state is known, the history may be thrown away

  ⇒ 특정 state를 사용하면 history정보가 의미 없음

- The state is a sufficient statistic of the future

  ⇒ 특정 state 정보로 미래의 정보로 충분히 활용될 수 있다

- The environment state (St) is Markov
- The history (Ht) is Markov

  ⇒ history와 environment state 모두 과거의 정보들의 반영된 결과로 t 시점에서의 Markov state라고 할 수 있다.

**Additional Information**

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2017.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2017.png)

과거에 어떤 과정을 거쳐 특정 State에 도달하였지랑 무관하게 특정 State에서 발생하는 확률들은 독립적으로 일정하다.

[https://www.quora.com/What-is-a-state-of-Markov-chain](https://www.quora.com/What-is-a-state-of-Markov-chain)

## [용어] Fully Obserable Environments (MDP)

Full Observability : agent directly observes environment state

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2018.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2018.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2019.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2019.png)

- Agent state = Environment state = Information state
- Formally this is a **Markov decision process (MDP)**

**Additional Information**

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2020.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2020.png)

[https://tunpixelblog.wordpress.com/2016/02/25/fully-vs-partially-observable-environment/](https://tunpixelblog.wordpress.com/2016/02/25/fully-vs-partially-observable-environment/)

## [용어] Partially Observable Environments (POMDP)

Partial observability: agent indirectly observes environment
⇒
로봇이 보고있는 카메라는 현재 위치를 알려주지 않는다.
포커게임의 상태는 전체의 상태를 알려주지 않는다.
(매번 Environment 변화에 대해 기억하고 추론해야 한다)

- Agent state (Not Equeal) Environment state
- Formally this is a **partially observable Markov decision procecss (POMDP)**
- Agent must construct its own state representation

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2021.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2021.png)

**Additional Information**

# 2. Inside An RL Agent

## [용어] Policy

- A Policy is the agent's behavior
- **It is a map from state to action**

  ⇒ 특정 state에서 policy를 적용하면 action을 얻는다. 이 경우에 Deterministic 한 경우와 Stochastic한 경우가 있으며 Stochastic한 경우 확률적으로 action 이 결정된다.

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2022.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2022.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2023.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2023.png)

## [용어] Value Function

- **Value function is a prediction of future reward**
- Used to evaluate the goodness/badness of state
- And therefore to seleect between actions, e.g.

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2024.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2024.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2025.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2025.png)

## [용어] Model

- **A Model predicts what the environment will do next**

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2026.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2026.png)

![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2027.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2027.png)

**Model을 통해 다음 State와 다음 Reward를 예측할 수 있다.**

## [용어] Categorizing RL agents

- Value Based
  - No Policy (Implicit)
  - Value Function
- Policy Based
  - Policy
  - No Value Function
- Actor Critic
  - Policy
  - Value Function
- Model Free
  - Policy and/or Value Function
  - No Model
- Model Based

  - Policy and/or Function
  - Model

  ![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2028.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2028.png)

# 3. Problems within Reinforcement Learning

## [용어] Learning and Planning

Two fundamental problems in sequential decision making

- Reinforcement **Learning**

  - The Environment is initially unknown
  - The agent interacts with the environment
  - The agent improves its policy

  **Example**

  ![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2029.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2029.png)

- **Planning**

  - A model of the environment is known
  - The agent performs computations with its model (without any external interaction)
  - The agent improves its policy

  **Example**

  ![Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2030.png](Lecture%201%20Introduction%20to%20Reinforcement%20Learning%20436e12fc07f84d119988549c400daf08/Untitled%2030.png)

## [용어] Exploration and Exploitation

**Exploration**

**Exploration** finds more information about the environment

**Exploitation**

**Exploitation** exploits known information to maximize reward

## [용어] Prediction and Control

**Prediction**

Prediction: evaluate the future
⇒Given a policy

**Control**

Control: optimize the future
⇒Find a best policy
