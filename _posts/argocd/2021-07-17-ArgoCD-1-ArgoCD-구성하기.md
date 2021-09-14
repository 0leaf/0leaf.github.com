---
title: ArgoCD 1. ArgoCD 구성하기
layout: single
author_profile: false
read_time: true
comments: true
share: true
related: true
categories:
  - ArgoCD
tag:
  - ArgoCD, CI/CD
toc: true
toc_sticky: true
toc_label: 목차
description: desc
article_tag1: ArgoCD
article_tag2: CI/CD
article_tag3: infra
article_section: section
meta_keywords: ArgoCD, CI/CD
last_modified_at: "2021-07-17 17:13:00 +0800"
---

Argocd 구성 과정을 설명합니다.

# 0. 들어가기 전에

계속해서 Kuberentes 내에서의 infra 구성에 대한 글을 정리하고 있습니다. 이번 글도 마찬가지이며 웹 상에 공식 페이지 및 많은 글들이 구성 방법에 대해 설명하고 있지만 하나 두개씩 가이드와 다르거나 동작하지 않는 경우들을 심심치 않게 볼 수 있었습니다.

그러한 이유로 이 글을 작성하기로 마음먹은 이유도 있습니다. 혹시나 같은 경우를 겪는 누군가에게 도움이 되길 바라며 글을 시작하겠습니다.

이 글은 DevOps, GitOps, Helm 및 Kustomize 등 manifest에 대한 전반에 대해 이해하고 있다고 가정하며 자세하게 다루지는 않으며, Kubernetes 환경에서 진행됨을 말씀드립니다.

# 1. CD in DevOps

