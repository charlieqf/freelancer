<template>
  <div class="galaxy-map-page">
    <div class="galaxy-map-container">
      <div class="controls-panel">
        <div class="system-info" v-if="selectedSystem">
          <h2>{{ selectedSystem.name }}</h2>
          <p class="system-description">{{ selectedSystem.description }}</p>
          <div class="system-details">
            <div class="detail-row">
              <span class="detail-label">类型:</span> 
              <span class="detail-value">{{ getSystemTypeName(selectedSystem.type) }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">控制势力:</span> 
              <span class="detail-value">{{ getControllingFaction(selectedSystem.controlling_faction_id) }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">难度等级:</span> 
              <span class="detail-value">{{ selectedSystem.difficulty_level }}/10</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">危险等级:</span> 
              <span class="detail-value">{{ selectedSystem.danger_level }}/10</span>
            </div>
          </div>
          <div class="system-objects" v-if="currentSystemDetails">
            <h3>空间站 ({{ currentSystemDetails.stations ? currentSystemDetails.stations.length : 0 }})</h3>
            <ul class="stations-list">
              <li v-for="station in currentSystemDetails.stations" :key="station.station_id">
                {{ station.name }}
              </li>
            </ul>
            
            <h3>跳跃点 ({{ currentSystemDetails.jump_gates ? currentSystemDetails.jump_gates.length : 0 }})</h3>
            <ul class="jumpgates-list">
              <li 
                v-for="gate in currentSystemDetails.jump_gates" 
                :key="gate.gate_id"
                @click="jumpToSystem(gate.target_system_id)"
                class="jumpgate-item"
              >
                {{ gate.name }} → {{ getSystemName(gate.target_system_id) }}
              </li>
            </ul>
          </div>
        </div>
        <div class="no-selection" v-else>
          <h2>星系地图</h2>
          <p>请选择一个星系以查看详细信息</p>
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
          <p>加载星图数据...</p>
        </div>
        <div ref="galaxyMap" class="galaxy-map-svg"></div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed, watch } from 'vue'
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
    
    // 从store获取数据
    const systems = computed(() => store.getters['universe/allSystems'])
    const currentSystemDetails = computed(() => store.getters['universe/currentSystem'])
    const factions = computed(() => store.getters['universe/allFactions'])
    const isLoading = computed(() => store.getters['universe/isLoading'])
    const jumpGates = computed(() => store.getters['universe/jumpGatesInCurrentSystem'])
    
    // 地图状态
    const mapWidth = ref(0)
    const mapHeight = ref(0)
    const scale = ref(1)
    const translate = ref([0, 0])
    
    // 星系类型名称映射
    const systemTypes = {
      'core': '中心区域',
      'mid': '中层区域',
      'rim': '边缘区域',
      'unknown': '未知区域'
    }
    
    /**
     * 获取星系类型名称
     */
    const getSystemTypeName = (type) => {
      return systemTypes[type] || '未知'
    }
    
    /**
     * 获取控制势力名称
     */
    const getControllingFaction = (factionId) => {
      if (!factionId) return '无'
      // 添加调试信息，帮助我们了解数据状态
      console.log('查找势力ID:', factionId)
      console.log('可用势力列表:', factions.value)
      
      // 确保势力ID是数值类型进行比较
      const faction = factions.value.find(f => f.faction_id === parseInt(factionId))
      return faction ? faction.name : '未知'
    }
    
    /**
     * 获取星系名称
     */
    const getSystemName = (systemId) => {
      const system = systems.value.find(s => s.system_id === systemId)
      return system ? system.name : '未知星系'
    }
    
    /**
     * 初始化D3
     */
    const initD3 = () => {
      isLoading.value = true
      
      // 获取容器尺寸
      const container = galaxyMap.value
      mapWidth.value = container.clientWidth
      mapHeight.value = container.clientHeight
      
      console.log("初始化D3地图，容器尺寸:", { width: mapWidth.value, height: mapHeight.value })
      
      // 创建SVG容器
      svgContainer.value = d3.select(container)
        .append('svg')
        .attr('width', '100%')
        .attr('height', '100%')
        .attr('viewBox', `0 0 ${mapWidth.value} ${mapHeight.value}`)
        .attr('preserveAspectRatio', 'xMidYMid meet')
      
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
      
      // 创建星系图层
      mainGroup.append('g')
        .attr('class', 'systems-layer')
      
      // 创建缩放行为
      zoom.value = d3.zoom()
        .scaleExtent([0.2, 8])
        .on('zoom', handleZoom)
      
      // 应用缩放行为
      svgContainer.value.call(zoom.value)
      
      // 重置视图
      resetView()
      
      console.log("D3初始化完成，准备渲染星系...")
    }
    
    /**
     * 处理缩放事件
     */
    const handleZoom = (event) => {
      const transform = event.transform
      scale.value = transform.k
      translate.value = [transform.x, transform.y]
      
      // 应用变换
      d3.select(galaxyMap.value).select('.main-group')
        .attr('transform', `translate(${transform.x}, ${transform.y}) scale(${transform.k})`)
      
      console.log("视图缩放更新:", { scale: scale.value, translate: translate.value })
    }
    
    /**
     * 渲染星图
     */
    const renderMap = () => {
      if (!svgContainer.value || systems.value.length === 0) return
      
      console.log("开始渲染星图，共有星系:", systems.value.length)
      console.log("所有星系数据:", systems.value.map(s => ({ id: s.system_id, name: s.name, coords: [s.x_coord, s.y_coord] })))
      
      // 计算星系位置范围
      const xExtent = d3.extent(systems.value, d => d.x_coord)
      const yExtent = d3.extent(systems.value, d => d.y_coord)
      
      console.log("星系X坐标范围:", xExtent)
      console.log("星系Y坐标范围:", yExtent)
      
      // 创建比例尺
      const xScale = d3.scaleLinear()
        .domain(xExtent)
        .range([50, mapWidth.value - 50])
      
      const yScale = d3.scaleLinear()
        .domain(yExtent)
        .range([50, mapHeight.value - 50])
      
      // 选择跳跃点图层
      const jumpgatesLayer = svgContainer.value.select('.jumpgates-layer')
      
      // 清除现有连线
      jumpgatesLayer.selectAll('*').remove()
      
      // 创建跳跃点连线
      const jumpgateData = []
      systems.value.forEach(system => {
        // 这里我们需要从API获取跳跃点数据
        // 使用store中的jumpGates数据直接过滤
        const gates = store.state.universe.jumpGates.filter(
          gate => gate.source_system_id === system.system_id
        );
        
        if (gates && gates.length) {
          gates.forEach(gate => {
            const targetSystem = systems.value.find(s => s.system_id === gate.target_system_id)
            if (targetSystem) {
              jumpgateData.push({
                source: system,
                target: targetSystem,
                hidden: gate.is_hidden
              })
            }
          })
        }
      })
      
      // 渲染跳跃点连线
      jumpgatesLayer.selectAll('.jumpgate')
        .data(jumpgateData)
        .enter()
        .append('line')
        .attr('class', d => `jumpgate ${d.hidden ? 'hidden' : ''}`)
        .attr('x1', d => xScale(d.source.x_coord))
        .attr('y1', d => yScale(d.source.y_coord))
        .attr('x2', d => xScale(d.target.x_coord))
        .attr('y2', d => yScale(d.target.y_coord))
        .attr('stroke', d => d.hidden ? '#333' : '#4a89dc')
        .attr('stroke-width', 1.5)
        .attr('stroke-dasharray', d => d.hidden ? '3,3' : '0')
        .attr('opacity', d => d.hidden ? 0.4 : 0.7)
      
      // 选择星系图层
      const systemsLayer = svgContainer.value.select('.systems-layer')
      
      // 清除现有星系
      systemsLayer.selectAll('*').remove()
      
      // 渲染星系
      const systemNodes = systemsLayer.selectAll('.system')
        .data(systems.value)
        .enter()
        .append('g')
        .attr('class', d => `system system-${d.system_id} ${d.is_discovered ? 'discovered' : ''} ${d.type}`)
        .attr('transform', d => `translate(${xScale(d.x_coord)}, ${yScale(d.y_coord)})`)
        .on('click', (event, d) => {
          selectSystem(d)
        })
        .on('mouseover', function() {
          d3.select(this).select('circle').transition()
            .duration(200)
            .attr('r', 12)
        })
        .on('mouseout', function() {
          d3.select(this).select('circle').transition()
            .duration(200)
            .attr('r', 10)
        })
      
      // 添加星系圆点
      systemNodes.append('circle')
        .attr('r', 10)
        .attr('fill', d => getSystemColor(d))
        .attr('stroke', '#fff')
        .attr('stroke-width', 1.5)
        .attr('class', 'system-circle')
      
      // 添加星系名称
      systemNodes.append('text')
        .attr('x', 0)
        .attr('y', -15)
        .attr('text-anchor', 'middle')
        .attr('fill', '#fff')
        .text(d => d.name)
        .attr('class', 'system-label')
      
      isLoading.value = false
    }
    
    /**
     * 获取星系颜色
     */
    const getSystemColor = (system) => {
      // 根据星系类型分配不同颜色
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
     * 选择星系
     */
    const selectSystem = async (system) => {
      selectedSystem.value = system
      
      // 加载该星系的详细信息
      try {
        await store.dispatch('universe/changeCurrentSystem', system.system_id)
      } catch (error) {
        console.error('加载星系详情失败:', error)
      }
    }
    
    /**
     * 跳转到指定星系
     */
    const jumpToSystem = async (systemId) => {
      const targetSystem = systems.value.find(s => s.system_id === parseInt(systemId))
      
      if (targetSystem) {
        try {
          // 选择并加载目标星系
          selectSystem(targetSystem)
          
          // 将视图中心移动到该星系
          centerOnSystem(targetSystem)
        } catch (error) {
          console.error('加载星系详情失败:', error)
        }
      }
    }
    
    /**
     * 将视图中心移动到指定星系
     */
    const centerOnSystem = (system) => {
      if (!svgContainer.value || !system) return
      
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
      
      // 计算目标系统的位置
      const x = xScale(system.x_coord)
      const y = yScale(system.y_coord)
      
      // 计算居中需要的变换
      const centerX = mapWidth.value / 2
      const centerY = mapHeight.value / 2
      const tx = centerX - x * scale.value
      const ty = centerY - y * scale.value
      
      // 创建变换
      const transform = d3.zoomIdentity
        .translate(tx, ty)
        .scale(scale.value)
      
      // 应用变换
      svgContainer.value
        .transition()
        .duration(750)
        .call(zoom.value.transform, transform)
    }
    
    /**
     * 放大
     */
    const zoomIn = () => {
      svgContainer.value
        .transition()
        .duration(300)
        .call(zoom.value.scaleBy, 1.3)
    }
    
    /**
     * 缩小
     */
    const zoomOut = () => {
      svgContainer.value
        .transition()
        .duration(300)
        .call(zoom.value.scaleBy, 0.7)
    }
    
    /**
     * 重置视图
     */
    const resetView = () => {
      if (!svgContainer.value || systems.value.length === 0) return
      
      console.log("重置视图中...")
      
      // 计算星系位置范围，添加边距
      const padding = 50
      const xExtent = d3.extent(systems.value, d => d.x_coord)
      const yExtent = d3.extent(systems.value, d => d.y_coord)
      
      // 确保我们的视图能完全包含所有星系
      const width = mapWidth.value
      const height = mapHeight.value
      
      // 计算缩放比例，使所有星系都在视图中可见
      const xScale = width / (xExtent[1] - xExtent[0] + 2 * padding)
      const yScale = height / (yExtent[1] - yExtent[0] + 2 * padding)
      const scale = Math.min(xScale, yScale) * 0.9 // 稍微缩小一点以确保有边距
      
      // 计算中心点
      const centerX = (xExtent[0] + xExtent[1]) / 2
      const centerY = (yExtent[0] + yExtent[1]) / 2
      
      // 计算变换
      const translateX = width / 2 - centerX * scale
      const translateY = height / 2 - centerY * scale
      
      console.log("计算的视图变换:", { scale, translateX, translateY })
      
      // 应用变换
      const transform = d3.zoomIdentity
        .translate(translateX, translateY)
        .scale(scale)
      
      svgContainer.value.call(zoom.value.transform, transform)
    }
    
    // 组件挂载时
    onMounted(async () => {
      try {
        isLoading.value = true
        console.log("开始初始化星图...")
        
        // 1. 加载势力数据
        await store.dispatch('universe/fetchFactions')
        console.log('已加载势力数据:', store.getters['universe/allFactions'])
        
        // 2. 加载星系数据
        await store.dispatch('universe/fetchAllSystems');
        const systemsData = store.getters['universe/allSystems'];
        console.log('加载的星系数据:', systemsData);
        // 调试：检查星系数据是否正确加载
        if (!systemsData || systemsData.length === 0) {
          console.error('警告: 星系数据为空或未定义!');
        } else {
          console.log(`成功加载 ${systemsData.length} 个星系`);
          
          // 输出每个星系的坐标，帮助排查位置问题
          systemsData.forEach(system => {
            console.log(`星系 ${system.name} (ID: ${system.system_id}): x=${system.x_coord}, y=${system.y_coord}, z=${system.z_coord}`);
          });
        }
        
        // 3. 初始化D3
        console.log('初始化D3...');
        initD3();
        
        // 4. 渲染星图
        console.log('渲染星图...');
        renderMap();
        console.log('星图渲染完成');
        
        // 添加窗口大小改变时重新渲染的监听器
        window.addEventListener('resize', handleResize)
      } catch (error) {
        console.error('初始化星图失败:', error)
      } finally {
        isLoading.value = false
      }
    })
    
    // 监听系统数据变化
    watch(systems, () => {
      renderMap();
    });
    
    // 监听选中的星系变化
    watch(selectedSystem, () => {
      renderMap();
    });
    
    // 窗口大小改变处理
    const handleResize = () => {
      if (galaxyMap.value) {
        mapWidth.value = galaxyMap.value.clientWidth;
        mapHeight.value = galaxyMap.value.clientHeight;
        svgContainer.value
          .attr('width', mapWidth.value)
          .attr('height', mapHeight.value);
        
        renderMap();
      }
    };
    
    // 返回模板需要的函数和数据
    return {
      galaxyMap,
      systems,
      selectedSystem,
      currentSystemDetails,
      isLoading,
      jumpGates,
      getSystemTypeName,
      getControllingFaction,
      getSystemName,
      zoomIn,
      zoomOut,
      resetView,
      jumpToSystem,
      selectSystem
    };
  }
};
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

