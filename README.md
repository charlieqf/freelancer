# Freelancer - 太空冒险游戏

基于Flask+Python+Vue+HTML开发的单人太空冒险游戏，灵感来源于微软的同名游戏。

## 项目简介

Freelancer是一款单人太空冒险游戏，包含飞船和装备、探索、贸易、走私、战斗、势力关系等元素。本项目使用Flask作为后端，Vue.js作为前端框架，MySQL作为数据库。

## 主要功能

- **飞船系统**：购买、升级和自定义不同类型的飞船
- **探索系统**：探索广阔的宇宙，发现新的星系和星球
- **贸易系统**：在不同星系之间进行商品交易
- **走私系统**：高风险高回报的非法物品交易
- **战斗系统**：与太空中的敌对势力进行战斗
- **势力关系**：与不同势力建立关系，影响游戏进程
- **任务系统**：完成各种任务以获取奖励和声望

## 技术栈

- **后端**: Python + Flask
- **前端**: Vue.js + HTML/CSS
- **数据库**: MySQL

## 项目结构

```
freelancer/
├── backend/                  # Flask后端
│   ├── app/                  # 应用主目录
│   │   ├── api/              # API路由
│   │   ├── models/           # 数据库模型
│   │   ├── services/         # 业务逻辑层
│   │   ├── utils/            # 工具函数
│   │   └── __init__.py       # 应用初始化
│   ├── config.py             # 配置文件
│   ├── requirements.txt      # 依赖项
│   └── run.py                # 应用入口
├── frontend/                 # Vue前端
│   ├── public/               # 静态资源
│   ├── src/                  # 源代码
│   │   ├── assets/           # 资源文件
│   │   ├── components/       # 组件
│   │   ├── router/           # 路由配置
│   │   ├── store/            # Vuex状态管理
│   │   ├── views/            # 页面视图
│   │   ├── App.vue           # 根组件
│   │   └── main.js           # 入口文件
│   ├── package.json          # 依赖配置
│   └── vue.config.js         # Vue配置
├── database/                 # 数据库相关
│   └── schema.sql            # 数据库定义文件
└── README.md                 # 说明文档
```

## 安装与运行

### 环境要求

- Python 3.8+
- Node.js 14+
- MySQL 8.0+

### 后端设置

1. 进入后端目录
   ```
   cd backend
   ```

2. 创建并激活虚拟环境
   ```
   python -m venv venv
   venv\Scripts\activate
   ```

3. 安装依赖
   ```
   pip install -r requirements.txt
   ```

4. 数据库设置
   ```
   # 初始化数据库
   python init_db.py init
   
   # 导入游戏初始数据
   python init_db.py import
   ```

5. 启动服务器
   ```
   python run.py
   ```

### 前端设置

1. 进入前端目录
   ```
   cd frontend
   ```

2. 安装依赖
   ```
   npm install
   ```

3. 启动开发服务器
   ```
   npm run serve
   ```

## 数据库管理

### 数据库实例

- **类型**: MySQL 8.0+
- **位置**: 运行在WSL2 Ubuntu中
- **连接信息**:
  - 主机: 172.26.61.141
  - 端口: 3306
  - 用户: root
  - 密码: Fq830815850321
  - 数据库: freelancer (开发环境)
  - 数据库: freelancer_test (测试环境)

### 初始化数据库

项目提供了专门的数据库初始化脚本:

```bash
# 创建数据库并初始化表结构
python init_db.py init

# 导入初始游戏数据
python init_db.py import
```

### 数据库结构更新

项目使用Flask-Migrate (Alembic) 来管理数据库结构变更:

1. **修改模型**: 先在`app/models/`目录下修改相应的模型类

2. **创建迁移脚本**:
   ```bash
   flask db migrate -m "描述此次变更"
   ```

3. **检查**: 检查`migrations/versions/`目录下生成的迁移脚本

4. **应用变更**:
   ```bash
   flask db upgrade
   ```

5. **回滚变更** (如果需要):
   ```bash
   flask db downgrade
   ```

### 数据库架构文件

完整的游戏数据库结构在以下文件中定义:
- `database/schema_part1.sql`
- `database/schema_part2.sql`
- `database/schema_part3.sql`

这些文件包含表结构、关系定义和示例数据。

## 开发说明

- 后端API文档可通过 `/api/docs` 访问
- 游戏数据库设计文档位于 `database/schema.sql`

## 许可证

本项目仅供学习和个人使用。
