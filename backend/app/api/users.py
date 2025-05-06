"""
Freelancer游戏 - 用户API路由
"""
from flask import jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from . import api_bp
from ..models.user import User
from .. import db

@api_bp.route('/users', methods=['GET'])
@jwt_required()
def get_users():
    """获取用户列表（仅管理员可用）"""
    # 此处应添加管理员验证
    users = User.query.all()
    return jsonify({
        'status': 'success',
        'users': [user.to_dict() for user in users]
    }), 200

@api_bp.route('/users/<int:user_id>', methods=['GET'])
@jwt_required()
def get_user(user_id):
    """获取指定用户信息"""
    current_user_id = get_jwt_identity()
    
    # 用户只能查看自己的信息（此处可添加管理员例外）
    if current_user_id != user_id:
        return jsonify({
            'status': 'error',
            'message': '没有权限查看其他用户信息'
        }), 403
    
    user = User.query.get_or_404(user_id)
    return jsonify({
        'status': 'success',
        'user': user.to_dict()
    }), 200

@api_bp.route('/register', methods=['POST'])
def register():
    """用户注册"""
    data = request.get_json()
    
    # 验证必要字段
    required_fields = ['username', 'email', 'password']
    for field in required_fields:
        if field not in data:
            return jsonify({
                'status': 'error',
                'message': f'缺少必要字段：{field}'
            }), 400
    
    # 检查用户名和邮箱是否已存在
    if User.query.filter_by(username=data['username']).first():
        return jsonify({
            'status': 'error',
            'message': '用户名已存在'
        }), 400
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({
            'status': 'error',
            'message': '电子邮箱已存在'
        }), 400
    
    # 创建新用户
    user = User(
        username=data['username'],
        email=data['email']
    )
    user.set_password(data['password'])
    
    db.session.add(user)
    db.session.commit()
    
    return jsonify({
        'status': 'success',
        'message': '注册成功',
        'user_id': user.user_id
    }), 201

@api_bp.route('/login', methods=['POST'])
def login():
    """用户登录"""
    data = request.get_json()
    
    # 验证必要字段
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({
            'status': 'error',
            'message': '请提供用户名和密码'
        }), 400
    
    # 查找用户
    user = User.query.filter_by(username=data['username']).first()
    if not user or not user.check_password(data['password']):
        return jsonify({
            'status': 'error',
            'message': '用户名或密码错误'
        }), 401
    
    # 更新最后登录时间
    user.update_last_login()
    db.session.commit()
    
    # 生成JWT令牌
    from flask_jwt_extended import create_access_token
    access_token = create_access_token(identity=user.user_id)
    
    return jsonify({
        'status': 'success',
        'message': '登录成功',
        'access_token': access_token,
        'user': user.to_dict()
    }), 200
