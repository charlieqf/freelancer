"""
Freelancer游戏 - 数据库初始化脚本
"""
import os
import sys
import pymysql
from flask import Flask

def parse_db_uri(db_uri):
    """解析数据库连接URI"""
    parts = db_uri.replace('mysql+pymysql://', '').split('@')
    user_pass = parts[0].split(':')
    host_port_db = parts[1].split('/')
    host_port = host_port_db[0].split(':')
    
    username = user_pass[0]
    password = user_pass[1] if len(user_pass) > 1 else ''
    host = host_port[0]
    port = int(host_port[1]) if len(host_port) > 1 else 3306
    database = host_port_db[1]
    
    return {
        'host': host,
        'port': port,
        'user': username,
        'password': password,
        'database': database
    }

def init_db():
    """初始化数据库和表结构"""
    from app import create_app, db
    
    # 创建应用实例获取配置
    app = create_app(os.getenv('FLASK_CONFIG') or 'development')
    
    with app.app_context():
        # 提取配置信息
        db_uri = app.config['SQLALCHEMY_DATABASE_URI']
        db_info = parse_db_uri(db_uri)
        
        print(f"正在连接到MySQL服务器: {db_info['host']}:{db_info['port']}")
        try:
            # 先创建数据库（如果不存在）
            conn = pymysql.connect(
                host=db_info['host'],
                port=db_info['port'],
                user=db_info['user'],
                password=db_info['password']
            )
            cursor = conn.cursor()
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_info['database']} "
                           f"CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
            cursor.close()
            conn.close()
            print(f"数据库 {db_info['database']} 已准备就绪")
            
            # 然后使用SQLAlchemy创建表结构
            db.create_all()
            print("表结构创建完成")
            
            return True
            
        except Exception as e:
            print(f"数据库初始化失败: {e}")
            return False

def import_game_data():
    """导入游戏初始数据"""
    from app import create_app
    
    # 创建应用实例获取配置
    app = create_app(os.getenv('FLASK_CONFIG') or 'development')
    
    with app.app_context():
        # 提取配置信息
        db_uri = app.config['SQLALCHEMY_DATABASE_URI']
        db_info = parse_db_uri(db_uri)
        
        # 构建SQL文件路径
        base_dir = os.path.abspath(os.path.dirname(__file__))
        project_root = os.path.dirname(base_dir)
        sql_dir = os.path.join(project_root, 'database')
        
        # 按顺序执行SQL文件
        sql_files = [
            os.path.join(sql_dir, 'schema_part1.sql'),
            os.path.join(sql_dir, 'schema_part2.sql'),
            os.path.join(sql_dir, 'schema_part3.sql')
        ]
        
        print(f"正在连接到MySQL服务器: {db_info['host']}:{db_info['port']}")
        try:
            conn = pymysql.connect(
                host=db_info['host'],
                port=db_info['port'],
                user=db_info['user'],
                password=db_info['password'],
                database=db_info['database'],
                charset='utf8mb4'
            )
            
            for sql_file in sql_files:
                print(f"正在导入: {os.path.basename(sql_file)}")
                with open(sql_file, 'r', encoding='utf-8') as f:
                    sql_commands = f.read()
                    
                cursor = conn.cursor()
                # 按语句执行SQL
                for statement in sql_commands.split(';'):
                    if statement.strip():
                        try:
                            cursor.execute(statement)
                        except Exception as e:
                            print(f"执行语句出错: {e}")
                            print(f"语句: {statement[:100]}...")
                
                cursor.close()
                conn.commit()
            
            conn.close()
            print("游戏数据导入完成！")
            return True
            
        except Exception as e:
            print(f"游戏数据导入失败: {e}")
            return False

if __name__ == '__main__':
    if len(sys.argv) > 1:
        if sys.argv[1] == 'init':
            print("初始化数据库...")
            if init_db():
                print("数据库初始化成功!")
        elif sys.argv[1] == 'import':
            print("导入游戏数据...")
            if import_game_data():
                print("游戏数据导入成功!")
        else:
            print("未知命令。使用 'init' 初始化数据库或 'import' 导入游戏数据。")
    else:
        print("请指定操作命令： python init_db.py [init|import]")
