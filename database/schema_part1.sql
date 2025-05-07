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

CREATE TABLE items (
    item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '物品ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '物品名称',
    description TEXT COMMENT '物品描述',
    item_type ENUM('commodity', 'weapon', 'equipment', 'consumable') NOT NULL COMMENT '物品类型',
    weight FLOAT DEFAULT 1.0 COMMENT '单位重量',
    base_price DECIMAL(15,2) DEFAULT 0.00 COMMENT '基础价格',
    manufacturer_id INT COMMENT '生产商ID',
    is_legal BOOLEAN DEFAULT TRUE COMMENT '是否合法物品（仅对 commodity 有效）',
    contraband_level TINYINT DEFAULT 0 COMMENT '违禁等级(0-10)',
    icon_url VARCHAR(255) COMMENT '图标地址',
    rarity_level TINYINT DEFAULT 1 COMMENT '稀有度(1-10)',
    is_tradeable BOOLEAN DEFAULT TRUE COMMENT '是否可交易',
    is_usable BOOLEAN DEFAULT FALSE COMMENT '是否可使用',
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
) COMMENT='游戏中所有可用物品，包括商品、武器、装备和消耗品';


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
    has_shop BOOLEAN DEFAULT FALSE COMMENT '是否有商店',
    has_bar BOOLEAN DEFAULT FALSE COMMENT '是否有酒吧',
    has_inn BOOLEAN DEFAULT FALSE COMMENT '是否有旅馆',
    has_mission_board BOOLEAN DEFAULT FALSE COMMENT '是否有任务板',
    market_tax_rate DECIMAL(5,2) DEFAULT 5.00 COMMENT '市场税率，影响交易成本',
    FOREIGN KEY (system_id) REFERENCES star_systems(system_id)
) COMMENT '存储游戏中的空间站信息';

CREATE TABLE station_shop_items (
    shop_item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '商店商品ID，主键',
    station_id INT NOT NULL COMMENT '所属空间站ID',
    item_id INT NOT NULL COMMENT '商品ID（可以是装备、武器或消耗品）',
    item_type ENUM('equipment', 'weapon', 'consumable') NOT NULL COMMENT '商品类型',
    stock_quantity INT DEFAULT 0 COMMENT '库存数量',
    price DECIMAL(10,2) NOT NULL COMMENT '当前售价',
    last_restocked DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上次补货时间',
    restock_interval_hours INT DEFAULT 24 COMMENT '补货周期，单位小时',
    FOREIGN KEY (station_id) REFERENCES stations(station_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
) COMMENT='存储空间站的商店库存信息，每行对应一个可销售商品';

CREATE TABLE station_bars (
    bar_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '酒吧ID，主键',
    station_id INT NOT NULL COMMENT '所属空间站ID',
    name VARCHAR(100) NOT NULL COMMENT '酒吧名称',
    atmosphere TEXT COMMENT '环境描述，如音乐风格、灯光、背景氛围',
    music_theme VARCHAR(100) COMMENT '当前播放的音乐主题',
    is_open BOOLEAN DEFAULT TRUE COMMENT '是否营业状态',
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
) COMMENT='记录每个空间站中酒吧的信息，支持任务交互和NPC功能';

CREATE TABLE bar_npcs (
    npc_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'NPC ID，主键',
    bar_id INT NOT NULL COMMENT '所在酒吧ID',
    name VARCHAR(100) NOT NULL COMMENT 'NPC名称',
    role ENUM('quest_giver', 'info_dealer', 'crew_candidate') NOT NULL COMMENT 'NPC角色类型',
    dialogue TEXT COMMENT '与NPC交谈时的主要对白',
    is_available BOOLEAN DEFAULT TRUE COMMENT '当前是否出现在酒吧中',
    reputation_requirement INT DEFAULT 0 COMMENT '需要达到的最低声望值才可交互',
    voice_file_url VARCHAR(255) COMMENT '语音文件地址，可用于语音对白',
    FOREIGN KEY (bar_id) REFERENCES station_bars(bar_id)
) COMMENT='记录酒吧中可交互的NPC，包括任务发布者、线索提供者和雇佣船员等';

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
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '账户创建时间',
    last_login DATETIME COMMENT '上次登录时间'
) COMMENT '存储用户账户信息和基础游戏状态';

