"""
Freelancer游戏 - 用户模型
"""
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

from .. import db

class User(db.Model):
    """用户模型"""
    __tablename__ = 'users'
    
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    avatar_url = db.Column(db.String(255))
    credits = db.Column(db.Numeric(15, 2), default=1000.00)
    reputation = db.Column(db.Integer, default=0)
    # 暂时注释掉外键约束，等导入完整架构后再启用
    # faction_id = db.Column(db.Integer, db.ForeignKey('factions.faction_id'))
    faction_id = db.Column(db.Integer)
    # current_system_id = db.Column(db.Integer, db.ForeignKey('star_systems.system_id'))
    current_system_id = db.Column(db.Integer)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    # 关系 - 暂时注释掉，等其他模型创建后再启用
    """
    ships = db.relationship('PlayerShip', backref='owner', lazy='dynamic')
    achievements = db.relationship('UserAchievement', backref='user', lazy='dynamic')
    missions = db.relationship('PlayerMission', backref='user', lazy='dynamic')
    faction_standings = db.relationship('PlayerFactionStanding', backref='user', lazy='dynamic')
    discoveries = db.relationship('PlayerDiscovery', backref='user', lazy='dynamic')
    statistics = db.relationship('PlayerStatistic', backref='user', uselist=False)
    settings = db.relationship('GameSetting', backref='user', uselist=False)
    """
    
    def __init__(self, username, email, **kwargs):
        """初始化用户"""
        self.username = username
        self.email = email
        for key, value in kwargs.items():
            setattr(self, key, value)
    
    def set_password(self, password):
        """设置密码哈希"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """验证密码"""
        return check_password_hash(self.password_hash, password)
    
    def update_last_login(self):
        """更新最后登录时间"""
        self.last_login = datetime.utcnow()
    
    def add_credits(self, amount):
        """增加游戏币"""
        self.credits += amount
    
    def deduct_credits(self, amount):
        """扣除游戏币"""
        if self.credits < amount:
            return False
        self.credits -= amount
        return True
    
    def to_dict(self):
        """转换为字典，用于API响应"""
        return {
            'user_id': self.user_id,
            'username': self.username,
            'email': self.email,
            'avatar_url': self.avatar_url,
            'credits': float(self.credits),
            'reputation': self.reputation,
            'faction_id': self.faction_id,
            'current_system_id': self.current_system_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None
        }
    
    def __repr__(self):
        return f'<User {self.username}>'
