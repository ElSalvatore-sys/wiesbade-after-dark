# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of WiesbadenAfterDark seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Where to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **security@wiesbadenafterdark.com**

### What to Include

Please include the following information in your report:

1. **Type of vulnerability** (e.g., SQL injection, XSS, authentication bypass)
2. **Full paths** of source file(s) related to the vulnerability
3. **Location** of the affected source code (tag/branch/commit or direct URL)
4. **Step-by-step instructions** to reproduce the issue
5. **Proof-of-concept or exploit code** (if possible)
6. **Impact** of the vulnerability and potential exploitation scenarios
7. **Your contact information** for follow-up questions

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: Within 7 days
  - High: Within 14 days
  - Medium: Within 30 days
  - Low: Within 60 days

### Our Commitment

- We will acknowledge receipt of your vulnerability report
- We will send you regular updates about our progress
- We will notify you when the vulnerability is fixed
- We will publicly acknowledge your responsible disclosure (if you wish)

## Security Best Practices

### For Backend API

1. **Authentication**
   - All endpoints (except public ones) require JWT authentication
   - Tokens expire after 7 days (access) and 30 days (refresh)
   - Refresh token rotation is enforced

2. **Database Security**
   - All queries use parameterized statements (SQL injection protection)
   - Database credentials stored in environment variables
   - Supabase RLS (Row Level Security) enabled

3. **CORS Protection**
   - Restricted to specific origins (no wildcards in production)
   - Credentials support limited to trusted domains

4. **Rate Limiting**
   - API endpoints are rate-limited per user
   - SMS verification has cooldown periods

5. **Data Validation**
   - Pydantic schemas validate all input data
   - Phone numbers validated before SMS sending

### For iOS App

1. **Secure Storage**
   - Auth tokens stored in iOS Keychain
   - Sensitive data never stored in UserDefaults
   - No credentials in app bundle

2. **Network Security**
   - HTTPS-only communication (no HTTP exceptions)
   - Certificate pinning (recommended for production)
   - API tokens never logged

3. **Local Data**
   - SwiftData for local persistence
   - No PII stored unencrypted
   - Automatic data cleanup on logout

## Known Security Considerations

### Current Mitigations

- ✅ **CORS**: Restricted origins (no wildcard)
- ✅ **SQL Injection**: Parameterized queries only
- ✅ **XSS**: FastAPI auto-escapes responses
- ✅ **CSRF**: Token-based auth (no cookies)
- ✅ **Secrets**: Environment variables, not in code
- ✅ **Dependencies**: Automated scanning via Dependabot
- ✅ **Code Scanning**: Weekly CodeQL analysis

### Planned Enhancements

- ⏳ **Rate Limiting**: Advanced per-endpoint limits
- ⏳ **Audit Logging**: Comprehensive security event logging
- ⏳ **2FA**: Two-factor authentication option
- ⏳ **Certificate Pinning**: iOS app certificate validation
- ⏳ **WAF**: Web Application Firewall on Railway
- ⏳ **Penetration Testing**: Professional security audit

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the vulnerability and determine its severity
2. Develop and test a fix
3. Prepare a security advisory
4. Release the fix in a new version
5. Publicly disclose the vulnerability details (after users have had time to update)

## Security Hall of Fame

We recognize and thank security researchers who responsibly disclose vulnerabilities:

- *Be the first!* 🎉

## Bug Bounty Program

We currently do not offer a paid bug bounty program, but we deeply appreciate responsible disclosure and will publicly acknowledge your contribution.

## Contact

For security concerns, please email: **security@wiesbadenafterdark.com**

For general support: **support@wiesbadenafterdark.com**

---

**Last Updated**: 2024-11-15
