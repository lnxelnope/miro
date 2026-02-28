import Link from 'next/link';

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-white/10 bg-gray-950">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="grid gap-8 md:grid-cols-4">
          <div className="md:col-span-2">
            <div className="flex items-center gap-2">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-gradient-to-br from-brand-500 to-purple-500 font-bold text-white text-lg">
                M
              </div>
              <span className="text-xl font-bold">MiRO</span>
            </div>
            <p className="mt-4 max-w-sm text-sm text-gray-400">
              The most accurate AI food tracker. Decode every bite with
              ingredient-level precision. No login. No subscription trap. Your
              data stays on your device.
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
            </ul>
          </div>
        </div>

        <div className="mt-12 border-t border-white/10 pt-8 text-center text-sm text-gray-500">
          <p>&copy; {currentYear} TNB Group. All rights reserved.</p>
          <p className="mt-1">
            MiRO — My Intake Record Oracle
          </p>
        </div>
      </div>
    </footer>
  );
}