-- 游戏存档表
-- 存储玩家的游戏存档
CREATE TABLE game_saves (
    game_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '存档ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    save_name VARCHAR(50) NOT NULL COMMENT '存档名称',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    last_played_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '最后游玩时间',
    game_version VARCHAR(20) COMMENT '游戏版本',
    total_playtime INT DEFAULT 0 COMMENT '总游玩时间(秒)',
    
    -- 游戏进度概述
    credits INT DEFAULT 1000 COMMENT '游戏币',
    current_system_id INT COMMENT '当前星系ID',
    reputation_level INT DEFAULT 1 COMMENT '声望等级',
    faction_id INT COMMENT '加入的阵营ID',
    discovered_systems_count INT DEFAULT 0 COMMENT '已发现星系数',
    completed_missions_count INT DEFAULT 0 COMMENT '已完成任务数',
    
    -- 可选字段
    thumbnail_path VARCHAR(255) COMMENT '存档缩略图路径',
    status VARCHAR(20) DEFAULT 'active' COMMENT '存档状态',
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (current_system_id) REFERENCES star_systems(system_id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_last_played_at (last_played_at)
) COMMENT '存储玩家的游戏存档';

-- 用户成就表
-- 记录用户获得的成就
CREATE TABLE user_achievements (
    achievement_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '成就ID，主键',
    user_id INT NOT NULL COMMENT '用户ID',
    game_id INT NOT NULL COMMENT '存档ID',
    achievement_type VARCHAR(50) NOT NULL COMMENT '成就类型(探索/贸易/战斗等)',
    achievement_name VARCHAR(100) NOT NULL COMMENT '成就名称',
    description TEXT COMMENT '成就描述',
    points INT DEFAULT 0 COMMENT '成就点数，用于排行榜等',
    achieved_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '获得成就的时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    INDEX idx_user_game (user_id, game_id)
) COMMENT '记录用户获得的游戏成就';


-- -----------------------------------------------------
-- 势力关系表
-- -----------------------------------------------------


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
    game_id INT NOT NULL COMMENT '存档ID',
    faction_id INT NOT NULL COMMENT '势力ID',
    standing_value INT DEFAULT 0 COMMENT '关系值(-100到100)',
    title VARCHAR(50) NULL COMMENT '玩家在势力中的头衔',
    last_changed DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关系最后更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (faction_id) REFERENCES factions(faction_id),
    INDEX idx_user_game_faction (user_id, game_id, faction_id)
) COMMENT '记录玩家与各势力的关系';

-- 数据示例：factions
INSERT INTO factions (name, description, government_type, primary_industry, home_system_id, is_player_accessible, icon_url)
VALUES
-- 四大主权国家
('自由星系联盟（Liberty）', '作为人类殖民最早、科技最发达的国家之一，自由星系联盟崇尚市场经济、个人权利与强大军力。它是银河系金融与信息的中心，但其内部也日益受大公司与安全机构的影响，政治日渐复杂。', '联邦制', '商业与安全', 1, TRUE, '/assets/factions/liberty.png'),

('布雷顿尼亚（Bretonia）', '布雷顿尼亚融合工业强国与殖民帝国双重传统，拥有复杂的贵族阶级体系和强大的矿业舰队。尽管经济放缓，其文化影响力与坚韧意志仍然使其在政治舞台上占据一席之地。', '君主立宪制', '采矿与重工业', 2, TRUE, '/assets/factions/bretonia.png'),

('库萨里帝国（Kusari）', '库萨里是一片深受传统与家族文化影响的星域，由强势的企业财阀主导经济与政策。虽然尊奉帝皇，但其政治结构高度商业化。以严密的舰队与精密制造著称，是东方星际文化的代表。', '君主制', '制造与农业', 3, TRUE, '/assets/factions/kusari.png'),

('莱茵兰（Rheinland）', '作为技术和军工业的巨擘，莱茵兰以高效率与秩序著称。长年的内乱与外战塑造了其铁血与进取的国民性格，现正处于政治重建和工业升级并行阶段。', '联邦制', '能源与军工', 4, TRUE, '/assets/factions/rheinland.png'),

('盛唐联邦', '盛唐联邦承袭儒家思想与现代科技相结合的发展道路。以伦理与集体为核心治理理念，其社会高度组织化，农业与信息科技相辅相成，是东亚哲学在星际时代的延续者。', '中央联邦制', '信息科技与农业生态', 5, TRUE, '/assets/factions/tang_union.png'),

('斯拉夫星域共和国', '诞生于资源严峻、气候恶劣的边疆星区，斯拉夫共和国以军事与重工业立国。强调国家统一与边防扩张，其人民坚韧而自给，形成了独特的中央集权政治文化。', '中央集权制', '重工业与资源提炼', 6, TRUE, '/assets/factions/slavic_dominion.png'),

-- 中立与特殊组织
('赏金猎人公会（Bounty Hunters Guild）', '一个遍布星系的佣兵组织，接受合法与灰色委托以打击罪犯、保护货运或追捕目标。他们组织松散，但作战经验丰富，是正规军无法覆盖地带的重要力量。', '公会制', '佣兵服务', 7, TRUE, '/assets/factions/bhg.png'),

('气体开采公会（Gas Miners Guild）', '主要在危险地带采集氦-3的组织，依赖高度自动化与专业飞行员。由于其对能源战略物资的控制，在多个势力间保持技术中立与外交平衡。', '工会自治', '能源采集', 8, TRUE, '/assets/factions/gmg.png'),

('中立拓荒者（Zoners）', 'Zoners是放弃主权体系、迁徙至边缘空间的和平主义者。他们依靠科学研究、自由贸易和生态实验进行生存与发展，常常在废弃空间站建立自给自足社区。', '自治联盟', '贸易与科研', 9, TRUE, '/assets/factions/zoners.png'),

('废品回收者（Junkers）', '以打捞太空残骸与处理工业废料为业的拾荒者组织，虽然与多个势力建立商业关系，但其暗中参与走私与信息渗透，使他们常常被视为危险但必要的存在。', '松散组织', '回收与走私', 10, TRUE, '/assets/factions/junkers.png'),

