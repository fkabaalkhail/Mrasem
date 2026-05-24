import { createClient } from "@supabase/supabase-js";
import { notFound } from "next/navigation";
import { InviteCard } from "./InviteCard";

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export default async function InvitePage({ params }: { params: { token: string } }) {
  const { data: invite } = await supabase
    .from("invitations")
    .select("*")
    .eq("token", params.token)
    .single();

  if (!invite) return notFound();

  const expired = invite.expires_at && new Date(invite.expires_at) < new Date();

  return (
    <div className="flex min-h-screen items-center justify-center bg-[#f5f0eb] px-4 py-8">
      <InviteCard invite={invite} expired={!!expired} />
    </div>
  );
}
