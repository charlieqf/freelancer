-- 《Freelancer》太空冒险游戏数据库定义文件 (Part 1)
-- 创建数据库
CREATE DATABASE IF NOT EXISTS freelancer CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE freelancer;

-- -----------------------------------------------------
-- 基础系统表
-- -----------------------------------------------------

-- -----------------------------------------------------
-- 游戏世界表
-- -----------------------------------------------------

-- 星系表
-- 存储游戏中的星系信息
CREATE TABLE star_systems (
    system_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '星系ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '星系名称',
    description TEXT COMMENT '星系描述',
    difficulty_level TINYINT COMMENT '难度等级(1-10)',
    danger_level TINYINT DEFAULT 1 COMMENT '危险等级(1-10)，表示敌人出没频率',
    type ENUM('core', 'mid', 'rim', 'unknown') DEFAULT 'mid' COMMENT '银河区域分类',
    controlling_faction_id INT COMMENT '控制该星系的势力ID',
    x_coord FLOAT NOT NULL COMMENT '星系X坐标',
    y_coord FLOAT NOT NULL COMMENT '星系Y坐标',
    z_coord FLOAT NOT NULL COMMENT '星系Z坐标',
    is_discovered BOOLEAN DEFAULT FALSE COMMENT '是否已被玩家发现'
) COMMENT '存储游戏中所有星系的信息';

-- 行星表
-- 存储星系中的行星
CREATE TABLE planets (
    planet_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '行星ID，主键',
    system_id INT NOT NULL COMMENT '所属星系ID',
    name VARCHAR(100) NOT NULL COMMENT '行星名称',
    description TEXT COMMENT '行星描述',
    has_station BOOLEAN DEFAULT FALSE COMMENT '是否有空间站',
    resource_richness TINYINT COMMENT '资源丰富度(1-10)',
    controlling_faction_id INT COMMENT '控制该行星的势力ID',
    orbital_position FLOAT COMMENT '轨道位置',
    FOREIGN KEY (system_id) REFERENCES star_systems(system_id) ON DELETE CASCADE
) COMMENT '存储星系中的行星信息';

-- 空间站表
-- 存储游戏中的空间站
CREATE TABLE stations (
    station_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '空间站ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '空间站名称',
    description TEXT COMMENT '空间站描述',
    system_id INT NOT NULL COMMENT '所属星系ID',
    planet_id INT NULL COMMENT '所属行星ID，可以为NULL表示深空空间站',
    controlling_faction_id INT COMMENT '控制该空间站的势力ID',
    has_shipyard BOOLEAN DEFAULT FALSE COMMENT '是否有船坞',
    has_market BOOLEAN DEFAULT FALSE COMMENT '是否有市场',
    has_mission_board BOOLEAN DEFAULT FALSE COMMENT '是否有任务板',
    market_tax_rate DECIMAL(5,2) DEFAULT 5.00 COMMENT '市场税率，影响交易成本',
    FOREIGN KEY (system_id) REFERENCES star_systems(system_id),
    FOREIGN KEY (planet_id) REFERENCES planets(planet_id)
) COMMENT '存储游戏中的空间站信息';

-- 跳跃门表
-- 存储连接不同星系的跳跃门
CREATE TABLE jump_gates (
    gate_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '跳跃门ID，主键',
    name VARCHAR(100) COMMENT '跳跃门名称',
    source_system_id INT NOT NULL COMMENT '起始星系ID',
    destination_system_id INT NOT NULL COMMENT '目标星系ID',
    stability TINYINT DEFAULT 10 COMMENT '稳定性(1-10)',
    toll_fee DECIMAL(10,2) DEFAULT 0.00 COMMENT '通行费',
    one_way BOOLEAN DEFAULT FALSE COMMENT '是否为单向跳跃门',
    FOREIGN KEY (source_system_id) REFERENCES star_systems(system_id),
    FOREIGN KEY (destination_system_id) REFERENCES star_systems(system_id)
) COMMENT '存储星系间的跳跃门信息';

