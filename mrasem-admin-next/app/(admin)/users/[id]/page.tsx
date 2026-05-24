"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import type { AppUser, Booking } from "@/lib/types";

export default function UserBookingsPage() {
  const params = useParams();
  const id = Number(params.id);
  const [user, setUser] = useState<AppUser | null>(null);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const sb = createClient();
    void sb
      .from("users")
      .select("*")
      .eq("id", id)
      .single()
      .then(({ data, error: uErr }) => {
        if (uErr || !data) {
          setError(uErr?.message ?? "User not found");
          return;
        }
        const u = data as AppUser;
        setUser(u);
        void sb
          .from("bookings")
          .select("*")
          .eq("user_phone", u.phone)
          .order("created_at", { ascending: false })
          .then(({ data: b, error: bErr }) => {
            if (!bErr && b) setBookings(b as Booking[]);
          });
      });
  }, [id]);

  if (error || !user) {
    return (
      <div>
        <Link href="/users" className="text-sm text-mrasem-awaki hover:underline">
          ← Users
        </Link>
        <p className="mt-4 text-gray-500">{error ?? "Loading…"}</p>
      </div>
    );
  }

  return (
    <div>
      <Link href="/users" className="text-sm text-mrasem-awaki hover:underline">
        ← Users
      </Link>
      <h1 className="mt-4 text-2xl font-semibold text-mrasem-preiwinki">Bookings</h1>
      <p className="mt-1 font-mono text-sm text-gray-600">{user.phone}</p>
      {user.name && <p className="text-sm text-gray-500">{user.name}</p>}
      {user.membership_id && <p className="text-sm text-gray-500">Membership: {user.membership_id}</p>}
      <div className="mt-6 overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        <table className="min-w-full text-left text-sm">
          <thead className="border-b border-gray-100 bg-gray-50/80">
            <tr>
              <th className="px-4 py-3 font-medium text-gray-600">Ticket</th>
              <th className="px-4 py-3 font-medium text-gray-600">Place</th>
              <th className="px-4 py-3 font-medium text-gray-600">When</th>
              <th className="px-4 py-3 font-medium text-gray-600">Status</th>
            </tr>
          </thead>
          <tbody>
            {bookings.length === 0 ? (
              <tr>
                <td colSpan={4} className="px-4 py-6 text-center text-gray-500">
                  No bookings for this phone
                </td>
              </tr>
            ) : (
              bookings.map((b) => (
                <tr key={b.id} className="border-b border-gray-50">
                  <td className="px-4 py-3 font-mono text-xs">{b.ticket_code}</td>
                  <td className="px-4 py-3">{b.place_title}</td>
                  <td className="px-4 py-3 text-gray-600">
                    {b.date_display} {b.time_display}
                  </td>
                  <td className="px-4 py-3">{b.status}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
