import { prisma } from '@my-monorepo/db/client'
import { NEXT_AUTH_CONFIG } from '@/config/settings'

// prisma.user の型を取得
type UserDelegate = typeof prisma.user

/**
 * 設定に応じて Prisma のモデルデリゲートを返すヘルパー関数
 * @returns Prisma のモデルデリゲート
 */
export function getUserDelegate(): UserDelegate {
  if (NEXT_AUTH_CONFIG.userModel === 'user') {
    return prisma.user
  }
  // 他のモデルに対応する場合はここに追加
  // else if (NEXT_AUTH_CONFIG.userModel === 'admin') {
  //   return prisma.admin;
  // }
  throw new Error(`Unsupported user model: ${String(NEXT_AUTH_CONFIG.userModel)}`)
}
