cat << "EOF" | sed -e '1,/```/s/```/---/'


# 0. 블로그 포스팅 전체 과정
![sample](https://user-images.githubusercontent.com/6061207/192129798-5c5e9857-9ca6-4d3e-a53d-576b15a9a085.gif)

# 1. github actions
[공식 페이지](https://docs.github.com/en/actions)에서 actions에 대해 아래와 같이 말하고 있습니다
> Automate, customize, and execute your software development workflows right in your repository with GitHub Actions. You can discover, create, and share actions to perform any job you'd like, including CI/CD, and combine actions in a completely customized workflow.

github actions를 구성하게 되면 github 인터페이스 등을 활용하여 자동화된 workflow를 구성할 수 있습니다. CI/CD 같은 프로세스를 구성할 수도 있고 bot 같은 동작들을 처리하도록 하게 할수도 있습니다.  
여기서는 actions를 활용해서 github issue로 포스팅을 관리하는 과정을 설명해보도록 하겠습니다.

# 2. jekyll posting 방법 이해
[jekyll posting 구조](https://jekyllrb.com/docs/posts/)를 살펴보면  폴더에 md 파일을 포함시켜주면 배포되도록 구성되어 있음을 알 수 있습니다.
파일의 이름은  형태를 따라줘야 합니다.
실제 구성되는 md 파일의 내용은 아래와 같이 쓰면 된다고 설명하고 있습니다.

이전 글에서 minimal-mistakes 테마를 배포했는데, 해당 홈페이지에서도 여러 포스팅 샘플들을 확인할 수 있습니다.

# 3. github issue로 블로그 포스팅 쉽게 하기 actions 소개
로컬에서 md 파일로 블로그를 포스팅 하다보니 포스팅들을 관리하기 어렵다는 생각을 했습니다.
결국  라는 아이디어와  의 생각으로 actions 프로젝트를 구성해봤습니다.
내용은 단순하며, 초기 구성된 actions 프로젝트는 [링크](https://github.com/0leaf/issue-to-md-posting)를 확인해주시면 됩니다.

## 3.1 actions 구성하기
[링크](https://github.com/0leaf/issue-to-md-posting)의 설명을 참고하여 구성해봅니다.
아래 내용을 복사하여 actions를 구성하며, 이해를 돕기 위해 과정을 남깁니다.

![1](https://user-images.githubusercontent.com/6061207/192130181-a43073dd-88d3-4b4c-beb5-99c1d892971d.gif)


## 3.2 issue template 구성하기
github issues는 반복적으로 쓰는 구조를 template로 구성할 수 있습니다. 매번 포스팅 meta 정보는 같은 구조로 되어있기 때문에 이를 template으로 만들어 두는 과정을 설명합니다.
앞서 포스팅 기본 구조는 살펴봤으나 minimal-mistakes의 구조에 맞는 템플릿을 아래와 같은 샘플로 사용하도록 하겠습니다.
markdown


![1](https://user-images.githubusercontent.com/6061207/192130593-e56ea73b-5e93-472a-809d-a0ab0a4e4c02.gif)

# 4. 전체 구성 이해
github issue 탭에 포스팅 하고자 하는 항목의 md 를 직접 구성하고, 포스팅 업데이트를 원할 경우 label을 release 혹은 원하는 tag name으로 달아주면 자동으로 배포됩니다.
[issue-to-md-posting](https://github.com/0leaf/issue-to-md-posting)의 actions를 활용하였는데, 살펴보면 github issue를 md 파일로 push 하는 과정을 actions로 구성해두었습니다. 
주의 맟 참고 사항은 다음과 같습니다
-  처럼 issue 제목을 생성할 경우 공백은 -로 자동으로 변환하지만 날짜 유형은 맞춰주어야 함
- 최초 생성한 issue의 제목을 변경할 경우 파일 이름이 다르게 같은 내용으로 파일이 생성되므로 유의
- 현재 버전은 issue를 삭제 해도 _post의 md 파일은 삭제되지 않으므로 삭제가 필요한 경우 직접 commit 반영하여 삭제 



EOF
