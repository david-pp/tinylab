---
title: Gitlab备份和迁移
date: 2019-01-31 21:00:00
category :
tags: []
---

2018年6月份时基于Docker搭建了一个Gitlab，最近由于机器升级，需要迁移到新机器。那么问题来了？

- Gitlab如何备份？
- Gitlab如何完整的迁移？

废话不多说，直接上命令吧：（假设运行Gitlab的的Docker容器名字为`gitlab`）

# Gitlab备份

都说云主机很安全，但是总觉得没个备份心里不踏实。之前Gitlab的运行命令如下：

```bash
sudo docker run --detach     --hostname gitlab.xxx.com     --publish 443:443 --publish 80:80 --publish 1024:1024     --name gitlab     --restart always     --volume /srv/gitlab/config:/etc/gitlab     --volume /srv/gitlab/logs:/var/log/gitlab     --volume /srv/gitlab/data:/var/opt/gitlab     docker.io/gitlab/gitlab-ce:latest
```

数据挂载在`/srv/gitlab`目录下。


备份命令：

```bash
docker exec -t gitlab gitlab-rake gitlab:backup:create
```

创建Gitlab的备份，备份文件位于`/srv/gitlab/data/backups`目录下，生成的文件名如`1548648399_2019_01_28_11.0.1_gitlab_backup.tar`，其中`11.0.1`是当前gitlab的版本号，恢复时使用的gitlab必须是同样的版本号，否则没法进行恢复。该文件里面包含了所有user、group、git repository数据。

# Gitlab迁移

1> 准备好新机器、安装docker

2> 拉相应版本的gitlab-ce镜像

```bash
docker pull gitlab/gitlab-ce:11.0.1-ce.0
```
3> 运行全新Gitlab容器

```bash
sudo docker run --detach     --hostname gitlab.xxx.com     --publish 443:443 --publish 80:80 --publish 1024:1024     --name gitlab     --restart always     --volume /srv/gitlab/config:/etc/gitlab     --volume /srv/gitlab/logs:/var/log/gitlab     --volume /srv/gitlab/data:/var/opt/gitlab     docker.io/gitlab/gitlab-ce:11.0.1-ce.0
```

4> 复制备份文件到backups目录

```
# 停掉gitlab容器
docker stop gitlab

# 复制备份文件
cp 1548648399_2019_01_28_11.0.1_gitlab_backup.tar /srv/gitlab/data/backups/

# 重启gitlab容器
docker start gitlab
```

5> 进入gitlab容器，恢复Gitlab数据

```bash
# 进入GITLAB
docker exec -it gitlab /bin/bash

# 停止数据服务
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

# 检查状态
gitlab-ctl status

# 数据恢复
sudo gitlab-rake gitlab:backup:restore BACKUP=1548648399_2019_01_28_11.0.1

# 重启并验证

sudo gitlab-ctl restart
sudo gitlab-rake gitlab:check SANITIZE=true

```

至此，完成数据迁移，恢复到和之前一模一样。记录一下迁移过程，以备后用！


