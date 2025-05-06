# Freelancer 数据库架构说明文档

## 概述

本文档详细描述了Freelancer太空冒险游戏的数据库架构设计，包括表结构、关系以及设计考量。数据库采用MySQL实现，并使用了完整的外键约束确保数据完整性。

## 数据库结构

数据库结构被分为三个主要部分：

- **schema_part1.sql**: 基础游戏世界和用户系统
- **schema_part2.sql**: 经济贸易和任务战斗系统
- **schema_part3.sql**: 游戏进度、设置以及索引与延迟的外键约束

### 表分组

#### 用户与角色相关表
- `users`: 用户账号信息
- `user_achievements`: 用户成就记录

#### 势力相关表
- `factions`: 游戏内的各大势力
- `faction_relationships`: 势力之间的关系
- `player_faction_standing`: 玩家与各势力的关系

#### 游戏世界表
- `manufacturers`: 制造商信息
- `star_systems`: 星系信息
- `planets`: 行星信息
- `stations`: 空间站信息
- `jump_gates`: 星系间跳跃门

#### 飞船相关表
- `ship_models`: 飞船型号定义
- `player_ships`: 玩家拥有的飞船
- `equipment_types`: 装备类型
- `equipment_items`: 装备项目
- `ship_equipment`: 飞船装备
- `ship_cargo_items`: 飞船货物

#### 经济贸易相关表
- `commodities`: 商品信息
- `market_prices`: 市场价格
- `trade_history`: 交易历史

#### 任务战斗相关表
- `mission_types`: 任务类型
- `missions`: 具体任务
- `player_missions`: 玩家任务状态
- `enemy_types`: 敌人类型
- `combat_encounters`: 战斗记录

#### 游戏进度和设置相关表
- `game_events`: 游戏事件
- `player_discoveries`: 玩家发现
- `player_statistics`: 玩家统计数据
- `game_settings`: 游戏设置
- `game_logs`: 游戏日志

## 关键表详解

### 用户系统

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    credits DECIMAL(15,2) DEFAULT 1000.00,
    faction_id INT,
    current_system_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

用户表存储基本账户信息，包括金钱(credits)、所属势力和当前位置。

### 飞船系统

```sql
CREATE TABLE player_ships (
    ship_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    model_id INT NOT NULL,
    name VARCHAR(100),
    current_health INT,
    current_location_type ENUM('system', 'planet', 'station'),
    current_location_id INT,
    x_coord DECIMAL(10,2),
    y_coord DECIMAL(10,2),
    z_coord DECIMAL(10,2),
    ship_status ENUM('docked', 'in_orbit', 'in_space', 'in_warp') NOT NULL,
    is_active BOOLEAN DEFAULT FALSE
)
```

玩家飞船表采用了复合定位系统，可以通过位置类型、ID、精确坐标和状态共同描述飞船当前位置。

### 经济系统

```sql
CREATE TABLE market_prices (
    price_id INT PRIMARY KEY AUTO_INCREMENT,
    station_id INT NOT NULL,
    commodity_id INT NOT NULL,
    buy_price DECIMAL(15,2),
    sell_price DECIMAL(15,2),
    available_quantity INT,
    demand_level TINYINT,
    last_updated DATETIME
)
```

市场价格表记录各空间站商品的价格波动，支持动态经济系统。

## 外键关系与循环依赖

为解决表之间的循环依赖关系，采用了以下策略：

1. **分离创建顺序**: 将表创建分为三个部分，先创建无依赖的基础表。
2. **延迟外键约束**: 使用ALTER TABLE语句在所有表创建完成后添加外键约束。

举例：

```sql
-- 创建表时不添加外键
CREATE TABLE star_systems (
    system_id INT PRIMARY KEY AUTO_INCREMENT,
    controlling_faction_id INT
)

-- 后续添加外键约束
ALTER TABLE star_systems
ADD CONSTRAINT fk_system_controlling_faction
FOREIGN KEY (controlling_faction_id) REFERENCES factions(faction_id);
```

## 索引策略

数据库已为常用查询创建了适当的索引，包括：

- 用户名和邮箱索引，加速登录查询
- 市场价格索引，加速经济系统查询
- 飞船位置索引，加速位置相关查询
- 星系坐标索引，加速空间导航查询
- 势力关系索引，加速政治系统查询

## 设计考量

1. **位置表示方法**: 采用类型+ID+坐标三位一体的系统，可灵活表示游戏中所有位置类型。
2. **多对多关系处理**: 如玩家与成就、飞船与装备等多对多关系，均通过中间表实现。
3. **枚举类型**: 大量使用枚举类型限制值域，提高数据完整性。
4. **注释**: 每个表和字段都添加了详细中文注释，便于开发和维护。

## 初始化与迁移

数据库初始化通过`init_db.py`脚本执行：

```bash
python init_db.py init     # 创建表结构
python init_db.py import   # 导入示例数据
```

后续迁移通过Flask-Migrate管理：

```bash
flask db migrate -m "migration message"
flask db upgrade
```
