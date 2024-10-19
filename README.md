# pmxcli

## What's
这是一款基于Docker的程序，专门用于缥缈墟定制订阅的Linux环境的Clash客户端。

## Why
为[缥缈墟](https://s.piaomiaoxu.xyz)的用户专门提供一款便捷的Linux端工具，只需使用一键脚本就可完成安装部署，使用时也仅仅只是需要输入在缥缈墟的有效账号信息就可以实现自动更新并获取订阅信息，无需其他操作，当然如果想对规则进行处理也可以使用集成的*metacubexd*面板进行操作

## How To Use

### 方式一
只需要在支持安装Docker的Linux环境中使用下面的指令即可完成安装

```
bash <(curl -sL https://raw.githubusercontent.com/piaomiaoxu/pmxcli/refs/heads/main/installation.sh)
```

### 方式二
下载上面的 docker-compose.yaml 并在同路径使用 `docker compose up -d` 启动

## Credits
* [metacubexd](https://github.com/MetaCubeX/metacubexd)
* [mihomo](https://github.com/MetaCubeX/mihomo)

