---
title: Ch 1 - Introduction to Reinforcement Learning
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
article_tag1: RL
article_tag2: ML
article_tag3: 강화학습
article_section: section
meta_keywords: Reinforcement Learning, Machine Learning
last_modified_at: "2020-02-17 23:00:00 +0800"
---

강화학습과 관련된 기본 내용을 설명합니다.

# 1. The Reinforcement Learning Problem

## [개념] Sequential Decision Making

강화학습은 결정을 순차적으로 내려야 하는 문제에 적용됩니다. MDP는 순차적 행동 결정 문제를 수학적으로 정의해서 에이전트가 순차적 행동 결정 문제에 접근할 수 있도록 합니다.

- **Goal : Future Reward**가 최대가 되는 **Action**을 선택

장기적인 Reward를 사용하는 것이 단기적인 Reward를 사용하는 것 보다 좋을 수 있습니다. 그 예로 주식투자와 같은 도메인에서 활용할 경우 단기적인 정보 보다 장기적인 정보의 Reward가 더 효율적일 수 있음을 의미합니다.

순차적 행동 결정 문제의 구성요소는 State(상태), Action(행동), Reward(보상), Policy(정책)이 있습니다.

## [용어] Reward

**Definition (Reward Hypothesis)**

강화학습은 Reward Hypothesis에 기초하며 목표는 축적된 reward의 최대값을 찾는 것으로 설명 될 수 있습니다.

**Reward Hypothesis**

> That all of what we mean by goals and purposes can be well thought of as maximization of the expected value of the cumulative sum of a received scalar signal (reward).
> http://incompleteideas.net/rlai.cs.ualberta.ca/RLAI/rewardhypothesis.html

- Reward는 방향을 갖지 않으며 크기만 갖는 스칼라 feedback signal에 기인합니다.
- Agent가 step t 에서 얼마나 잘 행동하는지를 보여주는 지표로 볼 수 있습니다.
- Agent의 job은 보상 값들의 누적을 최대화 하는 것입니다.

## [개념] History & State

**History**

**History**는 observations, rewards, actions의 순서들의 집합을 의미합니다.

$$H_{t} = O_1,R_1,A_1,...,A_{t-1},O_t,R_t$$

즉 시간 t까지에 대한 모든 관측 가능한 변수들을 의미합니다.

**State**

**State**는 다음에 발생할 일을 결정하는데 사용 되는 정보를 의미하며 정적인 요소들 뿐만 아니라 속도 등과 같은 동적인 요소도 상태로 표현할 수 있습니다.

$$S_{t}=f(H_t)$$

## [용어] Environment State

**Environment state** 는 Environment 입장에서의 상태를 말하는데 이는 Agent가 Environment의 상태 정보를 제한적으로 알 수 밖에 없는 private 한 정보를 의미합니다. 인간이 세상을 바라볼 때 보이고 들리는 위주의 것들을 보며 그 정보들이 실제로 어떤 연관성들을 갖는지 알기 어려운 것처럼 생각할 수 있겠습니다.

