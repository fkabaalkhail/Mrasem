"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { ImageUploadField } from "@/components/ImageUploadField";
import type { Car } from "@/lib/types";

export default function EditCarPage() {
  const params = useParams();
  const id = Number(params.id);
  const router = useRouter();
  const [form, setForm] = useState<Partial<Car> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const sb = createClient();
    void sb
      .from("cars")
      .select("*")
      .eq("id", id)
      .single()
      .then(({ data, error: qErr }) => {
        if (qErr || !data) setError(qErr?.message ?? "Not found");
        else setForm(data as Car);
      });
  }, [id]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form) return;
    setSaving(true);
    const sb = createClient();
    const { error: upErr } = await sb
      .from("cars")
      .update({
        name: form.name,
        category: form.category,
        passengers: form.passengers,
        image_name: form.image_name,
        about: form.about,
        arabic_name: form.arabic_name,
        arabic_about: form.arabic_about,
        arabic_passenger_line: form.arabic_passenger_line,
        updated_at: new Date().toISOString(),
      })
      .eq("id", id);
    setSaving(false);
    if (upErr) setError(upErr.message);
    else {
      router.push("/cars");
      router.refresh();
    }
  }

  async function onDelete() {
    if (!confirm("Delete?")) return;
    const sb = createClient();
    await sb.from("cars").delete().eq("id", id);
    router.push("/cars");
    router.refresh();
  }

  if (!form) return <p className="text-gray-500">{error ?? "Loading…"}</p>;

  return (
    <div>
      <div className="mb-6 flex gap-4">
        <Link href="/cars" className="text-sm text-mrasem-awaki hover:underline">
          ← Back
        </Link>
        <h1 className="text-2xl font-semibold text-mrasem-preiwinki">Edit car #{id}</h1>
      </div>
      <form
        onSubmit={(e) => void onSubmit(e)}
        className="max-w-2xl space-y-4 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
      >
        <Field label="Name" value={form.name ?? ""} onChange={(v) => setForm({ ...form, name: v })} />
        <div>
          <label className="block text-sm font-medium text-gray-700">Category</label>
          <select
            value={form.category ?? "Standard"}
            onChange={(e) => setForm({ ...form, category: e.target.value })}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          >
            <option value="Standard">Standard</option>
            <option value="Luxury">Luxury</option>
            <option value="VIP">VIP</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Passengers</label>
          <input
            type="number"
            min={1}
            value={form.passengers ?? 4}
            onChange={(e) => setForm({ ...form, passengers: parseInt(e.target.value, 10) || 1 })}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">About</label>
          <textarea
            value={form.about ?? ""}
            onChange={(e) => setForm({ ...form, about: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <ImageUploadField
          folder="cars"
          value={form.image_name ?? ""}
          onChange={(url) => setForm({ ...form, image_name: url })}
        />
        <hr className="my-2" />
        <p className="text-sm font-semibold text-gray-500">Arabic fields</p>
        <Field label="Arabic Name (الاسم)" value={form.arabic_name ?? ""} onChange={(v) => setForm({ ...form, arabic_name: v })} />
        <Field label="Arabic Passenger Line (عدد الركاب)" value={form.arabic_passenger_line ?? ""} onChange={(v) => setForm({ ...form, arabic_passenger_line: v })} />
        <div>
          <label className="block text-sm font-medium text-gray-700">Arabic About (عن السيارة)</label>
          <textarea value={form.arabic_about ?? ""} onChange={(e) => setForm({ ...form, arabic_about: e.target.value })} rows={4} className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm" dir="rtl" />
        </div>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <div className="flex gap-3">
          <button type="submit" disabled={saving} className="rounded-lg bg-mrasem-preiwinki px-5 py-2.5 text-sm text-white">
            Save
          </button>
          <button type="button" onClick={() => void onDelete()} className="rounded-lg border border-red-200 px-5 py-2.5 text-sm text-red-800">
            Delete
          </button>
        </div>
      </form>
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700">{label}</label>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
      />
    </div>
  );
}
