<template>
  <div class="game-save-card" :class="{ 'active': isActive }">
    <div class="save-info">
      <h3 class="save-name">{{ gameSave.save_name }}</h3>
      <div class="save-meta">
        <span class="last-played">上次游玩: {{ formatDate(gameSave.last_played_at) }}</span>
        <span class="playtime">游戏版本: {{ gameSave.game_version }}</span>
        <span class="created-at">创建于: {{ formatDate(gameSave.created_at) }}</span>
      </div>
    </div>
    <div class="save-actions">
      <button 
        class="btn load-btn" 
        @click="loadSave" 
        :disabled="loading"
      >
        <span v-if="loading">加载中...</span>
        <span v-else>{{ isActive ? '继续游戏' : '加载游戏' }}</span>
      </button>
      <button class="btn edit-btn" @click="editSave">
        <i class="fas fa-edit"></i>
      </button>
      <button class="btn delete-btn" @click="confirmDelete">
        <i class="fas fa-trash"></i>
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GameSaveCard',
  props: {
    gameSave: {
      type: Object,
      required: true
    },
    isActive: {
      type: Boolean,
      default: false
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    formatDate(dateString) {
      if (!dateString) return '未知';
      
      const date = new Date(dateString);
      return date.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    loadSave() {
      this.$emit('load', this.gameSave.game_id);
    },
    editSave() {
      this.$emit('edit', this.gameSave);
    },
    confirmDelete() {
      if (confirm(`确定要删除存档 "${this.gameSave.save_name}" 吗？此操作不可撤销。`)) {
        this.$emit('delete', this.gameSave.game_id);
      }
    }
  }
}
</script>

<style scoped>
.game-save-card {
  background-color: rgba(0, 0, 0, 0.7);
  border: 1px solid #30363d;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: all 0.3s ease;
}

.game-save-card.active {
  border-color: #58a6ff;
  box-shadow: 0 0 10px rgba(88, 166, 255, 0.3);
}

.save-info {
  flex: 1;
}

.save-name {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #c9d1d9;
}

.save-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  font-size: 14px;
  color: #8b949e;
}

.save-actions {
  display: flex;
  gap: 8px;
}

.btn {
  background-color: transparent;
  border: 1px solid #30363d;
  border-radius: 6px;
  padding: 8px 16px;
  color: #c9d1d9;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn:hover {
  background-color: #21262d;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.load-btn {
  background-color: #238636;
}

.load-btn:hover {
  background-color: #2ea043;
}

.edit-btn, .delete-btn {
  padding: 8px;
}

.delete-btn:hover {
  background-color: #da3633;
  border-color: #f85149;
}
</style>
