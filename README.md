&nbsp;
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="img/logo.svg">
    <img alt="AdGuard Home" src="img/log.svg" width="100px">
  </picture>
</p>

<h3 align="center">HiveMPOS 是一款服务器集群控制软件专门针对挖矿代理设计,轻松管理几十上白台代理服务器</h3>
<p align="center">
  免费使用，如果你只是使用代理功能那么软件将一直免费，如果你使用了算力手续费功能,那么作为回报软件将收取用户算力的0.18%
</p>

<p align="center">
   <a href="https://github.com/hivecassiny/HiveMPOS/releases">
     <img src="https://img.shields.io/github/v/tag/hivecassiny/HiveMPOS?label=version&color" alt="version">
   </a>
    <a href="https://github.com/hivecassiny/HiveMPOS">
    <img src="https://img.shields.io/github/stars/hivecassiny/HiveMPOS.svg" alt="GitHub stars">
    </a>
   <a href="https://t.me/hivempos" target="_blank">
          <img src="https://img.shields.io/badge/Telegram-2CA5E0?logo=telegram&logoColor=white" alt="Telegram" />
   </a>
</p> 

<br/>
<p align="center">
  <img src="https://cdn.adtidy.org/public/Adguard/Common/adguard_home.gif" width="800"/>
</p>
<hr/>

## 软件说明

> [!NOTE]
> HiveMPOS是一款矿池代理软件，它实现了多服务器的群控管理，精简UI交互设计。
> 
> HiveMPOS软件和代理软件是独立的两个程序，我们把专门用来代理的程序称为内核。
> 
> HiveMPOS可以通过远程登录内核通过自动化程序自动安装，忽略复杂的服务器安装步骤，如果你对服务器较为熟悉你也可以手动安装。
> 
> HiveMPOS提供本地客户加密软件，支持`数据压缩`压缩将大大的减少流量的消耗，这对于使用流量卡的用户来说极为重要。
> 

## 服务条款
    1.本客户端设计、维护人员仅提供技术服务，不以营利为目的，本客户端的运行遵守服务器所在地的法律法规。本客户端用户必须严
      格按照当地法律法规使用本软件，如使用本客户端违反当地法律，应承担相应的法律责任。
    2.在使用本应用程序之前，请详细阅读本应用程序的描述。如果用户没有因本应用程序的技术问题造成任何损失，由用户自行负责，
      损失由应用程序开发和维护人员负责。无论如何，用户不得就此向开发者或维护者提出索赔或诉讼。
    3.您应确保您不是中国大陆、古巴、伊朗、朝鲜、叙利亚、俄罗斯或其他受相关国家或政府或国际机构管理或执行的制裁的国家或地
      区的居民。由此产生的法律责任由本人承担。
## HiveMPOS的安装
> - 类linux系统使用一键脚本自动安装
> - windows系统自己下载安装包解压运行
> - 首次运行的端口是10000，运行成功后web浏览器打开http://你的IP:10000
> - 然后进入系统的注册向导页面根据提示一步步设置即可

### Linux 
> - amd64架构(现在主流vps服务器都是这个架构)
  ```shell
   bash <(curl -s -L https://raw.githubusercontent.com/hivecassiny/HiveMPOS/main/install.sh)
  ```
### windows
> - 下载地址如下
> - https://github.com/hivecassiny/HiveMPOS/releases/latest/download/hivempos_windows_amd64.zip
> - 直接下载解压压缩文件运行hivempos_windows_amd64.exe
