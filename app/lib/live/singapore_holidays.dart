/// 新加坡公共假期（含周日补假），与服务端
/// `server/src/common/singapore-holidays.ts` 保持一致。
///
/// 数据来源：新加坡人力部（MOM）年度公告；按年维护，
/// 新一年官方公告发布后补充。
const Map<int, Set<String>> _singaporePublicHolidays = {
  2025: {
    '01-01', // 元旦
    '01-29', // 农历新年
    '01-30',
    '03-31', // 开斋节
    '04-18', // 耶稣受难日
    '05-01', // 劳动节
    '05-12', // 卫塞节
    '06-07', // 哈芝节
    '08-09', // 国庆日
    '10-20', // 屠妖节
    '12-25', // 圣诞节
  },
  2026: {
    '01-01', // 元旦
    '02-17', // 农历新年
    '02-18',
    '03-21', // 开斋节
    '04-03', // 耶稣受难日
    '05-01', // 劳动节
    '05-27', // 哈芝节
    '05-31', // 卫塞节（周日）
    '06-01', // 卫塞节补假
    '08-09', // 国庆日（周日）
    '08-10', // 国庆日补假
    '11-08', // 屠妖节（周日）
    '11-09', // 屠妖节补假
    '12-25', // 圣诞节
  },
  2027: {
    '01-01', // 元旦
    '02-06', // 农历新年
    '02-07',
    '02-08', // 农历新年补假
    '03-10', // 开斋节
    '03-26', // 耶稣受难日
    '05-01', // 劳动节
    '05-17', // 哈芝节
    '05-20', // 卫塞节
    '08-09', // 国庆日
    '10-28', // 屠妖节
    '12-25', // 圣诞节
  },
};

/// 判断日期（YYYY-MM-DD）是否为新加坡公共假期。
bool isSingaporePublicHoliday(String date) {
  final parts = date.split('-');
  if (parts.length != 3) return false;
  final year = int.tryParse(parts[0]);
  if (year == null) return false;
  final monthDay = '${parts[1]}-${parts[2]}';
  return _singaporePublicHolidays[year]?.contains(monthDay) ?? false;
}

/// 是否需要加价：周六/周日，或新加坡公共假期。
bool isSurchargeDate(String date) {
  final weekday = DateTime.tryParse(date)?.weekday ?? DateTime.monday;
  final isWeekend = weekday == DateTime.saturday || weekday == DateTime.sunday;
  return isWeekend || isSingaporePublicHoliday(date);
}
