---
title: redis - key rules
layout: single
author_profile: false
read_time: true
share: true
related: true
categories:
  - redis
tags:
  - redis
  - key
  - rules
  - convention
toc: false
toc_stiky: true
description: ""
article_section: ""
meta_keywords: ""
last_modified_at: '"2024-06-30 09:00:00 +0800"'
---

## TL; DR
- 계층 구조를 표현하기 위한 delimiter를 정합니다 (":")
- 쉽게 이해 가능하기 위한 길이로 key를 구성합니다.

## Keyspace

Redis 키는 binary safe합니다. 즉, "foo"와 같은 문자열부터 JPEG 파일의 내용까지 모든 바이너리 시퀀스를 키로 사용할 수 있으며, 빈 문자열도 유효한 키입니다.
- 매우 길거나, 짧은 키는 좋지 않습니다. 
	- "user:1000:followers"와 "u1000flw"를 비교하자면 "user:1000:followers" 이 더 나은 옵션이며 적절한 키 길이의 균형을 잡는것이 필요합니다. 
- 스키마를 고수하려고 노력하세요.
	- 예를 들어 "object-type:id"는 "user:1000"처럼 좋은 아이디어입니다. .이나 -는 "comment:4321:reply.to" 또는 "comment:4321:reply-to"처럼 여러 단어로 구성된 필드에 자주 사용될 수 있습니다.
- 허용되는 최대 키 크기는 512MB입니다.

# Refrences
- https://redis.io/docs/latest/develop/use/keyspace/