"""
Freelancer游戏 - 配置文件
包含开发和生产环境的配置选项
"""
import os
from datetime import timedelta

class Config:
    """基本配置类"""
    # 安全配置
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'your-secret-key-for-dev'
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'your-jwt-secret-key'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1)
    
    # 应用配置
    DEBUG = False
    TESTING = False
    
    # 数据库配置
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # 游戏设置
    INITIAL_CREDITS = 1000.00
    INITIAL_SYSTEM_ID = 1
    
    @staticmethod
    def init_app(app):
        pass

class DevelopmentConfig(Config):
    """开发环境配置"""
    DEBUG = True
    
    # 开发环境数据库 - WSL2 MySQL
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:Fq830815850321@172.26.61.141:3306/freelancer'

class TestingConfig(Config):
    """测试环境配置"""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:Fq830815850321@172.26.61.141:3306/freelancer_test'

class ProductionConfig(Config):
    """生产环境配置"""
    # 生产环境应从环境变量获取配置
    SECRET_KEY = os.environ.get('SECRET_KEY')
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
                             'mysql+pymysql://production_user:password@localhost:3306/freelancer'

config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
