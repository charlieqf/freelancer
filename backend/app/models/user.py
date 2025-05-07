"""
Freelancer游戏 - 用户模型
"""
from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token, create_refresh_token

from .. import db

class User(db.Model):
    """用户模型"""
    __tablename__ = 'users'
    
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    avatar_url = db.Column(db.String(255))
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
    
    # 注意：移除add_credits和deduct_credits方法
    # 游戏币现在已经移动到GameSave模型中
        
    def generate_tokens(self):
        """生成JWT访问令牌和刷新令牌
        
        Returns:
            dict: 包含访问令牌、刷新令牌和用户信息的字典
        """
        access_token = create_access_token(
            identity=str(self.user_id),  
            additional_claims={
                'username': self.username,
                'email': self.email
            },
            expires_delta=timedelta(minutes=30)
        )
        
        refresh_token = create_refresh_token(
            identity=str(self.user_id),  
            expires_delta=timedelta(days=7)
        )
        
        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': self.to_dict()
        }
    
    def to_dict(self):
        """转换为字典，用于API响应"""
        return {
            'user_id': self.user_id,
            'username': self.username,
            'email': self.email,
            'avatar_url': self.avatar_url,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None
        }
    
    def __repr__(self):
        return f'<User {self.username}>'
