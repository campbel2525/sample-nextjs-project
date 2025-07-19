import { NextAuthOptions } from 'next-auth'
import CredentialsProvider from 'next-auth/providers/credentials'
import { prisma } from '@my-monorepo/db/client'
import { createHash } from 'crypto'
import { NEXT_AUTH_CONFIG, APP_PAGES } from '@/config/settings'

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: 'credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null
        }

        try {
          // ユーザーを検索
          const user = await prisma.user.findUnique({
            where: {
              email: credentials.email,
            },
          })

          if (!user) {
            return null
          }

          // 設定されたハッシュ方式でパスワードをハッシュ化して比較
          const hashedPassword = createHash(NEXT_AUTH_CONFIG.passwordHash)
            .update(credentials.password)
            .digest('hex')

          if (user.password !== hashedPassword) {
            return null
          }

          // 認証成功時にユーザー情報を返す
          return {
            id: user.id.toString(),
            email: user.email,
            name: user.name,
          }
        } catch {
          return null
        }
      },
    }),
  ],
  session: {
    strategy: 'jwt',
    maxAge: NEXT_AUTH_CONFIG.session.maxAge,
  },
  jwt: {
    maxAge: NEXT_AUTH_CONFIG.session.maxAge,
  },
  pages: {
    signIn: APP_PAGES.auth.login,
  },
  cookies: {
    sessionToken: {
      name: NEXT_AUTH_CONFIG.cookies.sessionToken,
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: process.env.NODE_ENV === 'production',
      },
    },
    callbackUrl: {
      name: NEXT_AUTH_CONFIG.cookies.callbackUrl,
      options: {
        sameSite: 'lax',
        path: '/',
        secure: process.env.NODE_ENV === 'production',
      },
    },
    csrfToken: {
      name: NEXT_AUTH_CONFIG.cookies.csrfToken,
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: process.env.NODE_ENV === 'production',
      },
    },
  },
  callbacks: {
    async jwt({ token, user, trigger, session }) {
      // 初回ログイン時
      if (user) {
        token.id = user.id
        token.name = user.name
        token.email = user.email
      }

      // セッション更新時 (例: プロフィール更新後)
      if (trigger === 'update' && session) {
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
        token.name = session.user.name
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
        token.email = session.user.email
      }

      // DBから最新のユーザー情報を取得してトークンを更新
      if (token.id) {
        const dbUser = await prisma.user.findUnique({
          where: { id: parseInt(token.id) },
        })
        if (dbUser) {
          token.name = dbUser.name
          token.email = dbUser.email
        }
      }

      return token
    },
    session({ session, token }) {
      if (session.user && token.id) {
        session.user.id = token.id
      }
      if (session.user && token.name) {
        session.user.name = token.name
      }
      if (session.user && token.email) {
        session.user.email = token.email
      }
      return session
    },
  },
}
