import axios, { AxiosError } from 'axios';
import { auth } from './auth';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

export const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  (config) => {
    const token = auth.getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      auth.clear();
      if (typeof window !== 'undefined') {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export const authApi = {
  login: (email: string, password: string) =>
    api.post('/auth/login', { email, password }),

  register: (name: string, email: string, password: string) =>
    api.post('/auth/register', { name, email, password }),
};

export const tasksApi = {
  getAll: () => api.get('/tasks'),

  create: (data: { title: string; description?: string; status?: string }) =>
    api.post('/tasks', data),

  update: (id: string, data: { title: string; description?: string; status?: string }) =>
    api.put(`/tasks/${id}`, data),

  delete: (id: string) => api.delete(`/tasks/${id}`),
};
