<template>
  <div class="game-save-list">
    <div class="list-header">
      <h2 class="list-title">我的游戏存档</h2>
      <button class="create-btn" @click="showCreateSaveModal = true">
        创建新存档
      </button>
    </div>
    
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>加载游戏存档中...</p>
    </div>
    
    <div v-else-if="!gameSaves || gameSaves.length === 0" class="empty-state">
      <p>你还没有创建任何游戏存档</p>
      <button class="create-btn" @click="showCreateSaveModal = true">
        创建第一个存档
      </button>
    </div>
    
    <div v-else class="saves-container">
      <game-save-card
        v-for="save in gameSaves"
        :key="save.game_id"
        :gameSave="save"
        :isActive="currentGameId === save.game_id"
        :loading="loadingGameId === save.game_id"
        @load="handleLoadGameSave"
        @edit="editGameSave"
        @delete="deleteGameSave"
      />
    </div>
    
    <!-- 创建存档对话框 -->
    <div v-if="showCreateSaveModal" class="modal-backdrop">
      <div class="modal">
        <h3>创建新游戏存档</h3>
        <div class="modal-content">
          <div class="form-group">
            <label for="saveName">存档名称</label>
            <input 
              type="text" 
              id="saveName" 
              v-model="newSaveName" 
              placeholder="输入存档名称"
              @keyup.enter="createNewSave"
            />
          </div>
        </div>
        <div class="modal-actions">
          <button class="cancel-btn" @click="cancelCreateSave">取消</button>
          <button 
            class="create-btn" 
            @click="createNewSave" 
            :disabled="!newSaveName.trim() || creatingNewSave"
          >
            {{ creatingNewSave ? '创建中...' : '创建存档' }}
          </button>
        </div>
      </div>
    </div>
    
    <!-- 编辑存档对话框 -->
    <div v-if="showEditModal" class="modal-backdrop">
      <div class="modal">
        <h3>编辑游戏存档</h3>
        <div class="modal-content">
          <div class="form-group">
            <label for="editSaveName">存档名称</label>
            <input 
              type="text" 
              id="editSaveName" 
              v-model="editingSaveName" 
              placeholder="输入新的存档名称"
              @keyup.enter="updateSaveName"
            />
          </div>
        </div>
        <div class="modal-actions">
          <button class="cancel-btn" @click="cancelEdit">取消</button>
          <button 
            class="save-btn" 
            @click="updateSaveName" 
            :disabled="!editingSaveName.trim() || updatingSave"
          >
            {{ updatingSave ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import GameSaveCard from './GameSaveCard.vue';

export default {
  name: 'GameSaveList',
  components: {
    GameSaveCard
  },
  data() {
    return {
      showCreateSaveModal: false,
      showEditModal: false,
      newSaveName: '',
      editingSave: null,
      editingSaveName: '',
      loadingGameId: null,
      creatingNewSave: false,
      updatingSave: false,
      deletingSaveId: null
    };
  },
  computed: {
    ...mapState('gameSaves', {
      gameSaves: state => state.gameSaves,
      loading: state => state.isLoading
    }),
    ...mapGetters('gameSaves', ['currentGameSave']),
    
    currentGameId() {
      return this.currentGameSave ? this.currentGameSave.game_id : null;
    }
  },
  methods: {
    ...mapActions('gameSaves', [
      'fetchGameSaves',
      'createGameSave',
      'loadGameSave',
      'updateGameSave',
      'deleteGameSave'
    ]),
    
    async handleLoadGameSave(gameId) {
      this.loadingGameId = gameId;
      try {
        await this.loadGameSave(gameId);
        this.$router.push('/dashboard');
      } catch (error) {
        console.error('加载存档失败:', error);
      } finally {
        this.loadingGameId = null;
      }
    },
    
    async createNewSave() {
      if (!this.newSaveName.trim() || this.creatingNewSave) return;
      
      this.creatingNewSave = true;
      try {
        await this.createGameSave(this.newSaveName.trim());
        this.showCreateSaveModal = false;
        this.newSaveName = '';
      } catch (error) {
        console.error('创建存档失败:', error);
      } finally {
        this.creatingNewSave = false;
      }
    },
    
    editGameSave(save) {
      this.editingSave = save;
      this.editingSaveName = save.save_name;
      this.showEditModal = true;
    },
    
    async updateSaveName() {
      if (!this.editingSaveName.trim() || this.updatingSave) return;
      
      this.updatingSave = true;
      try {
        await this.updateGameSave({
          gameId: this.editingSave.game_id,
          updateData: { save_name: this.editingSaveName.trim() }
        });
        this.showEditModal = false;
      } catch (error) {
        console.error('更新存档失败:', error);
      } finally {
        this.updatingSave = false;
        this.editingSave = null;
      }
    },
    
    async deleteGameSave(gameId) {
      this.deletingSaveId = gameId;
      try {
        await this.deleteGameSave(gameId);
      } catch (error) {
        console.error('删除存档失败:', error);
      } finally {
        this.deletingSaveId = null;
      }
    },
    
    cancelCreateSave() {
      this.showCreateSaveModal = false;
      this.newSaveName = '';
    },
    
    cancelEdit() {
      this.showEditModal = false;
      this.editingSave = null;
      this.editingSaveName = '';
    }
  },
  created() {
    this.fetchGameSaves();
  }
};
</script>

<style scoped>
.game-save-list {
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.list-title {
  margin: 0;
  color: #c9d1d9;
  font-size: 24px;
}

.create-btn {
  background-color: #238636;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  color: #ffffff;
  cursor: pointer;
  transition: all 0.2s ease;
}

.create-btn:hover {
  background-color: #2ea043;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: rgba(0, 0, 0, 0.7);
  border: 1px solid #30363d;
  border-radius: 8px;
  padding: 48px;
  text-align: center;
}

.empty-state p {
  margin-bottom: 16px;
  color: #8b949e;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px;
}

.loading-spinner {
  border: 4px solid rgba(255, 255, 255, 0.1);
  border-left: 4px solid #58a6ff;
  border-radius: 50%;
  width: 30px;
  height: 30px;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.saves-container {
  display: flex;
  flex-direction: column;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal {
  background-color: #0d1117;
  border: 1px solid #30363d;
  border-radius: 8px;
  padding: 24px;
  width: 90%;
  max-width: 500px;
}

.modal h3 {
  margin-top: 0;
  margin-bottom: 16px;
  color: #c9d1d9;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #c9d1d9;
}

.form-group input {
  width: 100%;
  padding: 8px;
  background-color: #0d1117;
  border: 1px solid #30363d;
  border-radius: 6px;
  color: #c9d1d9;
  font-size: 14px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.cancel-btn {
  background-color: transparent;
  border: 1px solid #30363d;
  border-radius: 6px;
  padding: 8px 16px;
  color: #c9d1d9;
  cursor: pointer;
}

.save-btn {
  background-color: #238636;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  color: #ffffff;
  cursor: pointer;
}

.save-btn:hover {
  background-color: #2ea043;
}

.save-btn:disabled, .create-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
