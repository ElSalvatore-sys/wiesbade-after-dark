export function PrivacyPolicy() {
  return (
    <div className="max-w-3xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold text-white mb-6">Privacy Policy</h1>
      <p className="text-gray-400 mb-8">Last updated: November 29, 2025</p>
      
      <div className="prose prose-invert space-y-6 text-gray-300">
        <section>
          <h2 className="text-xl font-semibold text-white mb-3">1. Introduction</h2>
          <p>
            WiesbadenAfterDark (&quot;we&quot;, &quot;our&quot;, or &quot;us&quot;) operates the WiesbadenAfterDark mobile application 
            and Owner Portal. This Privacy Policy explains how we collect, use, and protect your personal 
            information when you use our services.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">2. Information We Collect</h2>
          <p>We collect the following types of information:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li><strong>Account Information:</strong> Name, email address, phone number when you register</li>
            <li><strong>Profile Data:</strong> Profile photo, preferences, and settings</li>
            <li><strong>Usage Data:</strong> Check-ins, bookings, points earned, and app interactions</li>
            <li><strong>Device Information:</strong> Device type, operating system, and app version</li>
            <li><strong>Location Data:</strong> Only when you check in at venues (with your permission)</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">3. How We Use Your Information</h2>
          <p>We use your information to:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li>Provide and improve our services</li>
            <li>Process bookings and check-ins</li>
            <li>Calculate and manage loyalty points</li>
            <li>Send notifications about events and promotions (with your consent)</li>
            <li>Ensure security and prevent fraud</li>
            <li>Comply with legal obligations</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">4. Data Sharing</h2>
          <p>We share your data only with:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li><strong>Partner Venues:</strong> Basic booking and check-in information</li>
            <li><strong>Service Providers:</strong> Hosting, analytics, and payment processing</li>
            <li><strong>Legal Requirements:</strong> When required by law or to protect rights</li>
          </ul>
          <p className="mt-2">We never sell your personal data to third parties.</p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">5. Your Rights (GDPR)</h2>
          <p>Under GDPR, you have the right to:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2">
            <li><strong>Access:</strong> Request a copy of your personal data</li>
            <li><strong>Rectification:</strong> Correct inaccurate data</li>
            <li><strong>Erasure:</strong> Request deletion of your data (&quot;right to be forgotten&quot;)</li>
            <li><strong>Portability:</strong> Receive your data in a portable format</li>
            <li><strong>Objection:</strong> Object to certain processing activities</li>
            <li><strong>Withdraw Consent:</strong> Withdraw consent at any time</li>
          </ul>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">6. Data Security</h2>
          <p>
            We implement industry-standard security measures including encryption, secure servers, 
            and regular security audits. However, no method of transmission over the Internet is 
            100% secure.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">7. Data Retention</h2>
          <p>
            We retain your data for as long as your account is active or as needed to provide services. 
            You can request deletion at any time through the app settings or by contacting us.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white mb-3">8. Contact Us</h2>
          <p>For privacy-related questions or to exercise your rights:</p>
          <ul className="list-none space-y-1 mt-2">
            <li>Email: privacy@wiesbadenafterdark.com</li>
            <li>Address: Wiesbaden, Germany</li>
          </ul>
        </section>
      </div>
    </div>
  );
}
