import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});

const expoArabic = localFont({
  src: "./fonts/ExpoArabic-Medium.ttf",
  variable: "--font-expo-arabic",
  weight: "500",
});

export const metadata: Metadata = {
  title: "Mrasem Admin",
  description: "Manage restaurants, activities, events, cars, and bookings",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${expoArabic.variable} font-sans antialiased`}>
        {children}
      </body>
    </html>
  );
}
