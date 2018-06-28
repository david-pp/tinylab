---
title: 搭个GitLab玩玩
date: 2018-06-28 21:00:00
category : 工具
tags: [git, gitlab]
---

Git作为勾搭国外程序大神的绝佳工具，GitHub上有着各种高质量的开源代码值得我们去学习和借鉴。作为一个小团队，代码又不想公开，有没有可能自己搭一个类似GitHub的网站了？有，国外的大神们，开发了GitLab并开源了社区版供程序猿们把玩。

![](/images/gitlab-devops-loop.png)

<!--more-->

GitLab功能和GitHub类似：

- 基于git的版本库，做代码的版本控制。
- 支持MarkDown的wiki，记录项目的文档。
- 支持Issue Tracking，任务追踪，看板功能也不错，小型团队的开发计划使用这个完全足矣。
- 支持持续集成和持续发布（CI/CD）。
- 等等。

![](/images/gitlab-devops.png)


废话不多说，关于Git、GitHub、GitLab的介绍和使用，Google一下满大街都是。下面着重把搭建的过程记录一下：

官方提供了多种安装方式，使用Docker镜像安装是最便捷的，当然这也是Docker的牛逼之处。

**1> 安装Docker并启动**

```bash
yum install docker
systemctl daemon-reload
systemctl restart docker
```

**2> 下载GitLab镜像**

```bash
docker pull gitlab/gitlab-ce:latest
```

**3> 运行GitLab**

```bash
sudo docker run --detach     --hostname gitlab.xxx.com     --publish 443:443 --publish 80:80 --publish 22:22     --name gitlab     --restart always     --volume /srv/gitlab/config:/etc/gitlab     --volume /srv/gitlab/logs:/var/log/gitlab     --volume /srv/gitlab/data:/var/opt/gitlab     docker.io/gitlab/gitlab-ce:latest
```

- hostname :  主机地址。
- 443, 80, 22 :  https、http、ssh端口。
- volume :  gitlab在物理机器上的路径。

**4> 修改配置（可选）**

进入gitlab的环境：

```bash
docker exec -it gitlab /bin/bash
```

修改配置文件：

```bash
vim /et/gitlab/gitlab.rb
```

**5>打开浏览器输入hostname的地址，就可以随意玩了。（如果无法访问，查看防火墙设置，确保主机和相应的端口能被访问）**

![](/images/gitlab-demo.jpg)
