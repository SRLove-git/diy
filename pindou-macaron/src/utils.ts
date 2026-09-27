export function formatDateTime(iso: string | Date | null | undefined): string {
  if (!iso) return '';
  const d = typeof iso === 'string' ? new Date(iso) : iso;
  if (Number.isNaN(d.getTime())) return '';
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(
    d.getHours(),
  )}:${pad(d.getMinutes())}`;
}

export function todayString(): string {
  const d = new Date();
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

export function addDays(base: string, delta: number): string {
  const d = new Date(`${base}T00:00:00`);
  d.setDate(d.getDate() + delta);
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

export type SeatStatus = 'idle' | 'reserved' | 'using' | 'abnormal';

export interface BookedWindow {
  startTime: string;
  endTime: string;
  status: string;
}

/** 将桌位可用性接口结果映射为座位网格的状态 */
export function availabilityToSeats(
  items: Array<{ name: string; bookedWindows: BookedWindow[] }>,
): Array<{ id: string; status: SeatStatus }> {
  return items.map((t) => {
    const active = t.bookedWindows.some(
      (w) => w.status === 'in_service' || w.status === 'checked_in',
    );
    const status: SeatStatus = t.bookedWindows.length
      ? active
        ? 'using'
        : 'reserved'
      : 'idle';
    return { id: t.name, status };
  });
}

export const appointmentStatusLabel: Record<string, string> = {
  pending: '待确认',
  booked: '已预约',
  checked_in: '已核销',
  in_service: '服务中',
  completed: '已完成',
  cancelled: '已取消',
};

export const appointmentStatusTone: Record<string, string> = {
  pending: 'butter',
  booked: 'blue',
  checked_in: 'lilac',
  in_service: 'mint',
  completed: 'mint',
  cancelled: 'berry',
};
