"""
Freelancer游戏 - 游戏存档模型
"""
from datetime import datetime
from .. import db

class GameSave(db.Model):
    """游戏存档模型"""
    __tablename__ = 'game_saves'
    
    game_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete='CASCADE'), nullable=False)
    save_name = db.Column(db.String(50), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_played_at = db.Column(db.DateTime, default=datetime.utcnow)
    game_version = db.Column(db.String(20))
    total_playtime = db.Column(db.Integer, default=0)  # 以秒为单位
    
    # 游戏进度概述
    credits = db.Column(db.Integer, default=1000)
    current_system_id = db.Column(db.Integer, db.ForeignKey('star_systems.system_id', ondelete='SET NULL'))
    reputation = db.Column(db.Integer, default=1)  # 之前的reputation_level
    faction_id = db.Column(db.Integer, db.ForeignKey('factions.faction_id'))
    discovered_systems_count = db.Column(db.Integer, default=0)
    completed_missions_count = db.Column(db.Integer, default=0)
    
    # 可选字段
    thumbnail_path = db.Column(db.String(255))
    status = db.Column(db.String(20), default='active')
    
    # 关系
    user = db.relationship('User', backref=db.backref('game_saves', lazy='dynamic'))
    current_system = db.relationship('StarSystem', foreign_keys=[current_system_id])
    faction = db.relationship('Faction', foreign_keys=[faction_id])
    
    def to_dict(self):
        """转换为字典，用于API响应"""
        return {
            'game_id': self.game_id,
            'user_id': self.user_id,
            'save_name': self.save_name,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'last_played_at': self.last_played_at.isoformat() if self.last_played_at else None,
            'game_version': self.game_version,
            'total_playtime': self.total_playtime,
            'credits': self.credits,
            'current_system_id': self.current_system_id,
            'reputation': self.reputation,
            'faction_id': self.faction_id,
            'discovered_systems_count': self.discovered_systems_count,
            'completed_missions_count': self.completed_missions_count,
            'thumbnail_path': self.thumbnail_path,
            'status': self.status
        }
