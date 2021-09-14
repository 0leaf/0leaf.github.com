---
title: Python - WSGI 와 Flask 연동에 대한 필요성
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Python
tag:
  - Python, Flask, WSGI
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: Flask
article_tag2: WSGI
article_tag3: uWSGI
article_section: section
meta_keywords: Python, WSGI, CGI, Gunicorn, Flask
last_modified_at: "2021-05-15 21:08:00 +0800"
---

본 글은 python 기반 Flask로 서버를 구성함에 있어 WSGI 와의 연동에 대한 필요성을 설명합니다.

# 0. 들어가기 전에

요즘 Tensorflow와 Torch 기반으로 모델 개발을 하시는 분들이 많은데 구축한 모델을 추론하는 서버를 서비스에 적용하거나 테스트할 목적으로 flask로 구성하는 경우가 많을 것입니다.

물론 [TensorFlow serving](https://www.tensorflow.org/tfx/serving/architecture?hl=ko) 과 [Torch Serve](https://pytorch.org/serve/)에 대해서 다루는 글은 아니며, 딥러닝과 전혀 관계 없이 API 서버를 구성함에 있어 가벼움의 장점을 갖는 Flask로 많이 구성하시게 될 것입니다.

python 기반의 프레임워크로 서버를 구성할 때 고민해야 할 포인트들이 많습니다. 그냥 python이 친숙하거나 쉽다고 Flask로 서버를 구성하여 실제 서비스 제공할 생각이라면 위험 할 수 있다고 생각합니다.

그래서 두루뭉술한 개념들을 정리하고 고민해볼 포인트와 실험 해볼 포인트들을 정리하여 기술해보고자 합니다.

# 1. 서버 구성 비교 (Web Server + CGI + Application, Web Application Server)

![image](https://user-images.githubusercontent.com/79149004/118359793-0fe5d180-b5c0-11eb-9879-dcf68da3e774.png){: .align-center width="600" height="330"}

본 글은 Web Server와 Web Application Server간의 차이 등을 다루고 자하는 글이 아니지만, 필요한 내용이 있어 간단한 그림을 준비했습니다. 더 자세한 구조 혹은 WAS, WebServer, CGI 등에 대해 잘 모르신다면 깊게 다룬 관련 글들이 많으므로 찾아보시길 권해드립니다. 두가지만 짧게 짚고 넘어가겠습니다.

## 1.1. **정적 웹서버 vs 동적 웹서버**

> 정적 웹서버 : 정적 웹 서버 혹은 스택은 HTTP 서버 (소프트웨어)가 있는 컴퓨터(하드웨어)로 구성되어 있습니다. 서버가 그 불려진 파일을 당신의 브라우저에게 전송하기 때문에 그것을 "정적"이라고 부릅니다.

> 동적 웹서버 : 동적 웹 서버는 정적 웹 서버와 추가적인 소프트웨어(대부분 일반적인 **애플리케이션 서버와 데이터베이스**)로 구성되어 있습니다. 애플리케이션 서버가 HTTP 서버를 통해 당신의 브라우저에게 불려진 파일들을 전송하기 전에, 애플리케이션 서버가 업데이트하기 때문에 이것을 동적이라고 부릅니다.

> [mozilla](https://developer.mozilla.org/ko/docs/Learn/Common_questions/What_is_a_web_server)

**다시 말해서 html, javascript 만을 제공하는 정적 웹서버를 구성하고 싶다면 Flask로 띄울 필요가 없다**는 이야기 입니다.

만약 **db 연동이나 로직을 처리하는 application을 구성해야 하는 경우라면 그때 flask나 django가 필요**하다는 이야기 입니다.

## 1.**2. CGI/WSGI는 왜 필요한가?**

CGI와 관련된 자세한 내용을 원하신다면 [참고글](https://docs.python.org/3.0/howto/webservers.html)을 한번 읽어보시길 권해드립니다. 여기서는 이해를 돕기 위해 쉽게 설명하고 넘어가도록 하겠습니다.

> 공용 게이트웨이 인터페이스(영어: Common Gateway Interface; CGI)는 웹 서버 상에서 사용자 프로그램을 동작시키기 위한 조합입니다.

[Wiki](https://ko.wikipedia.org/wiki/%EA%B3%B5%EC%9A%A9_%EA%B2%8C%EC%9D%B4%ED%8A%B8%EC%9B%A8%EC%9D%B4_%EC%9D%B8%ED%84%B0%ED%8E%98%EC%9D%B4%EC%8A%A4)에 정리된 말 그대로 C로 만들어진 Ngnix Webserver 에서 다른 언어로 만들어진 application을 호출하고 그 결과를 사용자에게 전달하려면 중간에서의 처리를 담당하는 것이 필요하다고 생각 될 것 같습니다.

- CGI를 사용하는 경우 : 클라이언트 -> 웹서버 -> CGI -> Application
- WSGI를 사용하는 경우 : 클라이언트 -> 웹서버 -> WSGI (미들웨어) -> Application Server

WSGI는 Application Server를 연결해주는 미들웨어로서의 역할을 수행하며 그와 관련된 Python 계열의 WSGI는 gunicorn, uWSGI 등이 있으며 공식 문서를 보면 worker 기반으로 배포 시 서버를 효과적으로 구성할 수 있는 많은 옵션들을 제공해줍니다.

## 1.3. Flask/django 만 사용 한다는 것은?

![image](https://user-images.githubusercontent.com/79149004/118359810-22f8a180-b5c0-11eb-98c8-69e47406c8c9.png){: .align-center width="600" height="250"}

flask/django만 이용해서 서버를 구성한다는 것은 사용자가 직접 Application Server로 호출 하게 한다는 의미라고 볼 수 있습니다.

물론 flask가 정적 웹 서버를 제공하도록 만들 수도 있으니 그냥 저렇게 호출하면 안되냐고 생각하실 수 있는데, Web Server가 해주는 기능이 단순히 정적 웹 페이지를 내려주는 것만 하는 것이 아닙니다.

[nginx 기능](https://ko.wikipedia.org/wiki/Nginx)을 보시면 로드 벨런싱부터 다른 많은 기능을 제공해 주고 있습니다. Flask만으로는 본래 웹서버가 처리해줘야 할 많은 기능들을 처리하기 어렵다는 이야기 입니다.

# 2. Flask는?

Flask는 python 기반 웹 애플리케이션 프레임워크이며 django와 달리 db와 같은 기능들을 자체 프레임워크에 포함하고 있지 않기 때문에 가볍습니다. 따라서 작은 프로젝트에서 부터 확장성이 필요한 여러 프로젝트까지 다양한 목적으로 많이 사용됩니다.

개발 단계에서 Flask로 간단한 빌트인 서버를 띄울 수 있는데 실제 서비스 목적으로 배포해야 한다면 [Flask 공식 글](https://flask.palletsprojects.com/en/1.1.x/quickstart/#a-minimal-application)에서 WSGI를 붙여야 한다고 권장하고 있습니다.

> This launches a very simple builtin server, which is good enough for testing but probably not what you want to use in production. For deployment options see Deployment Options.
> Flask’s built-in server is not suitable for production as it doesn’t scale well

flask app은 기본적으로 blocking 작업이 있을때 동기적으로 방식으로 동작하기 때문에 여러 요청이 있을 경우 순차적으로 응답합니다. File IO, 외부 API 호출, 딥러닝 모델 추론 등의 긴 연산 시간이 필요할 경우 WSGI와의 연동이 필요합니다.

# 3. WSGI는?

1번 항목에서 WSGI에 대한 언급을 조금 하긴 했는데, 이번 글에서는 대표적으로 많이 쓰이는 WSGI 중 uWSGI를 예를 들어서 정리해보도록 하겠습니다.

uWSGI는 Nginx(Web Server)와 Flask를 연결해주는 인터페이스 역할 뿐만 아니라, [많은 기능](https://uwsgi-docs.readthedocs.io/en/latest/Options.html)을 제공하고 있습니다. 다른 WSGI들도 비슷한 기능들을 제공해주겠지만 각각의 비교는 이 글에

서 다루지 않습니다.

이 기능들 중에 Flask가진 단점 중 순차적 응답에 대한 문제를 multi process, thread 기반의 worker 방식으로 해결할 수 있습니다. 서버 구성 방식도 여러가지가 존재합니다.

또한 Flask 서버에서 memory leak이 발생했을때 일정 메모리 이상 올라갈 경우 worker 를 재시작 하는 등의 옵션도 제공합니다. 이 문제와 관련해서는 [인스타그램](https://instagram-engineering.com/adaptive-process-and-memory-management-for-python-web-servers-15b0c410a043) 의 사례를 보면 이해가 됩니다.

uWSGI와 Flask를 연동하여 서버를 구성하면 목적에 맞게 다양한 방식을 구성할 수 있습니다.

prefork, lazyapp, emperor mode, zerg dance 등 시간이 되시면 [uWSGI 서버 배포 모드](http://zarnovican.github.io/2016/02/15/uwsgi-graceful-reload/) 글을 읽어보시면 각 모드에 대해 그림으로 이해하기 쉽게 설명해 놓았습니다.

지금까지의 내용을 단순한 그림으로 정리하고 넘어가겠습니다.

![image](https://user-images.githubusercontent.com/79149004/118359812-2ab84600-b5c0-11eb-82ac-4b0c51c39517.png){: .align-center width="600" height="500"}

파란색 네모를 시간이 오래걸리는 요청이라고 생각하면 Flask로 직접 요청하는 것과 WSGI를 통해서 요청하는 것의 차이는 위의 모습으로 쉽게 이해할 수 있습니다. 물론 DB Connection이나 큰 딥러닝 모델을 물고 worker를 구성할 것인지 등의 구조는 서버 배포 모드 방식과 Application 코드 구성과 맞물려 있습니다.

그림을 통해 보면 당연히 WSGI를 통해 요청하게 되면 시간이 많이 걸리는 요청에 대해 많은 사용자 트래픽을 효율적으로 처리할 수 있다는 것을 이해할 수 있습니다.

# 4. 정리

가벼운 마음으로 글을 작성하기 시작했는데 생각보다 하고싶은 말을 바로 적으려니 읽으시는 분의 배경 지식에 따라서 제 생각이 잘 전달되지 않을 것 같다고 생각했습니다. 원래는 flask에 대한 동시성 성능에 대한 테스트를 주로 다루려고 시작했던 글인데 관련된 개념 부터 정리하게 되었습니다. 이후 WSGI와 연관되는 내용들을 정리하고 공유드릴 수 있는 기회가 있으면 좋겠습니다.

# 참고자료

[https://developer.mozilla.org/ko/docs/Learn/Common_questions/What_is_a_web_server](https://developer.mozilla.org/ko/docs/Learn/Common_questions/What_is_a_web_server)

[https://flask.palletsprojects.com/en/1.1.x/quickstart/#a-minimal-application](https://flask.palletsprojects.com/en/1.1.x/quickstart/#a-minimal-application)

[https://docs.python.org/3.0/howto/webservers.html](https://docs.python.org/3.0/howto/webservers.html)

[http://zarnovican.github.io/2016/02/15/uwsgi-graceful-reload/](http://zarnovican.github.io/2016/02/15/uwsgi-graceful-reload/)
