import sql from './db'
import type { ResolvedUser } from './types'

export async function resolveToken(token: string): Promise<ResolvedUser | null> {
  try {
    const rows = await sql<ResolvedUser[]>`
      SELECT id, name, role, timezone
      FROM public.users
      WHERE id = ${token}
      LIMIT 1
    `
    return rows[0] ?? null
  } catch (err) {
    console.error('[auth] resolveToken error:', err)
    return null
  }
}