-- 敌对与非法势力
('科西尔（Corsairs）', '科西尔出身资源匮乏星球，拥有浓厚的战士文化和家族荣誉观。其经济完全依赖掠夺与非法贸易，舰船粗犷而强悍，常年骚扰主要航道与殖民区。', '部族军阀', '走私与战斗', 11, FALSE, '/assets/factions/corsairs.png'),

('奥特卡斯特（Outcasts）', '控制Cardamine毒品生产与分销的星际帝国。该物质致命依赖性极强，形成对外统治工具，其人口因长期暴露而具备特殊基因特征。', '毒品王国', '卡达明毒品贸易', 12, FALSE, '/assets/factions/outcasts.png'),

('秩序组织（The Order）', '由前军事高层组成的秘密组织，致力于揭示和抵抗Nomad外星威胁。他们在阴影中运作，不被任何国家正式承认，却拥有惊人科技与隐秘网络。', '秘密军事', '反外星防御', 13, FALSE, '/assets/factions/order.png'),

-- 外星势力
('游牧者（Nomads）', '一种能量态非人类生命形式，具心灵控制与物理变形能力。由人类早期殖民失误引发战争，对人类文明构成最大潜在威胁。', '非人类', '未知', 14, FALSE, '/assets/factions/nomads.png');



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



-- -----------------------------------------------------
-- 飞船与装备表
-- -----------------------------------------------------

-- 飞船型号表
-- 存储游戏中所有可用的飞船型号
CREATE TABLE ship_models (
    model_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '飞船型号ID，主键',
    name VARCHAR(100) NOT NULL COMMENT '飞船名称',
    description TEXT COMMENT '飞船描述',
    class ENUM('fighter', 'interceptor', 'bomber', 'freighter', 'transport', 'explorer', 'support', 'capital') NOT NULL COMMENT '飞船分类',
    manufacturer_id INT NOT NULL COMMENT '制造商ID',
    faction_id INT COMMENT '所属势力ID',
    cargo_capacity INT DEFAULT 0 COMMENT '货物容量',
    weapon_slots INT DEFAULT 2 COMMENT '武器槽位数',
    armor INT DEFAULT 100 COMMENT '装甲强度',
    speed INT DEFAULT 100 COMMENT '最大航速',
    maneuverability TINYINT DEFAULT 5 COMMENT '机动性(1-10)',
    jump_range INT DEFAULT 1 COMMENT '最大跃迁距离(单位星系)',
    crew_capacity INT DEFAULT 1 COMMENT '所需船员人数',
    price DECIMAL(12,2) NOT NULL COMMENT '基础价格',
    is_military BOOLEAN DEFAULT FALSE COMMENT '是否为军用型号',
    image_url VARCHAR(255) COMMENT '飞船图像URL',
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id),
    FOREIGN KEY (faction_id) REFERENCES factions(faction_id)
) COMMENT '定义所有飞船型号及其属性';


