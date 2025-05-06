"""
Freelancer游戏 - API蓝图
"""
from flask import Blueprint

api_bp = Blueprint('api', __name__)

# 从该包中导入路由模块
from . import users

# 以下模块将在后续开发中添加
# from . import systems, ships, trading, missions, factions
