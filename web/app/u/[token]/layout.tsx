import { notFound } from 'next/navigation'
import Link from 'next/link'
import { resolveToken } from '@/lib/auth'

export default async function UserLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: Promise<{ token: string }>
}) {
  const { token } = await params
  const user = await resolveToken(token)
  if (!user) notFound()

  return (
    <div className="min-h-screen bg-zinc-950">
      <header className="sticky top-0 z-10 border-b border-zinc-800 bg-zinc-950/90 backdrop-blur">
        <div className="mx-auto max-w-2xl px-4 py-3 flex items-center justify-between gap-4">
          <span className="font-bold tracking-tight text-white">NightClaw</span>

          <nav className="flex gap-1">
            <NavLink href={`/u/${token}/today`}>Today</NavLink>
            <NavLink href={`/u/${token}/week`}>Week</NavLink>
            <NavLink href={`/u/${token}/weekly`}>Weekly Update</NavLink>
          </nav>

          <div className="hidden sm:block text-right shrink-0">
            <p className="text-sm font-medium text-white leading-none">{user.name}</p>
            <p className="text-xs text-zinc-500 mt-0.5 capitalize">
              {user.role.replace(/_/g, ' ')}
            </p>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-2xl px-4 py-6">{children}</main>
    </div>
  )
}

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="rounded-md px-3 py-1.5 text-sm font-medium text-zinc-400 transition hover:bg-zinc-800 hover:text-white"
    >
      {children}
    </Link>
  )
}
