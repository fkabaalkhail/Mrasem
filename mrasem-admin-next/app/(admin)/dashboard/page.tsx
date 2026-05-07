"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { useLang } from "@/lib/lang";

export default function DashboardPage() {
  const { t } = useLang();
  const [counts, setCounts] = useState({ bookings: 0, users: 0, restaurants: 0, activities: 0, events: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const sb = createClient();
    Promise.all([
      sb.from("bookings").select("*", { count: "exact", head: true }),
      sb.from("users").select("*", { count: "exact", head: true }),
      sb.from("restaurants").select("*", { count: "exact", head: true }),
      sb.from("activities").select("*", { count: "exact", head: true }),
      sb.from("season_events").select("*", { count: "exact", head: true }),
    ]).then(([b, u, r, a, e]) => {
      setCounts({
        bookings: b.count ?? 0,
        users: u.count ?? 0,
        restaurants: r.count ?? 0,
        activities: a.count ?? 0,
        events: e.count ?? 0,
      });
      setLoading(false);
    });
  }, []);

  const cards = [
    { label: t("Bookings", "الحجوزات"), value: counts.bookings, href: "/bookings" },
    { label: t("Users", "المستخدمين"), value: counts.users, href: "/users" },
    { label: t("Restaurants", "المطاعم"), value: counts.restaurants, href: "/restaurants" },
    { label: t("Activities", "الأنشطة"), value: counts.activities, href: "/activities" },
    { label: t("Season Events", "فعاليات الموسم"), value: counts.events, href: "/events" },
  ];

  return (
    <div>
      <h1 className="text-2xl font-semibold text-mrasem-preiwinki">{t("Dashboard", "لوحة التحكم")}</h1>
      <p className="mt-1 text-sm text-gray-600">{t("Overview of your Mrasem data", "نظرة عامة على بيانات مراسم")}</p>
      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {loading
          ? Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="h-24 animate-pulse rounded-xl border border-gray-200 bg-gray-50" />
            ))
          : cards.map((c) => (
              <a
                key={c.label}
                href={c.href}
                className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm transition hover:border-mrasem-awaki/40 hover:shadow"
              >
                <p className="text-sm font-medium text-gray-500">{c.label}</p>
                <p className="mt-2 text-3xl font-semibold text-mrasem-preiwinki">{c.value}</p>
              </a>
            ))}
      </div>
    </div>
  );
}
