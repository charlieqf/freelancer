# 玩家位置状态机设计

## 1. 概述

本文档详细描述Freelancer游戏中玩家位置的状态机设计。玩家在游戏世界中的位置是一个复杂的状态系统，需要精确跟踪玩家在宇宙、星系、行星、空间站等位置间的移动和状态变化。

### 1.1 设计目标

- 准确反映玩家在游戏世界中的物理位置
- 支持所有可能的位置状态和状态转换
- 提供清晰的API来读取和更新玩家位置
- 支持游戏功能如任务系统、交易系统和社交互动
- 易于扩展以适应未来的游戏功能

### 1.2 状态机基本原理

玩家位置状态机采用分层设计，允许玩家同时具有多个维度的状态（物理位置、交通模式、活动状态）。所有状态变化都遵循预定义的转换规则，确保游戏中的位置逻辑合理且一致。

## 2. 位置状态机模型

### 2.1 核心状态层级

我们将玩家位置状态分为三个主要层级：

1. **物理位置层** - 玩家在宇宙中的物理位置
2. **交通模式层** - 玩家使用的交通工具状态
3. **活动状态层** - 玩家当前进行的活动

### 2.2 数据库模型

```sql
CREATE TABLE player_locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    
    -- 物理位置层
    system_id INT,
    planet_id INT,
    station_id INT,
    
    -- 交通模式层
    transport_mode VARCHAR(20),  -- 'on_foot', 'in_ship', 'in_vehicle'
    transport_id INT,            -- 飞船或车辆的ID
    
    -- 活动状态层
    activity_state VARCHAR(20),  -- 'exploring', 'trading', 'docked', 'in_transit'
    
    -- 额外信息
    area_type VARCHAR(20),       -- 'bar', 'hangar', 'market', 'mission_board'
    
    -- 过渡状态信息
    destination_id INT,
    destination_type VARCHAR(20),
    
    -- 时间戳
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- 外键关联
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (system_id) REFERENCES star_systems(system_id),
    FOREIGN KEY (planet_id) REFERENCES planets(planet_id),
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);
```

### 2.3 Python模型

```python
class PlayerLocation(db.Model):
    """玩家位置模型"""
    __tablename__ = 'player_locations'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    player_id = db.Column(db.Integer, db.ForeignKey('players.player_id'), nullable=False)
    
    # 物理位置层
    system_id = db.Column(db.Integer, db.ForeignKey('star_systems.system_id'))
    planet_id = db.Column(db.Integer, db.ForeignKey('planets.planet_id'))
    station_id = db.Column(db.Integer, db.ForeignKey('stations.station_id'))
    
    # 交通模式层
    transport_mode = db.Column(db.String(20))  # 'on_foot', 'in_ship', 'in_vehicle'
    transport_id = db.Column(db.Integer)  # 飞船ID或车辆ID
    
    # 活动状态层
    activity_state = db.Column(db.String(20))  # 'exploring', 'trading', 'docked', 'in_transit'
    
    # 额外信息
    area_type = db.Column(db.String(20))  # 'bar', 'hangar', 'market', 'mission_board'
    
    # 过渡状态信息
    destination_id = db.Column(db.Integer)
    destination_type = db.Column(db.String(20))  # 'system', 'planet', 'station'
    
    # 时间戳
    updated_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # 关系
    player = db.relationship('Player', backref='location')
    system = db.relationship('StarSystem')
    planet = db.relationship('Planet')
    station = db.relationship('SpaceStation')
    
    # 状态查询方法
    def is_in_ship_in_system(self):
        """检查玩家是否在星系中驾驶飞船"""
        return (self.system_id is not None and
                self.transport_mode == 'in_ship' and
                self.activity_state == 'exploring')
    
    def is_in_ship_in_transit(self):
        """检查玩家是否在飞船中处于跃迁状态"""
        return (self.transport_mode == 'in_ship' and
                self.activity_state == 'in_transit')
    
    def is_on_foot_in_station(self):
        """检查玩家是否在空间站内步行"""
        return (self.station_id is not None and
                self.transport_mode == 'on_foot')
                
    def to_dict(self):
        """将位置信息转换为字典"""
        data = {
            'player_id': self.player_id,
            'updated_at': self.updated_at.isoformat()
        }
        
        # 添加物理位置信息
        if self.system_id:
            data['system'] = self.system.to_dict() if self.system else {'system_id': self.system_id}
        if self.planet_id:
            data['planet'] = self.planet.to_dict() if self.planet else {'planet_id': self.planet_id}
        if self.station_id:
            data['station'] = self.station.to_dict() if self.station else {'station_id': self.station_id}
        
        # 添加其他状态信息
        data['transport_mode'] = self.transport_mode
        data['transport_id'] = self.transport_id
        data['activity_state'] = self.activity_state
        data['area_type'] = self.area_type
        
        # 添加目的地信息（如果在过渡状态）
        if self.activity_state == 'in_transit':
            data['destination'] = {
                'id': self.destination_id,
                'type': self.destination_type
            }
        
        return data
```

