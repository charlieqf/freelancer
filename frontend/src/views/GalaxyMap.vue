<template>
  <div class="galaxy-map-page">
    <div class="galaxy-map-container">
      <div class="sidebar">
        <!-- 星系信息 -->
        <div class="system-info" v-if="selectedSystem && !selectedStation && !selectedJumpGate">
          <h3>{{ selectedSystem.name }}</h3>
          <div class="detail-line">
            <div class="detail-label">ID:</div>
            <div class="detail-value">{{ selectedSystem.system_id }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">类型:</div>
            <div class="detail-value">{{ getSystemTypeName(selectedSystem.type) }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">坐标:</div>
            <div class="detail-value">({{ selectedSystem.x_coord }}, {{ selectedSystem.y_coord }})</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">控制势力:</div>
            <div class="detail-value">{{ getControllingFaction(selectedSystem.controlling_faction_id) }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">行星:</div>
            <div class="detail-value">{{ selectedSystem.planet_count || 0 }}</div>
          </div>
        </div>
        
        <!-- 空间站信息 -->
        <div class="station-info" v-if="selectedStation">
          <div class="back-link" @click="deselectAll">
            <i class="fas fa-arrow-left"></i> 返回
          </div>
          <h3>{{ selectedStation.name }}</h3>
          <div class="detail-line">
            <div class="detail-label">ID:</div>
            <div class="detail-value">{{ selectedStation.station_id }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">所在星系:</div>
            <div class="detail-value">{{ getSystemName(selectedStation.system_id) }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">控制势力:</div>
            <div class="detail-value">{{ getControllingFaction(selectedStation.controlling_faction_id) }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">设施:</div>
            <div class="detail-value">
              <div class="facility-list">
                <div v-if="selectedStation.has_shipyard" class="facility"><i class="fas fa-rocket"></i> 船坞</div>
                <div v-if="selectedStation.has_shop || selectedStation.has_trade_center" class="facility"><i class="fas fa-exchange-alt"></i> 贸易中心</div>
                <div v-if="selectedStation.has_bar" class="facility"><i class="fas fa-glass-martini"></i> 酒吧</div>
                <div v-if="selectedStation.has_mission_board" class="facility"><i class="fas fa-tasks"></i> 任务板</div>
                <div v-if="selectedStation.has_equipment_dealer" class="facility"><i class="fas fa-wrench"></i> 装备商</div>
                <div v-if="selectedStation.has_inn" class="facility"><i class="fas fa-bed"></i> 旅店</div>
              </div>
            </div>
          </div>
          <div class="detail-line" v-if="selectedStation.market_tax_rate !== undefined">
            <div class="detail-label">贸易税率:</div>
            <div class="detail-value">{{ (selectedStation.market_tax_rate * 100).toFixed(1) }}%</div>
          </div>
          <div class="detail-line" v-if="selectedStation.description">
            <div class="description">{{ selectedStation.description }}</div>
          </div>
          <div class="action-buttons">
            <button class="action-button">
              <i class="fas fa-compass"></i> 导航至此
            </button>
            <button class="action-button">
              <i class="fas fa-info-circle"></i> 更多信息
            </button>
          </div>
        </div>
        
        <!-- 跳跃点信息 -->
        <div class="jumpgate-info" v-if="selectedJumpGate">
          <div class="back-link" @click="deselectAll">
            <i class="fas fa-arrow-left"></i> 返回
          </div>
          <h3>跳跃点 #{{ selectedJumpGate.gate_id || selectedJumpGate.id }}</h3>
          <div class="detail-line">
            <div class="detail-label">ID:</div>
            <div class="detail-value">{{ selectedJumpGate.gate_id || selectedJumpGate.id }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">从:</div>
            <div class="detail-value">{{ getSystemName(selectedJumpGate.source_system_id) }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">到:</div>
            <div class="detail-value">{{ getSystemName(selectedJumpGate.target_system_id || selectedJumpGate.destination_system_id) }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">稳定性:</div>
            <div class="detail-value">{{ selectedJumpGate.difficulty_level || selectedJumpGate.stability || 5 }}/10</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">通行费:</div>
            <div class="detail-value">{{ selectedJumpGate.toll_fee > 0 ? `${selectedJumpGate.toll_fee} CR` : '免费' }}</div>
          </div>
          <div class="detail-line">
            <div class="detail-label">状态:</div>
            <div class="detail-value">{{ selectedJumpGate.is_hidden || selectedJumpGate.one_way ? '单向/隐蔽' : '公开' }}</div>
          </div>
          <div class="action-buttons">
            <button class="action-button" @click="jumpToSystem(selectedJumpGate.target_system_id || selectedJumpGate.destination_system_id)">
              <i class="fas fa-space-shuttle"></i> 跳跃
            </button>
            <button class="action-button">
              <i class="fas fa-info-circle"></i> 情报
            </button>
          </div>
        </div>
        
        <div class="system-select" v-if="!selectedSystem && !selectedStation && !selectedJumpGate">
          <h3>星系地图</h3>
          <p>请选择一个星系、空间站或跳跃点来查看详细信息</p>
        </div>
        
        <div class="map-filters">
          <h3>地图选项</h3>
          <div class="filter-group">
            <label class="filter-checkbox">
              <input type="checkbox" v-model="showStations" @change="handleFilterChange('stations', showStations)">
              <span class="checkbox-label">显示空间站</span>
            </label>
          </div>
          <div class="filter-group">
            <label class="filter-checkbox">
              <input type="checkbox" v-model="showJumpGates" @change="handleFilterChange('jumpgates', showJumpGates)">
              <span class="checkbox-label">显示跳跃点</span>
            </label>
          </div>
        </div>
      </div>
      <div class="map-container">
        <div class="map-controls">
          <button @click="zoomIn" title="放大" class="control-button">
            <i class="fas fa-plus"></i>
          </button>
          <button @click="zoomOut" title="缩小" class="control-button">
            <i class="fas fa-minus"></i>
          </button>
          <button @click="resetView" title="重置视图" class="control-button">
            <i class="fas fa-sync-alt"></i>
          </button>
        </div>
        <div class="loading-overlay" v-if="isLoading">
          <div class="spinner"></div>
          <div class="loading-text">加载星图中...</div>
        </div>
        <div class="legend">
          <h4 class="legend-title">图例</h4>
          <div class="legend-section">
            <h5>星系类型</h5>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #e74c3c;"></div>
              <span class="legend-label">核心区域</span>
            </div>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #3498db;"></div>
              <span class="legend-label">中间区域</span>
            </div>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #2ecc71;"></div>
              <span class="legend-label">边缘区域</span>
            </div>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #95a5a6;"></div>
              <span class="legend-label">未知区域</span>
            </div>
          </div>
          <div class="legend-section">
            <h5>空间站</h5>
            <div class="legend-item">
              <div class="legend-color legend-station" style="background-color: #27ae60;"></div>
              <span class="legend-label">贸易站</span>
            </div>
            <div class="legend-item">
              <div class="legend-color legend-station" style="background-color: #f39c12;"></div>
              <span class="legend-label">矿业站</span>
            </div>
            <div class="legend-item">
              <div class="legend-color legend-station" style="background-color: #c0392b;"></div>
              <span class="legend-label">军事站</span>
            </div>
            <div class="legend-item">
              <div class="legend-color legend-station" style="background-color: #3498db;"></div>
              <span class="legend-label">研究站</span>
            </div>
            <div class="legend-item">
              <div class="legend-color legend-station" style="background-color: #8e44ad;"></div>
              <span class="legend-label">造船厂</span>
            </div>
          </div>
          <div class="legend-section">
            <h5>跳跃点</h5>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #3498db;"></div>
              <span class="legend-label">安全跳跃点</span>
            </div>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #e74c3c;"></div>
              <span class="legend-label">危险跳跃点</span>
            </div>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #555; opacity: 0.6;"></div>
              <span class="legend-label">隐藏跳跃点</span>
            </div>
          </div>
        </div>
        <div ref="galaxyMap" class="galaxy-map-svg"></div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useStore } from 'vuex'
import * as d3 from 'd3'

export default {
  name: 'GalaxyMapPage',
  setup() {
    const store = useStore()
    const galaxyMap = ref(null)
    const svgContainer = ref(null)
    const zoom = ref(null)
    const selectedSystem = ref(null)
    const selectedStation = ref(null)
    const selectedJumpGate = ref(null)
    const systems = ref([])
    const stations = ref([])
    const jumpGates = ref([])
    const showStations = ref(true)
    const showJumpGates = ref(true)
    const isLoading = ref(true)
    
    // 从store获取数据
    const factions = computed(() => store.getters['universe/allFactions'])
    
    // 地图状态
    const mapWidth = ref(0)
    const mapHeight = ref(0)
    const scale = ref(1)
    const translate = ref([0, 0])
    
    // 获取星系类型名称
    const getSystemTypeName = (type) => {
      const types = {
        'core': '核心区域',
        'hub': '枢纽',
        'border': '边境',
        'outer': '外缘',
        'disputed': '争议区域',
        'unexplored': '未探索',
        'special': '特殊区域'
      }
      return types[type] || type
    }
    
    // 获取星系名称
    const getSystemName = (systemId) => {
      if (!systemId) return '未知星系'
      const system = systems.value.find(s => s.system_id === systemId)
      return system ? system.name : '未知星系'
    }
    
    // 获取控制势力名称
    const getControllingFaction = (factionId) => {
      if (!factionId) return '无'
      
      const faction = factions.value.find(f => f.faction_id === factionId)
      return faction ? faction.name : '未知势力'
    }
    
    // 获取星系半径，基于类型和重要性
    const getSystemRadius = (system) => {
      // 核心系统更大
      if (system.type === 'core') {
        return 10
      } else if (system.type === 'mid') {
        return 8
      } else if (system.type === 'rim') {
        return 7
      } else {
        return 6
      }
    }
    
    /**
     * 获取星系颜色，基于类型
     */
    const getSystemColor = (system) => {
      if (system.type === 'core') {
        return '#e74c3c' // 红色 - 核心区域
      } else if (system.type === 'mid') {
        return '#3498db' // 蓝色 - 中等区域
      } else if (system.type === 'rim') {
        return '#2ecc71' // 绿色 - 边缘区域
      } else {
        return '#95a5a6' // 灰色 - 未知区域
      }
    }
    
    /**
     * 获取星系边框颜色
     */
    const getSystemStrokeColor = (system) => {
      if (system.is_discovered) {
        return '#fff'
      } else {
        return '#555'
      }
    }
    
    /**
     * 放大地图
     */
    const zoomIn = () => {
      if (svgContainer.value) {
        svgContainer.value
          .transition()
          .duration(300)
          .call(zoom.value.scaleBy, 1.3)
      }
    }
    
    /**
     * 缩小地图
     */
    const zoomOut = () => {
      if (svgContainer.value) {
        svgContainer.value
          .transition()
          .duration(300)
          .call(zoom.value.scaleBy, 0.7)
      }
    }
    
    /**
     * 重置视图
     */
    const resetView = () => {
      if (svgContainer.value && systems.value.length > 0) {
        // 计算星系位置范围
        const xExtent = d3.extent(systems.value, d => d.x_coord)
        const yExtent = d3.extent(systems.value, d => d.y_coord)
        
        // 创建比例尺
        const width = mapWidth.value
        const height = mapHeight.value
        
        // 计算缩放比例
        const xScale = width / (xExtent[1] - xExtent[0] + 100)
        const yScale = height / (yExtent[1] - yExtent[0] + 100)
        const scaleFactor = Math.min(xScale, yScale) * 0.9
        
        // 计算中心点
        const centerX = (xExtent[0] + xExtent[1]) / 2
        const centerY = (yExtent[0] + yExtent[1]) / 2
        
        // 应用变换
        const transform = d3.zoomIdentity
          .translate(width / 2 - centerX * scaleFactor, height / 2 - centerY * scaleFactor)
          .scale(scaleFactor)
        
        svgContainer.value.call(zoom.value.transform, transform)
      }
    }
    
    // 初始化D3
    const initD3 = () => {
      // 基本D3初始化代码
      if (galaxyMap.value) {
        mapWidth.value = galaxyMap.value.clientWidth
        mapHeight.value = galaxyMap.value.clientHeight
        
        svgContainer.value = d3.select(galaxyMap.value)
          .append('svg')
          .attr('width', '100%')
          .attr('height', '100%')
          
        // 添加背景网格
        const gridSize = 50;
        const gridGroup = svgContainer.value.append('g').attr('class', 'grid');
        
        // 水平线
        for (let y = 0; y < mapHeight.value; y += gridSize) {
          gridGroup.append('line')
            .attr('x1', 0)
            .attr('y1', y)
            .attr('x2', mapWidth.value)
            .attr('y2', y)
            .attr('stroke', '#1a2535')
            .attr('stroke-width', 1);
        }
        
        // 垂直线
        for (let x = 0; x < mapWidth.value; x += gridSize) {
          gridGroup.append('line')
            .attr('x1', x)
            .attr('y1', 0)
            .attr('x2', x)
            .attr('y2', mapHeight.value)
            .attr('stroke', '#1a2535')
            .attr('stroke-width', 1);
        }
        
        // 创建主图层
        const mainGroup = svgContainer.value.append('g')
          .attr('class', 'main-group')
        
        // 创建跳跃点连线图层
        mainGroup.append('g')
          .attr('class', 'jumpgates-layer')
        
        // 创建空间站图层
        mainGroup.append('g')
          .attr('class', 'stations-layer')
        
        // 创建星系图层
        mainGroup.append('g')
          .attr('class', 'systems-layer')
        
        // 创建缩放行为
        zoom.value = d3.zoom()
          .scaleExtent([0.2, 8])
          .on('zoom', event => {
            const transform = event.transform
            scale.value = transform.k
            translate.value = [transform.x, transform.y]
            
            d3.select(galaxyMap.value).select('.main-group')
              .attr('transform', `translate(${transform.x}, ${transform.y}) scale(${transform.k})`)
          })
          
        svgContainer.value.call(zoom.value)
      }
    }

    /**
     * 渲染星图
     */
    const renderMap = () => {
      if (!svgContainer.value) return
      if (!systems.value || !Array.isArray(systems.value) || systems.value.length === 0) return
      
      // 计算星系位置范围
      const xExtent = d3.extent(systems.value, d => d.x_coord)
      const yExtent = d3.extent(systems.value, d => d.y_coord)
      
      // 创建比例尺
      const xScale = d3.scaleLinear()
        .domain(xExtent)
        .range([50, mapWidth.value - 50])
      
      const yScale = d3.scaleLinear()
        .domain(yExtent)
        .range([50, mapHeight.value - 50])
      
      // 渲染星系
      renderSystems(xScale, yScale)
      
      // 如果跳跃点数据已加载完成，渲染跳跃点
      if (jumpGates.value && Array.isArray(jumpGates.value)) {
        renderJumpGates(xScale, yScale)
      }
      
      // 如果空间站数据已加载完成，渲染空间站
      if (stations.value && Array.isArray(stations.value)) {
        renderStations(xScale, yScale)
      }
    }
    
    /**
     * 渲染星系
     */
    const renderSystems = (xScale, yScale) => {
      // 选择星系图层
      const systemsLayer = svgContainer.value.select('.systems-layer')
      
      // 清除现有星系
      systemsLayer.selectAll('*').remove()
      
      // 渲染星系
      const systemNodes = systemsLayer.selectAll('.system')
        .data(systems.value)
        .enter()
        .append('g')
        .attr('class', d => `system system-${d.system_id}`)
        .attr('transform', d => `translate(${xScale(d.x_coord)}, ${yScale(d.y_coord)})`)
      
      // 添加星系外圈
      systemNodes.append('circle')
        .attr('r', d => getSystemRadius(d) + 2)
        .attr('fill', 'none')
        .attr('stroke', d => getSystemStrokeColor(d))
        .attr('stroke-width', 1)
        .attr('opacity', 0.6)
      
      // 添加星系主体
      systemNodes.append('circle')
        .attr('r', d => getSystemRadius(d))
        .attr('fill', d => getSystemColor(d))
        .attr('stroke', '#fff')
        .attr('stroke-width', 0.5)
      
      // 添加星系名称
      systemNodes.append('text')
        .attr('class', 'system-name')
        .attr('y', d => getSystemRadius(d) + 12)
        .attr('text-anchor', 'middle')
        .attr('fill', '#fff')
        .attr('font-size', '10px')
        .text(d => d.name)
      
      // 添加点击事件
      systemNodes.on('click', (event, d) => {
        selectSystem(d)
      })
    }
    
    /**
     * 渲染跳跃点
     */
    const renderJumpGates = (xScale, yScale) => {
      console.log('renderJumpGates调用，显示状态:', showJumpGates.value);
      
      // 清除现有连线，无论是否显示都应该先清除
      const jumpgatesLayer = svgContainer.value.select('.jumpgates-layer');
      jumpgatesLayer.selectAll('*').remove();
      
      // 如果不显示跳跃点，提前返回
      if (!showJumpGates.value) {
        console.log('跳跃点显示已关闭，不渲染');
        return;
      }
      
      if (!jumpGates.value || !Array.isArray(jumpGates.value)) {
        console.log('跳跃点数据不存在或不是数组');
        return;
      }
      
      console.log(`开始渲染 ${jumpGates.value.length} 个跳跃点`);
      
      // 创建跳跃点连线数据
      const jumpgateData = []
      
      // 使用我们从API加载的跳跃点数据
      jumpGates.value.forEach(gate => {
        const sourceSystem = systems.value.find(s => s.system_id === gate.source_system_id)
        // 支持 target_system_id 和 destination_system_id 两种字段名
        const targetSystem = systems.value.find(s => s.system_id === (gate.target_system_id || gate.destination_system_id))
        
        if (sourceSystem && targetSystem) {
          jumpgateData.push({
            id: gate.gate_id || gate.id,
            gate: gate, // 保存原始数据对象以便在点击时使用
            source: sourceSystem,
            target: targetSystem,
            hidden: gate.is_hidden || gate.one_way,
            dangerous: (gate.difficulty_level || gate.stability || 0) > 5
          })
        }
      })
      
      // 创建跳跃点组
      const gateGroups = jumpgatesLayer.selectAll('.jumpgate')
        .data(jumpgateData)
        .enter()
        .append('g')
        .attr('class', d => `jumpgate jumpgate-${d.id}`)
        .on('click', (event, d) => {
          event.stopPropagation() // 阻止事件冒泡
          selectJumpGate(d.gate) // 使用原始的跳跃点数据
        })
      
      // 添加跳跃点连线
      gateGroups.append('line')
        .attr('x1', d => xScale(d.source.x_coord))
        .attr('y1', d => yScale(d.source.y_coord))
        .attr('x2', d => xScale(d.target.x_coord))
        .attr('y2', d => yScale(d.target.y_coord))
        .attr('stroke', d => d.dangerous ? '#e74c3c' : (d.hidden ? '#555' : '#3498db'))
        .attr('stroke-width', d => d.dangerous ? 0.8 : 1.2) // 危险跳跃点(红色)使用更细的线条
        .attr('stroke-dasharray', d => d.hidden ? '3,3' : '0')
        .attr('opacity', d => d.hidden ? 0.4 : 0.7)
      
      // 添加跳跃点标记
      gateGroups.append('circle')
        .attr('class', 'jumpgate-marker')
        .attr('cx', d => (xScale(d.source.x_coord) + xScale(d.target.x_coord)) / 2)
        .attr('cy', d => (yScale(d.source.y_coord) + yScale(d.target.y_coord)) / 2)
        .attr('r', 3)
        .attr('fill', d => d.dangerous ? '#e74c3c' : (d.hidden ? '#555' : '#3498db'))
        .attr('stroke', '#fff')
        .attr('stroke-width', 0.5)
        .on('mouseover', function() {
          d3.select(this).attr('r', 5).attr('stroke-width', 1.5)
        })
        .on('mouseout', function() {
          d3.select(this).attr('r', 3).attr('stroke-width', 0.5)
        })
    }
    
    /**
     * 渲染空间站
     */
    const renderStations = (xScale, yScale) => {
      console.log('renderStations调用，显示状态:', showStations.value);
      
      // 清除现有空间站，无论是否显示都应该先清除
      const stationsLayer = svgContainer.value.select('.stations-layer');
      stationsLayer.selectAll('*').remove();
      
      // 如果不显示空间站，提前返回
      if (!showStations.value) {
        console.log('空间站显示已关闭，不渲染');
        return;
      }
      
      if (!stations.value || !Array.isArray(stations.value)) {
        console.log('空间站数据不存在或不是数组');
        return;
      }
      
      console.log(`开始渲染 ${stations.value.length} 个空间站`);
      
      // 渲染空间站
      const stationNodes = stationsLayer.selectAll('.station')
        .data(stations.value)
        .enter()
        .append('g')
        .attr('class', d => `station station-${d.station_id}`)
        .attr('transform', d => {
          // 查找空间站所属的星系
          const system = systems.value.find(s => s.system_id === d.system_id)
          if (!system) return ''
          
          // 基于站点ID计算位置偏移，这样同一星系的多个空间站不会重叠
          const angle = (d.station_id % 6) * (Math.PI / 3)
          const distance = 20 // 距星系的距离
          const x = xScale(system.x_coord) + Math.cos(angle) * distance
          const y = yScale(system.y_coord) + Math.sin(angle) * distance
          
          return `translate(${x}, ${y})`
        })
        .on('click', (event, d) => {
          event.stopPropagation() // 阻止事件冒泡
          selectStation(d)
        })
        .on('mouseover', function() {
          d3.select(this).select('rect').attr('stroke', '#fff').attr('stroke-width', 2)
        })
        .on('mouseout', function() {
          d3.select(this).select('rect').attr('stroke', '#555').attr('stroke-width', 0.5)
        })
      
      // 添加空间站图形
      stationNodes.append('rect')
        .attr('width', 10)
        .attr('height', 10)
        .attr('x', -5)
        .attr('y', -5)
        .attr('fill', d => {
          // 根据空间站类型设置颜色
          if (d.has_shipyard) return '#e74c3c' // 船坞为红色
          if (d.has_trade_center || d.has_shop) return '#f1c40f' // 贸易中心为黄色
          return '#3498db' // 默认蓝色
        })
        .attr('stroke', '#555')
        .attr('stroke-width', 0.5)
        .attr('rx', 2) // 圆角
        .attr('ry', 2)
        
      // 添加空间站名称标签
      stationNodes.append('text')
        .attr('x', 0)
        .attr('y', -8)
        .attr('text-anchor', 'middle')
        .attr('font-size', '8px')
        .attr('fill', '#fff')
        .attr('pointer-events', 'none') // 防止文本干扰鼠标事件
        .text(d => d.name)
    }
    
    // 我们不再需要这个函数，因为我们在renderStations中直接设置了颜色
    
    /**
     * 选择星系
     */
    const selectSystem = (system) => {
      selectedSystem.value = system
      selectedStation.value = null
      selectedJumpGate.value = null
    }
    
    /**
     * 选择空间站
     */
    const selectStation = (station) => {
      selectedStation.value = station
      selectedSystem.value = null
      selectedJumpGate.value = null
    }
    
    /**
     * 选择跳跃点
     */
    const selectJumpGate = (jumpGate) => {
      selectedJumpGate.value = jumpGate
      selectedSystem.value = null
      selectedStation.value = null
    }
    
    /**
     * 取消选择
     */
    const deselectAll = () => {
      selectedSystem.value = null
      selectedStation.value = null
      selectedJumpGate.value = null
    }
    
    /**
     * 处理过滤器变化
     */
    const handleFilterChange = (type, value) => {
      console.log(`过滤器变化 - ${type}: ${value}`);
      nextTick(() => {
        renderMap();
      });
    }
    
    /**
     * 跳转到指定系统
     */
    const jumpToSystem = (systemId) => {
      const system = systems.value.find(s => s.system_id === systemId)
      if (system) {
        // 获取当前的缩放和平移状态
        let currentTransform = d3.zoomTransform(svgContainer.value.node());
        let currentXScale = currentTransform.rescaleX(d3.scaleLinear().domain([0, galaxyMap.value.width]).range([0, galaxyMap.value.width]));
        let currentYScale = currentTransform.rescaleY(d3.scaleLinear().domain([0, galaxyMap.value.height]).range([0, galaxyMap.value.height]));
        
        // 缩放到目标系统
        const x = currentXScale(system.x_coord)
        const y = currentYScale(system.y_coord)
        
        // 添加动画效果
        d3.select(svgContainer.value)
          .transition()
          .duration(750)
          .call(zoom.value.transform, 
                d3.zoomIdentity
                  .translate(galaxyMap.value.width / 2 - x, galaxyMap.value.height / 2 - y)
                  .scale(1.5))
          
        // 选中目标系统
        selectSystem(system)
      }
    }
    
    // 组件挂载时加载数据和初始化D3
    onMounted(async () => {
      try {
        isLoading.value = true
        
        // 加载势力数据
        await store.dispatch('universe/fetchFactions')
        
        // 加载星系数据
        const systemsData = await store.dispatch('universe/fetchAllSystems', { showAll: true })
        systems.value = systemsData || []
        console.log(`加载了 ${systems.value.length} 个星系`);
        
        // 初始化D3
        initD3()
        
        // 加载空间站数据
        try {
          const stationsData = await store.dispatch('universe/fetchStations', { showAll: true })
          stations.value = stationsData || []
          console.log(`加载了 ${stations.value.length} 个空间站`);
        } catch (stationError) {
          console.error('加载空间站数据失败:', stationError)
          stations.value = []
        }
        
        // 加载跳跃点数据
        try {
          const jumpGatesData = await store.dispatch('universe/fetchJumpGates', { showAll: true })
          jumpGates.value = jumpGatesData || []
          console.log(`加载了 ${jumpGates.value.length} 个跳跃点`);
        } catch (gateError) {
          console.error('加载跳跃点数据失败:', gateError)
          jumpGates.value = []
        }
        
        // 确保数据加载后再次渲染地图
        nextTick(() => {
          renderMap()
        })
        
        isLoading.value = false
      } catch (error) {
        console.error('初始化星图失败:', error)
        isLoading.value = false
      }
    })
    
    // 监听过滤器变化
    watch([showStations, showJumpGates], (newValues, oldValues) => {
      console.log('过滤器变化', {
        showStations: {
          old: oldValues[0],
          new: newValues[0]
        },
        showJumpGates: {
          old: oldValues[1],
          new: newValues[1]
        }
      });
      nextTick(() => {
        renderMap();
      });
    }, { deep: true });
    
    return {
      galaxyMap,
      isLoading,
      selectedSystem,
      selectedStation,
      selectedJumpGate,
      zoomIn,
      zoomOut,
      resetView,
      showStations,
      showJumpGates,
      getControllingFaction,
      getSystemRadius,
      getSystemColor,
      getSystemStrokeColor,
      getSystemTypeName,
      getSystemName,
      selectSystem,
      selectStation,
      selectJumpGate,
      deselectAll,
      renderMap,
      handleFilterChange,
      jumpToSystem
    }
  }
}
</script>

<style scoped>
.galaxy-map-page {
  width: 100%;
  padding: 0;
  margin: 0;
}

.galaxy-map-container {
  display: flex;
  height: calc(100vh - 100px); /* 减少顶部空间 */
  background-color: #0a0e17;
  color: #fff;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
  width: 100%;
  margin: 0;
  border-radius: 0; /* 移除圆角，让地图充满边缘 */
}

.sidebar {
  width: 320px;
  min-width: 320px; /* 增加侧边栏宽度，让文字显示更完整 */
  padding: 1.5rem;
  background-color: #141b2d;
  border-right: 1px solid #2c3e50;
  overflow-y: auto;
  flex-shrink: 0; /* 防止侧边栏被压缩 */
}

.map-container {
  flex: 1;
  position: relative;
  overflow: hidden;
  width: calc(100% - 320px); /* 确保地图区域填充剩余空间 */
  display: flex; /* 使内部SVG能占满容器 */
  flex-direction: column; /* 垂直方向flex布局 */
}

.galaxy-map-svg {
  width: 100%;
  height: 100%;
  background-color: #0a0e17;
  flex: 1; /* 让SVG占满所有可用空间 */
}

.system-info h3 {
  margin-top: 0;
  color: #3498db;
  margin-bottom: 1rem;
}

.detail-line {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
  border-bottom: 1px solid #2c3e50;
  padding-bottom: 0.5rem;
}

.detail-label {
  color: #95a5a6;
  font-weight: 500;
}

.detail-value {
  color: #ecf0f1;
  white-space: normal; /* 允许文本换行 */
}

.station-info {
  padding: 1rem;
}

.station-info h3 {
  margin-top: 0;
  color: #3498db;
  margin-bottom: 1rem;
}

.station-info .back-link {
  cursor: pointer;
  color: #3498db;
  margin-bottom: 1rem;
}

.station-info .back-link:hover {
  text-decoration: underline;
}

.station-info .facility-list {
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}

.station-info .facility {
  margin-right: 1rem;
  margin-bottom: 0.5rem;
  padding: 0.2rem 0.5rem;
  border: 1px solid #3498db;
  border-radius: 4px;
  color: #3498db;
  font-size: 12px;
}

.station-info .description {
  margin-bottom: 1rem;
  color: #ecf0f1;
  font-size: 14px;
}

.station-info .action-buttons {
  display: flex;
  justify-content: space-between;
  margin-top: 1rem;
}

.station-info .action-button {
  background-color: #3498db;
  border: none;
  border-radius: 4px;
  color: #fff;
  cursor: pointer;
  padding: 0.5rem 1rem;
  font-size: 14px;
}

.station-info .action-button:hover {
  background-color: #2ecc71;
}

.jumpgate-info {
  padding: 1rem;
}

.jumpgate-info h3 {
  margin-top: 0;
  color: #3498db;
  margin-bottom: 1rem;
}

.jumpgate-info .back-link {
  cursor: pointer;
  color: #3498db;
  margin-bottom: 1rem;
}

.jumpgate-info .back-link:hover {
  text-decoration: underline;
}

.jumpgate-info .action-buttons {
  display: flex;
  justify-content: space-between;
  margin-top: 1rem;
}

.jumpgate-info .action-button {
  background-color: #3498db;
  border: none;
  border-radius: 4px;
  color: #fff;
  cursor: pointer;
  padding: 0.5rem 1rem;
  font-size: 14px;
}

.jumpgate-info .action-button:hover {
  background-color: #2ecc71;
}

.system-select {
  text-align: center;
  padding: 2rem 0;
}

.system-select h3 {
  color: #3498db;
  margin-bottom: 1rem;
}

.system-select p {
  color: #95a5a6;
}

.map-controls {
  position: absolute;
  top: 1rem;
  right: 1rem;
  z-index: 100;
  background-color: rgba(20, 27, 45, 0.7);
  border-radius: 4px;
  padding: 0.5rem;
  display: flex;
  flex-direction: column;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.map-controls button {
  margin-bottom: 0.5rem;
  width: 36px;
  height: 36px;
  background-color: #2c3e50;
  border: none;
  border-radius: 4px;
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  font-size: 14px;
}

.map-controls button:last-child {
  margin-bottom: 0;
}

.map-controls button:hover {
  background-color: #3498db;
  transform: scale(1.05);
}

.map-controls button:active {
  transform: scale(0.95);
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(10, 14, 23, 0.8);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: #3498db;
  animation: spin 1s ease-in-out infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-text {
  color: #ecf0f1;
  font-size: 16px;
}

/* D3 样式 */
:deep(.system) {
  cursor: pointer;
  opacity: 0.8;
  transition: opacity 0.2s;
}

:deep(.system:hover) {
  opacity: 1;
}

:deep(.system-name) {
  pointer-events: none;
}

.map-filters {
  margin-top: 20px;
  padding: 15px;
  background-color: rgba(32, 45, 65, 0.6);
  border-radius: 4px;
}

.map-filters h3 {
  margin-top: 0;
  margin-bottom: 15px;
  font-size: 16px;
  color: #3498db;
}

.filter-group {
  margin-bottom: 10px;
}

.filter-group:last-child {
  margin-bottom: 0;
}

.filter-checkbox {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.filter-checkbox input[type="checkbox"] {
  margin-right: 8px;
}

.checkbox-label {
  font-size: 14px;
  color: #ecf0f1;
}

/* 站点和跳跃点样式 */
.station rect:hover {
  stroke: #3498db;
  stroke-width: 2px;
}

.jumpgate line:hover {
  stroke-width: 2.5px;
  opacity: 1 !important;
}

.station-name, .jumpgate-info {
  pointer-events: none;
}

.legend {
  position: absolute;
  bottom: 20px;
  right: 20px;
  background-color: rgba(20, 27, 45, 0.8);
  padding: 15px;
  border-radius: 4px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  z-index: 1000;
}

.legend-title {
  margin-top: 0;
  margin-bottom: 10px;
  color: #3498db;
  font-size: 14px;
  font-weight: bold;
}

.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.legend-color {
  width: 16px;
  height: 16px;
  margin-right: 8px;
  border-radius: 2px;
}

.legend-label {
  font-size: 12px;
  color: #ecf0f1;
}

.legend-section {
  margin-bottom: 15px;
}

.legend-section h5 {
  margin: 5px 0;
  font-size: 13px;
  color: #f1c40f;
  font-weight: normal;
}

.legend-station {
  transform: rotate(45deg);
}

/* 性能优化 - 减少重绘 */
.systems-layer,
.stations-layer,
.jumpgates-layer {
  will-change: transform;
}
</style>
