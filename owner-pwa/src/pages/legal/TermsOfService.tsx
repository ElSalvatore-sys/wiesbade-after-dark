export function TermsOfService() {
  return (
    <div className="max-w-3xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold text-white mb-6">Terms of Service</h1>
      <p className="text-gray-400 mb-8">Last updated: November 29, 2025</p>
      
      <div className="prose prose-invert space-y-6 text-gray-300">
        <section>
          <h2 className="text-xl font-semibold text-white mb-3">1. Acceptance of Terms</h2>
          <p>
            By accessing or using the WiesbadenAfterDark app and services, you agree to be bound by 
            these Terms of Service. If you do not agree, please do not use our services.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">2. Description of Service</h2>
          <p>
            WiesbadenAfterDark provides a nightlife loyalty platform connecting users with bars, 
            clubs, and restaurants in Wiesbaden. Our services include:
          </p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li>Venue discovery and information</li>
            <li>Table and event booking</li>
            <li>Check-in and loyalty points system</li>
            <li>Exclusive offers and promotions</li>
            <li>Venue management tools (Owner Portal)</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">3. User Accounts</h2>
          <p>To use certain features, you must:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li>Be at least 18 years old</li>
            <li>Provide accurate registration information</li>
            <li>Keep your account credentials secure</li>
            <li>Notify us of any unauthorized access</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">4. Points and Rewards</h2>
          <ul className="list-disc pl-6 space-y-2">
            <li>Points are earned through check-ins and qualifying purchases</li>
            <li>Points have no cash value and cannot be transferred</li>
            <li>Points may expire after 12 months of account inactivity</li>
            <li>We reserve the right to modify the points program with notice</li>
            <li>Fraudulent activity will result in account termination and point forfeiture</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">5. Bookings and Reservations</h2>
          <ul className="list-disc pl-6 space-y-2">
            <li>Bookings are subject to venue availability and confirmation</li>
            <li>Cancellation policies vary by venue</li>
            <li>No-shows may affect your ability to make future bookings</li>
            <li>We are not responsible for venue service quality</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">6. Owner Portal (Business Users)</h2>
          <p>Venue owners and staff using the Owner Portal agree to:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li>Provide accurate venue and event information</li>
            <li>Honor published offers and promotions</li>
            <li>Protect customer data in accordance with GDPR</li>
            <li>Use the platform only for legitimate business purposes</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">7. Prohibited Conduct</h2>
          <p>You may not:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li>Use the service for illegal purposes</li>
            <li>Create fake accounts or check-ins</li>
            <li>Harass other users or venue staff</li>
            <li>Attempt to manipulate the points system</li>
            <li>Reverse engineer or copy our software</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">8. Limitation of Liability</h2>
          <p>
            WiesbadenAfterDark is provided &quot;as is&quot; without warranties. We are not liable for any 
            indirect, incidental, or consequential damages arising from your use of the service.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">9. Changes to Terms</h2>
          <p>
            We may update these terms at any time. Continued use after changes constitutes acceptance 
            of the new terms. We will notify users of significant changes.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">10. Governing Law</h2>
          <p>
            These terms are governed by the laws of Germany. Any disputes shall be resolved in the 
            courts of Wiesbaden, Germany.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">11. Contact</h2>
          <p>For questions about these terms:</p>
          <ul className="list-none space-y-1 mt-2">
            <li>Email: legal@wiesbadenafterdark.com</li>
            <li>Address: Wiesbaden, Germany</li>
          </ul>
        </section>
      </div>
    </div>
  );
}
