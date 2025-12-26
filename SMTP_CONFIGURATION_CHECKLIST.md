# SMTP Configuration Checklist
## WiesbadenAfterDark - Booking Emails Setup

**Status:** 🔄 IN PROGRESS
**Estimated Time:** 15 minutes
**Browser Tabs:** ✅ Opened

---

## Quick Links

- 📧 **Resend Signup:** https://resend.com
- ⚙️ **Supabase SMTP:** https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/settings/auth
- 📝 **Email Templates:** https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/auth/templates

---

## Step-by-Step Checklist

### Phase 1: Resend Account Setup (5 min)

- [ ] **1.1** Open https://resend.com in browser tab (already open)
- [ ] **1.2** Click "Start Building" or "Sign Up"
- [ ] **1.3** Sign up with Google or Email
- [ ] **1.4** Verify email (check inbox)
- [ ] **1.5** Navigate to API Keys section

**Current Status:** ⏳ Waiting for user

---

### Phase 2: Get Resend API Key (3 min)

- [ ] **2.1** Click "Create API Key" in Resend dashboard
- [ ] **2.2** Enter name: `WiesbadenAfterDark`
- [ ] **2.3** Select permission: "Sending access"
- [ ] **2.4** Click "Add" or "Create"
- [ ] **2.5** Copy the API key (starts with `re_`)
- [ ] **2.6** Save key somewhere safe (appears only once)

**⚠️ CRITICAL:** Copy the API key before closing the dialog!

**Current Status:** ⏳ Waiting for user

---

### Phase 3: Configure Supabase SMTP (5 min)

- [ ] **3.1** Open Supabase SMTP settings (already open)
- [ ] **3.2** Scroll to "SMTP Settings" section
- [ ] **3.3** Toggle ON "Enable Custom SMTP"
- [ ] **3.4** Enter Host: `smtp.resend.com`
- [ ] **3.5** Enter Port: `465`
- [ ] **3.6** Enter Username: `resend`
- [ ] **3.7** Paste your Resend API key in Password field
- [ ] **3.8** Enter Sender email: `noreply@resend.dev`
- [ ] **3.9** Enter Sender name: `WiesbadenAfterDark`
- [ ] **3.10** Set Rate limit: `60` seconds
- [ ] **3.11** Click "Save" button
- [ ] **3.12** Wait for success confirmation

**Current Status:** ⏳ Waiting for user

---

### Phase 4: Update Email Templates (Optional - 2 min)

- [ ] **4.1** Navigate to Email Templates in Supabase
- [ ] **4.2** Select "Password Reset" template
- [ ] **4.3** Update subject to German (see below)
- [ ] **4.4** Update body HTML (copy from below)
- [ ] **4.5** Click "Save"
- [ ] **4.6** Repeat for "Confirm Email" template

**Note:** Templates are optional but recommended for professional appearance

**Current Status:** ⏳ Waiting for user

---

## Copy-Paste Configuration

### SMTP Settings (Phase 3)

```
Host: smtp.resend.com
Port: 465
Username: resend
Password: [YOUR_RESEND_API_KEY]
Sender email: noreply@resend.dev
Sender name: WiesbadenAfterDark
Rate limit: 60
```

---

### Email Template: Password Reset (Phase 4)

**Subject:**
```
Passwort zurücksetzen - WiesbadenAfterDark
```

**Body HTML:**
```html
<div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; text-align: center;">
    <h1 style="color: white; margin: 0;">WiesbadenAfterDark</h1>
  </div>

  <div style="padding: 40px 20px; background: white;">
    <h2 style="color: #333;">Passwort zurücksetzen</h2>
    <p style="color: #666; line-height: 1.6;">Hallo,</p>
    <p style="color: #666; line-height: 1.6;">Sie haben eine Anfrage zum Zurücksetzen Ihres Passworts gestellt.</p>
    <p style="color: #666; line-height: 1.6;">Klicken Sie auf den Button unten, um ein neues Passwort zu erstellen:</p>

    <div style="text-align: center; margin: 30px 0;">
      <a href="{{ .ConfirmationURL }}"
         style="background: linear-gradient(to right, #7C3AED, #EC4899);
                color: white;
                padding: 14px 32px;
                text-decoration: none;
                border-radius: 8px;
                display: inline-block;
                font-weight: 600;">
        Passwort jetzt zurücksetzen
      </a>
    </div>

    <p style="color: #999; font-size: 14px; line-height: 1.6;">
      Falls Sie diese E-Mail nicht angefordert haben, können Sie sie ignorieren.<br>
      Der Link ist 24 Stunden gültig.
    </p>
  </div>

  <div style="background: #f5f5f5; padding: 20px; text-align: center;">
    <p style="color: #999; font-size: 12px; margin: 0;">
      © 2025 WiesbadenAfterDark<br>
      Diese E-Mail wurde automatisch gesendet.
    </p>
  </div>
</div>
```

