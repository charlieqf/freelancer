-- 《Freelancer》太空冒险游戏数据库定义文件 (Part 2)
-- 经济与贸易表、任务表
USE freelancer;

-- -----------------------------------------------------
-- 经济与贸易表
-- -----------------------------------------------------

-- 市场价格表
-- 记录各空间站的商品价格
CREATE TABLE market_prices (
    price_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '价格记录ID，主键',
    game_id INT NOT NULL COMMENT '存档ID',
    station_id INT NOT NULL COMMENT '空间站ID',
    item_id INT NOT NULL COMMENT '商品ID',
    buy_price DECIMAL(15,2) COMMENT '玩家可以购买的价格',
    sell_price DECIMAL(15,2) COMMENT '玩家可以出售的价格',
    available_quantity INT COMMENT '市场上可用数量',
    demand_level TINYINT COMMENT '需求等级(1-10)',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '价格最后更新时间',
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (station_id) REFERENCES stations(station_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    INDEX idx_game_station_item (game_id, station_id, item_id),
    INDEX idx_last_updated (last_updated)
) COMMENT '记录每个空间站的商品价格信息';

-- 交易历史表
-- 记录玩家的交易历史
CREATE TABLE trade_history (
    trade_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '交易ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    game_id INT NOT NULL COMMENT '存档ID',
    ship_id INT NOT NULL COMMENT '使用的飞船ID',
    station_id INT NOT NULL COMMENT '交易的空间站ID',
    item_id INT NOT NULL COMMENT '交易的商品ID',
    quantity INT NOT NULL COMMENT '交易数量',
    unit_price DECIMAL(15,2) NOT NULL COMMENT '单价',
    total_price DECIMAL(15,2) NOT NULL COMMENT '总价',
    transaction_type ENUM('buy', 'sell') COMMENT '交易类型：买入或卖出',
    transaction_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '交易时间',
    tax_amount DECIMAL(15,2) DEFAULT 0.00 COMMENT '支付的交易税',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (ship_id) REFERENCES player_ships(ship_id),
    FOREIGN KEY (station_id) REFERENCES stations(station_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    INDEX idx_user_game (user_id, game_id),
    INDEX idx_transaction_time (transaction_time)
) COMMENT '记录所有玩家的交易历史';

-- -----------------------------------------------------
-- 任务和战斗表
-- -----------------------------------------------------

-- 任务类型表
-- 定义游戏中的任务类型
CREATE TABLE mission_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '类型ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '任务类型名称',
    description TEXT COMMENT '类型描述',
    category ENUM('delivery', 'combat', 'exploration', 'smuggling', 'rescue') COMMENT '任务类别',
    base_reward DECIMAL(15,2) COMMENT '基础奖励',
    base_reputation INT COMMENT '基础声望奖励',
    difficulty_multiplier FLOAT DEFAULT 1.0 COMMENT '难度系数'
) COMMENT '定义游戏中的任务类型';

-- 任务表
-- 存储游戏中所有可用任务
CREATE TABLE missions (
    mission_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '任务ID，主键',
    type_id INT NOT NULL COMMENT '任务类型ID',
    title VARCHAR(100) NOT NULL COMMENT '任务标题',
    description TEXT COMMENT '任务描述',
    giver_station_id INT NOT NULL COMMENT '发布任务的空间站ID',
    target_system_id INT NULL COMMENT '目标星系ID',
    target_planet_id INT NULL COMMENT '目标行星ID',
    target_station_id INT NULL COMMENT '目标空间站ID',
    reward_credits DECIMAL(15,2) COMMENT '奖励金额',
    reward_reputation INT COMMENT '奖励声望',
    time_limit_hours INT NULL COMMENT '时间限制（小时）',
    difficulty_level TINYINT COMMENT '任务难度(1-10)',
    required_commodity_id INT NULL COMMENT '需要的商品ID',
    required_quantity INT NULL COMMENT '需要的商品数量',
    is_story_mission BOOLEAN DEFAULT FALSE COMMENT '是否为主线任务',
    is_repeatable BOOLEAN DEFAULT FALSE COMMENT '是否可重复完成',
    FOREIGN KEY (type_id) REFERENCES mission_types(type_id),
    FOREIGN KEY (giver_station_id) REFERENCES stations(station_id),
    FOREIGN KEY (target_system_id) REFERENCES star_systems(system_id),
    FOREIGN KEY (target_planet_id) REFERENCES planets(planet_id),
    FOREIGN KEY (target_station_id) REFERENCES stations(station_id),
    FOREIGN KEY (required_commodity_id) REFERENCES commodities(commodity_id)
) COMMENT '存储游戏中所有可用任务';

-- 玩家任务表
-- 记录玩家接受的任务
CREATE TABLE player_missions (
    player_mission_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '玩家任务ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    game_id INT NOT NULL COMMENT '存档ID',
    mission_id INT NOT NULL COMMENT '任务ID',
    status ENUM('active', 'completed', 'failed', 'abandoned') DEFAULT 'active' COMMENT '任务状态',
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    completion_time DATETIME NULL COMMENT '完成时间',
    current_progress INT DEFAULT 0 COMMENT '当前进度',
    total_steps INT COMMENT '总步骤数',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (mission_id) REFERENCES missions(mission_id),
    INDEX idx_user_game (user_id, game_id),
    INDEX idx_mission_status (status)
) COMMENT '记录玩家接受的任务及其状态';

-- 敌人类型表
-- 定义游戏中的敌人类型
CREATE TABLE enemy_types (
    enemy_type_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '敌人类型ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '敌人类型名称',
    description TEXT COMMENT '敌人描述',
    faction_id INT COMMENT '所属势力ID',
    difficulty_level TINYINT COMMENT '难度等级(1-10)',
    base_health INT COMMENT '基础生命值',
    base_damage INT COMMENT '基础伤害值',
    base_reward DECIMAL(15,2) COMMENT '基础奖励',
    ship_model_id INT COMMENT '使用的飞船型号ID',
    FOREIGN KEY (ship_model_id) REFERENCES ship_models(model_id),
    FOREIGN KEY (faction_id) REFERENCES factions(faction_id)
) COMMENT '定义游戏中的敌人类型';

-- 战斗遭遇表
-- 记录玩家的战斗经历
CREATE TABLE combat_encounters (
    encounter_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '遭遇ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    game_id INT NOT NULL COMMENT '存档ID',
    player_ship_id INT NOT NULL COMMENT '玩家使用的飞船ID',
    system_id INT NOT NULL COMMENT '发生战斗的星系ID',
    enemy_type_id INT NOT NULL COMMENT '敌人类型ID',
    enemy_count INT COMMENT '敌人数量',
    outcome ENUM('victory', 'defeat', 'escape', 'in_progress') DEFAULT 'in_progress' COMMENT '战斗结果',
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    end_time DATETIME NULL COMMENT '结束时间',
    reward_credits DECIMAL(15,2) NULL COMMENT '获得的奖励金额',
    reward_reputation INT NULL COMMENT '获得的声望奖励',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (player_ship_id) REFERENCES player_ships(ship_id),
    FOREIGN KEY (system_id) REFERENCES star_systems(system_id),
    FOREIGN KEY (enemy_type_id) REFERENCES enemy_types(enemy_type_id),
    INDEX idx_user_game (user_id, game_id)
) COMMENT '记录玩家的战斗经历';

-- 数据示例：mission_types
INSERT INTO mission_types (name, description, category, base_reward, base_reputation, difficulty_multiplier)
VALUES 
('货物运输', '在不同空间站之间运输货物', 'delivery', 1000.00, 5, 1.0),
('消灭敌人', '在特定区域消灭敌对势力', 'combat', 1500.00, 10, 1.5),
('探索未知', '探索未知的星系或行星', 'exploration', 2000.00, 15, 1.2),
('走私行动', '运输违禁品，避开巡逻队', 'smuggling', 3000.00, 0, 2.0),
('紧急救援', '营救被困人员或飞船', 'rescue', 2500.00, 20, 1.8);

-- 数据示例：missions
INSERT INTO missions (type_id, title, description, giver_station_id, target_system_id, target_station_id, reward_credits, reward_reputation, time_limit_hours, difficulty_level, required_commodity_id, required_quantity, is_story_mission)
VALUES 
(1, '医疗物资运输', '将急需的医疗物资运送到火星基地', 1, 1, 2, 1000.00, 5, 2, 2, 2, 10, FALSE),
(2, '清除海盗威胁', '消灭在天狼星系活动的海盗', 3, 3, NULL, 2000.00, 15, 5, 5, NULL, NULL, FALSE),
(3, '探索猎户座', '探索猎户座星云并收集数据', 4, 4, NULL, 3000.00, 20, 8, 7, NULL, NULL, TRUE),
(4, '高价值物品运输', '秘密运输一批军用装备到半人马前哨', 2, 2, 3, 5000.00, -5, 3, 6, 7, 5, FALSE),
(5, '援救受困矿工', '前往猎户矿业基地救援被困矿工', 4, 4, 5, 2500.00, 25, 4, 4, NULL, NULL, FALSE);

-- 数据示例：player_missions
INSERT INTO player_missions (user_id, mission_id, status, start_time, current_progress, total_steps)
VALUES 
(1, 1, 'active', '2025-05-04 14:30:00', 1, 3),
(1, 3, 'active', '2025-05-05 09:15:00', 0, 5),
(2, 2, 'completed', '2025-05-03 11:20:00', 5, 5),
(2, 4, 'active', '2025-05-05 16:45:00', 2, 4),
(3, 5, 'failed', '2025-05-02 13:10:00', 1, 3);

-- 数据示例：enemy_types
INSERT INTO enemy_types (name, description, faction_id, difficulty_level, base_health, base_damage, base_reward, ship_model_id)
VALUES 
('海盗侦察兵', '装备轻型武器的快速海盗飞船', 4, 2, 500, 50, 500.00, 1),
('海盗战士', '中等火力的标准海盗飞船', 4, 4, 1000, 100, 1000.00, 3),
('海盗头目', '重装火力的海盗精英飞船', 4, 7, 2000, 200, 3000.00, 3),
('帝国巡逻兵', '帝国边境巡逻队', 1, 5, 1500, 150, 0.00, 3),
('商业保安', '保护贸易路线的安保人员', 3, 3, 800, 80, 0.00, 1);

-- 数据示例：combat_encounters
INSERT INTO combat_encounters (user_id, player_ship_id, system_id, enemy_type_id, enemy_count, outcome, start_time, end_time, reward_credits, reward_reputation)
VALUES 
(1, 1, 1, 1, 2, 'victory', '2025-05-02 10:15:00', '2025-05-02 10:20:00', 1000.00, 5),
(1, 1, 3, 2, 3, 'defeat', '2025-05-03 15:30:00', '2025-05-03 15:40:00', 0.00, 0),
(2, 2, 2, 1, 1, 'victory', '2025-05-04 12:45:00', '2025-05-04 12:50:00', 500.00, 3),
(2, 2, 3, 3, 1, 'escape', '2025-05-05 09:10:00', '2025-05-05 09:15:00', 0.00, 0),
(3, 3, 4, 2, 4, 'victory', '2025-05-04 17:20:00', '2025-05-04 17:35:00', 4000.00, 20);
