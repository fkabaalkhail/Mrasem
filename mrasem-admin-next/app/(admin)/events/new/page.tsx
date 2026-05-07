"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { ImageUploadField } from "@/components/ImageUploadField";

export default function NewEventPage() {
  const router = useRouter();
  const [form, setForm] = useState({
    name: "",
    category: "",
    image_name: "",
    location: "",
    description: "",
    city: "Jeddah",
    arabic_name: "",
    arabic_category: "",
    arabic_description: "",
    arabic_location: "",
  });
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!form.name.trim() || !form.arabic_name.trim() || !form.city.trim()) {
      setError("Please fill in all required fields.");
      return;
    }
    setSaving(true);
    const sb = createClient();
    const { error: insErr } = await sb.from("season_events").insert({
      name: form.name,
      category: form.category,
      image_name: form.image_name || null,
      location: form.location || null,
      description: form.description || null,
      city: form.city,
      arabic_name: form.arabic_name,
      arabic_category: form.arabic_category,
      arabic_description: form.arabic_description || null,
      arabic_location: form.arabic_location || null,
    });
    setSaving(false);
    if (insErr) {
      setError(insErr.message);
      return;
    }
    router.push("/events");
    router.refresh();
  }

  return (
    <div>
      <div className="mb-6 flex items-center gap-4">
        <Link href="/events" className="text-sm text-mrasem-awaki hover:underline">
          ← Back
        </Link>
        <h1 className="text-2xl font-semibold text-mrasem-preiwinki">New season event</h1>
      </div>
      <form
        onSubmit={(e) => void onSubmit(e)}
        className="max-w-2xl space-y-4 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
      >
        <Input label="Name" value={form.name} onChange={(v) => setForm({ ...form, name: v })} required />
        <Input label="Category" value={form.category} onChange={(v) => setForm({ ...form, category: v })} required />
        <Input label="City" value={form.city} onChange={(v) => setForm({ ...form, city: v })} required />
        <Input label="Location" value={form.location} onChange={(v) => setForm({ ...form, location: v })} />
        <div>
          <label className="block text-sm font-medium text-gray-700">Description</label>
          <textarea
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <ImageUploadField
          folder="season-events"
          value={form.image_name}
          onChange={(url) => setForm({ ...form, image_name: url })}
          recommendedSize="1420 x 1000 px"
          recommendedRatio="10:7"
        />
        <hr className="my-2" />
        <p className="text-sm font-semibold text-gray-500">Arabic fields</p>
        <Input label="Arabic Name (الاسم)" value={form.arabic_name} onChange={(v) => setForm({ ...form, arabic_name: v })} />
        <Input label="Arabic Category (التصنيف)" value={form.arabic_category} onChange={(v) => setForm({ ...form, arabic_category: v })} />
        <Input label="Arabic Location (الموقع)" value={form.arabic_location} onChange={(v) => setForm({ ...form, arabic_location: v })} />
        <div>
          <label className="block text-sm font-medium text-gray-700">Arabic Description (الوصف)</label>
          <textarea value={form.arabic_description} onChange={(e) => setForm({ ...form, arabic_description: e.target.value })} rows={4} className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm" dir="rtl" />
        </div>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <button
          type="submit"
          disabled={saving}
          className="rounded-lg bg-mrasem-preiwinki px-5 py-2.5 text-sm font-medium text-white disabled:opacity-50"
        >
          Create
        </button>
      </form>
    </div>
  );
}

function Input({
  label,
  value,
  onChange,
  required,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  required?: boolean;
}) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700">{label}</label>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        required={required}
        className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
      />
    </div>
  );
}
