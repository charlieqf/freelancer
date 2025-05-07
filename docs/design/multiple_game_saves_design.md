# 多存档系统设计文档

## 1. 概述

本文档详细描述Freelancer游戏中多存档系统的设计。在单人游戏中，用户可能希望创建多个游戏存档，以尝试不同的游戏路线或保存不同的游戏进度。多存档系统允许用户创建、加载、管理多个游戏存档，为游戏增加更多灵活性和可玩性。

### 1.1 设计目标

- 支持用户创建多个独立的游戏存档
- 提供简单直观的存档管理界面
- 确保不同存档之间的数据隔离和完整性
- 优化数据库设计，避免存档数据冗余
- 提供快速切换存档的机制
- 支持存档备份、恢复和删除功能

### 1.2 系统基本原理

多存档系统的核心是通过`game_id`（存档ID）将用户的游戏数据与特定存档关联起来。系统分为两类数据：存档特定数据（与特定存档关联）和通用游戏数据（所有存档共享）。通过这种方式，游戏可以为每个存档维护独立的游戏状态，同时减少数据冗余。

## 2. 数据库设计

### 2.1 核心存档表设计

```sql
-- 游戏存档表
CREATE TABLE game_saves (
    game_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    save_name VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_played_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    game_version VARCHAR(20),
    total_playtime INT DEFAULT 0,  -- 以秒为单位
    
    -- 游戏进度概述
    credits INT DEFAULT 1000,
    current_system_id INT,
    reputation_level INT DEFAULT 1,
    discovered_systems_count INT DEFAULT 0,
    completed_missions_count INT DEFAULT 0,
    
    -- 可选：存档缩略图
    thumbnail_path VARCHAR(255),
    
    -- 可选：存档状态（正常、自动保存、损坏等）
    status VARCHAR(20) DEFAULT 'active',
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (current_system_id) REFERENCES star_systems(system_id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_last_played_at (last_played_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2.2 需要关联到存档的表

以下表需要添加`game_id`字段，关联到特定的游戏存档：

| 表名 | 描述 | 关联类型 |
|------|------|----------|
| player_locations | 玩家当前位置 | 强关联 |
| player_location_history | 玩家历史位置 | 强关联 |
| player_ships | 玩家拥有的飞船 | 强关联 |
| player_items | 玩家拥有的物品 | 强关联 |
| player_discoveries | 玩家的发现记录 | 强关联 |
| player_missions | 玩家的任务进度 | 强关联 |
| player_trade_history | 玩家的交易历史 | 强关联 |
| player_combat_logs | 玩家的战斗记录 | 强关联 |
| player_relationships | 玩家与NPC的关系 | 强关联 |
| player_achievements | 玩家成就 | 强关联 |

### 2.3 不需要关联到存档的表

以下表是所有存档共享的，不需要添加`game_id`字段：

| 表名 | 描述 | 原因 |
|------|------|------|
| users | 用户账户信息 | 账户级数据 |
| star_systems | 星系基础数据 | 游戏世界基础数据 |
| planets | 行星基础数据 | 游戏世界基础数据 |
| stations | 空间站基础数据 | 游戏世界基础数据 |
| jump_gates | 跳跃点基础数据 | 游戏世界基础数据 |
| factions | 势力基础数据 | 游戏世界基础数据 |
| items | 物品定义 | 游戏规则数据 |
| ships | 飞船定义 | 游戏规则数据 |
| missions | 任务模板 | 游戏规则数据 |

### 2.4 修改后的玩家位置表示例

```sql
-- 修改后的玩家位置表（添加game_id字段）
CREATE TABLE player_locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    game_id INT NOT NULL,  -- 新增：关联到特定存档
    
    -- 物理位置层
    system_id INT,
    planet_id INT,
    station_id INT,
    
    -- 交通模式层
    transport_mode VARCHAR(20),
    transport_id INT,
    
    -- 活动状态层
    activity_state VARCHAR(20),
    area_type VARCHAR(20),
    
    -- 过渡状态信息
    destination_id INT,
    destination_type VARCHAR(20),
    estimated_arrival_time DATETIME,
    
    -- 时间戳
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- 外键关联
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (system_id) REFERENCES star_systems(system_id) ON DELETE SET NULL,
    FOREIGN KEY (planet_id) REFERENCES planets(planet_id) ON DELETE SET NULL,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE SET NULL,
    
    -- 索引
    INDEX idx_user_game (user_id, game_id),
    INDEX idx_system_id (system_id),
    INDEX idx_activity_state (activity_state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 3. 后端API设计

### 3.1 存档管理API

#### 3.1.1 获取用户存档列表

```python
@user_bp.route('/game-saves', methods=['GET'])
@jwt_required()
def get_game_saves():
    """获取用户所有游戏存档"""
    current_user_id = get_jwt_identity()
    
    saves = GameSave.query.filter_by(user_id=current_user_id)\
        .order_by(GameSave.last_played_at.desc())\
        .all()
    
    return jsonify([save.to_dict() for save in saves])
```

#### 3.1.2 创建新存档

```python
@user_bp.route('/game-saves', methods=['POST'])
@jwt_required()
def create_game_save():
    """创建新游戏存档"""
    current_user_id = get_jwt_identity()
    data = request.json
    
    # 创建新存档
    new_save = GameSave(
        user_id=current_user_id,
        save_name=data.get('save_name', f"存档 {datetime.now().strftime('%Y-%m-%d %H:%M')}"),
        game_version=current_app.config.get('GAME_VERSION', '1.0.0')
    )
    
    db.session.add(new_save)
    db.session.commit()
    
    # 初始化新存档的游戏数据
    initialize_new_game_save(new_save.game_id, current_user_id)
    
    return jsonify(new_save.to_dict()), 201
```

#### 3.1.3 加载存档

```python
@user_bp.route('/game-saves/<int:game_id>/load', methods=['POST'])
@jwt_required()
def load_game_save(game_id):
    """加载指定的游戏存档"""
    current_user_id = get_jwt_identity()
    
    # 验证存档归属
    game_save = GameSave.query.filter_by(
        game_id=game_id, 
        user_id=current_user_id
    ).first_or_404()
    
    # 更新最后游玩时间
    game_save.last_played_at = datetime.utcnow()
    db.session.commit()
    
    # 返回初始游戏数据
    return jsonify({
        'message': '存档加载成功',
        'game_save': game_save.to_dict(),
        'initial_data': get_initial_game_data(game_id, current_user_id)
    })
```

#### 3.1.4 删除存档

```python
@user_bp.route('/game-saves/<int:game_id>', methods=['DELETE'])
@jwt_required()
def delete_game_save(game_id):
    """删除指定的游戏存档"""
    current_user_id = get_jwt_identity()
    
    # 验证存档归属
    game_save = GameSave.query.filter_by(
        game_id=game_id, 
        user_id=current_user_id
    ).first_or_404()
    
    # 删除存档（依赖于CASCADE删除关联数据）
    db.session.delete(game_save)
    db.session.commit()
    
    return jsonify({'message': '存档已删除'})
```

### 3.2 游戏数据API修改

所有与玩家特定数据相关的API都需要增加`game_id`参数，例如：

```python
@universe_bp.route('/player/location', methods=['GET'])
@jwt_required()
def get_player_location():
    """获取当前玩家位置信息"""
    current_user_id = get_jwt_identity()
    
    # 获取当前活动的游戏存档
    game_id = request.args.get('game_id')
    if not game_id:
        return jsonify({'message': '缺少必要的game_id参数'}), 400
    
    # 验证存档归属
    game_save = GameSave.query.filter_by(
        game_id=game_id,
        user_id=current_user_id
    ).first_or_404()
    
    # 获取玩家位置
    location = PlayerLocation.query.filter_by(
        user_id=current_user_id,
        game_id=game_id
    ).first()
    
    if not location:
        return jsonify({'message': '未找到玩家位置信息'}), 404
    
    return jsonify(location.to_dict())
```

## 4. 前端实现

### 4.1 存档管理界面

在前端添加存档管理界面，包括以下功能：

1. 显示所有存档列表，包括名称、创建时间、最后游玩时间、游戏时长等信息
2. 创建新存档
3. 加载存档
4. 删除存档
5. 重命名存档

### 4.2 全局存档状态管理

在Vuex中添加存档管理状态：

```javascript
// store/modules/gameSave.js
import axios from 'axios';

export default {
  state: {
    gameSaves: [],
    currentGameSave: null,
    isLoading: false,
    error: null
  },
  
  mutations: {
    SET_GAME_SAVES(state, saves) {
      state.gameSaves = saves;
    },
    SET_CURRENT_GAME_SAVE(state, save) {
      state.currentGameSave = save;
    },
    SET_LOADING(state, loading) {
      state.isLoading = loading;
    },
    SET_ERROR(state, error) {
      state.error = error;
    },
    ADD_GAME_SAVE(state, save) {
      state.gameSaves.unshift(save);
    },
    REMOVE_GAME_SAVE(state, gameId) {
      state.gameSaves = state.gameSaves.filter(save => save.game_id !== gameId);
    }
  },
  
  actions: {
    async fetchGameSaves({ commit }) {
      commit('SET_LOADING', true);
      try {
        const response = await axios.get('/api/user/game-saves');
        commit('SET_GAME_SAVES', response.data);
      } catch (error) {
        commit('SET_ERROR', error.response?.data?.message || '获取存档失败');
      } finally {
        commit('SET_LOADING', false);
      }
    },
    
    async createGameSave({ commit }, saveName) {
      commit('SET_LOADING', true);
      try {
        const response = await axios.post('/api/user/game-saves', { save_name: saveName });
        commit('ADD_GAME_SAVE', response.data);
        return response.data;
      } catch (error) {
        commit('SET_ERROR', error.response?.data?.message || '创建存档失败');
        throw error;
      } finally {
        commit('SET_LOADING', false);
      }
    },
    
    async loadGameSave({ commit }, gameId) {
      commit('SET_LOADING', true);
      try {
        const response = await axios.post(`/api/user/game-saves/${gameId}/load`);
        commit('SET_CURRENT_GAME_SAVE', response.data.game_save);
        return response.data;
      } catch (error) {
        commit('SET_ERROR', error.response?.data?.message || '加载存档失败');
        throw error;
      } finally {
        commit('SET_LOADING', false);
      }
    },
    
    async deleteGameSave({ commit }, gameId) {
      commit('SET_LOADING', true);
      try {
        await axios.delete(`/api/user/game-saves/${gameId}`);
        commit('REMOVE_GAME_SAVE', gameId);
        if (state.currentGameSave && state.currentGameSave.game_id === gameId) {
          commit('SET_CURRENT_GAME_SAVE', null);
        }
      } catch (error) {
        commit('SET_ERROR', error.response?.data?.message || '删除存档失败');
        throw error;
      } finally {
        commit('SET_LOADING', false);
      }
    }
  },
  
  getters: {
    currentGameId: state => state.currentGameSave?.game_id || null,
    gameSaves: state => state.gameSaves,
    isLoading: state => state.isLoading,
    error: state => state.error
  }
};
```

### 4.3 API请求拦截器

添加API请求拦截器，自动为带有玩家数据的请求添加`game_id`参数：

```javascript
// services/apiService.js
import axios from 'axios';
import store from '../store';

// 创建axios实例
const api = axios.create({
  baseURL: process.env.VUE_APP_API_URL || '/api'
});

// 请求拦截器
api.interceptors.request.use(config => {
  // 获取当前活动存档ID
  const currentGameId = store.getters.currentGameId;
  
  // 如果存在当前存档ID，且不是存档管理相关的API
  if (currentGameId && !config.url.includes('/game-saves')) {
    // 对于GET请求，添加到查询参数
    if (config.method === 'get') {
      config.params = {
        ...config.params,
        game_id: currentGameId
      };
    } 
    // 对于其他请求方法，添加到请求体
    else if (config.data) {
      config.data = {
        ...config.data,
        game_id: currentGameId
      };
    }
  }
  
  return config;
}, error => {
  return Promise.reject(error);
});

export default api;
```

## 5. 存档初始化和数据迁移

### 5.1 新存档初始化

当创建新存档时，需要初始化基本游戏数据：

```python
def initialize_new_game_save(game_id, user_id):
    """初始化新游戏存档的基础数据"""
    # 1. 创建初始玩家位置（通常是起始星系）
    starting_system_id = 1  # 假设ID为1的星系是起始星系
    player_location = PlayerLocation(
        user_id=user_id,
        game_id=game_id,
        system_id=starting_system_id,
        transport_mode='in_ship',
        activity_state='exploring'
    )
    
    # 2. 创建玩家初始飞船
    starter_ship = PlayerShip(
        user_id=user_id,
        game_id=game_id,
        ship_template_id=1,  # 初始飞船模板ID
        name="初始飞船",
        condition=100,
        is_active=True
    )
    
    # 3. 添加初始物品和资源
    starter_items = [
        PlayerItem(user_id=user_id, game_id=game_id, item_id=1, quantity=1),  # 基础武器
        PlayerItem(user_id=user_id, game_id=game_id, item_id=5, quantity=1),  # 基础护盾
        PlayerItem(user_id=user_id, game_id=game_id, item_id=10, quantity=100)  # 基础燃料
    ]
    
    # 4. 解锁初始任务
    starter_mission = PlayerMission(
        user_id=user_id,
        game_id=game_id,
        mission_id=1,  # 教程任务ID
        status='active',
        progress=0
    )
    
    # 提交所有初始数据
    db.session.add(player_location)
    db.session.add(starter_ship)
    db.session.add_all(starter_items)
    db.session.add(starter_mission)
    db.session.commit()
    
    # 记录首次位置历史
    player_location_history = PlayerLocationHistory(
        user_id=user_id,
        game_id=game_id,
        system_id=starting_system_id,
        transport_mode='in_ship',
        activity_state='exploring',
        reason='game_start',
        notes='游戏开始初始位置'
    )
    db.session.add(player_location_history)
    db.session.commit()
```

### 5.2 数据库迁移策略

对于已有项目添加多存档支持，需要执行以下迁移步骤：

1. 创建`game_saves`表
2. 为需要关联存档的表添加`game_id`字段
3. 为每个用户创建默认存档，并将其现有数据关联到该存档

```python
def migrate_to_multi_save_system():
    """将现有数据迁移到多存档系统"""
    # 1. 获取所有用户
    users = User.query.all()
    
    for user in users:
        # 2. 为每个用户创建默认存档
        default_save = GameSave(
            user_id=user.user_id,
            save_name="主存档",
            created_at=user.created_at,  # 使用用户创建时间
            last_played_at=datetime.utcnow()
        )
        db.session.add(default_save)
        db.session.flush()  # 获取新存档ID
        
        # 3. 更新用户的所有相关数据，添加game_id字段
        game_id = default_save.game_id
        
        # 更新玩家位置
        player_location = PlayerLocation.query.filter_by(user_id=user.user_id).first()
        if player_location:
            player_location.game_id = game_id
        
        # 更新玩家位置历史
        PlayerLocationHistory.query.filter_by(user_id=user.user_id).update({'game_id': game_id})
        
        # 更新其他相关表...
        # PlayerShip.query.filter_by(user_id=user.user_id).update({'game_id': game_id})
        # PlayerItem.query.filter_by(user_id=user.user_id).update({'game_id': game_id})
        # 等等...
    
    # 4. 提交所有更改
    db.session.commit()
```

## 6. 性能优化和最佳实践

### 6.1 索引优化

为确保多存档系统的高性能，添加以下索引：

1. 所有关联到存档的表都应该有`(user_id, game_id)`组合索引
2. `game_saves`表应该有`user_id`和`last_played_at`索引
3. 根据查询模式优化其他索引

### 6.2 数据缓存策略

为减少数据库查询：

1. 在应用层缓存当前活动存档ID
2. 缓存频繁访问的游戏数据
3. 使用Redis等工具实现会话级缓存

### 6.3 存档限制与管理

1. 限制每个用户的最大存档数量
2. 提供存档备份和导出功能
3. 实现存档自动保存功能
4. 添加存档压缩和清理机制

## 7. 用户界面设计

### 7.1 存档管理界面

存档管理界面应包含以下元素：

1. 存档列表，显示：
   - 存档名称和缩略图
   - 创建时间和最后游玩时间
   - 总游戏时长
   - 当前所在星系
   - 游戏进度概述（声望等级、完成任务数等）
   
2. 操作按钮：
   - 新建存档
   - 加载存档
   - 删除存档
   - 重命名存档
   - 备份存档
   
3. 确认对话框：
   - 删除存档确认
   - 覆盖存档确认

### 7.2 游戏内保存功能

游戏内应该提供以下存档相关功能：

1. 快速保存（覆盖当前存档）
2. 另存为（创建新存档）
3. 加载存档（打开存档列表）
4. 自动保存（定时保存游戏进度）

## 8. 示例代码和用例

### 8.1 创建新游戏场景

```python
# 后端处理
@user_bp.route('/new-game', methods=['POST'])
@jwt_required()
def start_new_game():
    current_user_id = get_jwt_identity()
    data = request.json
    
    # 创建新存档
    new_save = GameSave(
        user_id=current_user_id,
        save_name=data.get('save_name', '新游戏'),
        game_version=current_app.config.get('GAME_VERSION', '1.0.0')
    )
    
    db.session.add(new_save)
    db.session.commit()
    
    # 初始化新游戏数据
    initialize_new_game_save(new_save.game_id, current_user_id)
    
    # 返回初始游戏数据和存档信息
    return jsonify({
        'message': '新游戏已创建',
        'game_save': new_save.to_dict(),
        'initial_data': get_initial_game_data(new_save.game_id, current_user_id)
    }), 201
```

### 8.2 加载并继续游戏场景

```javascript
// 前端处理（Vue组件）
async continueGame(gameId) {
  try {
    // 加载存档
    const gameData = await this.$store.dispatch('loadGameSave', gameId);
    
    // 更新UI和游戏状态
    this.$store.dispatch('updatePlayerLocation', gameData.initial_data.location);
    this.$store.dispatch('updatePlayerInventory', gameData.initial_data.inventory);
    this.$store.dispatch('updatePlayerShips', gameData.initial_data.ships);
    this.$store.dispatch('updatePlayerMissions', gameData.initial_data.missions);
    
    // 导航到游戏主界面
    this.$router.push({ name: 'galaxy-map' });
    
    // 显示欢迎回来消息
    this.$notify({
      title: '继续游戏',
      message: `欢迎回到 ${gameData.game_save.save_name}`,
      type: 'success'
    });
  } catch (error) {
    this.$notify.error({
      title: '加载失败',
      message: error.message || '无法加载游戏存档'
    });
  }
}
```

## 9. 结论

多存档系统是单人游戏中的重要功能，它显著提升了游戏的可玩性和用户体验。通过本文档描述的设计方案，Freelancer游戏可以实现完善的多存档系统，支持用户创建、管理和切换不同的游戏存档。

实现多存档系统的关键在于：

1. 使用`game_id`字段将用户游戏数据与特定存档关联
2. 区分存档特定数据和通用游戏数据
3. 优化数据库设计和索引
4. 提供直观的用户界面
5. 确保数据一致性和完整性

通过这种设计，游戏可以为用户提供更加个性化和灵活的游戏体验。
