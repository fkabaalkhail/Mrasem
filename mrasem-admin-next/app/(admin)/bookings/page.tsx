"use client";

import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { SearchBar } from "@/components/SearchBar";
import { useLang } from "@/lib/lang";
import type { Booking } from "@/lib/types";

function statusBadge(status: string) {
  const base = "inline-block rounded-full px-4 py-1.5 text-xs font-semibold";
  if (status === "approved") return `${base} bg-[#d4edda] text-[#1b5e37]`;
  if (status === "rejected") return `${base} bg-[#f8d7da] text-[#842029]`;
  return `${base} bg-[#fff3cd] text-[#664d03]`;
}

export default function BookingsPage() {
  const { t } = useLang();
  const [rows, setRows] = useState<Booking[]>([]);
  const [q, setQ] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [loading, setLoading] = useState(true);

  function reload() {
    const sb = createClient();
    void sb
      .from("bookings")
      .select("*")
      .order("created_at", { ascending: false })
      .then(({ data, error }) => {
        if (!error && data) setRows(data as Booking[]);
        setLoading(false);
      });
  }

  useEffect(() => {
    reload();
  }, []);

  const filtered = useMemo(() => {
    let list = rows;
    if (statusFilter) list = list.filter((b) => b.status === statusFilter);
    const s = q.trim().toLowerCase();
    if (!s) return list;
    return list.filter(
      (b) =>
        b.place_title.toLowerCase().includes(s) ||
        b.user_phone.includes(q) ||
        (b.ticket_code && b.ticket_code.toLowerCase().includes(s))
    );
  }, [rows, q, statusFilter]);

  async function setStatus(id: number, status: "approved" | "rejected") {
    const sb = createClient();
    await sb.from("bookings").update({ status }).eq("id", id);
    reload();
  }

  return (
    <div>
      <h1 className="text-2xl font-semibold text-mrasem-preiwinki">{t("Bookings", "الحجوزات")}</h1>
      <p className="mt-1 text-sm text-gray-600">{t("Approve or reject reservation requests", "قبول أو رفض طلبات الحجز")}</p>
      <div className="mt-6 flex flex-col gap-4 sm:flex-row sm:items-center">
        <SearchBar value={q} onChange={setQ} placeholder={t("Search title, phone, ticket…", "بحث بالعنوان، الهاتف، التذكرة…")} />
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm"
        >
          <option value="">{t("All statuses", "جميع الحالات")}</option>
          <option value="pending">{t("Pending", "قيد الانتظار")}</option>
          <option value="approved">{t("Approved", "مقبول")}</option>
          <option value="rejected">{t("Rejected", "مرفوض")}</option>
        </select>
      </div>
      <div className="mt-4 overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        {loading ? (
          <p className="p-6 text-sm text-gray-500">{t("Loading…", "جاري التحميل…")}</p>
        ) : (
          <table className="min-w-full text-left text-sm">
            <thead className="border-b border-gray-100 bg-gray-50/80">
              <tr>
                <th className="px-4 py-3 font-medium text-gray-600">ID</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Phone", "الهاتف")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Place", "المكان")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("When", "الموعد")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Status", "الحالة")}</th>
                <th className="px-4 py-3 font-medium text-gray-600">{t("Actions", "إجراءات")}</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((b) => (
                <tr key={b.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                  <td className="px-4 py-3 text-gray-500">{b.id}</td>
                  <td className="px-4 py-3 font-mono text-xs">{b.user_phone}</td>
                  <td className="px-4 py-3">
                    <div className="font-medium">{b.place_title}</div>
                    {b.subtitle && (
                      <div className="text-xs text-gray-500">{b.subtitle}</div>
                    )}
                  </td>
                  <td className="px-4 py-3 text-gray-600">
                    {b.date_display} {b.time_display}
                  </td>
                  <td className="px-4 py-3">
                    <span className={statusBadge(b.status)}>
                      {b.status === "approved" ? t("Approved", "مقبولة") : b.status === "rejected" ? t("Rejected", "مرفوضة") : t("Pending", "قيد الانتظار")}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex flex-wrap gap-2">
                      {b.status === "pending" && (
                        <>
                          <button
                            type="button"
                            onClick={() => void setStatus(b.id, "approved")}
                            className="rounded-lg bg-mrasem-awaki px-3 py-1 text-xs font-medium text-white"
                          >
                            {t("Approve", "قبول")}
                          </button>
                          <button
                            type="button"
                            onClick={() => void setStatus(b.id, "rejected")}
                            className="rounded-lg border border-red-200 px-3 py-1 text-xs font-medium text-red-800"
                          >
                            {t("Reject", "رفض")}
                          </button>
                        </>
                      )}
                    </div>
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