![image](https://user-images.githubusercontent.com/79149004/109469781-d833b700-7ab1-11eb-8391-8a34793d02d9.png){:.aligncenter width="400" height="400"}

## [용어] Agent State

**Agent state** 는 Agent 입장에서의 상태를 말하는데 이는 Agent를 인간으로 본다면 거대한 Environment(지구) 로부터 어떤 동작을 통해 학습한 지식 그 상태를 의미한다고 볼 수 있겠습니다. 이러한 이유로 Agent state는 Histroy와 밀접한 관계를 갖고 있습니다.

![image](https://user-images.githubusercontent.com/79149004/109469697-b89c8e80-7ab1-11eb-8656-38719042817f.png){:.aligncenter width="400" height="400"}

## [용어] Markov state

**Definition**

![image](https://user-images.githubusercontent.com/79149004/109471615-58f3b280-7ab4-11eb-90f1-edb14649ce36.png){:.aligncenter}

Markov state (Information state) 는 위의 식으로 그 뜻을 이해할 수 있습니다. 풀어서 이야기하면 특정 상태에서의 정보는 해당 상태로부터 과거의 모든 history 정보를 포함하고 있을 수 있으며, 그 경우 미래의 정보를 판단하기 위해 과거의 history들은 고려하지 않아도 좋다. 즉 미래의 정보를 예측할 때 과거의 정보와 상관없이 현재의 정보를 바탕으로 고려하면 된다는 의미를 갖습니다.

- 특정 state 정보가 알려진다면, history 정보가 큰 의미 없다.
- 특정 state 정보로 미래의 정보를 판단하기 위해 충분히 활용될 수 있다.
- environment state (St) 와 history (Ht) 는 모두 Markov state라 할 수 있다.

  ⇒ history와 environment state 모두 과거의 정보들의 반영된 결과로 t 시점에서의 Markov state라고 할 수 있다.

**Additional Information**

과거에 어떤 과정을 거쳐 특정 State에 도달하였지와는 무관하게 특정 State에서 발생하는 확률들은 독립적으로 일정하며, 그 상태의 정보는 그 다음 상태를 예측하기에 충분한 정보로서 활용될 수 있습니다.
![image](https://user-images.githubusercontent.com/79149004/109470046-3791c700-7ab2-11eb-844d-74b49cc17bb1.png){:.aligncenter width="400" height="400"}
https://en.wikipedia.org/wiki/Markov_chain#Examples

## [용어] Fully Obserable Environments (MDP)

Full Observability : agent가 직접 environment의 상태를 바라볼 수 있는 경우를 의미하며 바둑, 체스와 같이 agent가 현재 environment의 정보를 취득할 수 있는 경우를 의미합니다.

- Agent state = Environment state = Information state
- Formally this is a **Markov decision process (MDP)**

![image](https://user-images.githubusercontent.com/79149004/109470556-edf5ac00-7ab2-11eb-93e8-c644909d85b5.png){:.aligncenter}

https://tunpixelblog.wordpress.com/2016/02/25/fully-vs-partially-observable-environment

![image](https://user-images.githubusercontent.com/79149004/109471243-d79c2000-7ab3-11eb-8703-98d6bbaacbe9.png){:.aligncenter}

(Fully Obserable Environment example)

## [용어] Partially Observable Environments (POMDP)

Partial observability: agent가 간접적으로만 environment의 상태를 알 수 있는 경우를 의미하며 스타크래프트, 카메라 센서만 부착된 로봇이 현재 위치를 파악하기 위한 경우, 포커게임 등 전체 environment 정보를 바로 파악할 수 없고, 가깝게 보이는 정보들을 바탕으로 판단해야 하는 경우들이 이에 해당합니다.

- Agent state (Not Equeal) Environment state
- Formally this is a **partially observable Markov decision procecss (POMDP)**
- Agent must construct its own state representation

![image](https://user-images.githubusercontent.com/79149004/109470635-0c5ba780-7ab3-11eb-9986-74204f65e5f9.png){:.aligncenter}

https://tunpixelblog.wordpress.com/2016/02/25/fully-vs-partially-observable-environment/

![image](https://user-images.githubusercontent.com/79149004/109471476-277ae700-7ab4-11eb-9bd3-367f61a64208.png){:.aligncenter}

(Partially Observable Environment example)

# 2. Inside An RL Agent

## [용어] Policy

- A Policy is the agent's behavior
- **It is a map from state to action**

  ⇒ 특정 state에서 policy를 적용하면 action을 얻을 수 있습니다. 이 경우에 Deterministic 한 경우와 Stochastic한 경우로 나뉘어지며, Stochastic한 경우 확률적으로 action 이 결정될 수 있습니다.

![image](https://user-images.githubusercontent.com/79149004/109471690-76c11780-7ab4-11eb-981c-f2856c5aa800.png){:.aligncenter width="450" height="50"}

![image](https://user-images.githubusercontent.com/79149004/109471735-85a7ca00-7ab4-11eb-9c4c-8e1e472dc487.png){:.aligncenter width="400" height="400"}

각 위치에서의 화살표가 의미하는 것이 action이며, policy에 특정 state 정보를 넣을 경우 action에 대한 정보를 얻을 수 있습니다.

## [용어] Value Function

- **Value function is a prediction of future reward**
- Used to evaluate the goodness/badness of state
- And therefore to seleect between actions, e.g.

![image](https://user-images.githubusercontent.com/79149004/109471765-922c2280-7ab4-11eb-9f23-d1ce86d43f10.png){:.alignleft width="450" height="45"}

![image](https://user-images.githubusercontent.com/79149004/109471995-e800ca80-7ab4-11eb-9feb-c13195e90684.png){:.aligncenter width="400" height="400"}

각 위치에서의 값들이 의미하는 것은 각 상태 s에 대한 value function의 값을 의미하며, 최적의 value function 을 구하는 것이 중요합니다.

## [용어] Model

- **A Model predicts what the environment will do next**

![image](https://user-images.githubusercontent.com/79149004/109472308-4af26180-7ab5-11eb-9fb8-31bf2ba953f8.png){:.alignleft width="450" height="150"}

![image](https://user-images.githubusercontent.com/79149004/109472424-737a5b80-7ab5-11eb-99f7-b5f98c4732f9.png){:.aligncenter width="400" height="400"}

위 이미지가 표현하는 grid layout은 transition model을 의미합니다.
각 숫자가 표현하는 것은 state s에서의 보상 값을 의미합니다.

**Model을 통해 다음 State와 다음 Reward를 예측할 수 있습니다.**

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

![image](https://user-images.githubusercontent.com/79149004/109473780-1b445900-7ab7-11eb-8d98-64d550568db5.png){:.aligncenter width="350" height="350"}

# 3. Problems within Reinforcement Learning

## [용어] Learning and Planning

Learning과 Planning의 가장 큰 차이는 환경의 모델에 대해서 알고 접근하느냐 입니다. Learning의 경우 환경의 모델을 알지 못하기 때문에 환경과 에이전트간의 상호작용으로 문제를 해결해야 합니다. Planning의 경우 주어진 model을 바탕으로 최적의 값을 계산하여 그 문제를 풀어낼 수 있습니다.

- Reinforcement **Learning**

  - The Environment is initially unknown
  - The agent interacts with the environment
  - The agent improves its policy

  **Example**  
  ![image](https://user-images.githubusercontent.com/79149004/109474229-a1609f80-7ab7-11eb-9a88-5c2043c59764.png)

- **Planning**

  - A model of the environment is known
  - The agent performs computations with its model (without any external interaction)
  - The agent improves its policy

  **Example**  
  ![image](https://user-images.githubusercontent.com/79149004/109474312-bb01e700-7ab7-11eb-90b4-d9a84a9ef4dd.png)

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
