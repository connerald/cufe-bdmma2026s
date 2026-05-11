# Hadoop 单机环境安装与配置

## 一、安装 VMware Workstation Pro 17.6.4

官网下载 `VMware-workstation-full-17.6.4-24832109.exe`。

## 二、安装 Ubuntu 22.04.5

下载 `ubuntu-22.04.5-desktop-amd64.iso`。

## 三、安装 Java 8

### 1. 更新 apt

```bash
sudo apt update
```

---

### 2. 安装 OpenJDK 8

```bash
sudo apt install openjdk-8-jdk
```

---

### 3. 检查安装结果

```bash
java -version
```

安装完成后，效果如下：
```bash
conner@conner-virtual-machine:~$ java -version
openjdk version "1.8.0_482"
OpenJDK Runtime Environment (build 1.8.0_482-8u482-ga~us1-0ubuntu1~22.04-b08)
OpenJDK 64-Bit Server VM (build 25.482-b08, mixed mode)
```

---

## 四、配置 JAVA_HOME

查看 Java 路径：

```bash
readlink -f $(which java)
```

一般类似：

```text
/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
```

则：

```bash
sudo vim ~/.bashrc
```

最后加入：

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
```

生效：

```bash
source ~/.bashrc
```

检查：

```bash
echo $JAVA_HOME
```

实验效果：
```bash
conner@conner-virtual-machine:~$ echo $JAVA_HOME
/usr/lib/jvm/java-8-openjdk-amd64
```

---

## 五、安装 SSH

Hadoop 依赖 SSH。

### 1. 安装 SSH 服务

```bash
sudo apt install openssh-server
```

启动 SSH 服务：

```bash
sudo service ssh start
```

---

### 2. 配置 SSH 免密登录

生成密钥：

```bash
ssh-keygen -t rsa
```

一路回车。

然后：

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

测试登录：

```bash
ssh localhost
```

第一次输入：

```text
yes
```

之后能免密登录即可。

---

## 六、下载 Hadoop


官方下载：

[Apache Hadoop Downloads](https://hadoop.apache.org/releases.html?utm_source=chatgpt.com)

或者直接使用命令下载：

```bash
wget https://downloads.apache.org/hadoop/common/hadoop-3.2.4/hadoop-3.2.4.tar.gz
```

也可以从清华源下载后，用 FileZilla 传入虚拟机。

---

## 七、解压 Hadoop

```bash
tar -zxvf hadoop-3.2.4.tar.gz
```

移动：

```bash
sudo mv hadoop-3.2.4 /usr/local/hadoop
```

---

## 八、配置环境变量

编辑：

```bash
sudo vim ~/.bashrc
```

加入：

```bash
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
```

生效：

```bash
source ~/.bashrc
```

检查：

```bash
hadoop version
```

---

## 九、配置 Hadoop

进入：

```bash
cd /usr/local/hadoop/etc/hadoop
```

---

## 十、修改 hadoop-env.sh

编辑：

```bash
vim hadoop-env.sh
```

找到：

```bash
export JAVA_HOME=
```

改成：

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

---

## 十一、配置 core-site.xml

```bash
vim core-site.xml
```

改为：

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
```

---

## 十二、配置 hdfs-site.xml

```bash
vim hdfs-site.xml
```

改：

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///usr/local/hadoop/tmp/name</value>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///usr/local/hadoop/tmp/data</value>
    </property>
