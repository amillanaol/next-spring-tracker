export type TaskStatus = 'PENDING' | 'IN_PROGRESS' | 'DONE';

export interface User {
  id: number;
  name: string;
  email: string;
}

export interface Task {
  id: number;
  title: string;
  description: string;
  status: TaskStatus;
  userId: number;
  createdAt: string;
}

export interface TaskFormData {
  title: string;
  description?: string;
  status?: TaskStatus;
}

export interface AuthResponse {
  token: string;
  type: string;
  id: number;
  name: string;
  email: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
}
