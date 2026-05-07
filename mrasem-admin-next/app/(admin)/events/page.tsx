"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { SearchBar } from "@/components/SearchBar";
import { useLang } from "@/lib/lang";
import { resolveImageSrc } from "@/lib/image";
import type { SeasonEvent } from "@/lib/types";

export default function EventsPage() {
  const { t } = useLang();
  const [rows, setRows] = useState<SeasonEvent[]>([]);
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const sb = createClient();
    void sb
      .from("season_events")
      .select("*")
      .order("id")
      .then(({ data, error }) => {
        if (!error && data) setRows(data as SeasonEvent[]);
        setLoading(false);
      });
  }, []);

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return rows;
    return rows.filter(
      (r) =>
        r.name.toLowerCase().includes(s) ||
        (r.arabic_name ?? "").includes(q) ||
        r.category.toLowerCase().includes(s) ||
        r.city.toLowerCase().includes(s)
    );
  }, [rows, q]);

  return (
    <div>
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-mrasem-preiwinki">{t("Season events", "فعاليات الموسم")}</h1>
          <p className="text-sm text-gray-600">{t("Manage season events", "إدارة فعاليات الموسم")}</p>
        </div>
        <Link
          href="/events/new"
          className="inline-flex rounded-lg bg-mrasem-awaki px-4 py-2 text-sm font-medium text-white hover:opacity-90"
        >
          {t("Add event", "إضافة فعالية")}
        </Link>
      </div>
      <div className="mt-6">
        <SearchBar value={q} onChange={setQ} />
      </div>
      <div className="mt-4 overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        {loading ? (
          <p className="p-6 text-sm text-gray-500">{t("Loading…", "جاري التحميل…")}</p>
        ) : (
          <table className="min-w-full text-left text-sm">
            <thead className="border-b border-gray-100 bg-gray-50/80">
              <tr>
                <th className="px-4 py-3 font-medium text-gray-600">ID</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Preview", "معاينة")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Name", "الاسم")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Arabic", "عربي")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Category", "التصنيف")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("City", "المدينة")}</th>
                <th className="px-4 py-3" />
              </tr>
            </thead>
            <tbody>
              {filtered.map((r) => {
                const previewSrc = resolveImageSrc(r.image_name, "season-events");
                return (
                  <tr key={r.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                    <td className="px-4 py-3 text-gray-500">{r.id}</td>
                    <td className="px-4 py-3">
                      {previewSrc ? (
                        <div className="w-20 overflow-hidden rounded-lg border border-gray-200 bg-gray-50">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={previewSrc}
                            alt={r.name}
                            className="aspect-[10/7] h-auto w-full object-cover"
                          />
                        </div>
                      ) : (
                        <span className="text-xs text-gray-400">No image</span>
                      )}
                    </td>
                    <td className="px-4 py-3 font-medium">{r.name}</td>
                    <td className="px-4 py-3 text-gray-700">{r.arabic_name}</td>
                    <td className="px-4 py-3">{r.category}</td>
                    <td className="px-4 py-3">{r.city}</td>
                    <td className="px-4 py-3 text-right">
                      <Link href={`/events/${r.id}`} className="text-mrasem-awaki hover:underline">
                        {t("Edit", "تعديل")}
                      </Link>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
