<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../../Assets/Viper-Logo_White.png">
  <source media="(prefers-color-scheme: light)" srcset="../../Assets/Viper-Logo_Black.png">
  <img src="../../Assets/Viper-Logo_Black.png" alt="Logo von V1P3R" width="200">
</picture>

# `Part 3` Proton Services Setup

This part explains **why we chose Proton** and how to configure a **secure, efficient workflow** across its core apps. Examples use **Proton Unlimited**; most steps also work with **Proton Plus** unless noted.

## Goal

By the end, you will

* Understand **Proton's** services and privacy model.
* Configure Proton for **safe, everyday use**.
* Apply **account security** and simple maintenance.
* Keep a **short checklist** to review settings over time.

<br>

# `Chapter I` Proton Mail

## `Step 1` Basic & Key Features

* **End‑to‑end encryption** messages are encrypted before they leave your device and stay encrypted at rest.
* **Tracker protection**blocks common tracking pixels/links and flags attempts.
* **Jurisdiction** based in Switzerland with strong privacy protections.
* **Ecosystem** works across devices; integrates with **Proton Calendar**; light/dark themes.

> [!TIP]
> If you're migrating, enable **forwarding** from your old inbox right after import so nothing is missed.

<!--// Responsive YouTube Embed //-->
<div style="position:relative;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:12px;">
  <iframe
    src="https://www.youtube-nocookie.com/embed/K2vzs6Q39Zc?modestbranding=1&rel=0"
    title="YouTube video player"
    loading="lazy"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
  ></iframe>
</div>

## `Step 2` Account Setup & Productivity

### Create your account

1. Go to **proton.me > Sign Up**.
2. Pick a plan (**Free** works to start).
3. Choose a **username** and a **strong, unique password**.
4. Complete any verification (CAPTCHA / email / SMS).

### Easy Switch (optional migration)

1. In Proton Mail, open **Easy Switch**.
2. Sign in to your old provider (Gmail/Yahoo/Outlook).
3. Select what to import (Mail/Contacts/Calendar).
4. *(Optional)* Turn on **Gmail forwarding** so new mail lands in Proton.

### Finish onboarding

* Set your **display name** (what recipients see).
* Choose a **theme** (light/dark).

### Organize with folders, labels, filters

* Folders: `Work`, `Personal`, `Projects`.
* Labels: `Urgent`, `To‑Review`.
* Example filter: **Settings > Filters > Add filter**
  Name: `Boss Emails` • Condition: **Sender is** `boss@example.com` • Actions: **Move to** `Work` + **Apply label** `Urgent`.

### Private search

* Use the search bar for sender/subject/keywords.
* To search message **content** privately, enable **Search message content** (local index in your browser).

### Speed up your flow

* **Keyboard shortcuts** (default on): `R` reply, `A` archive.
  Settings > Messages & composing > Keyboard shortcuts
* **Snooze** to resurface emails later.
* **Schedule send** to pick a send time (custom times on paid plans).
* *(Paid)* **Auto‑delete Spam/Trash**: Settings > Messages & composing > Messages.

> [!NOTE]
> Proton Mail + **Proton Calendar** keeps invites and events in sync.

<!--// Responsive YouTube Embed //-->
<div style="position:relative;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:12px;">
  <iframe
    src="https://www.youtube-nocookie.com/embed/K2vzs6Q39Zc?modestbranding=1&rel=0"
    title="YouTube video player"
    loading="lazy"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
  ></iframe>
</div>

## `Step 3` Aliases in Proton Mail

### What are aliases?

Additional addresses linked to your account so you can sign up for services without exposing your main address. You can route or disable them anytime.

### Types of aliases

1. **Plus aliases** (no setup) `username+keyword@proton.me` (e.g., `alex+shopping@proton.me`). Trace where an address leaked.
2. **Additional addresses** Settings > Identity & Addresses > **Add address**. Choose a new Proton address (or your custom domain), set a display name, **Save**.
3. **Hide‑my‑email aliases** *(max privacy)* Security Center > **Create an alias** to generate a random address. Toggle off if it starts receiving spam.

### Route and control with filters

Example: Send all mail to `work.eric@proton.me` into the `Work` folder.
Settings > Filters > Add filter > Condition: **To is** `work.eric@proton.me` > Action: **Move to** `Work`.