## 3. 状态定义

### 3.1 物理位置状态

物理位置表示玩家在游戏宇宙中的实际位置：

1. **星系中** - 玩家位于某个星系的开放空间中
2. **行星上** - 玩家位于行星表面
3. **空间站中** - 玩家位于空间站内部
4. **过渡中** - 玩家正在从一个位置移动到另一个位置（如跃迁）

### 3.2 交通模式状态

交通模式表示玩家使用的交通工具：

1. **步行(on_foot)** - 玩家不使用任何交通工具
2. **飞船内(in_ship)** - 玩家在飞船中
3. **车辆内(in_vehicle)** - 玩家在地面车辆中（行星表面）

### 3.3 活动状态

活动状态表示玩家当前进行的活动：

1. **探索(exploring)** - 玩家在自由移动或探索
2. **交易(trading)** - 玩家正在进行交易活动
3. **停靠(docked)** - 玩家的飞船停靠在空间站或行星表面
4. **过渡(in_transit)** - 玩家正在移动到新位置（如跃迁）
5. **战斗(combat)** - 玩家正在参与战斗
6. **任务(mission)** - 玩家正在执行特定任务

### 3.4 特定区域

对于空间站或行星基地，玩家可以在其中的特定区域：

1. **酒吧(bar)** - 酒吧区域，用于社交和获取情报
2. **机库(hangar)** - 飞船停放和维修区域
3. **市场(market)** - 交易商品的区域
4. **任务板(mission_board)** - 获取任务的区域
5. **装备商店(equipment_shop)** - 购买装备的区域
6. **旅馆(inn)** - 休息和保存游戏的区域

## 4. 状态转换

状态转换定义玩家如何从一个状态移动到另一个状态。下面列出了主要的状态转换规则：

### 4.1 物理位置转换

| 当前状态 | 目标状态 | 条件 | 转换描述 |
|------------|----------|------|----------|
| 星系 | 星系 | 过跃迁门 | 从一个星系跃迁到另一个星系 |
| 星系 | 空间站 | 进入空间站 | 当玩家飞船停靠到空间站 |
| 星系 | 行星 | 降落到行星 | 当玩家飞船降落到行星表面 |
| 空间站 | 星系 | 离开空间站 | 当玩家飞船从空间站出发 |
| 行星 | 星系 | 从行星起飞 | 当玩家飞船从行星表面起飞 |
| 行星 | 空间站 | 进入行星上的空间站 | 当玩家进入行星上的空间站 |

### 4.2 交通模式转换

| 当前状态 | 目标状态 | 条件 | 转换描述 |
|------------|----------|------|----------|
| on_foot | in_ship | 登入飞船 | 玩家在停靠港登入飞船 |
| in_ship | on_foot | 离开飞船 | 玩家从停靠的飞船中离开 |
| on_foot | in_vehicle | 进入地面车辆 | 玩家在行星表面进入车辆 |
| in_vehicle | on_foot | 离开地面车辆 | 玩家从地面车辆中离开 |

### 4.3 活动状态转换

| 当前状态 | 目标状态 | 条件 | 转换描述 |
|------------|----------|------|----------|
| exploring | docked | 停靠 | 玩家飞船停靠到空间站或行星表面 |
| docked | exploring | 起飞 | 玩家飞船从空间站或行星起飞 |
| exploring | in_transit | 跃迁 | 玩家进入跃迁状态 |
| in_transit | exploring | 完成跃迁 | 玩家完成跃迁后进入新星系 |
| exploring | combat | 遭遇敌人 | 玩家进入战斗状态 |
| combat | exploring | 脱离战斗 | 玩家结束战斗返回探索状态 |
| exploring | trading | 交易 | 玩家与商人交谈或打开交易界面 |
| trading | exploring | 结束交易 | 玩家关闭交易界面 |

