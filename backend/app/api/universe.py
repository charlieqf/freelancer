"""
Freelancer游戏 - 宇宙相关API端点
包括星系、空间站、跳跃点等的数据获取
"""
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.universe import StarSystem, SpaceStation, JumpGate, Planet, Faction
from app.models.user import User

# 创建蓝图
universe_bp = Blueprint('universe', __name__)

@universe_bp.route('/systems', methods=['GET'])
@jwt_required()
def get_all_systems():
    """获取所有星系的信息"""
    try:
        # 获取当前用户
        user_id = get_jwt_identity()
        user = User.query.get(int(user_id))
        
        if not user:
            return jsonify({'error': '无效的用户'}), 401
            
        # 获取所有星系
        systems = StarSystem.query.all()
        
        # 构造响应数据
        systems_data = []
        
        # 检查是否传入了type参数
        system_type = request.args.get('type', None)
        show_all = request.args.get('show_all', 'false').lower() == 'true'
        
        for system in systems:
            # 如果指定了类型过滤，则只返回该类型的星系
            if system_type and system.type != system_type:
                continue
                
            # 正常情况只返回已发现的或核心星系，但如果show_all=true则返回所有星系
            if show_all or system.is_discovered or system.type == 'core' or system.type == 'mid':
                systems_data.append(system.to_dict())
        
        return jsonify({
            'success': True,
            'count': len(systems_data),
            'systems': systems_data
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@universe_bp.route('/systems/<int:system_id>', methods=['GET'])
@jwt_required()
def get_system_details(system_id):
    """获取特定星系的详细信息"""
    try:
        # 获取当前用户
        user_id = get_jwt_identity()
        user = User.query.get(int(user_id))
        
        if not user:
            return jsonify({'error': '无效的用户'}), 401
            
        # 获取特定星系
        system = StarSystem.query.get(system_id)
        
        if not system:
            return jsonify({'error': '星系不存在'}), 404
            
        # 检查是否为玩家已发现的星系或初始星系
        if not system.is_discovered and system.type != 'core':
            return jsonify({'error': '星系尚未发现'}), 403
            
        # 获取系统详细信息
        system_data = system.to_dict(include_relations=True)
        
        # 获取星系中的行星
        planets = Planet.query.filter_by(system_id=system_id).all()
        system_data['planets'] = [planet.to_dict() for planet in planets]
        
        # 获取从该星系出发的跳跃点
        jump_gates = JumpGate.query.filter_by(source_system_id=system_id).all()
        system_data['jump_gates'] = []
        
        for gate in jump_gates:
            # 检查目标星系是否已被发现
            target_system = StarSystem.query.get(gate.target_system_id)
            if target_system.is_discovered or target_system.type == 'core' or not gate.is_hidden:
                system_data['jump_gates'].append(gate.to_dict())
        
        return jsonify({
            'success': True,
            'system': system_data
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@universe_bp.route('/stations', methods=['GET'])
@jwt_required()
def get_all_stations():
    """获取所有空间站的信息"""
    try:
        # 获取查询参数
        system_id = request.args.get('system_id', type=int)
        show_all = request.args.get('show_all', 'false').lower() == 'true'
        
        # 获取当前用户
        user_id = get_jwt_identity()
        user = User.query.get(int(user_id))
        
        if not user:
            return jsonify({'error': '无效的用户'}), 401
        
        # 添加调试信息
        print(f"查询空间站，参数：system_id={system_id}, show_all={show_all}")
            
        # 构建查询
        query = SpaceStation.query
        
        # 如果不显示所有空间站，需要检查星系是否被发现
        if not show_all:
            # 只显示已发现星系中的空间站
            query = query.join(StarSystem, SpaceStation.system_id == StarSystem.system_id).filter(
                db.or_(
                    StarSystem.is_discovered == True,
                    StarSystem.type == 'core'
                )
            )
        
        # 如果指定了system_id，只返回该星系中的空间站
        if system_id:
            system = StarSystem.query.get(system_id)
            if not system:
                return jsonify({'error': '星系不存在'}), 404
                
            # 检查是否为玩家已发现的星系或初始星系
            if not show_all and not system.is_discovered and system.type != 'core':
                return jsonify({'error': '星系尚未发现'}), 403
                
            query = query.filter(SpaceStation.system_id == system_id)
            
        # 获取空间站
        stations = query.all()
        
        # 打印数据库查询结果
        print(f"查询到 {len(stations)} 个空间站")
        for station in stations:
            print(f"空间站ID: {station.station_id}, 名称: {station.name}, 所属星系: {station.system_id}")
        
        # 构造响应数据
        stations_data = [station.to_dict() for station in stations]
        
        return jsonify({
            'success': True,
            'count': len(stations_data),
            'stations': stations_data
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@universe_bp.route('/stations/<int:station_id>', methods=['GET'])
@jwt_required()
def get_station_details(station_id):
    """获取特定空间站的详细信息"""
    try:
        # 获取当前用户
        user_id = get_jwt_identity()
        user = User.query.get(int(user_id))
        
        if not user:
            return jsonify({'error': '无效的用户'}), 401
            
        # 获取特定空间站
        station = SpaceStation.query.get(station_id)
        
        if not station:
            return jsonify({'error': '空间站不存在'}), 404
            
        # 获取所属星系
        system = StarSystem.query.get(station.system_id)
        
        # 检查是否为玩家已发现的星系或初始星系
        if not system.is_discovered and system.type != 'core':
            return jsonify({'error': '所属星系尚未发现'}), 403
            
        # 获取空间站详细信息
        station_data = station.to_dict()
        
        # 获取所属星系和行星信息
        station_data['system'] = system.to_dict()
        if station.planet_id:
            planet = Planet.query.get(station.planet_id)
            if planet:
                station_data['planet'] = planet.to_dict()
                
        # 获取控制势力信息
        if station.controlling_faction_id:
            faction = Faction.query.get(station.controlling_faction_id)
            if faction:
                station_data['controlling_faction'] = faction.to_dict()
        
        return jsonify({
            'success': True,
            'station': station_data
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@universe_bp.route('/jumpgates', methods=['GET'])
@jwt_required()
def get_all_jumpgates():
    """获取所有跳跃点的信息"""
    try:
        # 获取查询参数
        system_id = request.args.get('system_id', type=int)
        show_all = request.args.get('show_all', 'false').lower() == 'true'
        
        # 获取当前用户
        user_id = get_jwt_identity()
        user = User.query.get(int(user_id))
        
        if not user:
            return jsonify({'error': '无效的用户'}), 401
            
        # 添加调试信息
        print(f"查询跳跃点，参数：system_id={system_id}, show_all={show_all}")
            
        # 构建查询
        query = JumpGate.query
        
        # 如果不显示所有跳跃点，需要筛选未发现星系中的跳跃点
        if not show_all:
            # 只显示已知星系的跳跃点
            query = query.join(StarSystem, JumpGate.source_system_id == StarSystem.system_id).filter(
                db.or_(
                    StarSystem.is_discovered == True,
                    StarSystem.type == 'core'
                )
            )
        
        # 如果指定了system_id，只返回该星系的跳跃点
        if system_id:
            system = StarSystem.query.get(system_id)
            if not system:
                return jsonify({'error': '星系不存在'}), 404
                
            # 检查是否为玩家已发现的星系或初始星系
            if not show_all and not system.is_discovered and system.type != 'core':
                return jsonify({'error': '星系尚未发现'}), 403
                
            query = query.filter(JumpGate.source_system_id == system_id)
            
        # 获取跳跃点
        gates = query.all()
        
        # 打印数据库查询结果
        print(f"查询到 {len(gates)} 个跳跃点")
        for gate in gates:
            print(f"跳跃点ID: {gate.gate_id}, 名称: {gate.name}, 源星系: {gate.source_system_id}, 目标星系: {gate.destination_system_id}")
        
        # 构造响应数据
        gates_data = [gate.to_dict() for gate in gates]
        
        return jsonify({
            'success': True,
            'count': len(gates_data),
            'jumpgates': gates_data
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@universe_bp.route('/factions', methods=['GET'])
@jwt_required()
def get_all_factions():
    """获取所有势力的信息"""
    try:
        # 获取当前用户
        user_id = get_jwt_identity()
        user = User.query.get(int(user_id))
        
        if not user:
            return jsonify({'error': '无效的用户'}), 401
            
        # 添加调试信息
        print("开始查询factions表...")
        
        # 获取所有势力
        try:
            factions = Faction.query.all()
            print(f"获取到 {len(factions)} 个势力记录")
        except Exception as e:
            print(f"查询Faction表时发生错误: {str(e)}")
            # 打印更详细的错误信息，包括堆栈跟踪
            import traceback
            traceback.print_exc()
            return jsonify({'error': f'数据库查询失败: {str(e)}'}), 500
        
        # 构造响应数据
        try:
            factions_data = []
            for faction in factions:
                try:
                    faction_dict = faction.to_dict()
                    factions_data.append(faction_dict)
                    print(f"处理势力: {faction.name}")
                except Exception as e:
                    print(f"转换势力数据时出错 (ID={faction.faction_id}): {str(e)}")
                    continue
            
            print(f"成功处理 {len(factions_data)} 个势力数据")
            
            return jsonify({
                'success': True,
                'count': len(factions_data),
                'factions': factions_data
            }), 200
        except Exception as e:
            print(f"构造响应数据时出错: {str(e)}")
            traceback.print_exc()
            return jsonify({'error': f'处理数据失败: {str(e)}'}), 500
            
    except Exception as e:
        print(f"获取势力信息时出现未处理异常: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500
