Chef的安装和使用

实验环境：
本过程涉及到的机器都是运行的虚拟机上的redhat
Chef-server : 9.123.155.226
Chef-workstation : 9.123.155.77
Chef-client : 9.123.155.66

Chef Server的安装（在Chef-server上）
官网上的链接是：http://docs.opscode.com/install_server.html
Steps :
1.为了方便起见在/etc/hosts中将Chef-server、Chef-workstation和Chef-client的ip和domain name关联起来
vim /etc/hosts
Chef-server : 9.123.155.226
Chef-workstation : 9.123.155.77
Chef-client : 9.123.155.66
此外，还需要注意的是你的hostname需要是一个FQDN，可以在/etc/sysconfig/network中修改用户的hostname，修改为：your_hostname.domainname的形式

2.去Chef的官网上下载Chef Server
注意：需要选择Chef Server、你的操作系统类型（我的server是RedHat 6,故选择Enterprice Linux），版本（我的是6），
操作系统架构（我是64为Linux，故为x86_64，32位系统的可以选择i686之类的），之后是Chef版本，可以选择最新的，
这些都选择好之后就可以点击上面的链接下载了，我下载之后的名字是：chef-server-11.0.11-1.el6.x86_64.rpm

3.在server上的进行安装
这个就要视各种Linux系统的不同来进行了，我的是redhat，故我的安装命令是：rpm -ivh chef-server-11.0.11-1.el6.x86_64.rpm

4.配置Chef server
这一步很简单，只要执行: sudo chef-server-ctl reconfigure就可以了

5.web访问chef server
至此，我们可以通过web的方式去访问chef server，域名为：https://server_domain_OR_ip
用户名为默认的：admin
密码为默认的：p@ssw0rd1
在你第一次登陆成功之后，系统就会提示让你更换密码，输入你的新密码点Save user就可以了。


Chef Workstation的安装（在Chef-workstation上）
Steps
1.安装Chef client
在命令行输入：curl -L https://www.opscode.com/chef/install.sh | sudo bash
在改命令执行完之后，输入chef-client -v 查看chef-client是否安装完成。安装完成之后，会在本机的/opt/下多一个chef的文件夹，包含chef的安装文件

2.安装git
各种不同Linux版本的（当然Windows也是可以的，如果要在windows上安装，可以自行google）安装命令请参考：http://git-scm.com/download/linux
在我的系统中，命令为：yum install git，如果yum中没有git的源，可以先添加一个git的源，命令为：rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm

3.下载chef-repo库
首先cd到你想chef-repo存放的位置，然后执行：git clone git://github.com/opscode/chef-repo.git
执行成功之后，会在目录下多一个chef-repo的目录，这就是chef-repo的模板git库，我存放的位置为：~/chef-repo/

4.获得.chef文件的内容（*********重要********）
首先在~/chef-repo下面新建一个隐藏的文件.chef，命令为：mkdir -p ~/chef-repo/.chef
先说一下.chef文件中的内容（这些内容都是需要我们配置的），包括了
knife.rb：这个文件时knife命令的配置文件，需要和哪台server连接，与server连接的node_name，key文件位置等。
chef-validator.pem: 据我说知，这个文件应该是workstation首次与server连接时的private key文件
admin.pem : 这个是admin用户的private key文件。
workstation.pem： 这是workstation这个user的private key文件，由server在workstation第一次request时产生，并返回给workstation，以后workstation request
就通过这个pem文件而不是chef-validator.pem文件了。

首先我们从server上获得chef-validator.pem文件的内容
4.1、在web browser中输入https://server_domain_OR_ip，然后用admin和前面新设置的密码登陆
4.2、点击Clients Label ==> chef-validator上edit  ==>  勾选Private Key，然后Save client ==> 复制Private Key的内容到刚刚创建的chef-validator.pem（注意最后不要留空行）

其次我们从server上获得admin.pem的内容
4.3、还是在上面的web页面中选择user，然后是edit
4.4、勾选Regenerate Private Key并点Save，然后和4.2一样将Private key的内容复制到admin.pem中。

接着我们可以配置knife,命令为knife configure --initial，在这条命令下面，会提示我们输入一些knife的配置信息，具体是：
Where should I put the config file?  这里是让你执行knife.rb文件的存放位置，自然是~/chef-repo/.chef/knife.rb
server address     这里是https://server_domain_OR_ip:443
Please enter a name for the new user:   这里我选的是workstation
Please enter the admin name: 			这里默认不填就可以
the location of the existing administrators key:	这里填写~/chef-repo/.chef/admin.pem
Please enter the validator's name:	默认即可
the location of the existing validator key:		这里填写~/chef-repo/.chef/chef-validator.pem
path to the repository : 		~/chef-repo 
select a password for your new user: 		填写任意你想设置的密码即可

至此，~/chef-repo/.chef下面的四个文件就产生了。

5.将chef-repo的文件入git库
首先需要初始化git的name和email，命令为：
git config --global user.name="Your_name"
git config --global user.email="Your_email_address"
由于.chef文件中包含了一些配置信息，我们是不希望他被放进git库的，执行下面的命令向.gitignore中添加.chef内容
echo ".chef" >> .gitignore
接着，我们就可以将chef-repo下面的内容add、commit到git库中去了。
git add .
git commit -m "Finish configuring workstation"

6.将ruby的路径添加到PATH中去
echo 'export PATH="/opt/chef/embedde/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile


7.测试workstation是否能成功连接到chef server上
knife user list
如果显示
admin
workstation
则说明连接成功了。

Chef Client安装（在Chef-workstaion上）
这里选择用bootstrap的方式注册一台chef client，命令为：
knife bootstrap node_domain_OR_ip -x username -P password -N name_for_node --sudo 
说明：
node_domain_OR_ip : 是要注册为chef client的机器的域名或者ip地址（下面简称为Chef-client）
username   :   Chef-client登录的用户名
password   ：  Chef-client登录的密码
name_for_node : Chef-client注册后在server的name，这里我的是TestClient
--sudo :    这是一个option，如果username不是root，则需要此参数；如果是root则不需要

最后执行完之后，通过knife client list测试结果应该为：
chef-validator
chef-webui
TestClient

至此，Chef的配置全部完成！
