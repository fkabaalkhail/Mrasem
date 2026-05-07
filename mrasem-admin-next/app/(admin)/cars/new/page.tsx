"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { ImageUploadField } from "@/components/ImageUploadField";

export default function NewCarPage() {
  const router = useRouter();
  const [form, setForm] = useState({
    name: "",
    category: "Standard",
    passengers: 4,
    image_name: "",
    about: "",
    arabic_name: "",
    arabic_about: "",
    arabic_passenger_line: "",
  });
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!form.name.trim() || !form.arabic_name.trim() || !form.category.trim()) {
      setError("Please fill in all required fields.");
      return;
    }
    setSaving(true);
    const sb = createClient();
    const { error: insErr } = await sb.from("cars").insert({
      name: form.name,
      category: form.category,
      passengers: form.passengers,
      image_name: form.image_name || null,
      about: form.about || null,
      arabic_name: form.arabic_name,
      arabic_about: form.arabic_about || null,
      arabic_passenger_line: form.arabic_passenger_line || null,
    });
    setSaving(false);
    if (insErr) {
      setError(insErr.message);
      return;
    }
    router.push("/cars");
    router.refresh();
  }

  return (
    <div>
      <div className="mb-6 flex items-center gap-4">
        <Link href="/cars" className="text-sm text-mrasem-awaki hover:underline">
          ← Back
        </Link>
        <h1 className="text-2xl font-semibold text-mrasem-preiwinki">New car</h1>
      </div>
      <form
        onSubmit={(e) => void onSubmit(e)}
        className="max-w-2xl space-y-4 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
      >
        <Input label="Name" value={form.name} onChange={(v) => setForm({ ...form, name: v })} required />
        <div>
          <label className="block text-sm font-medium text-gray-700">Category</label>
          <select
            value={form.category}
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
            value={form.passengers}
            onChange={(e) => setForm({ ...form, passengers: parseInt(e.target.value, 10) || 1 })}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">About</label>
          <textarea
            value={form.about}
            onChange={(e) => setForm({ ...form, about: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <ImageUploadField
          folder="cars"
          value={form.image_name}
          onChange={(url) => setForm({ ...form, image_name: url })}
        />
        <hr className="my-2" />
        <p className="text-sm font-semibold text-gray-500">Arabic fields</p>
        <Input label="Arabic Name (الاسم)" value={form.arabic_name} onChange={(v) => setForm({ ...form, arabic_name: v })} />
        <Input label="Arabic Passenger Line (عدد الركاب)" value={form.arabic_passenger_line} onChange={(v) => setForm({ ...form, arabic_passenger_line: v })} />
        <div>
          <label className="block text-sm font-medium text-gray-700">Arabic About (عن السيارة)</label>
          <textarea value={form.arabic_about} onChange={(e) => setForm({ ...form, arabic_about: e.target.value })} rows={4} className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm" dir="rtl" />
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
