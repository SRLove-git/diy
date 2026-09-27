import { http } from './http';
import type {
  Appointment,
  AuthResult,
  Captcha,
  Comment,
  Paged,
  Post,
  SafeUser,
  Store,
  TableAvailability,
} from './types';

export const authApi = {
  captcha: () => http.get<Captcha>('/captcha'),
  login: (payload: {
    account: string;
    password: string;
    captchaId?: string;
    captchaText?: string;
  }) => http.post<AuthResult>('/auth/login', payload),
  register: (payload: {
    username: string;
    email: string;
    password: string;
    captchaId?: string;
    captchaText?: string;
    deviceId?: string;
  }) => http.post<AuthResult>('/auth/register', payload),
  me: () => http.get<SafeUser>('/auth/me'),
};

export const storesApi = {
  list: () => http.get<Store[]>('/stores'),
  detail: (id: number) => http.get<Store>(`/stores/${id}`),
};

export const appointmentsApi = {
  create: (payload: Record<string, unknown>) =>
    http.post<Appointment>('/appointments', payload),
  myList: (page = 1, pageSize = 50) =>
    http.get<Paged<Appointment>>(
      `/appointments?page=${page}&pageSize=${pageSize}`,
    ),
  availability: (storeId: number, date: string) =>
    http.get<TableAvailability[]>(
      `/appointments/availability?storeId=${storeId}&date=${date}`,
    ),
  findByCode: (code: string) =>
    http.get<Appointment>(`/appointments/code/${code}`),
  detail: (id: number) => http.get<Appointment>(`/appointments/${id}`),
  cancel: (id: number) => http.post<Appointment>(`/appointments/${id}/cancel`),
  checkIn: (code: string) =>
    http.post<Appointment>('/appointments/checkin', { code }),
  clockIn: (id: number) => http.post<Appointment>(`/appointments/${id}/clockin`),
  clockOut: (id: number) =>
    http.post<Appointment>(`/appointments/${id}/clockout`),
};

export const postsApi = {
  latest: (page = 1) => http.get<[Post[], number]>(`/posts?page=${page}`),
  hot: (page = 1) => http.get<[Post[], number]>(`/posts/hot?page=${page}`),
  create: (payload: { content: string; title?: string }) =>
    http.post<Post>('/posts', payload),
  like: (id: number) => http.post<{ liked: boolean }>(`/posts/${id}/like`),
  collect: (id: number) =>
    http.post<{ collected: boolean }>(`/posts/${id}/collect`),
  comments: (id: number, page = 1) =>
    http.get<[Comment[], number]>(`/posts/${id}/comments?page=${page}`),
  addComment: (id: number, content: string) =>
    http.post<Comment>(`/posts/${id}/comments`, { content }),
};
