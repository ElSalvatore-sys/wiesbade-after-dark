# Supabase Email Templates - German Configuration
## WiesbadenAfterDark Owner PWA

---

## How to Configure German Email Templates

### Step 1: Open Supabase Dashboard
https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli/auth/templates

### Step 2: Update Each Template

---

## Password Reset Email (Passwort zurücksetzen)

**Subject:**
Passwort zurücksetzen - WiesbadenAfterDark

**Body:**
```html
<h2>Passwort zurücksetzen</h2>

<p>Hallo,</p>

<p>Sie haben angefordert, Ihr Passwort für WiesbadenAfterDark zurückzusetzen.</p>

<p>Klicken Sie auf den folgenden Link, um ein neues Passwort zu erstellen:</p>

<p><a href="{{ .ConfirmationURL }}">Passwort zurücksetzen</a></p>

<p>Dieser Link ist 24 Stunden gültig.</p>

<p>Falls Sie diese Anfrage nicht gestellt haben, können Sie diese E-Mail ignorieren.</p>

<p>Mit freundlichen Grüßen,<br>
Ihr WiesbadenAfterDark Team</p>
```

---

## Confirm Email (E-Mail bestätigen)

**Subject:**
E-Mail bestätigen - WiesbadenAfterDark

**Body:**
```html
<h2>E-Mail-Adresse bestätigen</h2>

<p>Hallo,</p>

<p>Bitte bestätigen Sie Ihre E-Mail-Adresse, indem Sie auf den folgenden Link klicken:</p>

<p><a href="{{ .ConfirmationURL }}">E-Mail bestätigen</a></p>

<p>Falls Sie kein Konto erstellt haben, können Sie diese E-Mail ignorieren.</p>

<p>Mit freundlichen Grüßen,<br>
Ihr WiesbadenAfterDark Team</p>
```

---

## Invite User (Einladung)

**Subject:**
Einladung zu WiesbadenAfterDark

**Body:**
```html
<h2>Sie wurden eingeladen!</h2>

<p>Hallo,</p>

<p>Sie wurden eingeladen, WiesbadenAfterDark beizutreten.</p>

<p>Klicken Sie auf den folgenden Link, um Ihr Konto zu aktivieren:</p>

<p><a href="{{ .ConfirmationURL }}">Einladung annehmen</a></p>

<p>Mit freundlichen Grüßen,<br>
Ihr WiesbadenAfterDark Team</p>
```

---

## Magic Link (Anmeldung ohne Passwort)

**Subject:**
Ihr Anmeldelink - WiesbadenAfterDark

**Body:**
```html
<h2>Anmeldung</h2>

<p>Hallo,</p>

<p>Klicken Sie auf den folgenden Link, um sich anzumelden:</p>

<p><a href="{{ .ConfirmationURL }}">Jetzt anmelden</a></p>

<p>Dieser Link ist 1 Stunde gültig.</p>

<p>Mit freundlichen Grüßen,<br>
Ihr WiesbadenAfterDark Team</p>
```

---

## Important Settings

### Redirect URLs
In Supabase Dashboard > Authentication > URL Configuration:

- Site URL: `https://owner-pwa.vercel.app`
- Redirect URLs:
  - `https://owner-pwa.vercel.app/*`
  - `http://localhost:5173/*` (for development)

### Rate Limits
- Free tier: 4 emails per hour
- For production: Configure custom SMTP

---

## Testing Password Reset

1. Open PWA: https://owner-pwa.vercel.app/login
2. Click "Passwort vergessen?"
3. Enter email: [your test email]
4. Check inbox (and spam folder)
5. Click reset link
6. Set new password
7. Login with new password

**Expected:** Email arrives within 1-2 minutes

---

## Troubleshooting

### Email not arriving?
1. Check spam/junk folder
2. Check Supabase Dashboard > Authentication > Users
3. Verify email exists in system
4. Check rate limits (4/hour on free tier)

### Link not working?
1. Verify redirect URLs are configured
2. Check link hasn't expired (24 hours)
3. Try incognito/private browsing
