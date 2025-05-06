"""
Freelancer游戏 - 宇宙相关模型
包括星系、空间站、跳跃点等
"""
from app import db
from datetime import datetime

# 星系模型
class StarSystem(db.Model):
    """星系模型"""
    __tablename__ = 'star_systems'
    
    system_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    difficulty_level = db.Column(db.Integer)
    danger_level = db.Column(db.Integer, default=1)
    type = db.Column(db.String(20), default='mid')
    controlling_faction_id = db.Column(db.Integer, db.ForeignKey('factions.faction_id'))
    x_coord = db.Column(db.Float, nullable=False)
    y_coord = db.Column(db.Float, nullable=False)
    z_coord = db.Column(db.Float, nullable=False)
    is_discovered = db.Column(db.Boolean, default=False)
    
    # 关系
    planets = db.relationship('Planet', backref='system', lazy=True)
    stations = db.relationship('SpaceStation', backref='system', lazy=True)
    controlling_faction = db.relationship('Faction', lazy=True)
    
    # 将星系数据转换为字典
    def to_dict(self, include_relations=False):
        """将星系数据转换为字典"""
        data = {
            'system_id': self.system_id,
            'name': self.name,
            'description': self.description,
            'difficulty_level': self.difficulty_level,
            'danger_level': self.danger_level,
            'type': self.type,
            'controlling_faction_id': self.controlling_faction_id,
            'x_coord': self.x_coord,
            'y_coord': self.y_coord,
            'z_coord': self.z_coord,
            'is_discovered': self.is_discovered
        }
        
        # 包含关联数据
        if include_relations:
            data['stations'] = [station.to_dict() for station in self.stations]
            data['controlling_faction'] = self.controlling_faction.to_dict() if self.controlling_faction else None
        
        return data

# 行星模型
class Planet(db.Model):
    """行星模型"""
    __tablename__ = 'planets'
    
    planet_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    system_id = db.Column(db.Integer, db.ForeignKey('star_systems.system_id'), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    has_station = db.Column(db.Boolean, default=False)
    resource_richness = db.Column(db.Integer)
    controlling_faction_id = db.Column(db.Integer, db.ForeignKey('factions.faction_id'))
    orbital_position = db.Column(db.Float)
    
    # 关系
    controlling_faction = db.relationship('Faction', lazy=True)
    
    # 将行星数据转换为字典
    def to_dict(self):
        """将行星数据转换为字典"""
        return {
            'planet_id': self.planet_id,
            'system_id': self.system_id,
            'name': self.name,
            'description': self.description,
            'has_station': self.has_station,
            'resource_richness': self.resource_richness,
            'controlling_faction_id': self.controlling_faction_id,
            'orbital_position': self.orbital_position
        }

# 空间站模型
class SpaceStation(db.Model):
    """空间站模型"""
    __tablename__ = 'space_stations'
    
    station_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    system_id = db.Column(db.Integer, db.ForeignKey('star_systems.system_id'), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    planet_id = db.Column(db.Integer, db.ForeignKey('planets.planet_id'))
    controlling_faction_id = db.Column(db.Integer, db.ForeignKey('factions.faction_id'))
    has_shipyard = db.Column(db.Boolean, default=False)
    has_bar = db.Column(db.Boolean, default=False)
    has_trade_center = db.Column(db.Boolean, default=False)
    has_mission_board = db.Column(db.Boolean, default=False)
    has_equipment_dealer = db.Column(db.Boolean, default=False)
    price_modifier = db.Column(db.Float, default=1.0)
    
    # 关系
    planet = db.relationship('Planet', lazy=True)
    controlling_faction = db.relationship('Faction', lazy=True)
    
    # 将空间站数据转换为字典
    def to_dict(self):
        """将空间站数据转换为字典"""
        return {
            'station_id': self.station_id,
            'system_id': self.system_id,
            'name': self.name,
            'description': self.description,
            'planet_id': self.planet_id,
            'controlling_faction_id': self.controlling_faction_id,
            'has_shipyard': self.has_shipyard,
            'has_bar': self.has_bar,
            'has_trade_center': self.has_trade_center,
            'has_mission_board': self.has_mission_board,
            'has_equipment_dealer': self.has_equipment_dealer,
            'price_modifier': self.price_modifier
        }

# 跳跃点模型
class JumpGate(db.Model):
    """跳跃点模型"""
    __tablename__ = 'jump_gates'
    
    gate_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    source_system_id = db.Column(db.Integer, db.ForeignKey('star_systems.system_id'), nullable=False)
    target_system_id = db.Column(db.Integer, db.ForeignKey('star_systems.system_id'), nullable=False)
    difficulty_level = db.Column(db.Integer, default=1)
    toll_fee = db.Column(db.Float, default=0.0)
    is_hidden = db.Column(db.Boolean, default=False)
    
    # 关系
    source_system = db.relationship('StarSystem', foreign_keys=[source_system_id], lazy=True)
    target_system = db.relationship('StarSystem', foreign_keys=[target_system_id], lazy=True)
    
    # 将跳跃点数据转换为字典
    def to_dict(self, include_systems=False):
        """将跳跃点数据转换为字典"""
        data = {
            'gate_id': self.gate_id,
            'name': self.name,
            'source_system_id': self.source_system_id,
            'target_system_id': self.target_system_id,
            'difficulty_level': self.difficulty_level,
            'toll_fee': self.toll_fee,
            'is_hidden': self.is_hidden
        }
        
        # 包含关联系统数据
        if include_systems:
            data['source_system'] = self.source_system.to_dict()
            data['target_system'] = self.target_system.to_dict()
            
        return data

# 势力模型
class Faction(db.Model):
    """势力模型"""
    __tablename__ = 'factions'
    
    faction_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    government_type = db.Column(db.String(50))
    primary_industry = db.Column(db.String(50))
    home_system_id = db.Column(db.Integer)
    is_player_accessible = db.Column(db.Boolean, default=False)
    icon_url = db.Column(db.String(200))
    
    # 关系
    controlled_systems = db.relationship('StarSystem', backref='faction', lazy=True)
    
    # 将势力数据转换为字典
    def to_dict(self):
        """将势力数据转换为字典"""
        return {
            'faction_id': self.faction_id,
            'name': self.name,
            'description': self.description,
            'government_type': self.government_type,
            'primary_industry': self.primary_industry,
            'home_system_id': self.home_system_id,
            'is_player_accessible': self.is_player_accessible,
            'icon_url': self.icon_url
        }
