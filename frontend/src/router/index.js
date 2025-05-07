import { createRouter, createWebHistory } from 'vue-router'
import store from '../store'

// 导入视图组件
import Login from '../views/auth/Login.vue'
import Register from '../views/auth/Register.vue'
import Dashboard from '../views/Dashboard.vue'
import Profile from '../views/auth/Profile.vue'
import ChangePassword from '../views/auth/ChangePassword.vue'
import GameSaves from '../views/game/GameSaves.vue'
import NotFound from '../views/NotFound.vue'

// 路由配置
const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresAuth: false },
    beforeEnter: (to, from, next) => {
      // 已登录用户重定向到主页
      if (store.getters['auth/isAuthenticated']) {
        next({ name: 'Dashboard' })
      } else {
        next()
      }
    }
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
    meta: { requiresAuth: false },
    beforeEnter: (to, from, next) => {
      // 已登录用户重定向到主页
      if (store.getters['auth/isAuthenticated']) {
        next({ name: 'Dashboard' })
      } else {
        next()
      }
    }
  },
  {
    path: '/',
    component: () => import('../layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        redirect: { name: 'Dashboard' }
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: Dashboard,
        meta: { requiresAuth: true }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: Profile,
        meta: { requiresAuth: true }
      },
      {
        path: 'change-password',
        name: 'ChangePassword',
        component: ChangePassword,
        meta: { requiresAuth: true }
      },
      {
        path: 'galaxy-map',
        name: 'GalaxyMap',
        component: () => import('../views/GalaxyMap.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'missions',
        name: 'Missions',
        component: () => import('../views/Missions.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'trade',
        name: 'Trade',
        component: () => import('../views/Trade.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'shipyard',
        name: 'Shipyard',
        component: () => import('../views/Shipyard.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'game-saves',
        name: 'GameSaves',
        component: GameSaves,
        meta: { requiresAuth: true }
      }
    ]
  },
  // 404页面
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: NotFound
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

// 全局路由守卫
router.beforeEach((to, from, next) => {
  // 检查路由是否需要身份验证
  if (to.matched.some(record => record.meta.requiresAuth)) {
    // 需要身份验证，检查是否已登录
    if (!store.getters['auth/isAuthenticated']) {
      // 未登录，重定向到登录页
      next({ name: 'Login' })
    } else {
      // 已登录，允许访问
      next()
    }
  } else {
    // 不需要身份验证，直接访问
    next()
  }
})

export default router
