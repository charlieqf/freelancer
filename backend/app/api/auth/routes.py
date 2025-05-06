"""
认证API路由
提供用户注册、登录、令牌刷新和个人资料管理等功能
"""
from flask import request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token

from app.models.user import User
from app.services.auth_service import AuthService
from app.utils.security import is_valid_password, is_valid_email, is_valid_username
from app import db

from . import auth_bp

# 创建认证服务实例
auth_service = AuthService()

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    用户注册API
    ---
    请求体:
        username: 用户名
        email: 电子邮箱
        password: 密码
        faction_id: (可选) 势力ID
    响应:
        成功: 201 Created，返回访问令牌、刷新令牌和用户信息
        失败: 400 Bad Request 或 409 Conflict，返回错误信息
    """
    data = request.get_json()
    
    # 基本验证
    if not all(k in data for k in ('username', 'email', 'password')):
        return jsonify({'error': '缺少必要字段'}), 400
    
    try:
        # 创建新用户
        new_user = auth_service.create_user(
            username=data['username'],
            email=data['email'],
            password=data['password'],
            faction_id=data.get('faction_id', 1)  # 默认加入地球联邦
        )
        
        # 生成令牌并返回
        tokens = new_user.generate_tokens()
        return jsonify(tokens), 201
    
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    用户登录API
    ---
    请求体:
        username: 用户名
        password: 密码
    响应:
        成功: 200 OK，返回访问令牌、刷新令牌和用户信息
        失败: 400 Bad Request 或 401 Unauthorized，返回错误信息
    """
    data = request.get_json()
    
    if not all(k in data for k in ('username', 'password')):
        return jsonify({'error': '请提供用户名和密码'}), 400
    
    # 认证用户
    user = auth_service.authenticate_user(data['username'], data['password'])
    
    if not user:
        return jsonify({'error': '用户名或密码不正确'}), 401
    
    # 生成令牌并返回
    tokens = user.generate_tokens()
    return jsonify(tokens), 200

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    """
    刷新访问令牌API
    ---
    请求头:
        Authorization: Bearer <refresh_token>
    响应:
        成功: 200 OK，返回新的访问令牌
        失败: 401 Unauthorized，返回错误信息
    """
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if not user:
        return jsonify({'error': '用户不存在'}), 404
    
    # 创建新的访问令牌
    access_token = create_access_token(
        identity=user.user_id,
        additional_claims={
            'username': user.username,
            'faction_id': user.faction_id,
            'email': user.email
        }
    )
    
    return jsonify({'access_token': access_token}), 200

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """
    获取用户个人资料API
    ---
    请求头:
        Authorization: Bearer <access_token>
    响应:
        成功: 200 OK，返回用户资料
        失败: 404 Not Found，返回错误信息
    """
    current_user_id = int(get_jwt_identity())  # 将字符串ID转换为整数
    user = User.query.get(current_user_id)
    
    if not user:
        return jsonify({'error': '用户不存在'}), 404
    
    return jsonify(user.to_dict()), 200

@auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """
    更新用户个人资料API
    ---
    请求头:
        Authorization: Bearer <access_token>
    请求体:
        email: (可选) 新电子邮箱
        avatar_url: (可选) 头像URL
    响应:
        成功: 200 OK，返回更新后的用户资料
        失败: 400 Bad Request 或 404 Not Found，返回错误信息
    """
    current_user_id = int(get_jwt_identity())  # 将字符串ID转换为整数
    data = request.get_json()
    
    try:
        updated_user = auth_service.update_user_profile(current_user_id, data)
        if not updated_user:
            return jsonify({'error': '用户不存在'}), 404
            
        return jsonify(updated_user.to_dict()), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

@auth_bp.route('/change-password', methods=['PUT'])
@jwt_required()
def change_password():
    """
    修改密码API
    ---
    请求头:
        Authorization: Bearer <access_token>
    请求体:
        current_password: 当前密码
        new_password: 新密码
    响应:
        成功: 200 OK
        失败: 400 Bad Request 或 401 Unauthorized，返回错误信息
    """
    current_user_id = int(get_jwt_identity())  # 将字符串ID转换为整数
    data = request.get_json()
    
    if not all(k in data for k in ('current_password', 'new_password')):
        return jsonify({'error': '请提供当前密码和新密码'}), 400
    
    try:
        success = auth_service.change_password(
            current_user_id,
            data['current_password'],
            data['new_password']
        )
        
        if not success:
            return jsonify({'error': '当前密码不正确'}), 401
            
        return jsonify({'message': '密码修改成功'}), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
