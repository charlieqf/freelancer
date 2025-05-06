"""
测试Faction模型是否与数据库表结构匹配
"""
from app import create_app, db
from app.models.universe import Faction

app = create_app()

with app.app_context():
    try:
        print("尝试查询factions表...")
        result = db.session.execute(db.select(Faction)).all()
        print(f"成功获取了 {len(result)} 个势力记录")
        
        if len(result) > 0:
            faction = result[0][0]  # 获取第一个结果
            print(f"第一条记录: ID={faction.faction_id}, 名称={faction.name}")
            
            # 尝试转换为字典
            faction_dict = faction.to_dict()
            print("成功转换为字典:", faction_dict)
        else:
            print("factions表中没有数据")
            
    except Exception as e:
        print(f"错误: {str(e)}")
        import traceback
        traceback.print_exc()
