import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'End User License Agreement — MiRO',
  description:
    'MiRO End User License Agreement (EULA). Subscription terms, auto-renewal policy, and licensing terms.',
};

export default function EulaPage() {
  return (
    <div className="pt-24 pb-16">
      <section className="hero-gradient pb-12 pt-12">
        <div className="mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
            End User License Agreement
          </h1>
          <p className="mt-4 text-gray-400">Last updated: March 3, 2026</p>
        </div>
      </section>

      <article className="mx-auto max-w-4xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="prose prose-invert prose-gray max-w-none space-y-8 text-gray-300 [&_h2]:text-xl [&_h2]:font-bold [&_h2]:text-white [&_h2]:mt-10 [&_h2]:mb-4 [&_h3]:text-lg [&_h3]:font-semibold [&_h3]:text-white [&_h3]:mt-6 [&_h3]:mb-3 [&_p]:leading-relaxed [&_ul]:space-y-2 [&_li]:text-gray-400">
          <section>
            <h2>1. Agreement</h2>
            <p>
              This End User License Agreement (&quot;EULA&quot;) is a legal agreement
              between you and TNB Group (&quot;we&quot;, &quot;us&quot;, &quot;our&quot;) for the use of
              MiRO — My Intake Record Oracle (&quot;the App&quot;). By downloading,
              installing, or using the App, you agree to be bound by this EULA.
            </p>
          </section>

          <section>
            <h2>2. License Grant</h2>
            <p>
              We grant you a limited, non-exclusive, non-transferable, revocable
              license to download, install, and use the App on devices you own or
              control, solely for your personal, non-commercial purposes, subject
              to this EULA and any applicable App Store or Google Play rules.
            </p>
          </section>

          <section>
            <h2>3. In-App Purchases</h2>
            <h3>3.1 Energy Tokens (Consumable)</h3>
            <p>
              Energy tokens are consumable in-app purchases used to access
              AI-powered features. Each token enables one AI analysis.
            </p>
            <ul>
              <li>Energy tokens are consumed upon use and cannot be restored</li>
              <li>Purchased Energy tokens do not expire</li>
              <li>Energy tokens are non-refundable once delivered to your account</li>
              <li>Energy balance is tied to your device identifier</li>
            </ul>

            <h3>3.2 Energy Pass (Auto-Renewable Subscription)</h3>
            <p>
              The Energy Pass is an auto-renewable subscription that provides
              unlimited AI analysis and additional premium benefits during the
              subscription period.
            </p>
          </section>

          <section>
            <h2>4. Subscription Terms</h2>
            <h3>4.1 Subscription Plans</h3>
            <p>The Energy Pass is available in the following plans:</p>
            <ul>
              <li><strong className="text-white">Weekly</strong> — Billed every 7 days</li>
              <li><strong className="text-white">Monthly</strong> — Billed every 30 days</li>
              <li><strong className="text-white">Yearly</strong> — Billed every 365 days</li>
            </ul>
            <p>
              Prices are displayed in your local currency within the App and may
              vary by region. Current pricing is available on the subscription
              screen within the App.
            </p>

            <h3>4.2 Payment</h3>
            <ul>
              <li>
                Payment will be charged to your Apple ID account (iOS) or Google
                Play account (Android) at confirmation of purchase
              </li>
              <li>
                All payments are processed securely through the Apple App Store
                or Google Play Store — we do not have access to your payment
                information
              </li>
            </ul>

            <h3>4.3 Auto-Renewal</h3>
            <ul>
              <li>
                Your subscription will automatically renew at the end of each
                billing period unless you cancel at least 24 hours before the
                current period ends
              </li>
              <li>
                Your account will be charged for renewal within 24 hours prior
                to the end of the current period at the same price
              </li>
              <li>
                Price changes will be notified in advance; continued use after a
                price change constitutes acceptance
              </li>
            </ul>

            <h3>4.4 Cancellation</h3>
            <ul>
              <li>
                You may cancel your subscription at any time through your
                device&apos;s subscription management settings
              </li>
              <li>
                <strong className="text-white">iOS:</strong> Settings → Apple ID
                → Subscriptions, or through the App Store
              </li>
              <li>
                <strong className="text-white">Android:</strong> Google Play
                Store → Payments &amp; subscriptions → Subscriptions
              </li>
              <li>
                Cancellation takes effect at the end of the current billing
                period — you retain access to subscription benefits until then
              </li>
              <li>No refunds are provided for partial billing periods</li>
            </ul>

            <h3>4.5 Free Trial</h3>
            <p>
              If a free trial is offered, the trial period is specified at the
              time of subscription. If you do not cancel before the trial period
              ends, your subscription will automatically convert to a paid
              subscription and you will be charged accordingly.
            </p>

            <h3>4.6 Subscription Benefits</h3>
            <p>
              While your Energy Pass subscription is active, you receive:
            </p>
            <ul>
              <li>Unlimited AI food analysis (photo, label scan, and text lookup)</li>
              <li>Subscriber badge displayed in the app</li>
              <li>Priority support</li>
            </ul>
            <p>
              Upon cancellation or expiration, you revert to the standard Energy
              token system. Any remaining purchased Energy tokens in your
              account are not affected.
            </p>
          </section>

          <section>
            <h2>5. Restrictions</h2>
            <p>You agree not to:</p>
            <ul>
              <li>
                Copy, modify, distribute, sell, or lease any part of the App
              </li>
              <li>
                Reverse-engineer, decompile, or attempt to extract the source
                code of the App
              </li>
              <li>
                Exploit bugs, vulnerabilities, or automation tools to
                manipulate the Energy system
              </li>
              <li>
                Use the App for any unlawful purpose or in violation of any
                applicable laws
              </li>
              <li>
                Share, resell, or transfer Energy tokens or subscription
                benefits to other users except through official in-app features
              </li>
            </ul>
          </section>

          <section>
            <h2>6. Intellectual Property</h2>
            <p>
              The App, including its design, code, AI models, branding, and
              content, is the intellectual property of TNB Group. All rights not
              expressly granted in this EULA are reserved.
            </p>
          </section>

          <section>
            <h2>7. Disclaimer of Warranties</h2>
            <p>
              The App is provided &quot;AS IS&quot; and &quot;AS AVAILABLE&quot; without
              warranties of any kind. We do not guarantee the accuracy of AI
              food analysis results. MiRO is not a medical device and should not
              be used as a substitute for professional nutritional or medical
              advice.
            </p>
          </section>

          <section>
            <h2>8. Limitation of Liability</h2>
            <p>
              To the maximum extent permitted by law, TNB Group shall not be
              liable for any indirect, incidental, special, consequential, or
              punitive damages arising from your use of the App, including but
              not limited to inaccuracies in AI-generated nutritional data, loss
              of data, or health decisions based on information provided by the
              App.
            </p>
          </section>

          <section>
            <h2>9. Data &amp; Privacy</h2>
            <p>
              Your use of the App is also governed by our{' '}
              <a
                href="/miro/privacy/"
                className="text-brand-400 underline"
              >
                Privacy Policy
              </a>
              , which describes how we collect, use, and protect your data.
            </p>
          </section>

          <section>
            <h2>10. Account Deletion</h2>
            <p>
              You may delete your account and all associated data at any time
              through the App (Profile → Data → Delete Account). This
              permanently removes:
            </p>
            <ul>
              <li>All local data (food entries, meals, goals, preferences)</li>
              <li>Cloud-synced data (energy balance, food history backups, thumbnail images)</li>
              <li>Your Recovery Key</li>
            </ul>
            <p>
              Active subscriptions must be cancelled separately through your
              device&apos;s subscription settings before deleting your account.
            </p>
          </section>

          <section>
            <h2>11. Termination</h2>
            <p>
              This EULA is effective until terminated. We may terminate your
              license at any time if you breach these terms. Upon termination,
              you must cease all use of the App and delete all copies. Sections
              regarding intellectual property, limitation of liability, and
              governing law survive termination.
            </p>
          </section>

          <section>
            <h2>12. Changes to This EULA</h2>
            <p>
              We may update this EULA from time to time. We will notify you of
              significant changes through the App or on this page. Your
              continued use of the App after changes constitutes acceptance of
              the updated EULA.
            </p>
          </section>

          <section>
            <h2>13. Governing Law</h2>
            <p>
              This EULA is governed by the laws of Thailand. Any disputes shall
              be resolved in the courts of Thailand.
            </p>
          </section>

          <section>
            <h2>14. Contact</h2>
            <p>
              For questions about this EULA, contact us at:
            </p>
            <ul>
              <li>
                Email:{' '}
                <a
                  href="mailto:lnxelnope@gmail.com"
                  className="text-brand-400 underline"
                >
                  lnxelnope@gmail.com
                </a>
              </li>
              <li>Website: www.tnbgrp.com</li>
              <li>Publisher: TNB Group</li>
            </ul>
          </section>
        </div>
      </article>
    </div>
  );
}