-- -----------------------------------------------------
-- 用户相关表
-- -----------------------------------------------------

-- 用户表
-- 存储用户基本信息和游戏状态
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID，主键',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名，唯一',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    email VARCHAR(100) UNIQUE NOT NULL COMMENT '电子邮件，唯一',
    avatar_url VARCHAR(255) COMMENT '用户头像或代表图URL',
    credits DECIMAL(15,2) DEFAULT 1000.00 COMMENT '用户拥有的游戏币，初始1000',
    reputation INT DEFAULT 0 COMMENT '用户的全局声望值',
    faction_id INT COMMENT '初始加入的阵营ID',
    current_system_id INT COMMENT '用户当前所在的星系ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '账户创建时间',
    last_login DATETIME COMMENT '上次登录时间',
    FOREIGN KEY (current_system_id) REFERENCES star_systems(system_id)
) COMMENT '存储用户账户信息和基础游戏状态';

-- 用户成就表
-- 记录用户获得的成就
CREATE TABLE user_achievements (
    achievement_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '成就ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    achievement_type VARCHAR(50) NOT NULL COMMENT '成就类型(探索/贸易/战斗等)',
    achievement_name VARCHAR(100) NOT NULL COMMENT '成就名称',
    description TEXT COMMENT '成就描述',
    points INT DEFAULT 0 COMMENT '成就点数，用于排行榜等',
    achieved_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '获得成就的时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) COMMENT '记录用户获得的游戏成就';


-- -----------------------------------------------------
-- 势力关系表
-- -----------------------------------------------------

-- 势力表
-- 定义游戏中的各个势力
CREATE TABLE factions (
    faction_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '势力ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '势力名称',
    description TEXT COMMENT '势力描述',
    government_type VARCHAR(50) COMMENT '政府类型',
    primary_industry VARCHAR(50) COMMENT '主要产业',
    home_system_id INT COMMENT '势力母星系ID',
    is_player_accessible BOOLEAN DEFAULT TRUE COMMENT '玩家是否可加入',
    icon_url VARCHAR(255) COMMENT '势力图标URL',
    FOREIGN KEY (home_system_id) REFERENCES star_systems(system_id)
) COMMENT '定义游戏中的各个势力';

-- 势力关系表
-- 记录不同势力之间的关系
CREATE TABLE faction_relationships (
    relationship_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '关系ID，主键',
    faction_id1 INT NOT NULL COMMENT '势力1 ID',
    faction_id2 INT NOT NULL COMMENT '势力2 ID',
    relationship_level INT DEFAULT 0 COMMENT '关系等级(-100到100)',
    at_war BOOLEAN DEFAULT FALSE COMMENT '是否处于战争状态',
    trade_agreement BOOLEAN DEFAULT FALSE COMMENT '是否有贸易协定',
    last_changed DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关系最后更新时间',
    FOREIGN KEY (faction_id1) REFERENCES factions(faction_id),
    FOREIGN KEY (faction_id2) REFERENCES factions(faction_id)
) COMMENT '记录不同势力之间的动态关系';

-- 玩家和势力关系表
-- 记录玩家与各势力的关系
CREATE TABLE player_faction_standing (
    standing_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '关系ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    faction_id INT NOT NULL COMMENT '势力ID',
    standing_value INT DEFAULT 0 COMMENT '关系值(-100到100)',
    title VARCHAR(50) NULL COMMENT '玩家在势力中的头衔',
    last_changed DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关系最后更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (faction_id) REFERENCES factions(faction_id)
) COMMENT '记录玩家与各势力的关系';

-- 数据示例：factions
INSERT INTO factions (name, description, government_type, primary_industry, home_system_id, is_player_accessible, icon_url)
VALUES 
('地球联邦', '人类的主要政府组织，统治太阳系及周边', '民主联邦', '科技与制造', 1, TRUE, '/assets/factions/earth_fed.png'),
('半人马商业联盟', '重视贸易的商业联合体', '寡头制', '贸易与金融', 2, TRUE, '/assets/factions/centauri_trade.png'),
('天狼星自由联盟', '独立的星系联盟，以自由贸易著称', '议会制', '服务与运输', 3, TRUE, '/assets/factions/sirius_free.png'),
('猎户座海盗', '活跃在边缘地区的海盗组织', '无政府', '掠夺与走私', 4, FALSE, '/assets/factions/orion_pirates.png'),
('仙女座先驱者', '神秘的远方势力，拥有先进技术', '未知', '研究与探索', 5, FALSE, '/assets/factions/andromeda.png');

-- 数据示例：faction_relationships
INSERT INTO faction_relationships (faction_id1, faction_id2, relationship_level, at_war, trade_agreement)
VALUES 
(1, 2, 50, FALSE, TRUE),
(1, 3, 30, FALSE, TRUE),
(1, 4, -80, TRUE, FALSE),
(1, 5, 0, FALSE, FALSE),
(2, 3, 70, FALSE, TRUE),
(2, 4, -50, FALSE, FALSE),
(2, 5, 10, FALSE, TRUE),
(3, 4, -60, TRUE, FALSE),
(3, 5, 20, FALSE, TRUE),
(4, 5, -20, FALSE, FALSE);

-- 数据示例：player_faction_standing
INSERT INTO player_faction_standing (user_id, faction_id, standing_value, title)
VALUES 
(1, 1, 40, '受尊敬的公民'),
(1, 2, 20, '商业伙伴'),
(1, 3, 10, '访客'),
(1, 4, -30, NULL),
(2, 1, -10, NULL),
(2, 2, 60, '贸易大师'),
(2, 3, 50, '盟友'),
(3, 1, 70, '英雄'),
(3, 4, -80, '头号敌人');

-- 制造商表
-- 存储游戏中的制造商信息
CREATE TABLE manufacturers (
    manufacturer_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '制造商ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '制造商名称',
    description TEXT COMMENT '制造商描述',
    faction_id INT COMMENT '所属势力ID',
    specialization VARCHAR(100) COMMENT '专长领域',
    reputation_bonus INT DEFAULT 0 COMMENT '声望加成',
    headquarters_system_id INT COMMENT '总部所在星系',
    logo_url VARCHAR(255) COMMENT '制造商标志URL',
    established_date VARCHAR(50) COMMENT '成立日期',
    FOREIGN KEY (faction_id) REFERENCES factions(faction_id)
) COMMENT '存储游戏中的制造商信息';


-- -----------------------------------------------------
-- 飞船与装备表
-- -----------------------------------------------------

-- 飞船型号表
-- 存储游戏中所有可用的飞船型号
CREATE TABLE ship_models (
    model_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '型号ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '飞船型号名称',
    description TEXT COMMENT '飞船描述',
    manufacturer_id INT COMMENT '制造商ID',
    class VARCHAR(50) COMMENT '飞船类别(战斗/运输/探索等)',
    base_price DECIMAL(15,2) NOT NULL COMMENT '基础价格',
    cargo_capacity INT COMMENT '货舱容量(立方单位)',
    speed INT COMMENT '最大速度',
    max_health INT COMMENT '最大生命值',
    shield_capacity INT COMMENT '护盾容量',
    energy_capacity INT DEFAULT 100 COMMENT '能量槽容量，用于平衡武器/护盾使用',
    crew_required INT DEFAULT 1 COMMENT '所需船员数量，用于任务系统',
    weapon_hardpoints TINYINT COMMENT '武器挂载点数量',
    equipment_slots TINYINT COMMENT '设备插槽数量',
    image_url VARCHAR(255) COMMENT '飞船图片URL',
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
) COMMENT '存储游戏中所有飞船型号的信息';

-- 玩家拥有的飞船表
-- 记录玩家拥有的飞船
CREATE TABLE player_ships (
    ship_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '飞船实例ID，主键',
    user_id INT NOT NULL COMMENT '拥有者ID',
    model_id INT NOT NULL COMMENT '飞船型号ID',
    name VARCHAR(100) COMMENT '飞船自定义名称',
    current_health INT COMMENT '当前生命值',
    current_shield INT COMMENT '当前护盾值',
    current_energy INT COMMENT '当前能量值',
    current_cargo_space INT COMMENT '当前可用货舱空间',
    current_location_type ENUM('system', 'planet', 'station') COMMENT '当前位置类型',
    current_location_id INT COMMENT '当前位置ID',
    location_detail TEXT COMMENT '当前位置的详细信息，如坐标等',
    x_coord DECIMAL(10,2),
    y_coord DECIMAL(10,2),
    z_coord DECIMAL(10,2),
    ship_status ENUM('docked', 'in_orbit', 'in_space', 'in_warp') NOT NULL,
    is_active BOOLEAN DEFAULT FALSE COMMENT '是否当前正在使用',
    purchased_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '购买时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (model_id) REFERENCES ship_models(model_id)
) COMMENT '记录玩家拥有的飞船信息';

-- 装备类型表
-- 定义游戏中装备的类型
CREATE TABLE equipment_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '类型ID，主键',
    name VARCHAR(50) NOT NULL COMMENT '装备类型名称',
    description TEXT COMMENT '类型描述',
    category ENUM('weapon', 'shield', 'engine', 'scanner', 'cargo') COMMENT '装备类别'
) COMMENT '定义游戏中装备的类型';

