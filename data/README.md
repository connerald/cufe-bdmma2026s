# 数据目录说明

本项目使用的原始数据集是淘宝用户购物行为数据集，数据文件较大，因此未直接提交到 Git 仓库。

## 获取方式

请从阿里云天池平台获取原始数据，然后将文件放到本目录下。

- 数据集链接：<https://tianchi.aliyun.com/dataset/649/comment>
- 放置位置：`data/raw`

## 提交规则

- 只提交说明文件和目录占位文件，不要提交原始大数据文件。
- 如果数据文件名固定，可以在代码或实验说明中写清楚文件名。

## 目录占位

本目录保留 `.gitkeep` 仅用于让空目录被 Git 跟踪。

## 数据文件说明

- **文件名**: `UserBehavior.csv`
- **列（按顺序）**: 用户ID, 商品ID, 商品类目ID, 行为类型, 时间戳
- **格式**: 纯数据文件，无表头（no header）。每行为一条记录，字段由逗号分隔，列按上面顺序排列。
- **使用提示**: 读取时请显式指定无表头并按顺序映射列名。例如在 Python pandas 中使用 `header=None` 然后 `names=["user_id","item_id","category_id","behavior_type","timestamp"]`。

## 天池网页原始数据说明

### 1. 概述

UserBehavior 是阿里巴巴提供的淘宝用户行为数据集，用于隐式反馈推荐问题的研究。

### 2. 数据介绍

本数据集包含 2017 年 11 月 25 日至 2017 年 12 月 3 日之间、约一百万随机用户的全部行为数据，行为包括点击、购买、加购和收藏。数据组织形式类似 MovieLens-20M，即每一行表示一条用户行为，由用户ID、商品ID、商品类目ID、行为类型和时间戳组成，并以逗号分隔。

文件信息如下：

| 文件名称 | 说明 | 包含特征 |
| --- | --- | --- |
| `UserBehavior.csv` | 包含所有的用户行为数据 | 用户ID、商品ID、商品类目ID、行为类型、时间戳 |

各字段说明如下：

| 列名称 | 说明 |
| --- | --- |
| 用户ID | 整数类型，序列化后的用户ID |
| 商品ID | 整数类型，序列化后的商品ID |
| 商品类目ID | 整数类型，序列化后的商品所属类目ID |
| 行为类型 | 字符串，枚举类型，包括 `pv`、`buy`、`cart`、`fav` |
| 时间戳 | 行为发生的时间戳 |

用户行为类型共有四种：

| 行为类型 | 说明 |
| --- | --- |
| `pv` | 商品详情页 pv，等价于点击 |
| `buy` | 商品购买 |
| `cart` | 将商品加入购物车 |
| `fav` | 收藏商品 |

数据集规模如下：

| 维度 | 数量 |
| --- | ---: |
| 用户数量 | 987,994 |
| 商品数量 | 4,162,024 |
| 商品类目数量 | 9,439 |
| 所有行为数量 | 100,150,807 |

### 3. 引用

1. Han Z, Xiang L, Pengye Z, et al. 2018. Learning Tree-based Deep Model for Recommender Systems. In Proceedings of the 24th ACM SIGKDD International Conference on Knowledge Discovery & Data Mining.
2. Han Z, Daqing C, Ziru X, et al. 2019. Joint Optimization of Tree-based Index and Deep Model for Recommender Systems. In Advances in Neural Information Processing Systems.
3. Jingwei Z, Ziru X, Wei D, et al. 2020. Learning Optimal Tree Models under Beam Search. In International Conference on Machine Learning.

如果您发表的论文有使用本数据集，请发邮件到 `tianchi_open_dataset@alibabacloud.com`，回复论文链接，工作人员会给您寄送天池数据集小礼品。

### 4. 遵循协议

该数据集遵循协议：CC BY-NC-SA 4.0。