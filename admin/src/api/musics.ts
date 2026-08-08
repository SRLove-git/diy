import http from './http'

/** 曲库条目 */
export interface Music {
  id: number
  title: string
  artist: string
  cover: string
  musicUrl: string
  duration: number
  createdAt: string
}

/** 曲库管理 REST API（对应服务端 admin/musics 模块） */
export const musicApi = {
  /** 曲库列表（歌名/歌手模糊搜索，分页） */
  list(params?: { keyword?: string; page?: number; pageSize?: number }) {
    return http.get<[Music[], number]>('/admin/musics', { params })
  },

  /** 上传音频（+封面）并新建曲目 */
  upload(form: FormData) {
    return http.post<Music>('/admin/musics/upload', form, {
      timeout: 180000,
    })
  },

  /** 替换已有曲目的音频/封面文件 */
  replaceFiles(id: number, form: FormData) {
    return http.post<Music>(`/admin/musics/${id}/files`, form, {
      timeout: 180000,
    })
  },

  /** 更新曲目元数据 */
  update(
    id: number,
    data: Partial<
      Pick<Music, 'title' | 'artist' | 'cover' | 'musicUrl' | 'duration'>
    >,
  ) {
    return http.patch<Music>(`/admin/musics/${id}`, data)
  },

  /** 删除曲目 */
  remove(id: number) {
    return http.delete<{ deleted: boolean }>(`/admin/musics/${id}`)
  },
}
