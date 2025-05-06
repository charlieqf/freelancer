"""
Freelancer游戏 - Flask应用初始化
"""
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from datetime import timedelta

from config import config

# 创建扩展实例
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()

def create_app(config_name='default'):
    """
    应用工厂函数，创建Flask应用实例
    
    Args:
        config_name: 配置类名称，默认为development环境
        
    Returns:
        配置好的Flask应用实例
    """
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)
    
    # JWT配置
    app.config['JWT_SECRET_KEY'] = app.config['SECRET_KEY']
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(minutes=30)
    app.config['JWT_REFRESH_TOKEN_EXPIRES'] = timedelta(days=7)
    
    # 初始化扩展
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    CORS(app)  # 允许跨域请求
    
    # JWT错误处理
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return jsonify({
            'status': 401,
            'sub_status': 42,
            'error': '令牌已过期',
            'message': '请刷新访问令牌或重新登录'
        }), 401
    
    @jwt.invalid_token_loader
    def invalid_token_callback(error_string):
        print(f"Invalid token error: {error_string}")  # 添加调试日志
        return jsonify({
            'status': 401,
            'sub_status': 43,
            'error': '无效的令牌',
            'message': '认证失败，请重新登录'
        }), 401
    
    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return jsonify({
            'status': 401,
            'sub_status': 44,
            'error': '缺少令牌',
            'message': '需要提供访问令牌'
        }), 401
    
    # 注册蓝图
    from .api import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # 注册认证蓝图
    from .api.auth import auth_bp
    app.register_blueprint(auth_bp)
    
    return app
