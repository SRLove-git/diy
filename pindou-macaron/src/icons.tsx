import type { SVGProps } from 'react';

type IconProps = SVGProps<SVGSVGElement> & { size?: number };

const base = (props: IconProps) => {
  const { size = 20, ...rest } = props;
  return {
    width: size,
    height: size,
    viewBox: '0 0 24 24',
    fill: 'none',
    stroke: 'currentColor',
    strokeWidth: 1.8,
    strokeLinecap: 'round' as const,
    strokeLinejoin: 'round' as const,
    ...rest,
  };
};

export const HomeIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M3 10.5 12 3l9 7.5" />
    <path d="M5 9.5V21h14V9.5" />
    <path d="M9.5 21v-6h5v6" />
  </svg>
);

export const SocialIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <circle cx="12" cy="12" r="8.5" />
    <circle cx="9" cy="10" r="1.2" fill="currentColor" stroke="none" />
    <circle cx="15" cy="10" r="1.2" fill="currentColor" stroke="none" />
    <path d="M8.5 14.5c.9 1 1.9 1.6 3.5 1.6s2.6-.6 3.5-1.6" />
  </svg>
);

export const MarketIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M3 9.5 5.5 4h13L21 9.5" />
    <path d="M3 9.5h18v2.2" />
    <path d="M6 12v7M12 12v7M18 12v7" />
    <path d="M4.5 11.7h15" />
  </svg>
);

export const MineIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <circle cx="12" cy="8.5" r="3.2" />
    <path d="M5 20c.8-3.2 3.6-5 7-5s6.2 1.8 7 5" />
  </svg>
);

export const BeadIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <rect x="4" y="4" width="7" height="7" rx="2" />
    <rect x="13" y="4" width="7" height="7" rx="2" />
    <rect x="4" y="13" width="7" height="7" rx="2" />
    <rect x="13" y="13" width="7" height="7" rx="2" />
  </svg>
);

export const ClockIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <circle cx="12" cy="12" r="8.5" />
    <path d="M12 7.5V12l3 2" />
  </svg>
);

export const CheckIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M4.5 12.5 10 18l9.5-11" />
  </svg>
);

export const SeatIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <rect x="4" y="5" width="7" height="6" rx="1.6" />
    <rect x="13" y="5" width="7" height="6" rx="1.6" />
    <path d="M5 13v6M9 13v6M15 13v6M19 13v6" />
  </svg>
);

export const WaterIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M12 3.5c2.5 3 5 5.7 5 8.5a5 5 0 0 1-10 0c0-2.8 2.5-5.5 5-8.5Z" />
    <path d="M9.5 14.5a2.5 2.5 0 0 0 2.5 2.5" />
  </svg>
);

export const HeartIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M12 20s-7-4.3-9-8.4C1.8 8.4 4 5.5 7 5.5c2 0 3.4 1.1 5 3 1.6-1.9 3-3 5-3 3 0 5.2 2.9 4 6.1C19 15.7 12 20 12 20Z" />
  </svg>
);

export const CommentIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M4 5.5h16v10H9l-5 3.5v-13.5Z" />
  </svg>
);

export const StarIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="m12 4 2.4 4.9 5.4.8-3.9 3.8.9 5.4-4.8-2.5-4.8 2.5.9-5.4-3.9-3.8 5.4-.8Z" />
  </svg>
);

export const ArrowIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M5 12h14M13 6l6 6-6 6" />
  </svg>
);

export const ChevronRightIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="m9 6 6 6-6 6" />
  </svg>
);

export const PlusIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M12 5v14M5 12h14" />
  </svg>
);

export const SearchIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <circle cx="11" cy="11" r="6.5" />
    <path d="m16 16 4 4" />
  </svg>
);

export const ScanIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3" />
    <path d="M4 12h16" />
  </svg>
);

export const MenuIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M4 7h16M4 12h16M4 17h16" />
  </svg>
);

export const CloseIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M6 6l12 12M18 6 6 18" />
  </svg>
);

export const WalletIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <path d="M3.5 7.5A2.5 2.5 0 0 1 6 5h12a2.5 2.5 0 0 1 2.5 2.5" />
    <path d="M20.5 7.5H6A2.5 2.5 0 0 0 3.5 10v6.5A2.5 2.5 0 0 0 6 19h14.5" />
    <path d="M16 13.5h2" />
  </svg>
);

export const DeviceIcon = (p: IconProps) => (
  <svg {...base(p)}>
    <rect x="4" y="4" width="10" height="16" rx="2.2" />
    <path d="M7.5 17.5h3" />
    <rect x="14.5" y="8" width="5.5" height="12" rx="1.8" />
  </svg>
);
