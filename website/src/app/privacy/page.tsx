import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Privacy Policy — MiRO',
  description:
    'MiRO privacy policy. Learn how we protect your data and respect your privacy.',
};

export default function PrivacyPage() {
  return (
    <div className="pt-24 pb-16">
      <section className="hero-gradient pb-12 pt-12">
        <div className="mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
            Privacy Policy
          </h1>
          <p className="mt-4 text-gray-400">Last updated: March 1, 2026</p>
        </div>
      </section>

      <article className="mx-auto max-w-4xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="prose prose-invert prose-gray max-w-none space-y-8 text-gray-300 [&_h2]:text-xl [&_h2]:font-bold [&_h2]:text-white [&_h2]:mt-10 [&_h2]:mb-4 [&_h3]:text-lg [&_h3]:font-semibold [&_h3]:text-white [&_h3]:mt-6 [&_h3]:mb-3 [&_p]:leading-relaxed [&_ul]:space-y-2 [&_li]:text-gray-400">
          <section>
            <h2>1. Our Privacy Commitment</h2>
            <p>
              MiRO (&quot;My Intake Record Oracle&quot;) is built with privacy at its
              core. We believe your health data belongs to you and only you.
              This Privacy Policy explains what data we collect, how we use it,
              and the choices you have.
            </p>
            <p>
              <strong className="text-white">
                The short version: We collect almost nothing. Your food data
                stays on your device. No account required. No login. No personal
                information stored on our servers.
              </strong>
            </p>
          </section>

          <section>
            <h2>2. Data Storage — Local First</h2>
            <p>
              MiRO is an offline-first application. All food entries, nutrition
              data, meal history, personal goals, and preferences are stored
              locally on your device using an on-device database.
            </p>
            <ul>
              <li>No user accounts or profiles stored on our servers</li>
              <li>No email, name, or personal identifiers collected</li>
              <li>
                Uninstalling the app removes all local data (unless you create a
                backup)
              </li>
            </ul>

            <h3>2.1 Cloud Backup</h3>
            <p>
              When you claim your daily Energy, MiRO automatically syncs a compact
              backup of your food history to our servers. This includes:
            </p>
            <ul>
              <li>Food entry text data (food name, calories, nutrients, meal type, timestamp)</li>
              <li>Custom meals (recipe name, ingredients, nutrition data)</li>
              <li>Small thumbnail images (~40-80 KB) with nutrition metadata after AI analysis</li>
              <li>Health profile (gender, age, weight, height, activity level)</li>
              <li>Nutrition goals (calorie goal, macro targets, meal budgets, cuisine preference)</li>
              <li>AR Scale data (detected object labels, bounding box coordinates, image dimensions, pixel-per-cm calibration ratio)</li>
            </ul>
            <p>
              Full-resolution food photos and your name/avatar are <strong className="text-white">never uploaded</strong>.
              All synced data is identified by an anonymous hashed device ID — not linked
              to your personal identity. You can restore your food history on a new device
              using a Recovery Key.
            </p>

            <h3>2.2 Anonymized AI Training Data</h3>
            <p>
              We may use <strong className="text-white">anonymized</strong> food images and associated metadata
              (nutrition labels, detected object bounding boxes, calibration data) to improve AI food
              recognition models or license to third-party AI/ML companies. This data is:
            </p>
            <ul>
              <li>Fully anonymized — no device ID, personal identity, or location data is included</li>
              <li>Stripped of EXIF metadata and any identifying information</li>
              <li>Aggregated at population level — individual users cannot be identified</li>
              <li>Used solely for improving food recognition technology</li>
            </ul>
            <p>
              You may opt out of AI training data usage by contacting{' '}
              <a
                href="mailto:support@tnbgrp.com"
                className="text-brand-400 underline"
              >
                support@tnbgrp.com
              </a>.
            </p>
          </section>

          <section>
            <h2>3. Data We Process (Not Store)</h2>
            <h3>3.1 AI Food Analysis</h3>
            <p>
              When you use MiRO&apos;s AI features (photo analysis, chat-based
              logging), your request is sent to Google Gemini API for processing.
              This includes:
            </p>
            <ul>
              <li>Food photos you choose to analyze</li>
              <li>Text descriptions of meals you type in chat</li>
              <li>Your cuisine preference (to improve accuracy)</li>
            </ul>
            <p>
              This data is processed by Google Gemini and is subject to{' '}
              <a
                href="https://policies.google.com/privacy"
                className="text-brand-400 underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                Google&apos;s Privacy Policy
              </a>
              . We do not store your photos or analysis requests on our servers.
            </p>

            <h3>3.2 In-App Purchases</h3>
            <p>
              Energy token purchases and Energy Pass subscriptions are processed
              through Google Play or the Apple App Store. We receive transaction
              confirmations (purchase tokens) to validate and deliver your
              purchase. We do not have access to your payment information (credit
              card, billing address, etc.).
            </p>

            <h3>3.3 Firebase Services</h3>
            <p>We use Firebase for the following limited purposes:</p>
            <ul>
              <li>
                <strong className="text-white">Firebase Analytics:</strong>{' '}
                Anonymous usage analytics (screen views, feature usage). No
                personally identifiable information is collected.
              </li>
              <li>
                <strong className="text-white">Cloud Firestore:</strong> Stores
                your Energy balance, purchase records, subscription status, and
                compact food history backups for cross-device restoration.
                Identified by a random device-generated ID (not linked to any
                personal information).
              </li>
              <li>
                <strong className="text-white">Cloud Functions:</strong>{' '}
                Processes purchase validations, Energy transactions, and data
                sync operations server-side for security.
              </li>
              <li>
                <strong className="text-white">Firebase Storage:</strong>{' '}
                Stores small food thumbnail images (~40-80 KB) with nutrition
                metadata for cloud backup and restoration purposes.
              </li>
              <li>
                <strong className="text-white">Firebase Messaging:</strong>{' '}
                Optional push notifications (you can disable these in your
                device settings at any time).
              </li>
            </ul>
          </section>

          <section>
            <h2>4. Health Data</h2>
            <p>
              If you enable Health Sync, MiRO reads and writes health data
              through Apple Health (iOS) or Google Health Connect (Android):
            </p>
            <ul>
              <li>
                <strong className="text-white">Written:</strong> Nutrition data
                from food entries (calories, protein, carbs, fat, meal type)
              </li>
              <li>
                <strong className="text-white">Read:</strong> Active Energy
                burned (to adjust your daily calorie goal)
              </li>
            </ul>
            <p>
              This data exchange happens locally between MiRO and your device&apos;s
              Health system. None of this health data is sent to our servers.
              Permission is requested only when you enable Health Sync and can
              be revoked at any time.
            </p>
          </section>

          <section>
            <h2>5. Photo Gallery Access</h2>
            <p>
              MiRO&apos;s Gallery Auto-Scan feature optionally accesses your photo
              gallery to find food photos taken throughout the day. This scanning
              happens entirely on your device. Photos are not uploaded anywhere
              unless you explicitly choose to analyze them with AI.
            </p>
          </section>

          <section>
            <h2>6. Third-Party Services</h2>
            <ul>
              <li>
                <strong className="text-white">Google Gemini API:</strong> AI
                food analysis processing
              </li>
              <li>
                <strong className="text-white">Google Firebase:</strong>{' '}
                Analytics, purchase validation, notifications
              </li>
              <li>
                <strong className="text-white">Google Play / Apple App Store:</strong>{' '}
                In-app purchase processing
              </li>
              <li>
                <strong className="text-white">Google AdMob:</strong>{' '}
                Advertisements (subject to Google&apos;s ad privacy policies)
              </li>
            </ul>
          </section>

          <section>
            <h2>7. Children&apos;s Privacy</h2>
            <p>
              MiRO is not directed at children under the age of 13. We do not
              knowingly collect personal information from children. If you
              believe a child has provided us with personal data, please contact
              us so we can take appropriate action.
            </p>
          </section>

          <section>
            <h2>8. Data Deletion</h2>
            <p>
              MiRO gives you full control over your data:
            </p>
            <ul>
              <li>Delete individual food entries at any time within the app</li>
              <li>Use &quot;Factory Reset&quot; in Settings to clear all local data</li>
              <li>Uninstall the app to remove all data from your device</li>
              <li>
                To delete server-side data (Energy balance, purchase records,
                cloud-synced food history, and thumbnail images), contact us at{' '}
                <a
                  href="mailto:support@tnbgrp.com"
                  className="text-brand-400 underline"
                >
                  support@tnbgrp.com
                </a>
              </li>
            </ul>
            <p>
              Cloud-synced food history is retained for up to 90 days for
              restoration purposes and automatically expires. Thumbnail images
              are retained until you request deletion.
            </p>
          </section>

          <section>
            <h2>9. Changes to This Policy</h2>
            <p>
              We may update this Privacy Policy from time to time. We will notify
              you of any significant changes through the app or on this page.
              Your continued use of MiRO after changes constitutes acceptance
              of the updated policy.
            </p>
          </section>

          <section>
            <h2>10. Contact Us</h2>
            <p>
              If you have questions about this Privacy Policy or your data,
              contact us at:
            </p>
            <ul>
              <li>
                Email:{' '}
                <a
                  href="mailto:support@tnbgrp.com"
                  className="text-brand-400 underline"
                >
                  support@tnbgrp.com
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
