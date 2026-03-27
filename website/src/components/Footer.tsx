import Link from 'next/link';
import Image from 'next/image';
import { publicAsset } from '@/lib/publicAsset';

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-gray-200 bg-brand-950 text-white">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="grid gap-8 md:grid-cols-4">
          <div className="md:col-span-2">
            <div className="flex items-center gap-2.5">
              <Image
                src={publicAsset('/arcal/logo.png')}
                alt="ArCal"
                width={36}
                height={36}
                className="rounded-lg"
              />
              <span className="text-xl font-bold">ArCal</span>
            </div>
            <p className="mt-4 max-w-sm text-sm text-gray-400">
              Precise calories, zero effort. The easiest AI calorie counter with
              AR scan. No login. No subscription trap. Your data stays on your
              device.
            </p>
          </div>

          <div>
            <h3 className="mb-4 text-sm font-semibold uppercase tracking-wider text-gray-400">
              Product
            </h3>
            <ul className="space-y-3 text-sm">
              <li>
                <Link
                  href="/#features"
                  className="text-gray-400 transition-colors hover:text-white"
                >
                  Features
                </Link>
              </li>
              <li>
                <Link
                  href="/#pricing"
                  className="text-gray-400 transition-colors hover:text-white"
                >
                  Pricing
                </Link>
              </li>
              <li>
                <Link
                  href="/#download"
                  className="text-gray-400 transition-colors hover:text-white"
                >
                  Download
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="mb-4 text-sm font-semibold uppercase tracking-wider text-gray-400">
              Legal & Support
            </h3>
            <ul className="space-y-3 text-sm">
              <li>
                <Link
                  href="/support/"
                  className="text-gray-400 transition-colors hover:text-white"
                >
                  Support
                </Link>
              </li>
              <li>
                <Link
                  href="/privacy/"
                  className="text-gray-400 transition-colors hover:text-white"
                >
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link
                  href="/terms/"
                  className="text-gray-400 transition-colors hover:text-white"
                >
                  Terms of Service
                </Link>
              </li>
              <li>
                <Link
                  href="/eula/"
                  className="text-gray-400 transition-colors hover:text-white"
                >
                  EULA
                </Link>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 border-t border-white/10 pt-8 text-center text-sm text-gray-500">
          <p>&copy; {currentYear} TNB Group. All rights reserved.</p>
          <p className="mt-1">ArCal — AI Calories Counter</p>
        </div>
      </div>
    </footer>
  );
}
