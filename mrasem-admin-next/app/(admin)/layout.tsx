"use client";

import { Sidebar } from "@/components/Sidebar";
import { LangProvider } from "@/lib/lang";
import { LangToggle } from "@/components/LangToggle";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <LangProvider>
      <div className="flex min-h-screen bg-mrasem-page">
        <Sidebar />
        <div className="flex-1 overflow-auto">
          <div className="flex justify-end p-4 pb-0">
            <LangToggle />
          </div>
          <main className="p-6 pt-2 lg:px-8">{children}</main>
        </div>
      </div>
    </LangProvider>
  );
}
