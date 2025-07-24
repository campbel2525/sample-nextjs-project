import { PrismaClient } from '@prisma/client'
import { execSync } from 'child_process'
import * as path from 'path'

// Lambda環境用のPrismaクライアント設定
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL
    }
  }
})

async function runMigration() {
  try {
    console.log('🚀 Starting database migration...')
    console.log('📍 Current working directory:', process.cwd())
    console.log('🔗 Database URL configured:', !!process.env.DATABASE_URL)

    // Prismaスキーマのパスを設定
    const schemaPath = path.join(process.cwd(), 'packages/db/prisma/schema.prisma')
    console.log('📄 Schema path:', schemaPath)

    // マイグレーションを実行
    console.log('⚡ Running prisma migrate deploy...')
    execSync('npx prisma migrate deploy --schema=./packages/db/prisma/schema.prisma', {
      stdio: 'inherit',
      env: {
        ...process.env,
        DATABASE_URL: process.env.DATABASE_URL
      }
    })

    console.log('✅ Database migration completed successfully')

    // 接続をテスト
    console.log('🔍 Testing database connection...')
    await prisma.$connect()
    console.log('✅ Database connection test successful')

    // 簡単なクエリでテスト
    const result = await prisma.$queryRaw`SELECT 1 as test`
    console.log('✅ Database query test successful:', result)

  } catch (error) {
    console.error('❌ Migration failed:', error)
    if (error instanceof Error) {
      console.error('Error message:', error.message)
      console.error('Error stack:', error.stack)
    }
    throw error
  } finally {
    await prisma.$disconnect()
  }
}

// Lambda handler
export const handler = async (event: any, context: any) => {
  console.log('🔧 Lambda handler started')
  console.log('📋 Event:', JSON.stringify(event, null, 2))
  console.log('📋 Context:', JSON.stringify(context, null, 2))

  try {
    await runMigration()

    const response = {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Migration completed successfully',
        timestamp: new Date().toISOString(),
        requestId: context.awsRequestId
      })
    }

    console.log('✅ Lambda handler completed successfully')
    return response

  } catch (error) {
    console.error('❌ Lambda handler error:', error)

    const response = {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Migration failed',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        requestId: context.awsRequestId
      })
    }

    return response
  }
}

// CLI実行用
if (require.main === module) {
  console.log('🖥️  Running migration script in CLI mode')
  runMigration()
    .then(() => {
      console.log('✅ Migration script completed successfully')
      process.exit(0)
    })
    .catch((error) => {
      console.error('❌ Migration script failed:', error)
      process.exit(1)
    })
}
