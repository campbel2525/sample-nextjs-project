import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function runMigration() {
  try {
    console.log('Starting database migration...')

    // Prismaのマイグレーションを実行
    // 注意: Lambda環境では prisma migrate deploy を使用
    const { execSync } = require('child_process')

    // マイグレーションを実行
    execSync('npx prisma migrate deploy', {
      stdio: 'inherit',
      cwd: process.cwd()
    })

    console.log('✅ Database migration completed successfully')

    // 接続をテスト
    await prisma.$connect()
    console.log('✅ Database connection test successful')

  } catch (error) {
    console.error('❌ Migration failed:', error)
    throw error
  } finally {
    await prisma.$disconnect()
  }
}

// Lambda handler
export const handler = async (event: any, context: any) => {
  try {
    await runMigration()
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Migration completed successfully',
        timestamp: new Date().toISOString()
      })
    }
  } catch (error) {
    console.error('Lambda handler error:', error)
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Migration failed',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      })
    }
  }
}

// CLI実行用
if (require.main === module) {
  runMigration()
    .then(() => {
      console.log('Migration script completed')
      process.exit(0)
    })
    .catch((error) => {
      console.error('Migration script failed:', error)
      process.exit(1)
    })
}
