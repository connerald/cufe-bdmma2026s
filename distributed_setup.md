# 从单机到分布式集群的配置差异

本指南专注于**单机模式 → 分布式模式**的配置变化。假设你已按照 `hadoop-spark-setup.md` 完成了单机配置，此文档只列出需要修改的部分。

---

## 一、集群规划（3台机器）

### 集群架构

```
┌────────────────────────┐
│  Master（192.168.1.100）│
│  NameNode              │
│  ResourceManager       │
│  Spark Master          │
└────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ Slave-1       │ Slave-2       │ Slave-3 │
│ DataNode      │ DataNode      │ DataNode│
│ NodeManager   │ NodeManager   │ NodeM..│
│ Spark Worker  │ Spark Worker  │ Spark..│
└─────────────────────────────────────────┘
  192.168.1.101   192.168.1.102   192.168.1.103
```

### 节点映射表

| 角色 | 主机名 | IP地址 | 用途 |
|------|--------|--------|------|
| Master | hadoop-master | 192.168.1.100 | NameNode, ResourceManager, Spark Master |
| Slave-1 | hadoop-slave1 | 192.168.1.101 | DataNode, NodeManager, Spark Worker |
| Slave-2 | hadoop-slave2 | 192.168.1.102 | DataNode, NodeManager, Spark Worker |
| Slave-3 | hadoop-slave3 | 192.168.1.103 | DataNode, NodeManager, Spark Worker |

**将这些IP地址替换为你实际网络的真实IP。**

---

## 二、前置条件

假设你已完成以下工作（参考 `hadoop-spark-setup.md`）：
- ✅ 3台Ubuntu 22.04安装完成
- ✅ Java 8已安装
- ✅ SSH服务已启动
- ✅ Hadoop 和 Spark 已安装
- ✅ JAVA_HOME、HADOOP_HOME、SPARK_HOME已配置

---

## 三、单机 → 分布式的主要差异

| 方面 | 单机模式 | 分布式模式 |
|------|---------|----------|
| **HDFS地址** | `hdfs://localhost:9000` | `hdfs://hadoop-master:9000` |
| **副本数** | 1 | 3（3台Slave） |
| **NameNode角色** | 本机 | Master节点专用 |
| **DataNode数量** | 1 | 3 |
| **workers文件** | localhost | hadoop-slave1, hadoop-slave2, hadoop-slave3 |
| **SSH登录** | 本机免密 | Master→Slave无密码 |
| **Spark Master** | localhost:7077 | hadoop-master:7077 |

---

## 四、分布式特有配置

### 4.1 所有3台机器上：修改 /etc/hosts

```bash
sudo vim /etc/hosts
```

添加以下行（替换为你实际的IP）：

```
192.168.1.100  hadoop-master
192.168.1.101  hadoop-slave1
192.168.1.102  hadoop-slave2
192.168.1.103  hadoop-slave3
```

### 4.2 Master节点：SSH密钥配置

在Master上，生成无密码SSH密钥：

```bash
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

然后将Master的公钥分发到所有Slave：

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@hadoop-slave1
ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@hadoop-slave2
ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@hadoop-slave3
```

验证无密码登录：

```bash
ssh hadoop@hadoop-slave1  # 应该无需输入密码
exit
```

### 4.3 所有机器上：安装Hadoop和Spark

如果还未安装，需要在所有3台机器上安装：

```bash
# 在所有机器上
cd ~
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.4/hadoop-3.2.4.tar.gz
tar -xzf hadoop-3.2.4.tar.gz
mv hadoop-3.2.4 hadoop

wget https://archive.apache.org/dist/spark/spark-3.5.8/spark-3.5.8-bin-hadoop3.tgz
tar -xzf spark-3.5.8-bin-hadoop3.tgz
mv spark-3.5.8-bin-hadoop3 spark
```

---

## 五、配置文件修改（只需在Master修改，然后同步）

### 5.1 core-site.xml

**修改点：** HDFS地址从localhost改为hadoop-master

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoop-master:9000</value>
    </property>
</configuration>
```

### 5.2 hdfs-site.xml

**修改点：** 副本数从1改为3，并添加NameNode地址

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>  <!-- 改为3，分布式有3个Slave -->
    </property>
    
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://~/hadoop/dfs/name</value>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://~/hadoop/dfs/data</value>
    </property>
</configuration>
```

### 5.3 yarn-site.xml

**修改点：** ResourceManager从localhost改为hadoop-master

```xml
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>hadoop-master</value>  <!-- 改为Master主机名 -->
    </property>

    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
```

### 5.4 workers 文件

**修改点：** 从localhost改为3个Slave的主机名

```bash
vim $HADOOP_HOME/etc/hadoop/workers
```

内容改为：

```
hadoop-slave1
hadoop-slave2
hadoop-slave3
```

### 5.5 Spark spark-env.sh

**修改点：** 指向分布式的Master和Hadoop配置

```bash
cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
vim $SPARK_HOME/conf/spark-env.sh
```

