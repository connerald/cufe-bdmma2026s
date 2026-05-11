# cufe-bdmma2026s
CUFE - Big Data Management Methods and Applications - 2026 Spring

# 基于淘宝用户数据的商业大数据分析

## 数据准备

项目所需原始数据较大，不直接提交到仓库。请先从阿里云下载数据，再放到 [data/](data) 目录下。

- 数据说明见 [data/README.md](data/README.md)
- 仓库已配置为忽略 `data/` 下的原始数据文件，避免大文件误提交

## 任务实现

- 采样脚本：`src/etl/sample_user_behavior.py`
- Spark SQL：`sql/`
- SQL 输出：`output/sql/`
- 实验报告：`output/report/experiment_report.md`

### 推荐执行顺序

1. 放好原始数据 `data/raw/UserBehavior.csv`。
2. 执行 `python src/etl/sample_user_behavior.py`，把前 1/8 的样本导出到 `data/processed/user_behavior_sample.csv`。
3. 执行 `sh scripts/upload_sample_to_hdfs.sh`，把样本上传到 HDFS 的 `/user/$USER/cufe-bdmma2026s/data/processed/user_behavior_sample.csv`。
4. 在 Spark 环境中执行 `spark-submit scripts/run_spark_sql.py`，由 Spark SQL 在导入后的样本上生成 `user_profile` 维表并完成统计。

5. 从 HDFS 取回结果到本地项目目录：

```bash
# 列出 HDFS 上的结果目录（$USER 会被替换为当前用户，若 HDFS 用户不同可用 HDFS_USER 环境变量覆盖）
hdfs dfs -ls /home/${HDFS_USER:-$USER}/cufe-bdmma2026s/output/sql/results

# 将某个查询结果目录复制到本地项目的 output 下
hdfs dfs -get -f /home/${HDFS_USER:-$USER}/cufe-bdmma2026s/output/sql/results/03_time_buckets ./output/sql/results/03_time_buckets

# 或一次性复制全部查询结果到本地
hdfs dfs -get -f /home/${HDFS_USER:-$USER}/cufe-bdmma2026s/output/sql/results/* ./output/sql/results/
```

6. 将 `output/sql/results/` 下的结果整理进实验报告。