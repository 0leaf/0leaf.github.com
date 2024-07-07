---
title: redis - hashtag
layout: single
author_profile: false
read_time: true
share: true
related: true
categories:
  - Redis
tags:
  - Redis
  - Key
  - Hashtag
toc: false
toc_stiky: true
description: ""
article_section: ""
meta_keywords: ""
completed: false
visible: 
status: 
created: 2024-06-30T19:08
last_modified_at: 2024-07-07T15:20:12+09:00
thumnail_url: 
priority: 
---
# TL;DR
- redis cluster mode에서 MGET으로 데이터를 가져오려면, 저장할때 key에 hashtag인 `{}`를 포함해주어야 합니다.
# Hashslot
> CROSSSLOT Keys in request don't hash to the same slot

위와 같은 에러 메세지를 받았다면, cluster mode로 실행중인 redis에 [MGET](https://redis.io/docs/latest/commands/mget/)등으로 한번에 많은 요청을 받으려고 시도 할 때 발생합니다.
[aws 질문글](https://repost.aws/knowledge-center/elasticache-crossslot-keys-error-redis) 중에 관련된 내용이 있는데, 문제를 해결하기 위해서 키 내에 hashslot 명시하는 기준인 hashtag `{}` 를 포함하면 됩니다.
하지만, 기본적으로 cluster mode에서 hashslot이 저장되는 방식에 대한 이해를 바탕으로 hashslot을 설정하는 것이 좋습니다. 

아래와 같은 key를 예시로 들어봅니다.
```
1. categories:movies:{1}:name
2. categories:{movies}:1:name
```
cluster mode의 경우 hashslot을 n개의 shard로 나누어 관리하므로 같은 공간에 저장되는 것이 좋습니다. 담고자 하는 정보가 동일한 hashslot에 묶여 함께 저장되길 바라는 곳에 `{}`를 포함해야 합니다.

따라서, 특정 영화의 여러 속성을 한 번에 가져오는 경우가 더 일반적이라면 첫 번째 구조를 추천합니다.
그러나 범주 내의 여러 영화를 한 번에 가져오는 경우가 더 일반적이라면 두 번째 구조를 사용할 수 있습니다.

# Refrences
- https://redis.io/docs/latest/develop/use/keyspace/
- https://repost.aws/knowledge-center/elasticache-crossslot-keys-error-redis
- https://redis.io/docs/latest/operate/oss_and_stack/reference/cluster-spec/



