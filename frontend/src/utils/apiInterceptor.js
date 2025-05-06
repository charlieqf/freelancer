/**
 * API请求拦截器
 * 用于自动添加认证令牌和处理令牌刷新
 */
import authService from '../services/authService';

/**
 * 为API请求添加认证头
 * @param {Request} request - fetch API请求对象
 * @returns {Request} 带有认证头的请求
 */
export const addAuthHeader = (request) => {
  const user = authService.getCurrentUser();
  const headers = new Headers(request.headers);
  
  if (user && user.access_token) {
    headers.set('Authorization', `Bearer ${user.access_token}`);
  }
  
  return new Request(request, {
    headers
  });
};

/**
 * 初始化API拦截器
 * 可以在应用程序入口处调用此函数
 */
export const setupApiInterceptors = () => {
  // 保存原始的fetch函数
  const originalFetch = window.fetch;
  
  // 重写fetch以添加拦截器功能
  window.fetch = async (...args) => {
    let [resource, config] = args;
    
    // 为请求添加认证头
    if (config) {
      resource = addAuthHeader(new Request(resource, config));
    } else {
      resource = addAuthHeader(new Request(resource));
    }
    
    try {
      // 执行原始fetch
      const response = await originalFetch(resource);
      
      // 处理401错误 - 令牌过期
      if (response.status === 401) {
        const user = authService.getCurrentUser();
        
        // 尝试刷新令牌
        if (user && user.refresh_token) {
          try {
            // 获取新的访问令牌
            const refreshData = await authService.refreshToken();
            
            if (refreshData && refreshData.access_token) {
              // 使用新的访问令牌重试请求
              const newResource = addAuthHeader(resource);
              return originalFetch(newResource);
            }
          } catch (refreshError) {
            // 刷新令牌失败，需要重新登录
            console.error('刷新令牌失败:', refreshError);
            authService.logout();
            window.location.href = '/login';
            throw new Error('会话已过期，请重新登录');
          }
        }
      }
      
      return response;
    } catch (error) {
      console.error('API请求错误:', error);
      throw error;
    }
  };
};

/**
 * API响应处理函数
 * 用于标准化API响应处理
 * @param {Response} response - fetch API响应对象
 * @returns {Promise<Object>} 解析后的响应数据
 * @throws {Error} 如果响应不成功则抛出错误
 */
export const handleApiResponse = async (response) => {
  const data = await response.json();
  
  if (!response.ok) {
    const error = data.error || response.statusText;
    throw new Error(error);
  }
  
  return data;
};
