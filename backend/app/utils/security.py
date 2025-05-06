"""
安全相关工具函数
"""
from werkzeug.security import check_password_hash, generate_password_hash
import re

def validate_password(stored_hash, provided_password):
    """验证用户密码"""
    return check_password_hash(stored_hash, provided_password)

def hash_password(password):
    """生成密码哈希"""
    return generate_password_hash(password, method='pbkdf2:sha256')

def is_valid_password(password):
    """检查密码是否符合安全要求
    
    要求:
    - 至少8个字符
    - 包含大小写字母
    - 包含数字
    """
    if len(password) < 8:
        return False
    if not any(c.isupper() for c in password):
        return False
    if not any(c.islower() for c in password):
        return False
    if not any(c.isdigit() for c in password):
        return False
    return True

def is_valid_email(email):
    """检查邮箱格式是否有效"""
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(email_pattern, email))

def is_valid_username(username):
    """检查用户名是否有效
    
    要求:
    - 3-20个字符
    - 只包含字母、数字、下划线
    """
    if len(username) < 3 or len(username) > 20:
        return False
    username_pattern = r'^[a-zA-Z0-9_]+$'
    return bool(re.match(username_pattern, username))
