import { reactive } from 'vue'

export type AdminLang = 'zh' | 'en'

const KEY = 'admin_lang'

/** 管理后台语言状态（持久化到 localStorage），供全局模板与脚本共享 */
export const i18n = reactive({
  lang: (localStorage.getItem(KEY) as AdminLang) || 'zh',
  setLang(lang: AdminLang) {
    this.lang = lang
    localStorage.setItem(KEY, lang)
  },
  toggle() {
    this.setLang(this.lang === 'zh' ? 'en' : 'zh')
  },
})

type TParams = Record<string, string | number>

/**
 * 双语文案：第一个参数为中文，第二个为英文，按当前语言返回；
 * 可选 params 用 {name} 占位符做插值。
 */
export function t(zh: string, en: string, params?: TParams): string {
  let s = i18n.lang === 'en' ? en : zh
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      s = s.split(`{${key}}`).join(String(value))
    }
  }
  return s
}

declare module '@vue/runtime-core' {
  interface ComponentCustomProperties {
    $t: typeof t
  }
}