-- 装备项表
-- 存储游戏中所有可用的装备
CREATE TABLE equipment_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '装备ID，主键',
    type_id INT NOT NULL COMMENT '装备类型ID',
    name VARCHAR(100) NOT NULL COMMENT '装备名称',
    description TEXT COMMENT '装备描述',
    manufacturer_id INT COMMENT '制造商ID',
    base_price DECIMAL(15,2) NOT NULL COMMENT '基础价格',
    level TINYINT COMMENT '装备等级(1-10)',
    effect_value INT COMMENT '效果值(取决于装备类型)',
    energy_usage INT DEFAULT 0 COMMENT '能量消耗，用于能量管理系统',
    cooldown_time FLOAT DEFAULT 0.0 COMMENT '冷却时间，用于战斗节奏控制',
    weight INT COMMENT '重量单位',
    image_url VARCHAR(255) COMMENT '装备图片URL',
    FOREIGN KEY (type_id) REFERENCES equipment_types(type_id),
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
) COMMENT '存储游戏中所有可用的装备项';

-- 飞船装备关联表
-- 记录飞船上安装的装备
CREATE TABLE ship_equipment (
    ship_equipment_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '关联ID，主键',
    ship_id INT NOT NULL COMMENT '飞船ID',
    equipment_id INT NOT NULL COMMENT '装备ID',
    slot_number TINYINT COMMENT '安装在飞船上的插槽编号',
    condition TINYINT DEFAULT 100 COMMENT '装备当前状态(0-100)',
    installed_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '安装时间',
    FOREIGN KEY (ship_id) REFERENCES player_ships(ship_id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES equipment_items(item_id)
) COMMENT '记录飞船上安装的装备';

-- 船上货物明细表
-- 取代player_cargo表的专用表
CREATE TABLE ship_cargo_items (
    cargo_item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '货物项ID',
    ship_id INT NOT NULL COMMENT '飞船ID',
    commodity_id INT NOT NULL COMMENT '商品ID',
    quantity INT NOT NULL COMMENT '数量',
    purchased_price DECIMAL(15,2) COMMENT '购买单价',
    source_location_id INT COMMENT '购买地点ID',
    source_location_type ENUM('station', 'planet', 'system') COMMENT '购买地点类型',
    acquired_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '获取时间',
    FOREIGN KEY (ship_id) REFERENCES player_ships(ship_id) ON DELETE CASCADE
) COMMENT '记录飞船上装载的各种货物明细';

-- 数据示例：manufacturers
INSERT INTO manufacturers (name, description, faction_id, specialization, reputation_bonus, headquarters_system_id, logo_url, established_date)
VALUES 
('地球造船厂', '人类历史最悠久的飞船制造商，专注于可靠性和多功能性', 1, '多用途飞船', 5, 1, '/assets/manufacturers/earth_shipyard.png', '2150年'),
('半人马工业', '半人马座α星系最大的工业联合体，以大型运输船闻名', 2, '货运飞船', 3, 2, '/assets/manufacturers/centauri_industries.png', '2201年'),
('军方工业', '地球联邦军方下属的军工企业，主要生产战斗舰船和武器', 1, '军用装备', 10, 1, '/assets/manufacturers/military_ind.png', '2160年'),
('联合造船公司', '多星系合作组建的民间企业，产品性价比高', 3, '多用途飞船', 2, 3, '/assets/manufacturers/united_shipbuilding.png', '2230年'),
('天狼奢侈品公司', '专注于高端定制飞船的奢侈品制造商', 3, '豪华飞船', 8, 3, '/assets/manufacturers/sirius_luxury.png', '2245年'),
('防御系统公司', '专门研发防御系统的企业，以护盾技术著称', 1, '防御装备', 4, 1, '/assets/manufacturers/defense_systems.png', '2172年'),
('推进技术公司', '引擎和推进系统的专业制造商', 2, '推进系统', 3, 2, '/assets/manufacturers/propulsion_tech.png', '2190年'),
('科技探索公司', '专注于探索和扫描设备的高科技企业', 1, '扫描设备', 2, 1, '/assets/manufacturers/tech_explorers.png', '2215年'),
('商业解决方案', '专为商业用户提供飞船改装和优化服务的公司', 3, '货舱扩展', 1, 3, '/assets/manufacturers/business_solutions.png', '2225年');

-- 数据示例：users
INSERT INTO users (username, password_hash, email, avatar_url, credits, reputation, faction_id, current_system_id, created_at, last_login)
VALUES 
('commander1', 'hashed_password_123', 'commander1@example.com', '/assets/avatars/commander1.png', 5000.00, 20, 1, 1, '2025-01-01 10:00:00', '2025-05-05 15:30:00'),
('spacetrader', 'hashed_password_456', 'trader@example.com', '/assets/avatars/trader.png', 15000.00, 50, 2, 2, '2025-01-15 14:20:00', '2025-05-05 09:45:00'),
('explorer99', 'hashed_password_789', 'explorer@example.com', '/assets/avatars/explorer.png', 3200.00, 15, 3, 3, '2025-02-10 08:30:00', '2025-05-04 22:10:00');

-- 数据示例：user_achievements
INSERT INTO user_achievements (user_id, achievement_type, achievement_name, description, points, achieved_at)
VALUES 
(1, 'exploration', '星系探索者', '探索了10个不同的星系', 50, '2025-02-15 14:30:00'),
(1, 'combat', '海盗猎人', '击败了50个海盗', 100, '2025-03-10 18:45:00'),
(2, 'trade', '贸易大师', '完成了100次成功的交易', 150, '2025-03-05 12:20:00'),
(3, 'exploration', '第一次飞行', '完成了第一次星际旅行', 10, '2025-02-12 10:10:00');

-- 数据示例：star_systems
INSERT INTO star_systems (name, description, difficulty_level, danger_level, type, controlling_faction_id, x_coord, y_coord, z_coord, is_discovered)
VALUES 
('太阳系', '人类的发源地，拥有丰富的资源和发达的空间站网络', 1, 1, 'core', 1, 0.0, 0.0, 0.0, TRUE),
('半人马座α星系', '与地球最近的恒星系统之一，拥有丰富的矿产资源', 3, 3, 'mid', 2, 4.3, 0.5, -1.2, TRUE),
('天狼星系', '著名的贸易中心，多个势力在此有据点', 4, 5, 'mid', 3, -5.2, 3.1, 2.0, TRUE),
('猎户座星云', '资源丰富但危险的边缘区域，海盗活动频繁', 7, 8, 'rim', 4, 15.0, -2.5, 5.0, FALSE),
('仙女座M31', '遥远的星系，拥有未知的技术和资源', 10, 10, 'unknown', NULL, 100.0, 50.0, 25.0, FALSE);

-- 数据示例：planets
INSERT INTO planets (system_id, name, description, has_station, resource_richness, controlling_faction_id, orbital_position)
VALUES 
(1, '地球', '人类的家园，拥有最发达的技术和基础设施', TRUE, 5, 1, 3.0),
(1, '火星', '人类第一个殖民地，矿产资源丰富', TRUE, 7, 1, 5.0),
(2, '半人马座b行星', '一个气态巨行星，拥有丰富的氦-3资源', FALSE, 9, 2, 1.5),
(3, '天狼I', '天狼星系的主要贸易中心', TRUE, 4, 3, 2.0),
(4, '猎户A', '猎户座星云中的一颗岩质行星，富含稀有金属', TRUE, 8, 4, 4.0);

-- 数据示例：stations
INSERT INTO stations (name, description, system_id, planet_id, controlling_faction_id, has_shipyard, has_market, has_mission_board, market_tax_rate)
VALUES 
('地球轨道站', '地球轨道上最大的空间站，提供各种服务', 1, 1, 1, TRUE, TRUE, TRUE, 3.50),
('火星基地', '火星表面的主要殖民地和贸易中心', 1, 2, 1, TRUE, TRUE, TRUE, 4.00),
('半人马前哨', '半人马座α星系的主要贸易站', 2, 3, 2, FALSE, TRUE, TRUE, 6.50),
('天狼中心站', '天狼星系的核心空间站，多方势力交汇点', 3, 4, 3, TRUE, TRUE, TRUE, 5.00),
('猎户矿业基地', '专注于矿物开采和加工的空间站', 4, 5, 4, FALSE, TRUE, FALSE, 8.00);

-- 数据示例：jump_gates
INSERT INTO jump_gates (name, source_system_id, destination_system_id, stability, toll_fee, one_way)
VALUES 
('太阳-半人马跳跃门', 1, 2, 10, 0.00, FALSE),
('半人马-天狼跳跃门', 2, 3, 8, 50.00, FALSE),
('天狼-猎户跳跃门', 3, 4, 6, 100.00, FALSE),
('猎户-仙女座跳跃门', 4, 5, 3, 500.00, TRUE),
('太阳-天狼快速通道', 1, 3, 9, 200.00, FALSE);

-- 数据示例：ship_models
INSERT INTO ship_models (name, description, manufacturer_id, class, base_price, cargo_capacity, speed, max_health, shield_capacity, energy_capacity, crew_required, weapon_hardpoints, equipment_slots, image_url)
VALUES 
('轻型探索者', '适合初学者的小型多用途飞船', 1, '探索', 5000.00, 50, 300, 1000, 500, 200, 1, 2, 3, '/assets/ships/explorer.png'),
('商人号', '大型货运飞船，适合长途贸易', 2, '运输', 25000.00, 500, 150, 2000, 800, 300, 3, 1, 4, '/assets/ships/trader.png'),
('猎鹰战机', '小型高速战斗飞船', 3, '战斗', 15000.00, 20, 400, 800, 1000, 500, 1, 4, 2, '/assets/ships/fighter.png'),
('多功能主力舰', '平衡的中型飞船，适合多种任务', 4, '多用途', 40000.00, 200, 250, 3000, 1500, 400, 5, 3, 5, '/assets/ships/multipurpose.png'),
('豪华游艇', '昂贵但舒适的个人飞船', 5, '豪华', 100000.00, 100, 350, 1500, 2000, 600, 2, 2, 6, '/assets/ships/yacht.png');

-- 数据示例：player_ships
INSERT INTO player_ships (user_id, model_id, name, current_health, current_shield, current_energy, current_cargo_space, current_location_type, current_location_id, location_detail, is_active)
VALUES 
(1, 1, '我的第一艘船', 1000, 500, 200, 50, 'station', 1, '靠泊在1号码头，维护状态良好', TRUE),
(2, 2, '星际掠夺者', 2000, 800, 300, 400, 'station', 3, '停靠在主货运码头，准备装载货物', TRUE),
(3, 3, '无敌战机', 800, 1000, 500, 20, 'system', 3, '巡逻在天狼星系外围，坐标x:5.1 y:-2.3', TRUE),
(1, 4, '备用飞船', 3000, 1500, 400, 200, 'station', 1, '存放在地球轨道站的私人船坞', FALSE);

-- 数据示例：equipment_types
INSERT INTO equipment_types (name, description, category)
VALUES 
('激光武器', '高精度能量武器，适中的伤害和能耗', 'weapon'),
('导弹发射器', '高伤害但需要弹药的武器系统', 'weapon'),
('反应堆护盾', '标准的能量护盾，提供中等防护', 'shield'),
('推进引擎', '标准推进系统，平衡速度和能耗', 'engine'),
('先进扫描仪', '增强探测和扫描能力的设备', 'scanner'),
('扩展货舱', '增加飞船货物容量的模块', 'cargo');

-- 数据示例：equipment_items
INSERT INTO equipment_items (type_id, name, description, manufacturer_id, base_price, level, effect_value, energy_usage, cooldown_time, weight, image_url)
VALUES 
(1, '标准激光炮', '基础的激光武器系统', 3, 2000.00, 1, 100, 15, 0.5, 5, '/assets/equipment/laser1.png'),
(1, '高级激光炮', '改进型激光系统，更高的伤害', 3, 5000.00, 3, 250, 30, 0.8, 8, '/assets/equipment/laser3.png'),
(2, '追踪导弹发射器', '能锁定目标的导弹系统', 3, 8000.00, 4, 400, 50, 3.0, 15, '/assets/equipment/missile.png'),
(3, '基础护盾', '基础防护系统', 6, 3000.00, 2, 500, 20, 5.0, 10, '/assets/equipment/shield1.png'),
(4, '加速引擎', '提高最大速度的引擎升级', 7, 7000.00, 3, 150, 25, 0.0, 20, '/assets/equipment/engine2.png'),
(5, '长距离扫描仪', '扩展探测范围的扫描设备', 8, 4000.00, 2, 200, 10, 0.0, 3, '/assets/equipment/scanner.png'),
(6, '货舱扩展模块', '增加50单位货舱容量', 9, 6000.00, 2, 50, 0, 0.0, 25, '/assets/equipment/cargo.png');

-- 数据示例：ship_equipment
INSERT INTO ship_equipment (ship_id, equipment_id, slot_number, condition)
VALUES 
(1, 1, 1, 100),
(1, 4, 2, 95),
(1, 5, 3, 100),
(2, 7, 1, 100),
(2, 4, 2, 90),
(3, 2, 1, 100),
(3, 3, 2, 85),
(4, 1, 1, 100),
(4, 7, 2, 100);

-- 数据示例：ship_cargo_items
INSERT INTO ship_cargo_items (ship_id, commodity_id, quantity, purchased_price, source_location_id, source_location_type)
VALUES
(1, 1, 10, 50.00, 1, 'station'),
(1, 2, 5, 100.00, 1, 'station'),
(2, 3, 50, 180.00, 1, 'station'),
(2, 4, 20, 450.00, 1, 'station'),
(3, 5, 5, 750.00, 3, 'station'),
(4, 6, 3, 1400.00, 3, 'station');
