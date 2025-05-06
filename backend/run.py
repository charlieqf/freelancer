"""
Freelancer游戏 - 应用入口
"""
import os
import sys
from flask import Flask

# 添加当前目录到Python路径
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app import create_app, db
from flask_migrate import Migrate, upgrade

# 创建应用实例
app = create_app(os.getenv('FLASK_CONFIG') or 'development')
migrate = Migrate(app, db)

# 定义Flask shell上下文
@app.shell_context_processor
def make_shell_context():
    """为Flask shell命令添加上下文"""
    from app.models.user import User
    return dict(db=db, User=User)

if __name__ == '__main__':
    # 启动Web服务器
    app.run(host='0.0.0.0', port=5000)
