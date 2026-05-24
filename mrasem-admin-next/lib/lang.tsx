"use client";

import { createContext, useContext, useState, useEffect, ReactNode } from "react";

type Lang = "en" | "ar";

type LangContextValue = {
  lang: Lang;
  setLang: (next: Lang) => void;
  toggle: () => void;
  t: (en: string, ar: string) => string;
};

const LangContext = createContext<LangContextValue>({
  lang: "en",
  setLang: () => {},
  toggle: () => {},
  t: (en) => en,
});

export function LangProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>("en");

  useEffect(() => {
    const saved = localStorage.getItem("lang") as Lang | null;
    if (saved === "ar" || saved === "en") {
      setLangState(saved);
      document.documentElement.dir = saved === "ar" ? "rtl" : "ltr";
      document.documentElement.lang = saved;
    }
  }, []);

  function setLang(next: Lang) {
    setLangState(next);
    localStorage.setItem("lang", next);
    document.documentElement.dir = next === "ar" ? "rtl" : "ltr";
    document.documentElement.lang = next;
  }

  function toggle() {
    setLang(lang === "en" ? "ar" : "en");
  }

  const t = (en: string, ar: string) => (lang === "ar" ? ar : en);

  return <LangContext.Provider value={{ lang, setLang, toggle, t }}>{children}</LangContext.Provider>;
}

export const useLang = () => useContext(LangContext);
