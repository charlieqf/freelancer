import React, { useState, useEffect } from 'react';
import authService from '../../services/authService';

/**
 * 用户个人资料组件
 * 显示和编辑用户个人资料信息
 */
const Profile = () => {
  // 用户资料状态
  const [profile, setProfile] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  
  // 表单状态
  const [formData, setFormData] = useState({
    email: '',
    avatar_url: ''
  });
  
  // 加载和错误状态
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  
  // 加载个人资料
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const profileData = await authService.getProfile();
        setProfile(profileData);
        setFormData({
          email: profileData.email || '',
          avatar_url: profileData.avatar_url || ''
        });
      } catch (error) {
        setError('无法加载个人资料');
        console.error('加载个人资料错误:', error);
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchProfile();
  }, []);
  
  /**
   * 处理输入变化
   */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };
  
  /**
   * 处理表单提交
   */
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    setIsLoading(true);
    setError('');
    setSuccessMessage('');
    
    try {
      const updatedProfile = await authService.updateProfile(formData);
      setProfile(updatedProfile);
      setIsEditing(false);
      setSuccessMessage('个人资料已成功更新');
    } catch (error) {
      setError(error.message || '更新个人资料失败');
    } finally {
      setIsLoading(false);
    }
  };
  
  /**
   * 切换到编辑模式
   */
  const startEditing = () => {
    setFormData({
      email: profile.email || '',
      avatar_url: profile.avatar_url || ''
    });
    setIsEditing(true);
    setSuccessMessage('');
  };
  
  /**
   * 取消编辑
   */
  const cancelEditing = () => {
    setIsEditing(false);
    setError('');
  };
  
  // 加载状态
  if (isLoading && !profile) {
    return (
      <div className="profile-container">
        <div className="loading">加载个人资料中...</div>
      </div>
    );
  }
  
  // 错误状态
  if (error && !profile) {
    return (
      <div className="profile-container">
        <div className="error-message">{error}</div>
        <button onClick={() => window.location.reload()}>重试</button>
      </div>
    );
  }
  
  return (
    <div className="profile-container">
      <h2>飞行员个人资料</h2>
      
      {successMessage && <div className="success-message">{successMessage}</div>}
      {error && <div className="error-message">{error}</div>}
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="profile-form">
          <div className="form-group">
            <label htmlFor="email">电子邮箱</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              disabled={isLoading}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="avatar_url">头像URL</label>
            <input
              type="text"
              id="avatar_url"
              name="avatar_url"
              value={formData.avatar_url}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="输入头像图片的URL"
            />
          </div>
          
          <div className="form-actions">
            <button 
              type="submit" 
              className="save-button"
              disabled={isLoading}
            >
              {isLoading ? '保存中...' : '保存'}
            </button>
            <button 
              type="button" 
              className="cancel-button"
              onClick={cancelEditing}
              disabled={isLoading}
            >
              取消
            </button>
          </div>
        </form>
      ) : (
        <div className="profile-details">
          <div className="profile-header">
            <div className="profile-avatar">
              {profile.avatar_url ? (
                <img src={profile.avatar_url} alt={profile.username} />
              ) : (
                <div className="avatar-placeholder">{profile.username.charAt(0).toUpperCase()}</div>
              )}
            </div>
            
            <div className="profile-info">
              <h3>{profile.username}</h3>
              <p className="faction">所属势力: {profile.faction_id}</p>
              <p className="credits">游戏币: {profile.credits}</p>
              <p className="reputation">声望值: {profile.reputation}</p>
            </div>
          </div>
          
          <div className="profile-body">
            <div className="profile-section">
              <h4>账户信息</h4>
              <p><strong>电子邮箱:</strong> {profile.email}</p>
              <p><strong>注册时间:</strong> {new Date(profile.created_at).toLocaleString()}</p>
              <p><strong>最后登录:</strong> {profile.last_login ? new Date(profile.last_login).toLocaleString() : '从未登录'}</p>
            </div>
            
            <div className="profile-section">
              <h4>游戏数据</h4>
              <p><strong>当前星系:</strong> {profile.current_system_id || '无'}</p>
            </div>
          </div>
          
          <div className="profile-actions">
            <button onClick={startEditing} className="edit-button">
              编辑个人资料
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default Profile;
