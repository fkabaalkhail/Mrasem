"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { ImageUploadField } from "@/components/ImageUploadField";
import type { Activity } from "@/lib/types";

export default function EditActivityPage() {
  const params = useParams();
  const id = Number(params.id);
  const router = useRouter();
  const [form, setForm] = useState<Partial<Activity> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const sb = createClient();
    void sb
      .from("activities")
      .select("*")
      .eq("id", id)
      .single()
      .then(({ data, error: qErr }) => {
        if (qErr || !data) setError(qErr?.message ?? "Not found");
        else setForm(data as Activity);
      });
  }, [id]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form) return;
    setSaving(true);
    const sb = createClient();
    const { error: upErr } = await sb
      .from("activities")
      .update({
        name: form.name,
        rating: form.rating,
        category: form.category,
        image_name: form.image_name,
        location: form.location,
        description: form.description,
        city: form.city,
        arabic_name: form.arabic_name,
        arabic_category: form.arabic_category,
        arabic_description: form.arabic_description,
        arabic_location: form.arabic_location,
        safety_guidelines: form.safety_guidelines,
        arabic_safety_guidelines: form.arabic_safety_guidelines,
        updated_at: new Date().toISOString(),
      })
      .eq("id", id);
    setSaving(false);
    if (upErr) setError(upErr.message);
    else {
      router.push("/activities");
      router.refresh();
    }
  }

  async function onDelete() {
    if (!confirm("Delete?")) return;
    const sb = createClient();
    await sb.from("activities").delete().eq("id", id);
    router.push("/activities");
    router.refresh();
  }

  if (!form) return <p className="text-gray-500">{error ?? "Loading…"}</p>;

  return (
    <div>
      <div className="mb-6 flex gap-4">
        <Link href="/activities" className="text-sm text-mrasem-awaki hover:underline">
          ← Back
        </Link>
        <h1 className="text-2xl font-semibold text-mrasem-preiwinki">Edit activity #{id}</h1>
      </div>
      <form
        onSubmit={(e) => void onSubmit(e)}
        className="max-w-2xl space-y-4 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
      >
        <Field label="Name" value={form.name ?? ""} onChange={(v) => setForm({ ...form, name: v })} />
        <Field label="Category" value={form.category ?? ""} onChange={(v) => setForm({ ...form, category: v })} />
        <Field label="City" value={form.city ?? ""} onChange={(v) => setForm({ ...form, city: v })} />
        <Field label="Location" value={form.location ?? ""} onChange={(v) => setForm({ ...form, location: v })} />
        <div>
          <label className="block text-sm font-medium text-gray-700">Rating</label>
          <input
            type="number"
            step="0.1"
            min={0}
            max={5}
            value={form.rating ?? 0}
            onChange={(e) => setForm({ ...form, rating: parseFloat(e.target.value) || 0 })}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Description</label>
          <textarea
            value={form.description ?? ""}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <ImageUploadField
          folder="activities"
          value={form.image_name ?? ""}
          onChange={(url) => setForm({ ...form, image_name: url })}
        />
        <hr className="my-2" />
        <p className="text-sm font-semibold text-gray-500">Arabic fields</p>
        <Field label="Arabic Name (الاسم)" value={form.arabic_name ?? ""} onChange={(v) => setForm({ ...form, arabic_name: v })} />
        <Field label="Arabic Category (التصنيف)" value={form.arabic_category ?? ""} onChange={(v) => setForm({ ...form, arabic_category: v })} />
        <Field label="Arabic Location (الموقع)" value={form.arabic_location ?? ""} onChange={(v) => setForm({ ...form, arabic_location: v })} />
        <div>
          <label className="block text-sm font-medium text-gray-700">Arabic Description (الوصف)</label>
          <textarea value={form.arabic_description ?? ""} onChange={(e) => setForm({ ...form, arabic_description: e.target.value })} rows={4} className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm" dir="rtl" />
        </div>
        <hr className="my-2" />
        <p className="text-sm font-semibold text-gray-500">Safety guidelines</p>
        <div>
          <label className="block text-sm font-medium text-gray-700">Safety Guidelines</label>
          <textarea value={form.safety_guidelines ?? ""} onChange={(e) => setForm({ ...form, safety_guidelines: e.target.value })} rows={3} className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm" />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Arabic Safety Guidelines (إرشادات السلامة)</label>
          <textarea value={form.arabic_safety_guidelines ?? ""} onChange={(e) => setForm({ ...form, arabic_safety_guidelines: e.target.value })} rows={3} className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm" dir="rtl" />
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