> [!TIP]
> Start simple: one **plus alias** for shopping and one **random alias** for higher‑risk sign‑ups, each with a routing filter.

<!--// Responsive YouTube Embed //-->
<div style="position:relative;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:12px;">
  <iframe
    src="https://www.youtube-nocookie.com/embed/--fVh73YWFA?modestbranding=1&rel=0"
    title="YouTube video player"
    loading="lazy"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
  ></iframe>
</div>

<br>

# `Chapter II` Proton Pass

## `Step 1` Basic & Key Features

* **End‑to‑end encryption** for logins, cards, notes, and more.
* **Strong, unique passwords** with generator + Autofill.
* **Hide‑my‑email aliases** for spam control and inbox privacy.
* **Cross‑device sync** (desktop, browser, iOS/Android); offline access on paid plans.
* **Open source & audited**; part of the Proton ecosystem.

> [!IMPORTANT]
> Protect your **Proton account** with **2FA** before importing sensitive data.

<!--// Responsive YouTube Embed //-->
<div style="position:relative;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:12px;">
  <iframe
    src="https://www.youtube-nocookie.com/embed/ZzqHm1PaTH0?modestbranding=1&rel=0"
    title="YouTube video player"
    loading="lazy"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
  ></iframe>
</div>

## `Step 2` Install & Access Everywhere

### Goal / What good looks like

* Proton Pass installed on your browser, desktop, and phone; Autofill works.

### Browser extension

1. Install **Proton Pass** from your browser's extension store.
2. Sign in; enable **Autofill**.

### Desktop app

1. Download the **Proton Pass** desktop app from proton.me.
2. Install and sign in (optional: OS unlock helpers/biometrics).

### Mobile app (iOS/Android)

* Install **Proton Pass** from your app store.
* Enable Autofill:
  **iOS**: Settings > Passwords > Autofill Passwords > **Proton Pass**
  **Android**: System > Passwords & autofill (or Accessibility) > **Proton Pass**

### Import / Export

* **Import** from LastPass/1Password/Bitwarden/Chrome/Firefox: export (CSV/JSON) > Proton Pass **Import** > upload.
* **Export** for backups; prefer **encrypted** formats when available.

> [!WARNING]
> CSV exports are plaintext; handle locally, delete securely after import, **never email**.

<!--// Responsive YouTube Embed //-->
<div style="position:relative;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:12px;">
  <iframe
    src="https://www.youtube-nocookie.com/embed/ZzqHm1PaTH0?modestbranding=1&rel=0"
    title="YouTube video player"
    loading="lazy"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
  ></iframe>
</div>

## `Step 3` Build Your Vault

* **Logins** Add item > Login; set site, username, generated password; **Save**; test Autofill.
* **Credit cards** Number, expiry, CVC (billing address) > **Save**; checkout Autofill.
* **Aliases** Generate a **random alias** for sign‑ups; disable if it leaks.
* **Secure notes** Licenses, recovery steps, onboarding checklists.
* **Identities** Name/address/phone for consistent form fills.

<!--// Responsive YouTube Embed //-->
<div style="position:relative;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:12px;">
  <iframe
    src="https://www.youtube-nocookie.com/embed/yHXu55OEWjc?modestbranding=1&rel=0"
    title="YouTube video player"
    loading="lazy"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
  ></iframe>
</div>

<br>

# `Chapter III` Proton Authenticator

## `Step 1` Basic & Key Features

### Context / Why

An authenticator adds a one‑time code to your password. If your password leaks, the code blocks sign‑in.

### Goal / What good looks like

* You know what the app does, where your codes live, and how you'll back them up.

### Key features

* **TOTP codes** change every 30 seconds and work offline.
* **Two devices** keep you safe if one is lost.
* **Encrypted sync** (optional) keeps codes in your Proton account.
* **App lock** (PIN, biometrics) protects the app.
* **Backup and export** give you a recovery path.
* **Recovery codes** from each site are your safety net.

### Choices & defaults

* **Default:** Proton Authenticator with **encrypted sync** and **app lock**.
* **Alternative:** **Offline only** (no sync). Add codes to **two devices** manually.
  *Trade‑off: higher control, more manual work.*

