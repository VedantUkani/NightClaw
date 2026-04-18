import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'NightClaw',
  description: 'Your personal shift recovery dashboard',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body suppressHydrationWarning className="bg-zinc-950 text-white min-h-screen antialiased">
        {children}
      </body>
    </html>
  )
}
