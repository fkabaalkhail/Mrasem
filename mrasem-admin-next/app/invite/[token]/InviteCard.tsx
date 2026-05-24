"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

type Invite = {
  id: string;
  token: string;
  status: string;
  place_title: string;
  subtitle: string | null;
  image_name: string | null;
  date_display: string | null;
  time_display: string | null;
  branch: string | null;
  arabic_place_title: string | null;
  arabic_date_display: string | null;
  arabic_time_display: string | null;
  arabic_branch: string | null;
  sender_phone: string;
};

export function InviteCard({ invite, expired }: { invite: Invite; expired: boolean }) {
  const [status, setStatus] = useState(invite.status);
  const [loading, setLoading] = useState(false);

  async function respond(action: "accepted" | "declined") {
    setLoading(true);
    const sb = createClient();
    const { error } = await sb
      .from("invitations")
      .update({ status: action })
      .eq("token", invite.token)
      .eq("status", "pending");
    if (!error) setStatus(action);
    setLoading(false);
  }

  const resolved = status !== "pending";
  const senderHint = invite.sender_phone.replace(/(\+\d{3})\d+(\d{3})/, "$1•••$2");

  return (
    <div className="w-full max-w-sm overflow-hidden rounded-2xl bg-white shadow-xl">
      {/* Header image area */}
      <div className="relative h-44 bg-gradient-to-br from-[#213c2e] to-[#2d5a40] flex items-center justify-center">
        <div className="text-center text-white">
          <p className="text-xs uppercase tracking-widest opacity-70">You&apos;re invited to</p>
          <h1 className="mt-1 text-2xl font-semibold">{invite.place_title}</h1>
          {invite.subtitle && <p className="mt-0.5 text-sm opacity-80">{invite.subtitle}</p>}
        </div>
      </div>

      {/* Details */}
      <div className="space-y-3 px-6 py-5">
        {invite.date_display && (
          <Row label="Date" value={invite.date_display} />
        )}
        {invite.time_display && (
          <Row label="Time" value={invite.time_display} />
        )}
        {invite.branch && (
          <Row label="Location" value={invite.branch} />
        )}
        <Row label="From" value={senderHint} />

        {/* Arabic details if present */}
        {invite.arabic_place_title && (
          <div className="border-t border-gray-100 pt-3 text-right" dir="rtl">
            <p className="font-semibold text-[#31231b]">{invite.arabic_place_title}</p>
            {invite.arabic_branch && <p className="text-sm text-gray-500">{invite.arabic_branch}</p>}
            {invite.arabic_date_display && <p className="text-sm text-gray-500">{invite.arabic_date_display} — {invite.arabic_time_display}</p>}
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="border-t border-gray-100 px-6 py-4">
        {expired ? (
          <p className="text-center text-sm text-gray-400">This invitation has expired</p>
        ) : resolved ? (
          <p className="text-center text-sm font-medium">
            {status === "accepted" ? (
              <span className="text-[#213c2e]">✓ You accepted this invitation</span>
            ) : (
              <span className="text-gray-500">You declined this invitation</span>
            )}
          </p>
        ) : (
          <div className="flex gap-3">
            <button
              onClick={() => void respond("declined")}
              disabled={loading}
              className="flex-1 rounded-xl border border-gray-200 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-50 disabled:opacity-50"
            >
              Decline
            </button>
            <button
              onClick={() => void respond("accepted")}
              disabled={loading}
              className="flex-1 rounded-xl bg-[#213c2e] py-2.5 text-sm font-medium text-white transition hover:bg-[#2d5a40] disabled:opacity-50"
            >
              Accept
            </button>
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="bg-gray-50 px-6 py-3 text-center">
        <p className="text-xs text-gray-400">Powered by Mrasem</p>
      </div>
    </div>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between text-sm">
      <span className="text-gray-400">{label}</span>
      <span className="font-medium text-[#31231b]">{value}</span>
    </div>
  );
}