## `Step 2` Install & Migrate Codes

### Goal / What good looks like

* Authenticator installed on two devices; key accounts added; sign‑in tested.

### Steps / How

1. **Install** Proton Authenticator on your **phone**. Turn on **app lock** or **biometric**.
2. **Prepare a second device** (another phone or desktop app) and install there too.
3. **Add a high‑value account first**: Site > **Security > Two‑Factor** > **Authenticator app**; scan the **QR** with your phone; enter the **6‑digit code** to confirm.
4. **Add the same account to the second device**: scan the same QR during setup, or use the site's **view secret key** to add it manually.
5. **Migrate the rest**: if your old app offers **export**, import it; if not, **re‑scan** each service.
6. **Do not delete** the old authenticator entry yet. Keep it until you finish testing.

> [!WARNING]
> Don't remove the old app before you can sign in with the new codes on **both** devices.

### Verify

* Sign out of one account; sign in with **password + 6‑digit code**.
* Codes match and work on **both devices**.

<!--// Responsive YouTube Embed //-->
<div style="position:relative;padding-bottom:56.25%;height:0;overflow:hidden;border-radius:12px;">
  <iframe
    src="https://www.youtube-nocookie.com/embed/AabS3qmEeA4?modestbranding=1&rel=0"
    title="YouTube video player"
    loading="lazy"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
  ></iframe>
</div>

## `Step 3` Secure Sync, Backup & Recovery

### Goal / What good looks like

* Redundancy is in place; recovery works; you have a simple maintenance habit.

### Steps / How

1. **Enable sync** in Proton Authenticator if you chose the synced setup. If offline only, skip.
2. **Save recovery codes** for each site in a **secure note** or **printed copy** stored offline.
3. **Export an encrypted backup** from the authenticator after big changes.
4. **Remove stale entries** you no longer use.
5. **Set a quarterly reminder** to test codes on both devices and refresh backups.

> [!IMPORTANT]
> Keep recovery codes **outside** the authenticator and **separate** from your password manager.

> [!TIP]
> Start with email, cloud storage, banking, and social. These protect the rest.

### Verify

* Recovery codes are stored safely and reachable without the app.
* Encrypted backup exists and you know how to restore it.
* Both devices still show working codes.

### Proton vs Google

| **`Topic`**       | **`Proton Authenticator`**             | **`Google Authenticator`**                              |
| ----------------- | -------------------------------------- | ------------------------------------------------------- |
| **Sync & backup**     | Encrypted sync in your Proton account  | Sync with Google account; encryption defaults may vary  |
| **Encryption**        | End‑to‑end encryption for your secrets | Historically not E2E by default; check current settings |
| **Multi‑device**      | Easy to use on more than one device    | Works on multiple devices with account sync             |
| **Recovery & export** | Encrypted backup; export available     | Export via QR; account‑based restore helpful            |
| **Lock & privacy**    | App lock, biometrics, local‑only mode  | App lock available, wide ecosystem support              |

## Summary

You now have a secure Proton baseline: private email with aliases, a hardened password workflow with Proton Pass, and resilient 2FA with Proton Authenticator. Continue to the next part for deep‑dive setup of **Proton Drive** and **Proton Calendar**.

<!--// Checklist // -->
## Checklist

* [ ] **Proton account secured** strong, unique password in **Proton Pass** and **2FA** on with **Proton Authenticator**
* [ ] **Proton Mail ready** basic settings reviewed, folders/labels made, and at least one **alias** created (plus or random)
* [ ] **Proton Pass installed everywhere** browser extension + desktop/mobile; Autofill works; old passwords imported
* [ ] **Proton Authenticator set** codes on two devices (or encrypted sync enabled); recovery codes stored safely
* [ ] **Privacy settings reviewed** trackers blocked, minimal data sharing, sensible notifications across Proton apps
* [ ] **Simple maintenance plan** quarterly check of security settings, aliases, and backups
* [ ] **Baseline screenshots saved** Mail settings, Pass vault view, and Authenticator status for your report

<br>

---

> [⮝ **Go to the Next Part** ⮝](Part-4.md)

---

> [⮝ **Go to the Overview Page** ⮝](../)

---
