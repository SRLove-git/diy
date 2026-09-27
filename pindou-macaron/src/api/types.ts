export type AppointmentStatus =
  | 'pending'
  | 'booked'
  | 'checked_in'
  | 'in_service'
  | 'completed'
  | 'cancelled';

export interface StoreTable {
  id: number;
  name: string;
  capacity: number;
  enabled: boolean;
}

export interface TimeSlot {
  id: number;
  startTime: string;
  endTime: string;
  enabled: boolean;
}

export interface StorePackage {
  id: number;
  name: string;
  hours: number;
  price: number;
  memberPrice?: number | null;
  groupPrice?: number | null;
  enabled: boolean;
  sortOrder?: number;
}

export interface Store {
  id: number;
  name: string;
  address: string;
  lat?: number | null;
  lng?: number | null;
  rating: number;
  images: string[] | null;
  price: number;
  memberPrice?: number | null;
  groupPrice?: number | null;
  allDayPrice?: number | null;
  allDayMemberPrice?: number | null;
  allDayGroupPrice?: number | null;
  weekendSurchargePercent?: number;
  businessHours: string;
  phone: string;
  enabled: boolean;
  tables?: StoreTable[];
  slots?: TimeSlot[];
  packages?: StorePackage[];
}

export interface BookedWindow {
  startTime: string;
  endTime: string;
  status: string;
}

export interface TableAvailability {
  id: number;
  name: string;
  capacity: number;
  bookedWindows: BookedWindow[];
}

export interface AppointmentTable {
  id: number;
  name: string;
  capacity: number;
  people: number;
}

export interface Appointment {
  id: number;
  userId: number;
  type: 'store' | 'activity';
  bookingType: 'hourly' | 'package' | 'all_day';
  durationHours: number | null;
  packageId: number | null;
  packageName: string;
  storeId: number | null;
  storeName: string;
  tableId: number | null;
  tableName: string;
  tables?: AppointmentTable[];
  slotId: number | null;
  activityId: number | null;
  activitySessionId: number | null;
  activityName: string;
  date: string;
  startTime: string;
  endTime: string;
  peopleCount: number;
  code: string;
  amount: number;
  originalAmount: number;
  payStatus: 'unpaid' | 'paid';
  payMethod: string;
  status: AppointmentStatus;
  note: string;
  checkInTime: string | null;
  serviceStartTime: string | null;
  serviceEndTime: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface PostAuthor {
  nickname: string;
  avatar: string;
}

export interface PostMedia {
  type: 'image' | 'video';
  url: string;
  aspectRatio?: number;
  duration?: number;
}

export interface Post {
  id: number;
  userId: number;
  title: string;
  content: string;
  location: string;
  images: string[];
  medias: PostMedia[] | null;
  tags: string[];
  channelTag: string;
  status: 'pending' | 'approved' | 'rejected';
  likeCount: number;
  collectCount: number;
  commentCount: number;
  viewCount: number;
  shareCount: number;
  createdAt: string;
  updatedAt: string;
  author: PostAuthor;
}

export interface Comment {
  id: number;
  userId: number;
  postId: number;
  parentId: number | null;
  replyToId: number | null;
  content: string;
  likeCount: number;
  isHidden: boolean;
  createdAt: string;
  author?: PostAuthor;
}

export interface SafeUser {
  id: number;
  email: string | null;
  username: string | null;
  nickname: string;
  avatar: string;
  bio: string;
  gender: 'male' | 'female' | 'secret';
  birthday: string | null;
  location: string;
  isBanned: boolean;
  role: 'user' | 'admin';
  createdAt: string;
  updatedAt: string;
}

export interface Paged<T> {
  items: T[];
  total: number;
}

export interface Captcha {
  id: string;
  image: string;
  imageBase64: string;
  ttl: number;
}

export interface AuthResult {
  userId: number;
  accessToken: string;
  refreshToken: string;
  isNewUser?: boolean;
}
