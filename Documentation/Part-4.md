# `Part 4` Microsoft Account Configuration

In this part, you’ll learn how to secure your Microsoft Account by enabling key features and turning off risky defaults. This ensures your account—and connected Windows 11 device—are protected, recoverable, and under your control.

---

## Goal

By the end, you will:

* Understand the core security features of your Microsoft Account.
* Enable two‑step verification and secure recovery methods.
* Move toward passwordless sign‑in where possible.
* Review privacy and data‑sharing settings.
* Set up a regular maintenance checklist to keep things safe over time.

---

## Checklist

* [ ] Enable **Two‑step verification** on your Microsoft Account
* [ ] Add and verify **alternative sign‑in methods** (email, phone, security key)
* [ ] Set up **passwordless authentication** (Authenticator app / passkeys)
* [ ] Review and update **security info** (phone numbers, recovery emails)
* [ ] Review **trusted devices** and remove old devices
* [ ] Check **privacy & data collection** settings
* [ ] Review **connected apps & services** and remove unused ones
* [ ] Weekly or monthly: check **sign‑in activity** and alerts

> [!IMPORTANT]
> Your Microsoft Account is the anchor for your Windows device, OneDrive, Office 365, and more. If it’s weak, other protections can’t fully help.
> ([Microsoft Support][1])

---

### Step 1 — Enable Two‑step Verification

1. Go to your Microsoft account → **Security → Advanced security options**.
2. Under **Two‑step verification**, click **Turn on**. ([Microsoft Support][2])
3. Choose your primary verification method: Microsoft Authenticator app is recommended.
4. Set up backup methods: phone number and alternate email.
5. Save your recovery code in a safe location offline (USB or printout).

> [!TIP]
> Use an authenticator app or security key instead of SMS when possible—it reduces risk of SIM‑swap. ([Microsoft Support][3])

---

### Step 2 — Add & Verify Alternative Sign‑in Methods

1. Go to **Security info** page in your account. ([Microsoft Support][4])
2. Click **Add a new way to sign in or verify**.
3. Add at least **one phone number**, **one alternate email**, and if available, a **security key** (USB/NFC). ([Microsoft Support][5])
4. Confirm each method—enter the code sent to verify.
5. Remove any outdated or unused methods (old phone numbers, email addresses).

> [!WARNING]
> If you lose access to all your methods you may be locked out. Keep them current.

---

### Step 3 — Enable Passwordless Sign‑In (Optional but Recommended)

1. In the same **Advanced security options** page, look for **Passwordless account**. ([Microsoft Support][3])
2. Choose **Turn on**, then follow prompts: install the Microsoft Authenticator app, or add a security key, or enable Windows Hello.
3. Approve sign‑in via biometrics/PIN instead of password going forward.

> [!NOTE]
> Some older apps/devices may still need a password. Keep one method available for classic sign‑in. ([Microsoft Support][3])

---

### Step 4 — Review Trusted Devices & Remove Old Ones

1. Go to **Devices** section in your Microsoft account.
2. Identify devices you no longer use or recognise.
3. Select **Sign out** or **Remove device** for each unneeded item.
4. On your active devices, consider checking **“Don’t ask again on this device”** only if the device is private and secured. ([Microsoft Support][6])

---

### Step 5 — Review Privacy & Data‑Sharing Settings

1. Navigate to **Privacy → Privacy dashboard** in your Microsoft account. ([account.microsoft.com][7])
2. Adjust settings: limit diagnostic data, ad personalization, activity history.
3. Consider turning off syncing of unnecessary data across devices.
4. Check apps/services under **Apps & Services** and remove unused or unknown access.

---

### Step 6 — Connected Apps & Services

1. Go to **Security → More security options → Apps & services that use your account**.
2. Remove any app you no longer trust or need.
3. For each remaining, check what permissions they have (e.g., calendar, email, files).

---

### Step 7 — Maintenance Routine (Monthly)

* Check **Recent activity**: Security → **Review recent sign‑ins**.
* Remove any suspicious events.
* Verify your **backup methods**: phone, email, keys.
* Confirm you still have **access to your recovery code**.
* Ensure your authenticator app and security methods are still configured on all devices you use.
* Delete unused devices/applications from your Microsoft profile.