---

### Email Template: Confirm Email (Phase 4)

**Subject:**
```
E-Mail bestätigen - WiesbadenAfterDark
```

**Body HTML:**
```html
<div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; text-align: center;">
    <h1 style="color: white; margin: 0;">WiesbadenAfterDark</h1>
  </div>

  <div style="padding: 40px 20px; background: white;">
    <h2 style="color: #333;">Willkommen!</h2>
    <p style="color: #666; line-height: 1.6;">Hallo,</p>
    <p style="color: #666; line-height: 1.6;">Vielen Dank für Ihre Registrierung bei WiesbadenAfterDark.</p>
    <p style="color: #666; line-height: 1.6;">Bitte bestätigen Sie Ihre E-Mail-Adresse, um Ihr Konto zu aktivieren:</p>

    <div style="text-align: center; margin: 30px 0;">
      <a href="{{ .ConfirmationURL }}"
         style="background: linear-gradient(to right, #7C3AED, #EC4899);
                color: white;
                padding: 14px 32px;
                text-decoration: none;
                border-radius: 8px;
                display: inline-block;
                font-weight: 600;">
        E-Mail jetzt bestätigen
      </a>
    </div>

    <p style="color: #999; font-size: 14px; line-height: 1.6;">
      Falls Sie sich nicht registriert haben, können Sie diese E-Mail ignorieren.
    </p>
  </div>

  <div style="background: #f5f5f5; padding: 20px; text-align: center;">
    <p style="color: #999; font-size: 12px; margin: 0;">
      © 2025 WiesbadenAfterDark<br>
      Diese E-Mail wurde automatisch gesendet.
    </p>
  </div>
</div>
```

---

## Testing Instructions

### Test 1: Password Reset Email

Once SMTP is configured:

1. Open https://owner-pwa.vercel.app
2. Click "Passwort vergessen?" on login page
3. Enter your email address
4. Click "Zurücksetzen"
5. Check your inbox (and spam folder)
6. Verify email arrives within 1-2 minutes

**Expected:** Email with German subject line and styled template

---

### Test 2: Booking Confirmation Email

The Edge Function `send-booking-confirmation` is already deployed!

To test:

1. Log into Owner PWA
2. Navigate to Bookings page
3. Find a pending booking or create one
4. Click "Bestätigen" (Confirm)
5. Check the guest's email

**Expected:** Booking confirmation email in German

---

## Troubleshooting

### ❌ Email not arriving

**Check:**
- Spam/Junk folder
- Wait 2-3 minutes
- Verify SMTP credentials in Supabase
- Check Resend dashboard: https://resend.com/emails

**Solution:**
- Double-check API key (no spaces, full key)
- Verify port is 465, not 587
- Check rate limit (60 seconds minimum)

---

### ❌ Invalid credentials error

**Check:**
- API key starts with `re_`
- No extra spaces when pasting
- Username is exactly `resend` (lowercase)

**Solution:**
- Regenerate API key in Resend
- Copy-paste carefully
- Save and retry

---

### ❌ Rate limit exceeded

**Cause:** Resend free tier = 100 emails/day

**Solution:**
- Wait 24 hours
- Upgrade to paid plan
- Use different email provider

---

## Progress Tracking

| Phase | Status | Time | Notes |
|-------|--------|------|-------|
| Browser tabs opened | ✅ | 0 min | Complete |
| Resend account | ⏳ | 5 min | In progress |
| API key obtained | ⏳ | 3 min | Pending |
| Supabase SMTP config | ⏳ | 5 min | Pending |
| Email templates | ⏳ | 2 min | Optional |
| Testing | ⏳ | 2 min | Pending |

**Total Time:** 15-17 minutes

---

## When You're Done

✅ **Mark as complete:**
- [ ] SMTP configured in Supabase
- [ ] Test email received
- [ ] Booking confirmation tested
- [ ] Update FINAL_PROJECT_STATUS.md

✅ **Next step:**
- Data import (replace placeholders)
- Mobile device testing

---

## Support Resources

- **Resend Docs:** https://resend.com/docs/send-with-smtp
- **Supabase SMTP Guide:** https://supabase.com/docs/guides/auth/auth-smtp
- **This Project Guide:** SMTP_RESEND_SETUP.md

---

*Last Updated: December 26, 2025*
*Configuration Status: Manual setup required*
