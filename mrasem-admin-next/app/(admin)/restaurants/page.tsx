"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { SearchBar } from "@/components/SearchBar";
import type { Restaurant } from "@/lib/types";

export default function RestaurantsPage() {
  const [rows, setRows] = useState<Restaurant[]>([]);
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const sb = createClient();
    void sb
      .from("restaurants")
      .select("*")
      .order("id")
      .then(({ data, error }) => {
        if (!error && data) setRows(data as Restaurant[]);
        setLoading(false);
      });
  }, []);

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return rows;
    return rows.filter(
      (r) =>
        r.name.toLowerCase().includes(s) ||
        r.arabic_name.includes(q) ||
        r.city.toLowerCase().includes(s) ||
        r.cuisine.toLowerCase().includes(s)
    );
  }, [rows, q]);

  return (
    <div>
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-mrasem-preiwinki">Restaurants</h1>
          <p className="text-sm text-gray-600">Manage restaurant listings</p>
        </div>
        <Link
          href="/restaurants/new"
          className="inline-flex items-center justify-center rounded-lg bg-mrasem-awaki px-4 py-2 text-sm font-medium text-white hover:opacity-90"
        >
          Add restaurant
        </Link>
      </div>
      <div className="mt-6">
        <SearchBar value={q} onChange={setQ} placeholder="Search name, city, cuisine…" />
      </div>
      <div className="mt-4 overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        {loading ? (
          <p className="p-6 text-sm text-gray-500">Loading…</p>
        ) : (
          <table className="min-w-full text-left text-sm">
            <thead className="border-b border-gray-100 bg-gray-50/80">
              <tr>
                <th className="px-4 py-3 font-medium text-gray-600">ID</th>
                <th className="px-4 py-3 font-medium text-gray-600">Name</th>
                <th className="px-4 py-3 font-medium text-gray-600">Arabic</th>
                <th className="px-4 py-3 font-medium text-gray-600">City</th>
                <th className="px-4 py-3 font-medium text-gray-600">Rating</th>
                <th className="px-4 py-3 font-medium text-gray-600">Michelin</th>
                <th className="px-4 py-3" />
              </tr>
            </thead>
            <tbody>
              {filtered.map((r) => (
                <tr key={r.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                  <td className="px-4 py-3 text-gray-500">{r.id}</td>
                  <td className="px-4 py-3 font-medium text-mrasem-preiwinki">{r.name}</td>
                  <td className="px-4 py-3 text-gray-700">{r.arabic_name}</td>
                  <td className="px-4 py-3">{r.city}</td>
                  <td className="px-4 py-3">{r.rating ?? "—"}</td>
                  <td className="px-4 py-3">{r.has_michelin ? "Yes" : "—"}</td>
                  <td className="px-4 py-3 text-right">
                    <Link
                      href={`/restaurants/${r.id}`}
                      className="text-mrasem-awaki hover:underline"
                    >
                      Edit
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