---

## Definitions / Terms

* **Two‑step verification (2SV)**: Requiring two forms of identity (password + verification method) to sign in. ([Microsoft Support][2])
* **Passwordless sign‑in**: Using biometric/PIN or security key instead of a traditional password. ([Microsoft Support][3])
* **Security info / verification methods**: Phone numbers, alternate emails, authenticator apps, security keys used to verify identity. ([Microsoft Support][4])
* **Trusted device**: A device you mark so Microsoft requires fewer verification prompts from it. ([Microsoft Support][6])
* **Advanced security options**: The Microsoft account dashboard where all these settings live.
* **Passkey**: A phishing‑resistant sign‑in method tied to your device/biometric instead of a password. ([TechRadar][8])

---

## Risks / Caveats

* If recovery methods (phone, email) are lost or access is revoked, your account may become unrecoverable.
* Turning off passwords but mis‑configuring passwords or backup methods may lock you out.
* Using SMS only for 2SV is weaker than authenticator apps or security keys (SIM‑swap risk).
* Passwordless sign‑in may not work with older devices/apps; keep fallback methods.
* Removing devices reduces risk—but if you remove your only signed‑in device, you may be forced to re‑authenticate fully.
* Apps/services with wide access can act like account takeover vectors—review periodically.

---

## Tools / Commands

* Visit **[https://account.microsoft.com/security](https://account.microsoft.com/security)** and **[https://account.microsoft.com/privacy](https://account.microsoft.com/privacy)** for all settings.
* Use **Microsoft Authenticator** app (iOS/Android) for verification or passwordless sign‑in.
* Use **sign‑in logs**: Security → **Recent activity** to review access.
* Security keys (USB/NFC) compatible with FIDO2 can be added under **Security key**. ([Microsoft Support][5])

---

## Metadata

**Source:** Microsoft Support documentation & community articles (links cited)
**Date:** 2025‑11‑03
**Tags:** Microsoft Account, 2‑step verification, passwordless sign‑in, account security, privacy settings
**Keywords (5‑10):** Microsoft Account, two‑step verification, passwordless, security key, authenticator app, trusted devices, privacy settings, recovery info

---

Ready to secure your account? Let’s get started—open your Microsoft account’s Security dashboard and tick off each step one by one.

[1]: https://support.microsoft.com/en-us/account-billing/how-to-help-keep-your-microsoft-account-secure-628538c2-7006-33bb-5ef4-c917657362b9?utm_source=chatgpt.com "How to help keep your Microsoft account secure"
[2]: https://support.microsoft.com/en-us/account-billing/how-to-use-two-step-verification-with-your-microsoft-account-c7910146-672f-01e9-50a0-93b4585e7eb4?utm_source=chatgpt.com "How to use two-step verification with your Microsoft account"
[3]: https://support.microsoft.com/en-us/account-billing/how-to-go-passwordless-with-your-microsoft-account-674ce301-3574-4387-a93d-916751764c43?utm_source=chatgpt.com "How to go passwordless with your Microsoft account"
[4]: https://support.microsoft.com/en-us/account-billing/microsoft-account-security-info-verification-codes-bf2505ca-cae5-c5b4-77d1-69d3343a5452?utm_source=chatgpt.com "Microsoft account security info & verification codes"
[5]: https://support.microsoft.com/en-us/topic/sign-in-to-your-account-with-a-security-key-b23a2a45-6ab8-4c86-9f22-bcadf60235aa?utm_source=chatgpt.com "Sign in to your account with a security key - Microsoft Support"
[6]: https://support.microsoft.com/en-us/account-billing/add-a-trusted-device-to-your-microsoft-account-fe3860c8-bc04-9770-e218-b4fd6b767f4b?utm_source=chatgpt.com "Add a trusted device to your Microsoft account"
[7]: https://account.microsoft.com/account/privacy?utm_source=chatgpt.com "Microsoft Account Privacy Settings"
[8]: https://www.techradar.com/computing/cyber-security/what-are-passkeys-in-microsoft-authenticator-how-to-set-them-up?utm_source=chatgpt.com "Microsoft is phasing out passwords soon - here's why passkeys are replacing them and what to do next"
