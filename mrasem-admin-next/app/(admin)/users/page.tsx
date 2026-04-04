"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { SearchBar } from "@/components/SearchBar";
import type { AppUser } from "@/lib/types";

export default function UsersPage() {
  const [rows, setRows] = useState<AppUser[]>([]);
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const sb = createClient();
    void sb
      .from("users")
      .select("*")
      .order("id")
      .then(({ data, error }) => {
        if (!error && data) setRows(data as AppUser[]);
        setLoading(false);
      });
  }, []);

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return rows;
    return rows.filter(
      (u) =>
        u.phone.toLowerCase().includes(s) ||
        (u.name && u.name.toLowerCase().includes(s))
    );
  }, [rows, q]);

  return (
    <div>
      <h1 className="text-2xl font-semibold text-mrasem-preiwinki">Users</h1>
      <p className="mt-1 text-sm text-gray-600">App users by phone — open a row to see bookings</p>
      <div className="mt-6">
        <SearchBar value={q} onChange={setQ} placeholder="Search phone or name…" />
      </div>
      <div className="mt-4 overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        {loading ? (
          <p className="p-6 text-sm text-gray-500">Loading…</p>
        ) : (
          <table className="min-w-full text-left text-sm">
            <thead className="border-b border-gray-100 bg-gray-50/80">
              <tr>
                <th className="px-4 py-3 font-medium text-gray-600">ID</th>
                <th className="px-4 py-3 font-medium text-gray-600">Phone</th>
                <th className="px-4 py-3 font-medium text-gray-600">Name</th>
                <th className="px-4 py-3" />
              </tr>
            </thead>
            <tbody>
              {filtered.map((u) => (
                <tr key={u.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                  <td className="px-4 py-3 text-gray-500">{u.id}</td>
                  <td className="px-4 py-3 font-mono text-xs">{u.phone}</td>
                  <td className="px-4 py-3">{u.name ?? "—"}</td>
                  <td className="px-4 py-3 text-right">
                    <Link href={`/users/${u.id}`} className="text-mrasem-awaki hover:underline">
                      Bookings
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