</configuration>
```

---

## 十三、创建目录

```bash
sudo mkdir -p /usr/local/hadoop/tmp/name
sudo mkdir -p /usr/local/hadoop/tmp/data
```

给权限并更改所有者：

```bash
sudo chown -R $(whoami):$(whoami) /usr/local/hadoop/tmp
sudo chmod -R 755 /usr/local/hadoop/tmp
```

---

## 十四、格式化 NameNode

```bash
hdfs namenode -format
```

成功会看到：

```text
Storage directory ...
```

---

## 十五、启动 Hadoop

启动 HDFS：

```bash
start-dfs.sh
```

查看进程：

```bash
jps
```

应该看到：

```text
NameNode
DataNode
SecondaryNameNode
```

---

## 十六、启动 YARN

```bash
start-yarn.sh
```

再：

```bash
jps
```

应该还有：

```text
ResourceManager
NodeManager
```

---

## 十七、打开 Web UI

## HDFS

浏览器：

```text
http://localhost:9870
```

## YARN

```text
http://localhost:8088
```

---

## 十八、测试 HDFS

创建目录：

```bash
hdfs dfs -mkdir /test
```

查看：

```bash
hdfs dfs -ls /
```

上传文件：

```bash
hdfs dfs -put hello.txt /test
```

---

## 十九、关闭 Hadoop

### 1. 关闭 YARN

```bash
stop-yarn.sh
```

---

### 2. 关闭 HDFS

```bash
stop-dfs.sh
```

---

### 3. 检查进程

验证所有服务已停止：

```bash
jps
```

应该只看到 `Jps` 进程。

---

## 二十、安装 Spark

Spark 版本选择和 Hadoop 兼容的预编译包，例如 `spark-3.5.8-bin-hadoop3.tgz`。

### 1. 下载 Spark

```bash
wget https://downloads.apache.org/spark/spark-3.5.8/spark-3.5.8-bin-hadoop3.tgz
```

也可以从镜像站下载后再拷贝到虚拟机中。

---

### 2. 解压并移动

```bash
tar -zxvf spark-3.5.8-bin-hadoop3.tgz
sudo mv spark-3.5.8-bin-hadoop3 /usr/local/spark
```

---

### 3. 配置环境变量

编辑：

```bash
sudo vim ~/.bashrc
```

加入：

```bash
export SPARK_HOME=/usr/local/spark
export PATH=$PATH:$SPARK_HOME/bin
export PATH=$PATH:$SPARK_HOME/sbin
```

生效：

```bash
source ~/.bashrc
```

检查：

```bash
spark-shell --version
```

---

## 二十一、配置 Spark

进入配置目录：

```bash
cd /usr/local/spark/conf
```

---

### 1. 配置 spark-env.sh

复制模板：

```bash
cp spark-env.sh.template spark-env.sh
```

编辑：

```bash
vim spark-env.sh
```

加入：

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
export SPARK_DIST_CLASSPATH=$(hadoop classpath)
```

说明：`HADOOP_CONF_DIR` 用来让 Spark 读取 Hadoop 的配置，`SPARK_DIST_CLASSPATH` 用来保证 Spark 能找到 HDFS 和 YARN 相关依赖。

---

### 2. 配置 workers

如果使用 Spark standalone 模式，需要指定 worker 主机名。单机环境一般写：

```bash
cp workers.template workers
vim workers
```

内容改为：

```text
localhost
```

---

## 二十二、启动 Spark

Spark 可以单独运行，也可以提交到 Hadoop 的 YARN 上。

### 1. 启动 standalone 模式

如果想在本机上直接启动 Spark 集群，先执行：

```bash
start-master.sh
start-worker.sh spark://localhost:7077
```

然后查看进程：

```bash
jps
```

应看到：

```text
Master
Worker
```

Web UI：

```text
http://localhost:8080
```

---

### 2. 进入 Spark 交互环境

```bash
spark-shell
```

进入后可以测试运行：

```scala
sc.parallelize(1 to 5).collect()
```

如果安装了 Python 版本，也可以使用：

```bash
pyspark
```

---

### 3. 提交到 YARN

如果 Hadoop 的 HDFS 和 YARN 已经启动，可以直接提交 Spark 任务到 YARN：

```bash
spark-submit --master yarn --deploy-mode client your_app.py
```

如果是 Scala 或 Java 程序，把 `your_app.py` 换成对应的 jar 包或主类参数即可。

---

## 二十三、关闭 Spark

如果启动了 standalone 模式，关闭顺序如下：

```bash
stop-worker.sh
stop-master.sh
```

再用 `jps` 检查，确认 `Master` 和 `Worker` 已停止。

---
