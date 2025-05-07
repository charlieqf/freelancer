<template>
  <div class="game-saves-page">
    <div class="page-header">
      <h1>游戏存档管理</h1>
      <p class="page-description">在这里你可以管理你的游戏存档，创建新的游戏，或者加载已有存档</p>
    </div>
    
    <game-save-list />
    
    <div class="back-to-menu">
      <button class="back-btn" @click="goBack">返回</button>
    </div>
  </div>
</template>

<script>
import GameSaveList from '@/components/game-saves/GameSaveList.vue';

export default {
  name: 'GameSaves',
  components: {
    GameSaveList
  },
  methods: {
    goBack() {
      if (this.$store.getters['gameSaves/isGameSaveLoaded']) {
        this.$router.push('/dashboard');
      } else {
        // 如果没有加载游戏，则返回主菜单
        this.$router.push('/');
      }
    }
  }
};
</script>

<style scoped>
.game-saves-page {
  padding: 32px;
  max-width: 800px;
  margin: 0 auto;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.page-header {
  text-align: center;
  margin-bottom: 32px;
}

h1 {
  color: #e6edf3;
  margin-bottom: 8px;
}

.page-description {
  color: #8b949e;
  margin: 0;
}

.back-to-menu {
  margin-top: auto;
  padding-top: 32px;
  display: flex;
  justify-content: center;
}

.back-btn {
  background-color: transparent;
  border: 1px solid #30363d;
  border-radius: 6px;
  padding: 8px 16px;
  color: #c9d1d9;
  cursor: pointer;
  transition: all 0.2s ease;
}

.back-btn:hover {
  background-color: #21262d;
}
</style>
