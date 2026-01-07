import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
});

export const getMaterials = (params) => api.get('/materials', { params });
export const createMaterial = (data) => api.post('/materials', data);
export const getMaterial = (id) => api.get(`/materials/${id}`);
export const updateMaterial = (id, data) => api.put(`/materials/${id}`, data);
export const updateMaterialStatus = (id, status) => api.patch(`/materials/${id}/status`, { status });

export const getUsers = (params) => api.get('/users', { params });
export const getUser = (id) => api.get(`/users/${id}`);
export const updateUserStatus = (id, status) => api.patch(`/users/${id}/status`, { status });

export const uploadFile = (file) => {
  const formData = new FormData();
  formData.append('file', file);
  return api.post('/common/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
};

export const getTags = (params) => api.get('/tags', { params });
export const createTag = (data) => api.post('/tags', data);
export const updateTagStatus = (id, status) => api.patch(`/tags/${id}/status`, { status });

export const getSoftware = (params) => api.get('/software', { params });
export const createSoftware = (data) => api.post('/software', data);
export const updateSoftware = (id, data) => api.put(`/software/${id}`, data);
export const updateSoftwareStatus = (id, status) => api.patch(`/software/${id}/status`, { status });

export const getFilterOptions = () => api.get('/filters/options');

export const getFeedbacks = (params) => api.get('/feedback', { params });
export const updateFeedback = (id, data) => api.put(`/feedback/${id}`, data);

export const getHelpGuides = (params) => api.get('/help-guides/admin', { params });
export const createHelpGuide = (data) => api.post('/help-guides', data);
export const updateHelpGuide = (id, data) => api.put(`/help-guides/${id}`, data);
export const deleteHelpGuide = (id) => api.delete(`/help-guides/${id}`);

export const getMarketingPopups = (params) => api.get('/marketing-popups', { params });
export const createMarketingPopup = (data) => api.post('/marketing-popups', data);
export const updateMarketingPopup = (id, data) => api.put(`/marketing-popups/${id}`, data);
export const deleteMarketingPopup = (id) => api.delete(`/marketing-popups/${id}`);

export default api;