## 5. 实际示例

以下是一些常见场景及对应的玩家位置状态示例：

### 5.1 在太空中驾驶飞船

```json
{
  "player_id": 1,
  "system_id": 42,
  "planet_id": null,
  "station_id": null,
  "transport_mode": "in_ship",
  "transport_id": 101,
  "activity_state": "exploring",
  "area_type": null,
  "updated_at": "2025-05-07T12:15:30Z"
}
```

### 5.2 飞船停靠在空间站，玩家在站内酒吧

```json
{
  "player_id": 1,
  "system_id": 42,
  "planet_id": null,
  "station_id": 156,
  "transport_mode": "on_foot",
  "transport_id": 101,  // 记录停靠的飞船ID
  "activity_state": "exploring",
  "area_type": "bar",
  "updated_at": "2025-05-07T14:30:15Z"
}
```

### 5.3 在行星表面驾驶车辆

```json
{
  "player_id": 1,
  "system_id": 42,
  "planet_id": 23,
  "station_id": null,
  "transport_mode": "in_vehicle",
  "transport_id": 304,  // 地面车辆ID
  "activity_state": "exploring",
  "area_type": null,
  "updated_at": "2025-05-07T16:45:22Z"
}
```

### 5.4 在飞船中跃迁到另一个星系

```json
{
  "player_id": 1,
  "system_id": 42,  // 起始星系
  "planet_id": null,
  "station_id": null,
  "transport_mode": "in_ship",
  "transport_id": 101,
  "activity_state": "in_transit",
  "destination_id": 57,  // 目标星系ID
  "destination_type": "system",
  "updated_at": "2025-05-07T18:20:10Z"
}
```

### 5.5 在空间站市场进行交易

```json
{
  "player_id": 1,
  "system_id": 57,
  "planet_id": null,
  "station_id": 203,
  "transport_mode": "on_foot",
  "transport_id": 101,  // 停靠的飞船
  "activity_state": "trading",
  "area_type": "market",
  "updated_at": "2025-05-07T19:12:45Z"
}
```

### 5.6 在太空中参与战斗

```json
{
  "player_id": 1,
  "system_id": 57,
  "planet_id": null,
  "station_id": null,
  "transport_mode": "in_ship",
  "transport_id": 101,
  "activity_state": "combat",
  "area_type": null,
  "updated_at": "2025-05-07T20:05:33Z"
}
```

## 6. 常见问题处理

### 6.1 在星系中和在飞船中的区分

在本设计中，"在星系中"和"在飞船中"不是互斥的状态，而是位于不同层级的状态：

- "在星系中"是物理位置层的状态 (`system_id` 有值)
- "在飞船中"是交通模式层的状态 (`transport_mode = "in_ship"`)

通常情况下，玩家在星系中飞行时会同时满足这两个状态。当玩家位于空间站内时，物理位置变为"在空间站中"，但飞船的记录仍然保留在 `transport_id` 中，只是 `transport_mode` 变为 `"on_foot"`。

这样的设计允许我们：

1. 记录玩家当前使用的飞船，即使他们暂时离开了飞船
2. 区分玩家是在飞船里主动飞行，还是在空间站/行星上步行
3. 处理复杂情况，如飞船停靠但玩家在站内的场景

### 6.2 跃迁状态的处理

跃迁是一种特殊的过渡状态，它在以下两个方面与普通飞行不同：

1. `activity_state` 设置为 `"in_transit"`
2. 记录目的地信息在 `destination_id` 和 `destination_type` 中

跃迁完成后，系统应自动更新玩家的 `system_id`，并将 `activity_state` 改回 `"exploring"`。

### 6.3 位置历史记录

对于需要保存玩家历史位置的情况，建议：

1. 只记录关键位置变更（首次访问、完成任务等）
2. 使用单独的 `player_location_history` 表
3. 添加记录原因（reason 字段）
