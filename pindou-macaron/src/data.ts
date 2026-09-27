export type SeatStatus = 'idle' | 'reserved' | 'using' | 'abnormal';

export const brand = {
  name: '拼豆系统',
  version: '0.4.1',
  city: '北京',
  store: '默认门店',
};

export const h5Tabs = [
  { key: 'home', label: '首页', icon: 'home' },
  { key: 'social', label: '社交服务', icon: 'social' },
  { key: 'mine', label: '我的', icon: 'mine' },
] as const;

export const pcNav = [
  { key: 'home', label: '首页' },
  { key: 'bead', label: '智能拼豆' },
  { key: 'reservation', label: '预约订座' },
  { key: 'social', label: '社交作品' },
  { key: 'account', label: '我的' },
] as const;

export const serviceGrid = [
  { key: 'bead', icon: 'bead', label: '智能拼豆', route: '/h5/bead' },
  { key: 'reservation', icon: 'clock', label: '预约订座', route: '/h5/reservation' },
  { key: 'verify', icon: 'check', label: '一键核销', route: '/h5/verify' },
  { key: 'seat', icon: 'seat', label: '座位管理', route: '/h5/seat' },
] as const;

export const seatMeta: Record<SeatStatus, { label: string; tone: string }> = {
  idle: { label: '空闲', tone: 'mint' },
  reserved: { label: '已预约', tone: 'butter' },
  using: { label: '使用中', tone: 'blush' },
  abnormal: { label: '异常', tone: 'berry' },
};

export const materialPalette = [
  { code: '01', name: '蓝', color: '#8FB7E2' },
  { code: '02', name: '青', color: '#8FD0C6' },
  { code: '03', name: '橙', color: '#F2B98A' },
  { code: '04', name: '紫', color: '#B9A8DC' },
  { code: '05', name: '黑', color: '#6E5B52' },
];

export const beadPlans = [
  { name: '0.4.1 UI验证方案', size: '48.00cm x 48.00cm', beads: '2200 颗豆子', avatar: '0' },
  { name: '智能拼豆方案3', size: '52.00cm x 52.00cm', beads: '4000 颗豆子', avatar: '智' },
  { name: '智能拼豆方案2', size: '50.00cm x 50.00cm', beads: '3875 颗豆子', avatar: '智' },
  { name: '柯基拼豆方案', size: '46.00cm x 46.00cm', beads: '3600 颗豆子', avatar: '柯' },
];

// A gentle 16x16 macaron bead pattern (heart-ish shape).
export const pixelBoard: string[] = (() => {
  const heart = [
    '0011000000110000',
    '0111100001111000',
    '1111110011111100',
    '1111111111111100',
    '0111111111111000',
    '0011111111110000',
    '0001111111100000',
    '0000011111000000',
    '0000001110000000',
    '0000000000000000',
    '0000000000000000',
    '0000000000000000',
    '0000000000000000',
    '0000000000000000',
    '0000000000000000',
    '0000000000000000',
  ];
  const map: Record<string, string> = {
    '0': 'transparent',
    '1': '#F3A7B7',
    '2': '#F7C9D4',
    '3': '#F2B98A',
  };
  return heart.flatMap((row) => row.split('').map((c) => map[c] ?? 'transparent'));
})();

export const mineMenu = ['实名认证', '我的发布', '安全设置', '退出登录'];

export const reservationSteps = [
  '用户预约座位',
  '支付或抖音核销',
  '门店确认到店',
  '座位开始计时',
  '结束使用并生成订单',
];