![Untitled](https://user-images.githubusercontent.com/79149004/126030458-fd1ef4b0-e287-44aa-b68c-23f50f16bbac.png)

[https://programmerblog.net/what-is-devop/](https://programmerblog.net/what-is-devop/)

[https://www.opsera.io/blog/top-25-devops-tools-that-you-need-to-know](https://www.opsera.io/blog/top-25-devops-tools-that-you-need-to-know)

위 그림에서 보이는 DevOps 과정 중에서 오른쪽에 붉게 표시된 argoCD를 이용해 CD를 구성하게 될 것입니다. 향후 기회가 된다면 CI까지 연동해 Dev Ops 전체 과정이 부드럽게 이어져 동작하는 것을 공유드릴 수 있으면 좋겠습니다.

# 2. ArgoCD

[공식 문서](https://argoproj.github.io/argo-cd/)를 참고하면 ArgoCD에 대해 이렇게 설명하고 있습니다.

> Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes

> Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

정리해서 기술하자면 ArgoCD는 Devops과정 중 Kuberenetes 환경에서 Continuous Deploy 의 부분을 담당하는 도구라고 볼 수 있습니다.

Helm 및 Kustomize 의 manifest 구성을 GitOps 저장소에 반영하면 ArgoCD가 변경점을 체크하여 Deploy를 자동으로 진행합니다. 언급된 내용처럼 직관적으로 Deployment와 Pod 등의 구성을 확인할 수 있고, rollback 등도 UI로 쉽게 진행할 수 있습니다.

# 3. CD 구성

## 3.1 GitOps 구성

GitOps를 위해 Git repository가 필요합니다. GitOps 동작에 대한 내용은 [weaveworks - Operations by Pull Request](https://www.weave.works/blog/gitops-operations-by-pull-request)을 참고하시면 도움될 것 같습니다.

Git 기반의 repository들을 GitOps로 활용할 수 있고, AWS code commit, Github 등 어느 것을 사용하더라도 argoCD와 연동할 수 있습니다.

혹시 github를 사용하신다면, github repo를 하나 생성하고 테스트할 helm chart를 넣어둡니다.

![Untitled 1](https://user-images.githubusercontent.com/79149004/126030463-ea6140c6-e7ff-40e9-a11f-bcdefd9a1812.png)

본 글의 내용을 모두 진행하게 되면 Kubernetes 로의 배포는 위와 같은 그림으로 진행될 것입니다. User가 PR 하는 내용은 helm 등으로 구성된 K8S 구성 manifest이며 PR 이후 argoCD가 변경점을 보고 있다가, K8S에 반영하게 됩니다.

## 3.2 ArgoCD 설치

ArgoCD를 설치하는 과정은 [공식 홈페이지](https://argoproj.github.io/argo-cd/getting_started/)에 잘 기술되어 있습니다.

### 3.2.1 Kubernetes에 ArgoCD 설치

설치

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

외부에서 접근 가능하도록 Service type 변경 (node port 변경 후 port fowrding도 가능)

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

### 3.2.2 admin 계정 설정

**가이드에서 언급하고 있는대로 ArgoCD cli로 admin 계정 비밀번호를 설정하면 로그인 되지 않았습니다.**

argoproj의 [이슈](https://github.com/argoproj/argo-cd/issues/829) 에서 이미 언급된 내용이 있고, password가 일치하지 않는 문제가 발생하였습니다.

위 이슈의 내용 아래 명령으로 비밀번호를 변경할 수 있었고 (newpassword 부분을 원하는 것으로 변경), ArgoCD cli로 비밀번호만 변경할 목적이라면 사실 cli 설치 자체가 필요하지 않다고 생각되어 본 글에선 생략합니다.

```bash
kubectl patch secret -n argocd argocd-secret \
  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" newpassword | tr -d ':\n')'"}}'
```

환경에 htpasswd 가 없는 경우 아래 명령으로 설치해줍니다. (ubuntu)

```bash
apt install apache2-utils
```

# 4. ArgoCD 살펴보기

## 4.1 ArgoCD 접속

```bash
$ kubectl get svc -n argocd
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP                                                                    PORT(S)                      AGE
argocd-dex-server                         ClusterIP      172.20.234.216   <none>                                                                         5556/TCP,5557/TCP,5558/TCP   44d
argocd-metrics                            ClusterIP      172.20.19.60     <none>                                                                         8082/TCP                     44d
argocd-notifications-controller-metrics   ClusterIP      172.20.34.41     <none>                                                                         9001/TCP                     3d20h
argocd-redis                              ClusterIP      172.20.246.35    <none>                                                                         6379/TCP                     44d
argocd-repo-server                        ClusterIP      172.20.119.15    <none>                                                                         8081/TCP,8084/TCP            44d
argocd-server                             LoadBalancer   172.20.138.97    xxx.ap-northeast-2.elb.amazonaws.com   80:30462/TCP,443:31008/TCP   44d
argocd-server-metrics                     ClusterIP      172.20.231.166   <none>                                                                         8083/TCP                     44d
```

LoadBalancer 타입으로 변경한 경우 지정된 nlb 주소 (xxx.ap-northeast-2.elb.amazonaws.com) 로 브라우저에서 접속해봅니다.

![Untitled 2](https://user-images.githubusercontent.com/79149004/126030464-9ed58d8d-53a6-4a10-80da-bf3c97e232bf.png)

## 4.2 Argo App 구성

앞 단계에서 설정한 admin 계정 정보를 넣습니다.

![Untitled 3](https://user-images.githubusercontent.com/79149004/126030479-c76a5528-8318-48fc-8c85-6881f0c3daf4.png)

![Untitled 4](https://user-images.githubusercontent.com/79149004/126030486-659b9a16-9333-4c0f-9c1b-7004a588f89b.png)

접속해서 보이는 화면에서 helm 혹은 kustomize로 구성된 manifest가 존재하는 git repositiory를 등록 준 뒤 첫번째 탭을 선택하여 NewApp 버튼으로 연결된 repository의 helm chart를 연결합니다.

![argocd-ui](https://user-images.githubusercontent.com/79149004/126030515-16fb6f1f-710c-4213-b23e-97836d316efe.gif)

이제 gitops repository로 가서 values.yaml 등으로 원하는 부분을 변경 후 push 하면

위 화면처럼 Sync 기능을 통해 gitops repository와 현재 클러스터의 차이를 확인하여 변경점이 있을 경우 gitops repository의 helm chart 구성을 바탕으로 배포하게 됩니다.

해당 앱의 구조 파악 및 이전 버전으로의 rollback 등을 손쉽게 UI로 처리할 수 있습니다.

# 5. 정리

이번 글은 사실 많은 내용은 없습니다. 다만 공식 가이드에서 제공해준 내용대로 진행하다가 admin 계정 설정 부분에서 잘 안되었던 부분이 있어, 관련 내용을 기술하고자 ArgoCD와 관련된 내용도 일부 정리하게 되었습니다.

# 6. 참고자료

[https://argoproj.github.io/argo-cd/](https://argoproj.github.io/argo-cd/)

[https://programmerblog.net/what-is-devop/](https://programmerblog.net/what-is-devop/)

[https://www.opsera.io/blog/top-25-devops-tools-that-you-need-to-know](https://www.opsera.io/blog/top-25-devops-tools-that-you-need-to-know)
