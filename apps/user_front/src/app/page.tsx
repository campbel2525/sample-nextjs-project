'use client'

import { useSession, signOut } from 'next-auth/react'
import Link from 'next/link'
import { APP_PAGES } from '@/config/settings'

export default function Home() {
  const { data: session, status } = useSession()

  if (status === 'loading') {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-lg">読み込み中...</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <header className="mb-8 p-4 bg-white rounded-lg shadow">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold">
              サンプルアプリケーション
            </h1>
            <div className="flex items-center gap-4">
              {session ? (
                <>
                  <span className="">
                    こんにちは、{session.user.name || session.user.email}さん
                  </span>
                  <button
                    onClick={() => signOut()}
                    className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition-colors"
                  >
                    ログアウト
                  </button>
                </>
              ) : (
                <Link
                  href="/auth/login"
                  className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                >
                  ログイン
                </Link>
              )}
            </div>
          </div>
        </header>

        <main className="bg-white rounded-lg shadow p-6">
          {session ? (
            <div>
              <h2 className="text-xl font-semibold mb-4">
                ダッシュボード
              </h2>
              <div className="space-y-4">
                <div className="pt-4 border-t border-gray-200 dark:border-gray-600">
                  <Link
                    href={APP_PAGES.auth.profile}
                    className="inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    マイページ
                  </Link>
                </div>
              </div>
            </div>
          ) : (
            <div>
              <h2 className="text-xl font-semibold mb-4">
                ようこそ
              </h2>
              <p className="text-gray-600 dark:text-gray-300 mb-4">
                このアプリケーションを使用するにはログインが必要です。
              </p>
              <Link
                href="/auth/login"
                className="inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                ログインページへ
              </Link>
            </div>
          )}
        </main>
      </div>
    </div>
  )
}
