import postgres from 'postgres'

if (!process.env.DATABASE_URL) throw new Error('Missing DATABASE_URL')

const sql = postgres(process.env.DATABASE_URL, {
  max: 3,
  idle_timeout: 20,
  connect_timeout: 10,
  ssl: 'require',
})

export default sql