.controls-panel {
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

/* 确保主内容区域也占满宽度 */
.main-content {
  width: 100%;
  max-width: 100%;
  padding: 0; /* 移除内边距 */
  margin: 0 auto; /* 居中但不添加额外空间 */
  overflow: hidden; /* 防止溢出 */
}

.system-info h2 {
  margin-top: 0;
  color: #3498db;
  margin-bottom: 0.5rem;
}

.system-description {
  font-size: 0.9rem;
  line-height: 1.4;
  color: #bdc3c7;
  margin-bottom: 1.5rem;
}

.system-details {
  background-color: #1c2739;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1.5rem;
}

.detail-row {
  margin: 0.5rem 0;
  display: flex;
  align-items: flex-start;
}

.detail-label {
  color: #95a5a6;
  margin-right: 1rem;
  white-space: nowrap;
  min-width: 80px;
  flex-shrink: 0; /* 防止标签被压缩 */
}

.detail-value {
  flex: 1;
  text-align: right; /* 右对齐保持整齐 */
  word-break: keep-all; /* 尽量不断词 */
  white-space: normal; /* 允许必要时换行显示 */
  overflow: hidden; /* 溢出隐藏 */
  text-overflow: ellipsis; /* 如果溢出则使用省略号 */
}

.system-objects h3 {
  font-size: 1rem;
  margin: 1.5rem 0 0.5rem;
  color: #f1c40f;
}

.stations-list, .jumpgates-list {
  list-style: none;
  padding: 0;
  margin: 0 0 1.5rem;
}

.stations-list li, .jumpgates-list li {
  padding: 0.5rem 0.75rem;
  margin-bottom: 0.3rem;
  background-color: #1c2739;
  border-radius: 4px;
  font-size: 0.9rem;
}

.jumpgate-item {
  cursor: pointer;
  transition: background-color 0.2s;
}

.jumpgate-item:hover {
  background-color: #2c3e50;
}

.no-selection {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  text-align: center;
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
  right: 0;
  bottom: 0;
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

/* D3 样式 */
:deep(.system) {
  opacity: 0.8;
  transition: opacity 0.2s;
}

:deep(.system:hover) {
  opacity: 1;
}

:deep(.system.selected) {
  opacity: 1;
}

:deep(.system text) {
  opacity: 0;
  transition: opacity 0.2s;
}

:deep(.system:hover text), :deep(.system.selected text) {
  opacity: 1;
}

:deep(.core text) {
  opacity: 0.7;
}

:deep(.jumpgate) {
  pointer-events: none;
}

:deep(.jumpgate.hidden) {
  stroke-dasharray: 3,3;
}
</style>
