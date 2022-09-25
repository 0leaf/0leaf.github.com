---
title: [Blog] 1. github pages로 개발 블로그 시작하기 (github pages + jekyll)
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - Daily
tag:
  - Blog
toc: true
toc_sticky: true
toc_label: Contents
description: desc
article_section: section
meta_keywords: Daily
last_modified_at: "2022-09-24 09:00:00 +0800"
---

# 0. 들어가기 전에
이 글은 Blog의 테마 글로 몇차례에 걸쳐 업로드 할 예정입니다.
흐름대로 글을 읽으시려는  Blog 카테고리를 선택해 확인해주시기 바랍니다.

# 1. github.io와 jekyll 을 개발 블로그용으로 선택한 이유
많은 개발자들이 사용하는 블로그들을 살펴보면 [티스토리](https://www.tistory.com/), [벨로그](https://velog.io/), [미디엄](https://medium.com/) 들을 많이 사용하는 것으로 보이며 웹상에 많은 글들을 통해 각 서비스들의 장단점을 비교할 수 있습니다.
제가 github.io를 선택한 이유를 짧게 정리하면 다음과 같고, 저에게 유리한 장,단점이라 모두에게 해당되지 않을 수 있습니다.

장점
- 내가 작성한 글을 직접 백업, 관리할 수 있다.
- 필요한 경우 정적 페이지 구성을 내가 원하는대로 변경할 수 있다.
- markdown으로 작성가능하다.
- git history로 글 이력을 확인하고 관리할 수 있다.

단점
- github.io가 렌더링해주는 블로그 서비스는 기본적으로 public 레포로 구성해야 하며 원글을 모두가 볼 수 있다.
- 글을 편집하고 업데이트 하는 과정이 다소 불편하다.

단점 두가지에 대해서 저는 첫번째 단점으로는 github pro(유료)를 사용하면 private repo에서 정적 페이지 렌더링을 할 수 있도록 github에서
지원하며, 두번째의 경우 gtihub issue로 포스팅을 관리하는 방법을 고민했습니다.

# 2. github pages와 jekyll
## 2.1 github pages
[github pages](https://pages.github.com/)에 대한 설명은 링크되어 있는 공식 페이지에서 영상을 보시면 이해하기 쉽습니다.
기본적으로 정적 페이지를 렌더링해주는 서비스를 지원하고 있으며 가이드 해주는 대로 따라서 hello world 문자열을 표시하는 
페이지를 띄워보겠습니다.
가이드 문서의 업데이트가 안되었는지 그대로 따라서 하면 안되는 부분이 있어 아래 순서대로 내용 기술해보겠습니다.

### 2.1.1 github.io repository 생성
<img width="728" alt="image" src="https://user-images.githubusercontent.com/6061207/192085558-9d5236c8-5a23-46c1-970f-c1250111c43b.png">
{github id}.github.io 이름으로 repository를 생성합니다.

### 2.1.2 index.html push
[공식 가이드](https://pages.github.com/) 에서 가이드하는 것처럼 Hello World 문자열을 포함하는 index.html을 push 합니다.
---
git clone https://github.com/username/username.github.io
cd username.github.io
echo "Hello World" > index.html
git add --all
git commit -m "Initial commit"
git push -u origin main
---
<img width="541" alt="image" src="https://user-images.githubusercontent.com/6061207/192085785-12afe61b-d8d0-49ff-9752-89e81365a391.png">

### 2.1.3 github.io repository 설정 변경
<img width="631" alt="image" src="https://user-images.githubusercontent.com/6061207/192086014-ad5fa738-5b4e-4090-ba55-ee3d257a98f9.png">

Settings - Pages 화면에서 배포할 branch를 main으로 지정해줍니다. 이후에 원하는 경우 브랜치를 변경하실 수 있습니다. 

### 2.1.4 빌드 및 배포 과정 이해 및 확인
2.1.3 과정을 거친 뒤 Actions 탭을 눌러 확인하면, 자동으로 main 에 있는 정적 파일들을 빌드하여 github.com에서 제공하는 가상 인스턴스에 배포하는 과정을 볼 수 있습니다.
<img width="1317" alt="image" src="https://user-images.githubusercontent.com/6061207/192086071-4aa48fca-67da-4de1-9b07-ca4070661830.png">
<img width="759" alt="image" src="https://user-images.githubusercontent.com/6061207/192086237-d472d012-2c28-4f52-9ab3-bccb183b96f2.png">
위 과정을 통해 AWS의 [S3로 정적 페이지 호스팅](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/WebsiteHosting.html)과 같이 어떤 정적 페이지라도 github repo의 지정한 브랜치에 올려두면 호스팅이 된다는 것을 이해할 수 있습니다.
다만, github actions를 구성할 경우 아래 사진처럼 레포의 .github/workflows 폴더에 actions를 위한 파일을 구성해야 하는데,pages의 경우 actions 파일은 repo에서 찾아볼 수 없습니다.
<img width="260" alt="image" src="https://user-images.githubusercontent.com/6061207/192086658-10d427ba-cd05-442b-8d56-2d76e78463a0.png">


## 2. jekyll
[jekyll](https://jekyllrb.com/) 홈에서 아래와 같은 내용을 확인할 수 있듯이 블로그를 위한 정적 페이지 구성을 위한 프로젝트 입니다.
<img width="500" alt="image" src="https://user-images.githubusercontent.com/6061207/192086813-16173e04-3853-4f4f-a18e-322dbbc773ea.png">
블로그 포스트를 어떻게 하는지에 대한 기본 [가이드](https://jekyllrb.com/docs/posts/)도 공식 페이지에서 살펴볼 수 있습니다.

[jekyll 테마](https://github.com/topics/jekyll-theme) 페이지에서 다양한 테마들을 확인할 수 있습니다.
그 중에 [minimal-mistakes](https://github.com/mmistakes/minimal-mistakes)를 한번 적용해 보도록 하겠습니다.

### 2.2.1 jekyll 정적 페이지 받아와 배포하기
github pages를 배포했던 repo에 minimal-mistakes를 포함하여 push 하기만 하면 배포되는 것을 확인할 수 있습니다.
![Sep-25-2022 13-49-24](https://user-images.githubusercontent.com/6061207/192128893-a0cad463-afdb-4920-837f-650a74570685.gif)

 
