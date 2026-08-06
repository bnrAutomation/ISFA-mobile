# Device Authentication — Implementation Plan & Backend API Contract

This document is for the **backend team** to implement IAM endpoints and for **mobile** alignment. The Flutter app already sends the `device` object on login and includes a **Device re-registration** screen.

---

## Implementation plan (summary)

| Phase | Owner | Work |
|-------|--------|------|
| 1 | Backend | DB table `user_registered_device`, extend `POST /authenticate` with device validation |
| 2 | Backend | `POST /device-registration/request`, `GET /device-registration/status` |
| 3 | Mobile | ✅ Collect fingerprint, login payload, unauthorized dialog, re-registration UI |
| 4 | Backend | Admin API to approve/reject requests and reset device |
| 5 | QA | First login, same device, different device, approve request, PIN login |

### Login scenarios (backend)

| # | Condition | HTTP | Action |
|---|-----------|------|--------|
| 1 | Valid credentials, **no** registered device | `201` | Insert device row, return tokens |
| 2 | Valid credentials, fingerprint **matches** | `201` | Update `lastLoginAt`, return tokens |
| 3 | Valid credentials, fingerprint **mismatch** | `403` | `error: DEVICE_NOT_AUTHORIZED`, no token |

### Device fingerprint (server must recompute)

```
fingerprint = SHA256( deviceUniqueId + "|" + deviceBrand + "|" + deviceModel + "|" + appBundleId )
```

- **Android** `deviceUniqueId`: `Settings.Secure.ANDROID_ID` (sent as `androidInfo.id` from app)
- **iOS** `deviceUniqueId`: `identifierForVendor`
- **Do not** rely on IMEI for Android 10+ (optional field only)

---

## Base URL

```
{BASE_URL}/authentication-service/iam/api/v1
```

Example: `https://api.example.com/authentication-service/iam/api/v1`

---

## 1. Authenticate (existing — extended)

### URL

```
POST /authenticate
```

Full: `{BASE_URL}/authentication-service/iam/api/v1/authenticate`

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Content-Type` | Yes | `application/json` |
| `Device-Id` | Yes | Raw platform device ID (backward compatible) |
| `X-Device-Fingerprint` | Yes | SHA-256 hex fingerprint |
| `User-Agent` | No | Device display name |

### Request body

**Password login**

```json
{
  "username": "user@company.com",
  "password": "<sha256_hex_of_plain_password>",
  "userAgent": "Pixel 7_abc123deviceid",
  "device": {
    "platform": "android",
    "deviceUniqueId": "a1b2c3d4e5f67890",
    "deviceFingerprint": "8f434346648f6b96df89dda9015171780082c38d24baf80fa7651c83ee040fbc",
    "deviceModel": "Pixel 7",
    "deviceBrand": "google",
    "deviceName": "Pixel 7",
    "osVersion": "14",
    "appVersion": "1.0.39",
    "firebaseInstallationId": "optional-fid",
    "imei": null
  }
}
```

**PIN login** (same endpoint)

```json
{
  "username": "user@company.com",
  "pin": "1234",
  "userAgent": "Pixel 7_a1b2c3d4",
  "device": { }
}
```

### Success response — `201 Created`

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "optional",
  "expiresIn": 3600,
  "userId": "usr-12345",
  "deviceRegistered": true,
  "deviceRegistrationAction": "REGISTERED"
}
```

`deviceRegistrationAction` values:

| Value | Meaning |
|-------|---------|
| `REGISTERED` | First device bound on this login |
| `VERIFIED` | Existing device matched |
| `NONE` | Optional if you omit metadata |

### Error — wrong device — `403 Forbidden`

```json
{
  "error": "DEVICE_NOT_AUTHORIZED",
  "message": "You can only login using your registered device. Please use your authorized device or contact administrator."
}
```

Mobile shows blocking dialog; user may open **Request device change**.

### Other errors

| Status | Example |
|--------|---------|
| `401` | Invalid username/password/PIN |
| `400` | Missing `device` object |
| `500` | Server error |

---

## 2. Device re-registration request

User lost phone or needs a new authorized device. Credentials verify identity; admin approves before new fingerprint is bound.

### URL

```
POST /device-registration/request
```

Full: `{BASE_URL}/authentication-service/iam/api/v1/device-registration/request`

### Headers

Same as authenticate (`Device-Id`, `X-Device-Fingerprint`, `Content-Type`).

### Request body

```json
{
  "username": "user@company.com",
  "password": "<sha256_hex_of_plain_password>",
  "reason": "Company issued new handset; old device was lost.",
  "device": {
    "platform": "android",
    "deviceUniqueId": "new-device-id-xyz",
    "deviceFingerprint": "new-fingerprint-hex",
    "deviceModel": "SM-S911B",
    "deviceBrand": "samsung",
    "deviceName": "Samsung Galaxy S23",
    "osVersion": "14",
    "appVersion": "1.0.39"
  }
}
```

### Success — `201 Created`

