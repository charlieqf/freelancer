-- 《Freelancer》太空冒险游戏数据库定义文件 (Part 3)
-- 势力关系表、游戏进度和设置表
USE freelancer;

-- -----------------------------------------------------
-- 游戏进度和事件表
-- -----------------------------------------------------

-- 游戏事件表
-- 记录游戏中的特殊事件
CREATE TABLE game_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '事件ID，主键',
    title VARCHAR(100) NOT NULL COMMENT '事件标题',
    description TEXT COMMENT '事件描述',
    event_type VARCHAR(50) COMMENT '事件类型',
    trigger_condition TEXT COMMENT '触发条件',
    effect_script TEXT COMMENT '效果脚本',
    start_date DATETIME COMMENT '开始时间',
    end_date DATETIME NULL COMMENT '结束时间',
    is_active BOOLEAN DEFAULT FALSE COMMENT '是否激活'
) COMMENT '记录游戏中的特殊事件';

-- 玩家发现表
-- 记录玩家的发现
CREATE TABLE player_discoveries (
    discovery_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '发现ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    discovery_type ENUM('system', 'planet', 'station', 'anomaly') COMMENT '发现类型',
    object_id INT NOT NULL COMMENT '被发现对象的ID',
    discovery_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发现时间',
    reward_credits DECIMAL(15,2) COMMENT '获得的奖励金额',
    reward_reputation INT COMMENT '获得的声望奖励',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT '记录玩家的发现';

-- 玩家统计数据表
-- 记录玩家的游戏数据统计
CREATE TABLE player_statistics (
    stat_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '统计ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    systems_visited INT DEFAULT 0 COMMENT '访问过的星系数量',
    missions_completed INT DEFAULT 0 COMMENT '完成的任务数量',
    enemies_defeated INT DEFAULT 0 COMMENT '击败的敌人数量',
    total_credits_earned DECIMAL(15,2) DEFAULT 0.00 COMMENT '总共赚取的金额',
    total_distance_traveled DECIMAL(15,2) DEFAULT 0.00 COMMENT '总旅行距离',
    total_playtime_minutes INT DEFAULT 0 COMMENT '总游戏时间(分钟)',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '最后更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT '记录玩家的游戏统计数据';

-- 数据示例：game_events
INSERT INTO game_events (title, description, event_type, trigger_condition, effect_script, start_date, end_date, is_active)
VALUES 
('海盗入侵', '猎户座海盗大规模入侵临近星系', 'invasion', 'player_level >= 10', 'increase_pirate_spawn_rate(3);decrease_market_prices(0.8);', '2025-05-10 00:00:00', '2025-05-20 00:00:00', TRUE),
('贸易展览会', '半人马商业联盟举办年度贸易展览会', 'economic', 'system_id == 2', 'increase_market_volume(2);add_special_commodities();', '2025-06-01 00:00:00', '2025-06-07 00:00:00', FALSE),
('科技突破', '地球联邦宣布重大科技突破', 'story', 'main_quest_progress >= 5', 'unlock_new_equipment();increase_faction_standing(1, 10);', '2025-05-15 00:00:00', NULL, FALSE),
('星际风暴', '能量风暴影响多个星系间的旅行', 'environmental', NULL, 'increase_jump_gate_instability();increase_fuel_consumption(1.5);', '2025-05-08 00:00:00', '2025-05-12 00:00:00', TRUE),
('和平协议', '地球联邦与天狼星自由联盟签署和平协议', 'political', 'faction_war_ended == true', 'update_faction_relationship(1, 3, 20);open_new_trading_routes();', '2025-07-01 00:00:00', NULL, FALSE);

-- 数据示例：player_discoveries
INSERT INTO player_discoveries (user_id, discovery_type, discovery_id, discovery_time, reward_credits, reward_reputation)
VALUES 
(1, 'system', 4, '2025-04-10 15:30:00', 5000.00, 30),
(1, 'planet', 5, '2025-04-15 12:45:00', 2000.00, 15),
(2, 'station', 5, '2025-04-20 10:20:00', 3000.00, 20),
(2, 'anomaly', 1, '2025-04-25 16:10:00', 8000.00, 40),
(3, 'system', 5, '2025-05-01 11:30:00', 10000.00, 50);

-- 数据示例：player_statistics
INSERT INTO player_statistics (user_id, systems_visited, missions_completed, enemies_defeated, total_credits_earned, total_distance_traveled, total_playtime_minutes)
VALUES 
(1, 4, 12, 35, 50000.00, 5000.00, 720),
(2, 6, 25, 50, 120000.00, 8000.00, 1440),
(3, 3, 8, 20, 35000.00, 3000.00, 480);

-- -----------------------------------------------------
-- 游戏设置和配置表
-- -----------------------------------------------------

-- 游戏设置表
-- 存储玩家的游戏设置
CREATE TABLE game_settings (
    setting_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '设置ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    sound_enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用声音',
    music_volume TINYINT DEFAULT 70 COMMENT '音乐音量(0-100)',
    sfx_volume TINYINT DEFAULT 70 COMMENT '音效音量(0-100)',
    fullscreen BOOLEAN DEFAULT FALSE COMMENT '是否全屏',
    difficulty_setting ENUM('easy', 'normal', 'hard') DEFAULT 'normal' COMMENT '难度设置',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '最后更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT '存储玩家的游戏设置';

-- 游戏日志表
-- 记录游戏中的重要事件日志
CREATE TABLE game_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    log_type VARCHAR(50) COMMENT '日志类型',
    message TEXT COMMENT '日志消息',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT '记录游戏中的重要事件日志';

-- 数据示例：game_settings
INSERT INTO game_settings (user_id, sound_enabled, music_volume, sfx_volume, fullscreen, difficulty_setting)
VALUES 
(1, TRUE, 80, 70, FALSE, 'normal'),
(2, TRUE, 60, 80, TRUE, 'hard'),
(3, FALSE, 0, 50, FALSE, 'easy');

-- 数据示例：game_logs
INSERT INTO game_logs (user_id, log_type, message)
VALUES 
(1, 'login', '用户登录成功'),
(1, 'mission', '完成任务：医疗物资运输'),
(1, 'combat', '在太阳系击败2艘海盗侦察舰'),
(2, 'trade', '在半人马前哨购买了50单位矿石'),
(2, 'discovery', '发现新空间站：猎户矿业基地'),
(3, 'level_up', '玩家等级提升至10级'),
(3, 'ship_purchase', '购买了新飞船：轻型探索者');

-- -----------------------------------------------------
-- 索引创建
-- -----------------------------------------------------

-- 为用户名和邮箱创建索引以加速登录查询
CREATE INDEX idx_username ON users(username);
CREATE INDEX idx_email ON users(email);

-- 为物品价格创建索引以加速市场查询
CREATE INDEX idx_market_prices ON market_prices(station_id, commodity_id);

-- 为任务状态创建索引以加速任务查询
CREATE INDEX idx_player_missions_status ON player_missions(user_id, status);

-- 为飞船位置创建索引以加速位置查询
CREATE INDEX idx_ship_location ON player_ships(current_location_type, current_location_id);

-- 为星系坐标创建索引以加速空间查询
CREATE INDEX idx_system_coords ON star_systems(x_coord, y_coord, z_coord);

-- 为势力关系创建索引以加速关系查询
CREATE INDEX idx_faction_relations ON faction_relationships(faction_id1, faction_id2);

-- 为玩家与势力关系创建索引
CREATE INDEX idx_player_faction ON player_faction_standing(user_id, faction_id);

-- 为跳跃门创建索引以加速路径查询
CREATE INDEX idx_jump_gates ON jump_gates(source_system_id, destination_system_id);

-- -----------------------------------------------------
-- 添加延迟的外键约束（解决循环依赖）
-- -----------------------------------------------------

-- 添加星系表中的势力外键约束
ALTER TABLE star_systems
ADD CONSTRAINT fk_system_controlling_faction
FOREIGN KEY (controlling_faction_id) REFERENCES factions(faction_id);

-- 添加行星表中的势力外键约束
ALTER TABLE planets
ADD CONSTRAINT fk_planet_controlling_faction
FOREIGN KEY (controlling_faction_id) REFERENCES factions(faction_id);

-- 添加空间站表中的势力外键约束
ALTER TABLE stations
ADD CONSTRAINT fk_station_controlling_faction
FOREIGN KEY (controlling_faction_id) REFERENCES factions(faction_id);

-- 添加用户表中的势力外键约束
ALTER TABLE users
ADD CONSTRAINT fk_user_faction
FOREIGN KEY (faction_id) REFERENCES factions(faction_id);

-- 添加制造商表中的总部星系外键约束
ALTER TABLE manufacturers
ADD CONSTRAINT fk_manufacturer_headquarters
FOREIGN KEY (headquarters_system_id) REFERENCES star_systems(system_id);

-- 添加ship_cargo_items表中的商品外键约束
ALTER TABLE ship_cargo_items
ADD CONSTRAINT fk_cargo_commodity
FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id);

