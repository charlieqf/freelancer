import React, { useState } from 'react';
import authService from '../../services/authService';

/**
 * 修改密码组件
 * 允许用户修改自己的密码
 */
const ChangePassword = () => {
  // 表单状态
  const [formData, setFormData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  });
  
  // 加载和状态提示
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  
  /**
   * 处理输入变化
   */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
    
    // 清除错误和成功信息
    setError('');
    setSuccess('');
  };
  
  /**
   * 验证表单
   */
  const validateForm = () => {
    // 验证当前密码
    if (!formData.currentPassword) {
      setError('请输入当前密码');
      return false;
    }
    
    // 验证新密码
    if (!formData.newPassword) {
      setError('请输入新密码');
      return false;
    } else if (formData.newPassword.length < 8) {
      setError('新密码至少需要8个字符');
      return false;
    } else if (!/[A-Z]/.test(formData.newPassword)) {
      setError('新密码需要包含至少一个大写字母');
      return false;
    } else if (!/[a-z]/.test(formData.newPassword)) {
      setError('新密码需要包含至少一个小写字母');
      return false;
    } else if (!/[0-9]/.test(formData.newPassword)) {
      setError('新密码需要包含至少一个数字');
      return false;
    }
    
    // 验证确认密码
    if (formData.newPassword !== formData.confirmPassword) {
      setError('两次输入的新密码不匹配');
      return false;
    }
    
    // 验证新旧密码不同
    if (formData.currentPassword === formData.newPassword) {
      setError('新密码不能与当前密码相同');
      return false;
    }
    
    return true;
  };
  
  /**
   * 处理表单提交
   */
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // 验证表单
    if (!validateForm()) {
      return;
    }
    
    setIsLoading(true);
    setError('');
    setSuccess('');
    
    try {
      // 调用修改密码API
      await authService.changePassword(
        formData.currentPassword,
        formData.newPassword
      );
      
      // 清空表单
      setFormData({
        currentPassword: '',
        newPassword: '',
        confirmPassword: ''
      });
      
      // 显示成功消息
      setSuccess('密码已成功修改');
    } catch (error) {
      setError(error.message || '修改密码失败，请稍后再试');
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <div className="change-password-container">
      <h2>修改密码</h2>
      
      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}
      
      <form onSubmit={handleSubmit} className="change-password-form">
        <div className="form-group">
          <label htmlFor="currentPassword">当前密码</label>
          <input
            type="password"
            id="currentPassword"
            name="currentPassword"
            value={formData.currentPassword}
            onChange={handleChange}
            disabled={isLoading}
            placeholder="输入当前密码"
          />
        </div>
        
        <div className="form-group">
          <label htmlFor="newPassword">新密码</label>
          <input
            type="password"
            id="newPassword"
            name="newPassword"
            value={formData.newPassword}
            onChange={handleChange}
            disabled={isLoading}
            placeholder="输入新密码"
          />
          <small className="password-hint">密码需要至少8个字符，包含大小写字母和数字</small>
        </div>
        
        <div className="form-group">
          <label htmlFor="confirmPassword">确认新密码</label>
          <input
            type="password"
            id="confirmPassword"
            name="confirmPassword"
            value={formData.confirmPassword}
            onChange={handleChange}
            disabled={isLoading}
            placeholder="再次输入新密码"
          />
        </div>
        
        <button 
          type="submit" 
          className="change-password-button"
          disabled={isLoading}
        >
          {isLoading ? '处理中...' : '修改密码'}
        </button>
      </form>
    </div>
  );
};

export default ChangePassword;