```json
{
  "requestId": "drr-20260520-00042",
  "status": "PENDING",
  "message": "Device registration request submitted. Administrator approval required."
}
```

### Errors

| Status | Body |
|--------|------|
| `401` | Invalid credentials |
| `409` | Pending request already exists |
| `400` | Validation failed |

```json
{
  "error": "PENDING_REQUEST_EXISTS",
  "message": "A device change request is already pending for this user."
}
```

---

## 3. Device registration request status

### URL

```
GET /device-registration/status?username={username}
```

Full: `{BASE_URL}/authentication-service/iam/api/v1/device-registration/status?username=user@company.com`

### Success — `200 OK`

```json
{
  "requestId": "drr-20260520-00042",
  "status": "PENDING",
  "message": "Waiting for administrator approval.",
  "submittedAt": "2026-05-20T10:30:00Z",
  "reviewedAt": null
}
```

`status` enum: `PENDING` | `APPROVED` | `REJECTED` | `NONE` (no request)

When `APPROVED`, backend should replace `user_registered_device` row with the new `deviceFingerprint` from the request. User can then login from the new device.

### Errors

| Status | When |
|--------|------|
| `404` | Unknown username or no request |
| `401` | If you protect with auth |

---

## 4. Admin — approve device request (recommended)

### URL

```
POST /device-registration/{requestId}/approve
```

### Headers

`Authorization: Bearer <admin_token>`

### Request body

```json
{
  "adminComment": "Verified with HR ticket #4521"
}
```

### Success — `200 OK`

```json
{
  "requestId": "drr-20260520-00042",
  "status": "APPROVED",
  "message": "Device registered. User may login from the new device."
}
```

---

## 5. Admin — reject device request (recommended)

### URL

```
POST /device-registration/{requestId}/reject
```

### Request body

```json
{
  "adminComment": "User must return company asset first"
}
```

### Success — `200 OK`

```json
{
  "requestId": "drr-20260520-00042",
  "status": "REJECTED",
  "message": "Request rejected."
}
```

---

## 6. Admin — reset registered device (recommended)

Clears binding so **next successful login** auto-registers the current device.

### URL

```
POST /admin/users/{userId}/device/reset
```

### Success — `200 OK`

```json
{
  "userId": "usr-12345",
  "message": "Registered device cleared."
}
```

---

## Database schema (reference)

### `user_registered_device`

| Column | Type | Notes |
|--------|------|-------|
| `id` | UUID | PK |
| `user_id` | VARCHAR | FK, unique (one active device per user) |
| `device_fingerprint` | VARCHAR(64) | SHA-256 hex |
| `device_unique_id` | VARCHAR | ANDROID_ID / IDFV |
| `device_model` | VARCHAR | |
| `device_brand` | VARCHAR | |
| `device_name` | VARCHAR | |
| `platform` | VARCHAR | android / ios |
| `os_version` | VARCHAR | |
| `app_version` | VARCHAR | |
| `firebase_installation_id` | VARCHAR | nullable |
| `imei` | VARCHAR | nullable |
| `registered_at` | TIMESTAMP | |
| `last_login_at` | TIMESTAMP | |

### `device_registration_request`

| Column | Type | Notes |
|--------|------|-------|
| `id` | VARCHAR | requestId |
| `user_id` | VARCHAR | |
| `requested_fingerprint` | VARCHAR(64) | |
| `device_json` | JSONB | full device payload |
| `reason` | TEXT | |
| `status` | VARCHAR | PENDING/APPROVED/REJECTED |
| `admin_comment` | TEXT | nullable |
| `created_at` | TIMESTAMP | |
| `reviewed_at` | TIMESTAMP | nullable |

---

## Mobile app mapping

| Feature | Location |
|---------|----------|
| Device payload collection | `lib/utility/device_helper.dart` → `collectAuthDeviceInfo()` |
| Login API | `lib/module/login_module/login_repository.dart` |
| PIN login API | `lib/module/login_verify_module/pin_login_repository.dart` |
| Unauthorized dialog | `lib/module/device_registration_module/device_unauthorized_dialog.dart` |
| Re-registration screen | `lib/module/device_registration_module/device_registration_view.dart` |
| Route | `/device-registration` (`AppPaths.deviceRegistration`) |
| URL constants | `lib/utility/app_constants.dart` → `URLConstants` |

---

## Security notes

1. **Never issue tokens** when `DEVICE_NOT_AUTHORIZED`.
2. Recompute fingerprint on server; compare constant-time.
3. Rate-limit failed logins per username and per fingerprint.
4. Log audit events for mismatches and registration requests.
5. IMEI optional only; do not require on Android 10+.

---

## Testing checklist

- [ ] First login registers device and returns `201`
- [ ] Second login on same device returns `201`
- [ ] Login on different device returns `403` + `DEVICE_NOT_AUTHORIZED`
- [ ] PIN login enforces same rules
- [ ] Re-registration request creates `PENDING` row
- [ ] After admin `APPROVED`, login works on new device only
- [ ] After admin `reset`, next login on any device re-binds
