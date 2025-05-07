"""
Freelancer游戏 - API蓝图
"""
from flask import Blueprint

api_bp = Blueprint('api', __name__)

# 从该包中导入路由模块
from . import users
from . import game_saves
from .auth import auth_bp
from .universe import universe_bp

# 注册子蓝图
api_bp.register_blueprint(auth_bp, url_prefix='/auth')
api_bp.register_blueprint(universe_bp, url_prefix='/universe')

# 以下模块将在后续开发中添加
# from . import ships, trading, missions, factions
