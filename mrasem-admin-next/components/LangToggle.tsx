"use client";

import Image from "next/image";
import { useLang } from "@/lib/lang";

export function LangToggle() {
  const { lang, setLang } = useLang();

  const segment =
    "flex items-center gap-1.5 rounded-md px-2.5 py-1.5 text-sm font-medium transition focus:outline-none focus-visible:ring-2 focus-visible:ring-mrasem-awaki focus-visible:ring-offset-1";

  return (
    <div
      className="inline-flex rounded-lg border border-gray-200 bg-gray-100 p-0.5 shadow-sm"
      role="group"
      aria-label="Language"
    >
      <button
        type="button"
        onClick={() => setLang("en")}
        className={`${segment} ${
          lang === "en"
            ? "bg-white text-mrasem-awaki shadow-sm"
            : "text-gray-600 hover:text-gray-900"
        }`}
        aria-pressed={lang === "en"}
      >
        <Image
          src="/lang-flag-us.png"
          alt=""
          width={22}
          height={16}
          className="h-4 w-[22px] rounded object-cover"
          unoptimized
        />
        EN
      </button>
      <button
        type="button"
        onClick={() => setLang("ar")}
        className={`${segment} ${
          lang === "ar"
            ? "bg-white text-mrasem-awaki shadow-sm"
            : "text-gray-600 hover:text-gray-900"
        }`}
        aria-pressed={lang === "ar"}
      >
        <Image
          src="/lang-flag-sa.png"
          alt=""
          width={22}
          height={16}
          className="h-4 w-[22px] rounded object-cover"
          unoptimized
        />
        AR
      </button>
    </div>
  );
}
