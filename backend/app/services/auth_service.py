"""
认证服务 - 处理用户认证和授权相关功能
"""
from app.models.user import User
from app import db
from app.utils.security import hash_password, is_valid_password, is_valid_email, is_valid_username
from datetime import datetime

class AuthService:
    def create_user(self, username, email, password, faction_id=1):
        """创建新用户
        
        Args:
            username: 用户名
            email: 电子邮箱
            password: 密码明文
            faction_id: 默认势力ID，默认为1（地球联邦）
            
        Returns:
            User: 创建的用户对象
            
        Raises:
            ValueError: 如果提供的数据无效
        """
        # 数据验证
        if not is_valid_username(username):
            raise ValueError("用户名格式无效")
            
        if not is_valid_email(email):
            raise ValueError("邮箱格式无效")
            
        if not is_valid_password(password):
            raise ValueError("密码不符合安全要求")
            
        # 检查用户名和邮箱是否已存在
        if User.query.filter_by(username=username).first():
            raise ValueError("用户名已存在")
            
        if User.query.filter_by(email=email).first():
            raise ValueError("邮箱已被注册")
        
        # 生成密码哈希
        password_hash = hash_password(password)
        
        # 创建新用户
        new_user = User(
            username=username,
            password_hash=password_hash,
            email=email,
            credits=1000.00,  # 新玩家初始资金
            reputation=0,
            faction_id=faction_id,
            current_system_id=1,  # 从太阳系开始
            created_at=datetime.utcnow()
        )
        
        # 保存到数据库
        db.session.add(new_user)
        db.session.commit()
        return new_user

    def authenticate_user(self, username, password):
        """验证用户凭据
        
        Args:
            username: 用户名
            password: 密码明文
            
        Returns:
            User: 验证成功的用户对象，认证失败则返回None
        """
        # 查找用户
        user = User.query.filter_by(username=username).first()
        
        # 验证密码
        if user and user.check_password(password):
            # 更新最后登录时间
            user.last_login = datetime.utcnow()
            db.session.commit()
            return user
            
        return None

    def change_password(self, user_id, current_password, new_password):
        """修改用户密码
        
        Args:
            user_id: 用户ID
            current_password: 当前密码
            new_password: 新密码
            
        Returns:
            bool: 修改成功返回True，否则返回False
            
        Raises:
            ValueError: 如果新密码不符合安全要求
        """
        user = User.query.get(user_id)
        if not user:
            return False
            
        # 验证当前密码
        if not user.check_password(current_password):
            return False
            
        # 验证新密码
        if not is_valid_password(new_password):
            raise ValueError("新密码不符合安全要求")
            
        # 更新密码
        user.password_hash = hash_password(new_password)
        db.session.commit()
        return True
        
    def update_user_profile(self, user_id, data):
        """更新用户资料
        
        Args:
            user_id: 用户ID
            data: 包含可更新字段的字典
            
        Returns:
            User: 更新后的用户对象，如果用户不存在则返回None
        """
        user = User.query.get(user_id)
        if not user:
            return None
            
        # 可更新的字段
        allowed_fields = ['email', 'avatar_url']
        
        for field in allowed_fields:
            if field in data:
                # 邮箱需要额外验证
                if field == 'email' and data[field] != user.email:
                    if not is_valid_email(data[field]):
                        raise ValueError("邮箱格式无效")
                    
                    # 检查邮箱是否已存在
                    if User.query.filter_by(email=data[field]).first():
                        raise ValueError("邮箱已被注册")
                        
                setattr(user, field, data[field])
        
        db.session.commit()
        return user
