"""
Freelancer游戏 - 游戏存档API路由
"""
from flask import jsonify, request, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime

from . import api_bp
from ..models.game_save import GameSave
from ..models.user import User
from .. import db

# 游戏存档初始化服务
def initialize_new_game_save(game_id, user_id):
    """初始化新游戏存档的基础数据
    
    此处应该创建玩家初始数据，如：
    - 初始飞船
    - 初始位置
    - 初始势力关系
    - 初始统计数据
    等
    
    Todo: 完善此函数以创建完整的初始游戏状态
    """
    # 临时返回成功，后续会完善此函数
    return True


@api_bp.route('/game-saves', methods=['GET'])
@jwt_required()
def get_game_saves():
    """获取用户所有游戏存档"""
    current_user_id = get_jwt_identity()
    
    # 按最后游玩时间倒序排列
    saves = GameSave.query.filter_by(user_id=current_user_id)\
        .order_by(GameSave.last_played_at.desc())\
        .all()
    
    return jsonify({
        'status': 'success',
        'game_saves': [save.to_dict() for save in saves]
    }), 200


@api_bp.route('/game-saves', methods=['POST'])
@jwt_required()
def create_game_save():
    """创建新游戏存档"""
    current_user_id = get_jwt_identity()
    data = request.json or {}
    
    # 创建新存档
    new_save = GameSave(
        user_id=current_user_id,
        save_name=data.get('save_name', f"存档 {datetime.now().strftime('%Y-%m-%d %H:%M')}"),
        game_version=current_app.config.get('GAME_VERSION', '1.0.0')
    )
    
    db.session.add(new_save)
    db.session.commit()
    
    # 初始化新存档的游戏数据
    initialize_new_game_save(new_save.game_id, current_user_id)
    
    return jsonify({
        'status': 'success',
        'message': '存档创建成功',
        'game_save': new_save.to_dict()
    }), 201


@api_bp.route('/game-saves/<int:game_id>', methods=['GET'])
@jwt_required()
def get_game_save(game_id):
    """获取特定游戏存档详情"""
    current_user_id = get_jwt_identity()
    
    # 验证存档归属
    game_save = GameSave.query.filter_by(
        game_id=game_id, 
        user_id=current_user_id
    ).first_or_404()
    
    return jsonify({
        'status': 'success',
        'game_save': game_save.to_dict()
    }), 200


@api_bp.route('/game-saves/<int:game_id>/load', methods=['POST'])
@jwt_required()
def load_game_save(game_id):
    """加载指定的游戏存档"""
    current_user_id = get_jwt_identity()
    
    # 验证存档归属
    game_save = GameSave.query.filter_by(
        game_id=game_id, 
        user_id=current_user_id
    ).first_or_404()
    
    # 更新最后游玩时间
    game_save.last_played_at = datetime.utcnow()
    db.session.commit()
    
    # 返回初始游戏数据
    # TODO: 获取玩家在该存档中的完整状态
    return jsonify({
        'status': 'success',
        'message': '存档加载成功',
        'game_save': game_save.to_dict(),
        # 此处应该包含更多游戏状态数据
    }), 200


@api_bp.route('/game-saves/<int:game_id>', methods=['PUT'])
@jwt_required()
def update_game_save(game_id):
    """更新游戏存档信息（如存档名称）"""
    current_user_id = get_jwt_identity()
    data = request.json or {}
    
    # 验证存档归属
    game_save = GameSave.query.filter_by(
        game_id=game_id, 
        user_id=current_user_id
    ).first_or_404()
    
    # 当前只允许修改存档名
    if 'save_name' in data:
        game_save.save_name = data['save_name']
    
    db.session.commit()
    
    return jsonify({
        'status': 'success',
        'message': '存档信息更新成功',
        'game_save': game_save.to_dict()
    }), 200


@api_bp.route('/game-saves/<int:game_id>', methods=['DELETE'])
@jwt_required()
def delete_game_save(game_id):
    """删除指定的游戏存档"""
    current_user_id = get_jwt_identity()
    
    # 验证存档归属
    game_save = GameSave.query.filter_by(
        game_id=game_id, 
        user_id=current_user_id
    ).first_or_404()
    
    # 删除存档（依赖于数据库设置的级联删除，自动删除相关数据）
    db.session.delete(game_save)
    db.session.commit()
    
    return jsonify({
        'status': 'success',
        'message': '存档删除成功'
    }), 200
