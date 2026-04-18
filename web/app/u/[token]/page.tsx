import { redirect } from 'next/navigation'

export default async function TokenRoot({ params }: { params: Promise<{ token: string }> }) {
  const { token } = await params
  redirect(`/u/${token}/today`)
}
