# Alerta Backend - Laravel API

Complete Laravel backend and admin panel for the Alerta mobile security application.

## 📋 What's Included

### ✅ Completed Components

#### Database Layer (10 Tables)

- `users` - User accounts with subscription management
- `trusted_contacts` - Emergency contact management
- `panic_alerts` - SOS/Emergency alert tracking
- `threat_reports` - Community-reported threats
- `location_shares` - Live location sharing sessions
- `guardian_sessions` - Guardian Mode monitoring
- `vehicle_reports` - Transport vetting system
- `payment_transactions` - Paystack payment tracking
- `medical_ids` - User medical information
- `blackbox_recordings` - Cloud evidence storage

#### API Endpoints (7 Controllers)

- **Auth**: Register, Login (with duress PIN), Logout
- **Panic**: Trigger alerts, Resolve, View history
- **Contacts**: Full CRUD for trusted contacts
- **Threat Radar**: Nearby threats, Report submission, Verification
- **Location**: Start/stop/update location sharing
- **Subscription**: Status, Payment verification, History
- **Profile**: Update profile, password, duress PIN, medical ID

#### Admin Panel (3 Controllers)

- **Dashboard**: Statistics, active alerts, recent activity
- **Users**: Search, view, suspend/activate users
- **Alerts**: Monitor, filter, mark as false alarm

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd c:\Users\USER\Desktop\Alerta\alerta_backend
composer install
```

### 2. Configure Environment

```bash
# Copy .env.example to .env (already done)
# Edit .env and update:
# - Database credentials (DB_DATABASE, DB_USERNAME, DB_PASSWORD)
# - Paystack secret key (PAYSTACK_SECRET_KEY)
```

### 3. Generate Application Key

```bash
php artisan key:generate
```

### 4. Run Migrations

```bash
php artisan migrate
```

### 5. Create Admin User (Optional)

```bash
php artisan tinker
```

Then run:

```php
User::create([
    'name' => 'Admin',
    'email' => 'admin@alerta.ng',
    'phone' => '08012345678',
    'password' => bcrypt('admin123'),
    'is_admin' => true,
    'is_active' => true
]);
```

### 6. Start Development Server

```bash
php artisan serve
```

## 📡 API Base URL

```
http://localhost:8000/api
```

## 🔑 API Authentication

Uses Laravel Sanctum for token-based authentication.

### Register

```http
POST /api/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "0801234567",
  "password": "user1234",
  "duress_pin": "5678"
}
```

Response includes `token` for subsequent requests.

### Login

```http
POST /api/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "user1234"
}
```

Response includes `is_duress: true` if duress PIN was used.

### Authenticated Requests

```http
GET /api/user
Authorization: Bearer {your-token-here}
```

## 🛡️ Key Features

### Duress PIN Detection

Login endpoint detects if user used duress PIN and returns `is_duress: true` flag for silent alarm trigger.

### Subscription Management

- 7-day free trial for new users
- Automatic tier checking (free/premium)
- Payment verification with Paystack
- Subscription expiry tracking

### Geolocation Queries

Threat reports support nearby queries based on lat/lon coordinates.

### Community Verification

Threat reports auto-verify after 3 user confirmations.

## 🎨 Admin Panel

Access at: `http://localhost:8000/admin`

Features:

- Real-time statistics dashboard
- Active alert monitoring with map links
- User management (search, suspend, activate)
- Payments and revenue tracking

## 🔧 Next Steps

### For Mobile App Integration:

1. Update `lib/core/config/api_config.dart` in mobile app
2. Add API_BASE_URL constant: `http://your-server-ip:8000/api`
3. Update all service files to use HTTP requests instead of local storage
4. Test authentication flow
5. Test panic alert creation
6. Verify contact sync

### For Production Deployment:

1. Set up proper database (MySQL/PostgreSQL)
2. Configure HTTPS/SSL
3. Add Paystack webhook verification
4. Set up email/SMS for emergency notifications
5. Configure file storage for blackbox recordings (S3)
6. Add rate limiting and security headers
7. Set up proper logging and monitoring

## 📚 API Documentation

All endpoints are documented in `routes/api.php` with full method signatures in controllers.

## 🐛 Troubleshooting

If you encounter composer errors, you may need to:

1. Install Laravel manually: `composer global require laravel/installer`
2. Or use an existing Laravel installation

## 📝 Notes

- All PINs and passwords are hashed with bcrypt
- Location coordinates use decimal degrees (latitude, longitude)
- Payments are stored in kobo (1 NGN = 100 kobo)
- Soft deletes enabled on users table
- API returns JSON responses with proper HTTP status codes