添加：

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export SPARK_MASTER_HOST=hadoop-master
export SPARK_MASTER_PORT=7077
export HADOOP_CONF_DIR=~/hadoop/etc/hadoop
export YARN_CONF_DIR=~/hadoop/etc/hadoop
```

### 5.6 Spark workers 文件

```bash
cp $SPARK_HOME/conf/workers.template $SPARK_HOME/conf/workers
vim $SPARK_HOME/conf/workers
```

内容改为：

```
hadoop-master
hadoop-slave1
hadoop-slave2
hadoop-slave3
```

---

## 六、配置文件同步

在Master上，将修改好的配置同步到所有Slave：

```bash
# 同步Hadoop配置
scp -r $HADOOP_HOME/etc/hadoop/* hadoop@hadoop-slave1:~/hadoop/etc/hadoop/
scp -r $HADOOP_HOME/etc/hadoop/* hadoop@hadoop-slave2:~/hadoop/etc/hadoop/
scp -r $HADOOP_HOME/etc/hadoop/* hadoop@hadoop-slave3:~/hadoop/etc/hadoop/

# 同步Spark配置
scp -r $SPARK_HOME/conf/* hadoop@hadoop-slave1:~/spark/conf/
scp -r $SPARK_HOME/conf/* hadoop@hadoop-slave2:~/spark/conf/
scp -r $SPARK_HOME/conf/* hadoop@hadoop-slave3:~/spark/conf/
```

---

## 七、启动分布式集群

### 7.1 格式化NameNode（仅首次，Master上）

```bash
hdfs namenode -format
```

### 7.2 启动Hadoop（Master上）

```bash
# 启动HDFS和YARN
start-all.sh

# 或分别启动
start-dfs.sh
start-yarn.sh
```

### 7.3 启动Spark（Master上）

```bash
$SPARK_HOME/sbin/start-all.sh
```

### 7.4 验证启动

```bash
# Master上查看进程
jps  # 应该看到 NameNode, ResourceManager, Master等

# 查看Slave节点
hdfs dfs -report  # 应该看到3个DataNode
yarn node -list -all  # 应该看到3个NodeManager
```

---

## 八、Web UI 访问

| 服务 | URL | 说明 |
|------|-----|------|
| HDFS NameNode | http://192.168.1.100:50070 | 查看HDFS状态、文件、DataNode |
| YARN ResourceManager | http://192.168.1.100:8088 | 查看任务、资源、NodeManager |
| Spark Master | http://192.168.1.100:8080 | 查看Worker节点和应用 |

---

## 九、项目集成：修改上传脚本

编辑 `scripts/upload_sample_to_hdfs.sh`，改为使用分布式地址：

```bash
#!/bin/bash
# 分布式配置
HDFS_NAMENODE="hdfs://hadoop-master:9000"
HDFS_USER="hadoop"
PROJECT_DIR="/user/$HDFS_USER/cufe-bdmma2026s"

hdfs dfs -mkdir -p $PROJECT_DIR/data/processed
hdfs dfs -put -f data/processed/user_behavior_sample.csv $PROJECT_DIR/data/processed/
echo "上传完成到 $HDFS_NAMENODE$PROJECT_DIR/data/processed/"
```

## 十、项目集成：修改任务提交命令

运行Spark SQL任务时使用YARN模式（而非本地模式）：

```bash
spark-submit \
  --master yarn \
  --deploy-mode client \
  --driver-memory 2g \
  --executor-memory 2g \
  --executor-cores 2 \
  --num-executors 3 \
  scripts/run_spark_sql.py
```

---

## 十一、常用命令对比

| 操作 | 单机模式 | 分布式模式 |
|------|---------|----------|
| 查看DataNode | hdfs dfs -report | hdfs dfs -report（看3个） |
| 查看任务 | yarn node -list | yarn node -list -all（看3个） |
| 启动集群 | start-all.sh | Master上：start-all.sh |
| 提交任务 | spark-submit --master local | spark-submit --master yarn |
| 查看Spark状态 | http://localhost:8080 | http://hadoop-master:8080 |

---

## 十二、故障排查

### 问题：Slave的DataNode起不来

检查Slave上的log：
```bash
# Slave上
tail -f ~/hadoop/logs/hadoop-*-datanode-*.log
```

常见原因：
- hosts文件未配置 → 检查 `/etc/hosts`
- NameNode格式化ID不一致 → 删除Slave的dfs/data目录，重新启动
- SSH无密码登录未配置 → 在Master重新执行ssh-copy-id

### 问题：YARN看不到Slave的NodeManager

检查：
```bash
# Slave上查看日志
tail -f ~/hadoop/logs/hadoop-*-nodemanager-*.log

# 检查是否能ping通Master
ping hadoop-master
```

### 问题：Spark任务无法读取HDFS

在Spark任务中检查HDFS路径是否使用了分布式地址：

```python
# ❌ 错误（本地路径）
df = spark.read.csv("data/processed/user_behavior_sample.csv")

# ✅ 正确（HDFS路径）
df = spark.read.csv("hdfs://hadoop-master:9000/user/hadoop/cufe-bdmma2026s/data/processed/user_behavior_sample.csv")
```

---

## 十三、快速检查清单

- [ ] 3台机器IP分配完毕
- [ ] 所有机器 `/etc/hosts` 已配置
- [ ] Master→Slave SSH无密码登录已配置
- [ ] 所有机器已安装Hadoop和Spark
- [ ] Master修改了所有配置文件
- [ ] 配置文件已同步到所有Slave
- [ ] 所有机器创建了dfs/name和dfs/data目录
- [ ] NameNode已格式化
- [ ] HDFS和YARN已启动
- [ ] Spark集群已启动
- [ ] 3个DataNode都在线
- [ ] 3个NodeManager都在线
- [ ] Web UI能正常访问

---

## 十四、反向切换：从分布式回到单机

如果需要恢复为单机模式，只需修改配置文件：

```xml
<!-- core-site.xml -->
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>  <!-- 改回localhost -->
</property>
```

```xml
<!-- hdfs-site.xml -->
<property>
    <name>dfs.replication</name>
    <value>1</value>  <!-- 改回1 -->
</property>
```

```
<!-- workers -->
localhost  <!-- 改回localhost -->
```

然后重新格式化NameNode并启动即可。
