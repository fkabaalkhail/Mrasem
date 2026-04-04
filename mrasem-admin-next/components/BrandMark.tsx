import Image from "next/image";

type Props = {
  /** Sidebar: compact on dark brown. Login: larger on dark background. */
  variant?: "sidebar" | "login";
};

/**
 * Splash-screen Mrasem logo + “Admin” — matches app splash asset (`mrasem-logo`).
 */
export function BrandMark({ variant = "sidebar" }: Props) {
  const isLogin = variant === "login";

  return (
    <div
      className={`flex flex-wrap items-center gap-2.5 min-w-0 sm:gap-3 ${
        isLogin ? "justify-center" : ""
      }`}
    >
      <Image
        src="/mrasem-logo-full.png"
        alt="Mrasem"
        width={262}
        height={137}
        className={
          isLogin
            ? "h-[48px] w-auto max-w-[220px] object-contain object-left sm:h-[52px]"
            : "h-9 w-auto max-w-[118px] object-contain object-left sm:h-10 sm:max-w-[132px]"
        }
        priority
      />
      <div
        className={`hidden h-8 w-px shrink-0 sm:block ${isLogin ? "bg-white/25" : "bg-white/20"}`}
        aria-hidden
      />
      <span
        className={`font-semibold tracking-tight text-white ${
          isLogin ? "text-xl sm:text-2xl" : "text-base sm:text-lg"
        }`}
      >
        Admin
      </span>
    </div>
  );
}