-- 玩家拥有的飞船表
-- 记录玩家拥有的飞船
CREATE TABLE player_ships (
    ship_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '飞船实例ID，主键',
    user_id INT NOT NULL COMMENT '拥有者ID',
    game_id INT NOT NULL COMMENT '存档ID',
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
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES ship_models(model_id),
    INDEX idx_user_game (user_id, game_id),
    INDEX idx_active_ship (user_id, game_id, is_active)
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
    game_id INT NOT NULL COMMENT '存档ID',
    equipment_id INT NOT NULL COMMENT '装备ID',
    slot_number TINYINT COMMENT '安装在飞船上的插槽编号',
    equipment_condition TINYINT DEFAULT 100 COMMENT '装备当前状态(0-100)',
    installed_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '安装时间',
    FOREIGN KEY (ship_id) REFERENCES player_ships(ship_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES equipment_items(item_id),
    INDEX idx_ship_game (ship_id, game_id)
) COMMENT '记录飞船上安装的装备';

-- 船上货物明细表
-- 取代player_cargo表的专用表
CREATE TABLE ship_cargo_items (
    cargo_item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '货物项ID',
    ship_id INT NOT NULL COMMENT '飞船ID',
    game_id INT NOT NULL COMMENT '存档ID',
    commodity_id INT NOT NULL COMMENT '商品ID',
    quantity INT NOT NULL COMMENT '数量',
    purchased_price DECIMAL(15,2) COMMENT '购买单价',
    source_location_id INT COMMENT '购买地点ID',
    source_location_type ENUM('station', 'planet', 'system') COMMENT '购买地点类型',
    acquired_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '获取时间',
    FOREIGN KEY (ship_id) REFERENCES player_ships(ship_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES game_saves(game_id) ON DELETE CASCADE,
    INDEX idx_ship_game (ship_id, game_id)
) COMMENT '记录飞船上装载的各种货物明细';

-- 数据示例：manufacturers
INSERT INTO manufacturers (
    name, description, faction_id, specialization, reputation_bonus,
    headquarters_system_id, logo_url, established_date
)
VALUES
-- 自由星系联盟
('德雷克工业（Drake Industries）', '自由星系最大的舰船制造商，以模块化设计和高性价比著称。', 1, '轻型战斗舰、民用飞船', 5, 1, '/assets/manufacturers/drake.png', '3021-07-12'),

-- 布雷顿尼亚
('卡文迪许矿业公司（Cavendish Mining Co.）', '布雷顿尼亚贵族控制的大型矿业联合体，控制多个富矿带。', 2, '矿产采掘设备与重装装甲', 3, 2, '/assets/manufacturers/cavendish.png', '2984-04-18'),

-- 库萨里帝国
('山田重工（Yamada Heavy Works）', '库萨里最负盛名的企业财阀，涉足舰船、能源和轨道农业。', 3, '重型舰船与能源系统', 4, 3, '/assets/manufacturers/yamada.png', '2999-11-05'),

-- 莱茵兰
('西格玛军械厂（SIGMA Armaments）', '莱茵兰军方直属军工企业，专注于精密武器与装甲系统。', 4, '能量武器、战术模块', 6, 4, '/assets/manufacturers/sigma.png', '2967-03-09'),

-- 盛唐联邦
('明远系统科技（Mingyuan Systems）', '盛唐联邦核心科技研发机构，开发先进导航与通讯技术。', 5, 'AI导航、天文探测器', 7, 5, '/assets/manufacturers/mingyuan.png', '3040-01-01'),

-- 斯拉夫星域共和国
('新红星重工（New Red Star Works）', '共和国境内规模最大的国营重工业集团，耐用性极高。', 6, '工业机器人与舰体合金', 5, 6, '/assets/manufacturers/redstar.png', '2972-08-21'),

-- 赏金猎人公会
('天蝎动力（Scorpio Dynamics）', '为佣兵打造的模块化动力系统，注重火力输出。', 7, '动力核心、推进器', 2, 7, '/assets/manufacturers/scorpio.png', '3035-02-14'),

-- 气体开采公会
('H3开采联合（H3 Mining Guild）', '专门为氦-3采集打造的低温设备制造商。', 8, '深空采气设备', 1, 8, '/assets/manufacturers/h3guild.png', '3028-10-03'),

-- 中立拓荒者
('自由构件（Freeform Components）', 'Zoners使用的多用途构件制造商，适用于边境生存环境。', 9, '边境建材、空气处理模块', 2, 9, '/assets/manufacturers/freeform.png', '3017-06-06'),

-- 废品回收者
('循环工坊（CycleWorks）', '从废品中提炼再造部件，擅长低成本生产。', 10, '回收零件、改装组件', 1, 10, '/assets/manufacturers/cycle.png', '3001-12-12'),

-- 奥特卡斯特
('蓝光精炼集团（Blue Light Syndicate）', '秘密控制卡达明提炼技术的组织，在黑市极具影响力。', 12, '毒品加工与运输船改造', 0, 12, '/assets/manufacturers/bluelight.png', '3051-09-09'),

-- 秩序组织
('虚光研究所（Nulllight Institute）', '秩序组织内部高保密科研单位，研发反Nomads科技。', 13, '反外星生物武器、数据干扰系统', 0, 13, '/assets/manufacturers/nulllight.png', '3043-05-05');


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
('自由星系（Liberty Prime）', '银河自由贸易的中心，拥有发达的经济系统与强大军事存在，是无数商人与雇佣兵的梦想之地。', 3, 2, 'core', 1, 100.0, 50.0, 20.0, TRUE),

('布雷顿星区（Bretonia Core）', '工业化严重的殖民母星区，以小行星采矿与重型船坞著称，浓厚的阶级制度主导星区秩序。', 4, 3, 'core', 2, 60.0, 100.0, 30.0, TRUE),

('库萨里星域（Kusari Heartland）', '传统与科技并存的星域，巨大的轨道温室与造船厂散布其间，是东方舰队的重要基地。', 4, 2, 'core', 3, 140.0, 70.0, 25.0, TRUE),

('莱茵兰核心区（Rheinland Axis）', '军工与能源联合发展的工业强区，舰队巡逻频繁，安全但戒备森严。', 5, 3, 'core', 4, 80.0, 30.0, 60.0, TRUE),

('盛唐核心区（Tang Central）', '盛唐联邦行政和科技研究重地，气候宜人、治安良好，是最具秩序与文化底蕴的星域之一。', 3, 1, 'core', 5, 160.0, 80.0, 10.0, TRUE),

('斯拉夫要塞区（Slavic Bastion）', '资源丰富却气候恶劣，遍布巨型工业城与采矿基地，是共和国最具防御性的战略区。', 5, 4, 'core', 6, 30.0, 20.0, 80.0, TRUE),

('外层开采区（Helium Ridge）', '气体开采公会控制的能量星区，资源丰富但环境危险，适合经验丰富的飞行员探索。', 6, 5, 'mid', 8, 170.0, 110.0, 40.0, TRUE),

('边缘市场（Junkyard Belt）', '废品回收者控制的废弃轨道群，贸易与走私并存，是灰色交易的天堂。', 4, 6, 'mid', 10, 120.0, 140.0, 60.0, TRUE),

('自治走廊（Zoner Arc）', '由拓荒者建立的中立走廊，空间站零散但稳定，是边缘科学家和和平主义者的庇护所。', 3, 2, 'mid', 9, 200.0, 120.0, 30.0, TRUE),

('佣兵走廊（Hunter''s Range）', '赏金猎人公会控制的星区，几乎每天都有战斗发生，是雇佣兵试炼的摇篮。', 5, 7, 'mid', 7, 150.0, 30.0, 75.0, TRUE),

('奥米克隆阿尔法（Omicron Alpha）', 'Outcasts的首都星系，是Cardamine毒品的产地与走私枢纽，极度危险但利润丰厚。', 8, 9, 'rim', 12, 220.0, 80.0, 90.0, FALSE),

('奥米克隆伽马（Omicron Gamma）', 'Corsairs的主基地所在，星系贫瘠但军事化极强，航道常遭拦截与伏击。', 8, 8, 'rim', 11, 10.0, 90.0, 100.0, FALSE),

('隐匿之门（Delta Rift）', 'The Order的秘密要塞星系，雷区密布，只有获得授权的飞船才有可能安全通过。', 9, 9, 'rim', 13, 190.0, 10.0, 110.0, FALSE),

('虚空深域（Nomad Nexus）', 'Nomads的母体所在星域，常规飞船几乎无法生存，能量波动与心理攻击频发，是整个银河系的禁区。', 10, 10, 'unknown', 14, 250.0, 250.0, 250.0, FALSE);


-- 数据示例：planets
INSERT INTO planets (system_id, name, description, has_station, resource_richness, controlling_faction_id, orbital_position) VALUES
(1, '行星自由一号', '自由星系的行政中心和贸易枢纽，拥有繁荣的都市与轨道城邦。', TRUE, 6, 1, 0.7),
(2, '布雷顿矿星', '布雷顿尼亚的重型采矿基地，遍布巨型机械与轨道精炼厂。', TRUE, 8, 2, 1.2),
(3, '新东京', '库萨里的文化与政治中心，融合自然景观与超高科技都市。', TRUE, 5, 3, 0.9),
(4, '汉堡星', '莱茵兰首府，气候严酷但工业产能惊人，驻军密集。', TRUE, 7, 4, 1.1),
(5, '盛唐本星', '盛唐联邦的精神象征，维持严谨的农业生态与尖端研究中心。', TRUE, 5, 5, 1.0),
(6, '列宁诺夫', '斯拉夫共和国的政治与军事中心，星球地壳富含金属矿脉。', TRUE, 9, 6, 0.6),
(7, '气矿基地一号', '气体开采公会运营的氦-3提炼核心，布满浮空采集平台。', TRUE, 10, 8, 1.3),
(8, '破碎之环', '废品回收者重组的小行星带星球核心，进行走私与物资整理。', TRUE, 6, 10, 1.8),
(9, '自治之港', '拓荒者建设的生态星球，主打太空农业与和平社区实验。', TRUE, 4, 9, 1.5),
(10, '猎人要塞', '赏金猎人公会的军事中枢与训练营所在地。', TRUE, 3, 7, 1.1),
(11, '卡达明核心', '盛产毒品Cardamine的行星，人口依赖药物生存。', FALSE, 8, 12, 0.8),
(12, '海盗母星', 'Corsairs部族的母星，分裂统治但战斗力强悍。', FALSE, 7, 11, 1.0),
(13, '秩序之眼', '秩序组织的隐藏基地星球，拥有强大干扰与反制系统。', TRUE, 6, 13, 0.6),
(14, '虚空核心', 'Nomads的能量星体，呈现半透明与不规则结构。', FALSE, 10, 14, 0.5);


-- 数据示例：stations
INSERT INTO stations (name, description, system_id, planet_id, controlling_faction_id, has_shipyard, has_market, has_shop, has_bar, has_mission_board, market_tax_rate)
VALUES
-- Liberty
('Freeport Alpha', '自由星系联盟的重要经济枢纽，位于商业航道交汇处，设施先进，货物流通旺盛。', 1, 1, 1, TRUE, TRUE, TRUE, TRUE, TRUE, 5.00),
('Relay Station Beta', '中型通信与补给站，靠近边缘星带，为民用航行提供维修与补给服务，税率较低。', 1, 2, 1, FALSE, TRUE, TRUE, TRUE, TRUE, 3.50),

-- Bretonia
('Cambridge Station', '坐落于学术与工业并重的剑桥星轨，布雷顿尼亚的科研重地，亦承担部分舰船维修任务。', 2, 3, 2, TRUE, TRUE, TRUE, TRUE, TRUE, 6.00),
('Sheffield Industrial Hub', '资源丰富轨道上的工业站点，承担部分军民联合制造任务，配备小型船坞。', 2, 4, 2, TRUE, TRUE, FALSE, TRUE, TRUE, 6.80),

-- Kusari
('New Tokyo Nexus', '库萨里的太空门户，融合传统与现代的太空港，商业与文化交汇之地。', 3, 5, 3, TRUE, TRUE, TRUE, TRUE, TRUE, 5.50),
('Amaterasu Civic Port', '专为财阀与中产阶层打造的中型港口，环境洁净、管制严格。', 3, 6, 3, FALSE, TRUE, TRUE, TRUE, TRUE, 4.80),

-- Rheinland
('Wolf Engineering Platform', '围绕军工重地建造的轨道空间站，专注于舰船维护与战术部署，安保森严。', 4, 7, 4, TRUE, TRUE, TRUE, TRUE, TRUE, 6.50),
('Rheinland Outpost Delta', '接近边境的军事前哨，配有快速反应舰坞与高级侦测系统。', 4, 8, 4, TRUE, FALSE, FALSE, TRUE, TRUE, 5.20),

-- Tang Union
('Hengyang Station', '盛唐联邦设于衡阳星的高轨科考与行政站点，兼具科研、行政与生态物流职能。', 5, 9, 5, TRUE, TRUE, TRUE, TRUE, TRUE, 4.50),
('Starnet Ecological Node', '位于生态环带的资源节点站，采用低排放技术处理农业与环境物流。', 5, 10, 5, FALSE, TRUE, FALSE, TRUE, TRUE, 3.90),

-- Slavic Dominion
('Ural Resource Port', '坐落于资源丰富的乌拉尔星轨道，是斯拉夫星域共和国的资源集散和重工业基地。', 6, 11, 6, TRUE, TRUE, TRUE, TRUE, TRUE, 6.80),
('Leninburg Military Yards', '轨道上的军工复合体，配备远程防御与战舰改装能力。', 6, 12, 6, TRUE, TRUE, FALSE, TRUE, TRUE, 7.20),

-- Bounty Hunters Guild
('Sirius Border Outpost', '赏金猎人公会设于天狼星系的边境前哨，处理通缉令、交易战利品与舰船维护。', 7, 13, 7, TRUE, TRUE, TRUE, TRUE, TRUE, 5.00),
('Falcon Deep Station', '深入星云的隐藏基地，提供快速维修与任务布置，适合远征用。', 7, NULL, 7, TRUE, FALSE, FALSE, TRUE, TRUE, 4.20),

-- Gas Miners Guild
('He-3 Extraction Platform Sigma-17', '专用于开采氦-3的深空平台，是GMG组织的能源生命线，安保严格。', 8, 14, 8, TRUE, TRUE, TRUE, TRUE, TRUE, 5.50),
('Gamma Storage Array', '长距离运输能量存储与补给站，支持采矿编队远距离作业。', 8, NULL, 8, FALSE, TRUE, FALSE, TRUE, TRUE, 5.20),

-- Zoners
('Ring Freeport', '由Zoners在偏远轨道自建的自治贸易站，提供中立交易与补给服务。', 9, NULL, 9, FALSE, TRUE, TRUE, TRUE, TRUE, 4.00),

-- Junkers
('Rust Fortress', '建于废弃航道之上的拾荒者基地，是灰色市场与黑市交易的重要节点。', 10, 17, 10, FALSE, TRUE, TRUE, TRUE, TRUE, 7.00),

-- Corsairs
('Emperor''s Fang', '由Corsairs控制的武装堡垒，位于脉冲带深处，主要用于战舰修复与掠夺物资整备。', 11, NULL, 11, TRUE, TRUE, FALSE, TRUE, TRUE, 0.00),

-- Outcasts
('Flame of Cardamine', 'Outcasts的主要毒品精炼与走私中转站，是Cardamine分销网络的中心。', 12, NULL, 12, TRUE, TRUE, FALSE, TRUE, TRUE, 0.00),

-- The Order
('Osiris Watchpost', 'The Order 的核心军事哨站，用于对抗Nomads与秘密情报交流。', 13, NULL, 13, TRUE, TRUE, TRUE, TRUE, TRUE, 0.00),

-- Nomads
('Xenon Node X', 'Nomads 在亚空间显现的能量节点，人类无法接近，仅可在扫描中察觉其存在。', 14, NULL, 14, FALSE, FALSE, FALSE, FALSE, FALSE, 0.00);



-- 数据示例：jump_gates
INSERT INTO jump_gates (name, source_system_id, destination_system_id, stability, toll_fee, one_way) VALUES
('Gate 自由星系（Liberty） → 布雷顿尼亚（Bretonia）', 1, 2, 10, 0.00, FALSE),
('Gate 布雷顿尼亚（Bretonia） → 自由星系（Liberty）', 2, 1, 10, 0.00, FALSE),
('Gate 自由星系（Liberty） → 库萨里（Kusari）', 1, 3, 10, 0.00, FALSE),
('Gate 库萨里（Kusari） → 自由星系（Liberty）', 3, 1, 10, 0.00, FALSE),
('Gate 自由星系（Liberty） → 莱茵兰（Rheinland）', 1, 4, 10, 0.00, FALSE),
('Gate 莱茵兰（Rheinland） → 自由星系（Liberty）', 4, 1, 10, 0.00, FALSE),
('Gate 布雷顿尼亚（Bretonia） → 莱茵兰（Rheinland）', 2, 4, 10, 0.00, FALSE),
('Gate 莱茵兰（Rheinland） → 布雷顿尼亚（Bretonia）', 4, 2, 10, 0.00, FALSE),
('Gate 库萨里（Kusari） → 莱茵兰（Rheinland）', 3, 4, 10, 0.00, FALSE),
('Gate 莱茵兰（Rheinland） → 库萨里（Kusari）', 4, 3, 10, 0.00, FALSE),
('Gate 莱茵兰（Rheinland） → 盛唐联邦星域', 4, 5, 10, 0.00, FALSE),
('Gate 盛唐联邦星域 → 莱茵兰（Rheinland）', 5, 4, 10, 0.00, FALSE),
('Gate 盛唐联邦星域 → 斯拉夫星域', 5, 6, 10, 0.00, FALSE),
('Gate 斯拉夫星域 → 盛唐联邦星域', 6, 5, 10, 0.00, FALSE),
('Gate 莱茵兰（Rheinland） → 赏金猎人边境', 4, 7, 10, 0.00, FALSE),
('Gate 赏金猎人边境 → 莱茵兰（Rheinland）', 7, 4, 10, 0.00, FALSE),
('Gate 库萨里（Kusari） → 气矿区', 3, 8, 10, 0.00, FALSE),
('Gate 气矿区 → 库萨里（Kusari）', 8, 3, 10, 0.00, FALSE),
('Gate 赏金猎人边境 → 中立拓荒区', 7, 9, 10, 0.00, FALSE),
('Gate 中立拓荒区 → 赏金猎人边境', 9, 7, 10, 0.00, FALSE),
('Gate 气矿区 → 中立拓荒区', 8, 9, 10, 0.00, FALSE),
('Gate 中立拓荒区 → 气矿区', 9, 8, 10, 0.00, FALSE),
('Gate 中立拓荒区 → 废品带', 9, 10, 10, 0.00, FALSE),
('Gate 废品带 → 中立拓荒区', 10, 9, 10, 0.00, FALSE),
('Gate 废品带 → 科西尔星区', 10, 11, 10, 0.00, FALSE),
('Gate 科西尔星区 → 废品带', 11, 10, 10, 0.00, FALSE),
('Gate 科西尔星区 → 奥特卡斯特核心', 11, 12, 10, 0.00, FALSE),
('Gate 奥特卡斯特核心 → 科西尔星区', 12, 11, 10, 0.00, FALSE),
('Gate 奥特卡斯特核心 → 秩序星域', 12, 13, 10, 0.00, FALSE),
('Gate 秩序星域 → 奥特卡斯特核心', 13, 12, 10, 0.00, FALSE),
('Gate 秩序星域 → 未知星域', 13, 14, 10, 0.00, FALSE),
('Gate 未知星域 → 秩序星域', 14, 13, 10, 0.00, FALSE),
('隐秘跃迁门：Zoners → Nomads', 9, 14, 4, 0.00, TRUE),

-- 隐藏单向门 2：秩序组织秘密基地 → 莱茵兰（玩家可从深空返回）
('秘密返航门：Order → Rheinland', 13, 4, 5, 0.00, TRUE);

-- 数据示例：ship_models
INSERT INTO ship_models (name, description, class, faction_id, manufacturer_id, cargo_capacity, weapon_slots, shield_slots, speed, maneuverability, price, image_url) VALUES
('Spear (Liberty-Fighter)', '自由星系联盟主力战斗机，平衡性能与火力。', 'fighter', 1, 1, 50, 4, 2, 300, 7, 150000, '/assets/ships/liberty_fighter.png'),
('Transporter (Liberty-Freighter)', '用于长途贸易路线的自由联邦货运船。', 'freighter', 1, 1, 500, 2, 2, 200, 4, 220000, '/assets/ships/liberty_freighter.png'),
('Knight (Liberty-Multi)', '灵活多用途船只，适合中等任务与探索。', 'multi-role', 1, 1, 200, 3, 2, 250, 6, 180000, '/assets/ships/liberty_multi.png'),

('Sword (Bretonia-Fighter)', '布雷顿尼亚高防御战斗舰，适合阵地战。', 'fighter', 2, 2, 40, 5, 3, 280, 6, 155000, '/assets/ships/bretonia_fighter.png'),
('Bulkship (Bretonia-Freighter)', '强固构造的工业运输舰，用于矿产运输。', 'freighter', 2, 2, 600, 2, 3, 180, 3, 240000, '/assets/ships/bretonia_freighter.png'),
('Guardian (Bretonia-Multi)', '中型战术支持船，兼顾防御与火力。', 'multi-role', 2, 2, 250, 4, 3, 230, 5, 190000, '/assets/ships/bretonia_multi.png'),

('Hayate (Kusari-Fighter)', '库萨里高机动近战型战斗机，适合突袭。', 'fighter', 3, 3, 45, 4, 2, 320, 9, 145000, '/assets/ships/kusari_fighter.png'),
('Feilong (Kusari-Freighter)', '东方式高速商船，适合快速贸易运输。', 'freighter', 3, 3, 400, 2, 2, 240, 5, 210000, '/assets/ships/kusari_freighter.png'),
('Sakura (Kusari-Multi)', '美观而实用的多功能飞船，广受民间欢迎。', 'multi-role', 3, 3, 180, 3, 2, 260, 7, 175000, '/assets/ships/kusari_multi.png'),

('Hammer (Rheinland-Fighter)', '重装甲、重火力战斗机，压制力强。', 'fighter', 4, 4, 55, 5, 3, 270, 5, 160000, '/assets/ships/rheinland_fighter.png'),
('Hauler (Rheinland-Freighter)', '专为能源和军工运输打造的货舰。', 'freighter', 4, 4, 550, 2, 2, 190, 4, 230000, '/assets/ships/rheinland_freighter.png'),
('Logistic (Rheinland-Multi)', '可执行战场补给和远征探索的复合型舰船。', 'multi-role', 4, 4, 240, 3, 3, 240, 6, 185000, '/assets/ships/rheinland_multi.png'),

('Tiance (Tang-Fighter)', '高速机动战机，搭载先进数据链。', 'fighter', 5, 5, 40, 4, 2, 310, 8, 150000, '/assets/ships/tang_fighter.png'),
('Fenghe (Tang-Freighter)', '绿色生态舱与智能管理并重的货运船。', 'freighter', 5, 5, 450, 2, 3, 210, 5, 215000, '/assets/ships/tang_freighter.png'),
('Kunlun (Tang-Multi)', '适应多样任务环境，战略支援与科研并重。', 'multi-role', 5, 5, 220, 3, 3, 250, 6, 190000, '/assets/ships/tang_multi.png'),

('Ironstorm (Slavic-Fighter)', '重型突击舰，适合极端环境下作战。', 'fighter', 6, 6, 60, 5, 3, 260, 4, 165000, '/assets/ships/slavic_fighter.png'),
('Icecrown (Slavic-Freighter)', '超高耐压船体，适合深空资源运输。', 'freighter', 6, 6, 580, 2, 3, 180, 3, 245000, '/assets/ships/slavic_freighter.png'),
('Colonist (Slavic-Multi)', '殖民扩张型多用途舰船，具备应急战斗模块。', 'multi-role', 6, 6, 260, 3, 2, 230, 5, 200000, '/assets/ships/slavic_multi.png'),

('Hunter (BHG-Fighter)', '公会成员广泛使用的战斗猎机，捕捉强敌。', 'fighter', 7, 7, 45, 4, 2, 300, 7, 150000, '/assets/ships/bhg_fighter.png'),
('Custodian (BHG-Freighter)', '设计用于携带高额悬赏目标的押运舰。', 'freighter', 7, 7, 350, 2, 3, 220, 6, 205000, '/assets/ships/bhg_freighter.png'),
('Javelin (BHG-Multi)', '兼具战斗与抓捕功能的经典型号。', 'multi-role', 7, 7, 200, 3, 2, 260, 7, 180000, '/assets/ships/bhg_multi.png'),

('Gleamer (GMG-Fighter)', '轻型高能侦察舰，适合气体场作战。', 'fighter', 8, 8, 40, 3, 2, 310, 8, 140000, '/assets/ships/gmg_fighter.png'),
('Gasminer (GMG-Freighter)', '专为采矿与氦-3运输打造。', 'freighter', 8, 8, 420, 2, 2, 200, 4, 215000, '/assets/ships/gmg_freighter.png'),
('Drifter (GMG-Multi)', '移动实验平台，常用于气体采集与测绘任务。', 'multi-role', 8, 8, 210, 3, 3, 240, 6, 185000, '/assets/ships/gmg_multi.png'),

('Fang (Zoners-Fighter)', '边境自卫型小型舰艇。', 'fighter', 9, 9, 40, 3, 2, 300, 6, 135000, '/assets/ships/zoner_fighter.png'),
('Haven (Zoners-Freighter)', '和平贸易之用，注重隐形与舒适。', 'freighter', 9, 9, 370, 2, 3, 210, 6, 200000, '/assets/ships/zoner_freighter.png'),
('Dawn (Zoners-Multi)', '结合科研和探险功能的通用船。', 'multi-role', 9, 9, 220, 3, 3, 240, 6, 180000, '/assets/ships/zoner_multi.png'),

('Shadow (Junkers-Fighter)', '改装灵活的小型战斗舰。', 'fighter', 10, 10, 35, 4, 1, 290, 7, 130000, '/assets/ships/junkers_fighter.png'),
('Scrapboat (Junkers-Freighter)', '由多种残骸拼接而成的货舰，效率尚可。', 'freighter', 10, 10, 300, 1, 2, 200, 4, 180000, '/assets/ships/junkers_freighter.png'),
('Rogue (Junkers-Multi)', '非法贸易与回收的理想平台。', 'multi-role', 10, 10, 180, 2, 2, 240, 6, 160000, '/assets/ships/junkers_multi.png'),

('Wraith (Outcasts-Fighter)', '专为毒品卡达明护航设计，快速、致命，拥有极高的操控性。', 'fighter', 12, 11, 40, 5, 2, 330, 9, 170000, '/assets/ships/outcasts_fighter.png'),
('Syndicargo (Outcasts-Freighter)', '掩护下的毒品运输舰，具备大容量与反制能力。', 'freighter', 12, 11, 520, 3, 2, 210, 5, 230000, '/assets/ships/outcasts_freighter.png'),
('Eclipse (Outcasts-Multi)', '用于边境渗透与快速打击的多功能战舰。', 'multi-role', 12, 11, 230, 4, 3, 260, 8, 200000, '/assets/ships/outcasts_multi.png'),

('Phantom (Nomads-Fighter)', '能量构造的神秘战机，具有变幻莫测的战术能力。', 'fighter', 14, 12, 0, 6, 4, 350, 10, 0, '/assets/ships/nomads_fighter.png'),
('Absorber (Nomads-Freighter)', '具备非传统结构的运载单位，可吸收周围能量作为推进力。', 'freighter', 14, 12, 600, 3, 3, 230, 6, 0, '/assets/ships/nomads_freighter.png'),
('Sentience (Nomads-Multi)', '兼具战斗、探测与侵蚀能力的外星舰体。', 'multi-role', 14, 12, 300, 5, 4, 280, 9, 0, '/assets/ships/nomads_multi.png');



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
