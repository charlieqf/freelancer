"""
认证API的输入验证器
"""
from flask import request, jsonify
from functools import wraps
from app.utils.security import is_valid_username, is_valid_email, is_valid_password

def validate_registration_input(f):
    """注册请求验证装饰器"""
    @wraps(f)
    def decorated(*args, **kwargs):
        data = request.get_json()
        
        # 检查必要字段
        if not all(k in data for k in ('username', 'email', 'password')):
            return jsonify({'error': '缺少必要字段'}), 400
            
        # 验证用户名格式
        if not is_valid_username(data['username']):
            return jsonify({
                'error': '用户名无效',
                'details': '用户名必须为3-20个字符，只能包含字母、数字和下划线'
            }), 400
            
        # 验证邮箱格式
        if not is_valid_email(data['email']):
            return jsonify({
                'error': '邮箱格式无效',
                'details': '请提供有效的电子邮箱地址'
            }), 400
            
        # 验证密码强度
        if not is_valid_password(data['password']):
            return jsonify({
                'error': '密码不符合安全要求',
                'details': '密码必须至少8个字符，包含大小写字母和数字'
            }), 400
            
        return f(*args, **kwargs)
    return decorated

def validate_login_input(f):
    """登录请求验证装饰器"""
    @wraps(f)
    def decorated(*args, **kwargs):
        data = request.get_json()
        
        if not all(k in data for k in ('username', 'password')):
            return jsonify({'error': '请提供用户名和密码'}), 400
            
        return f(*args, **kwargs)
    return decorated

def validate_password_change(f):
    """密码修改请求验证装饰器"""
    @wraps(f)
    def decorated(*args, **kwargs):
        data = request.get_json()
        
        if not all(k in data for k in ('current_password', 'new_password')):
            return jsonify({'error': '请提供当前密码和新密码'}), 400
            
        # 验证新密码强度
        if not is_valid_password(data['new_password']):
            return jsonify({
                'error': '新密码不符合安全要求',
                'details': '密码必须至少8个字符，包含大小写字母和数字'
            }), 400
            
        # 确保新旧密码不同
        if data['current_password'] == data['new_password']:
            return jsonify({'error': '新密码不能与当前密码相同'}), 400
            
        return f(*args, **kwargs)
    return decorated
