<?php
/**
 * Alerta Backend - Shared Hosting Installer
 * Visit this file in your browser to complete installation
 * Example: https://app.alertasecure.com/install.php
 */

// Security: Delete this file after installation!
define('INSTALL_PASSWORD', 'alerta2024install'); // Change this!

session_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);

$step = $_GET['step'] ?? 'start';
$errors = [];
$success = [];

// Check if Laravel is present - works from both root, public folder, or public folder with laravel in sibling
$baseDir = __DIR__;
if (file_exists($baseDir . '/artisan')) {
    // We are in the root
} elseif (file_exists(dirname($baseDir) . '/artisan')) {
    // We are in public/ and app is in root
    $baseDir = dirname($baseDir);
} elseif (file_exists(dirname($baseDir) . '/laravel/artisan')) {
    // We are in public_html/ and app is in ../laravel (Hostinger setup)
    $baseDir = dirname($baseDir) . '/laravel';
} else {
    // Default fallback
    $baseDir = dirname($baseDir);
}

if (!file_exists($baseDir . '/artisan')) {
    die('Error: Laravel files not found. Please upload all backend files first. Looking in: ' . $baseDir . ' and parent directories.');
}

// Load Laravel
require $baseDir . '/vendor/autoload.php';
$app = require_once $baseDir . '/bootstrap/app.php';

use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

?>
<!DOCTYPE html>
<html>
<head>
    <title>Alerta Backend Installer</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e4e4e7;
            padding: 2rem;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(26, 26, 46, 0.8);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(239, 68, 68, 0.2);
            border-radius: 12px;
            padding: 2rem;
        }
        h1 {
            color: #ef4444;
            margin-bottom: 1rem;
            font-size: 2rem;
        }
        h2 {
            color: #fff;
            margin: 1.5rem 0 1rem;
            font-size: 1.5rem;
        }
        .step {
            background: rgba(239, 68, 68, 0.1);
            padding: 1rem;
            border-radius: 8px;
            margin: 1rem 0;
            border-left: 4px solid #ef4444;
        }
        .success {
            background: rgba(34, 197, 94, 0.1);
            border-left-color: #22c55e;
            color: #22c55e;
        }
        .error {
            background: rgba(239, 68, 68, 0.2);
            border-left-color: #ef4444;
            color: #ef4444;
        }
        .btn {
            display: inline-block;
            padding: 1rem 2rem;
            background: #ef4444;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            font-size: 1rem;
            margin: 1rem 0.5rem 0 0;
        }
        .btn:hover {
            background: #dc2626;
        }
        input, textarea {
            width: 100%;
            padding: 0.75rem;
            margin: 0.5rem 0;
            background: rgba(26, 26, 46, 0.6);
            border: 1px solid rgba(239, 68, 68, 0.2);
            border-radius: 6px;
            color: #fff;
            font-size: 1rem;
        }
        label {
            display: block;
            margin-top: 1rem;
            color: #a1a1aa;
        }
        code {
            background: rgba(0, 0, 0, 0.3);
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            color: #22c55e;
        }
        pre {
            background: rgba(0, 0, 0, 0.3);
            padding: 1rem;
            border-radius: 6px;
            overflow-x: auto;
            margin: 1rem 0;
        }
        .checklist {
            list-style: none;
            padding-left: 0;
        }
        .checklist li {
            padding: 0.5rem 0;
            padding-left: 2rem;
            position: relative;
        }
        .checklist li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #22c55e;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🛡️ Alerta Backend Installer</h1>
        
        <?php if ($step === 'start'): ?>
            <h2>Welcome to the Installation Wizard</h2>
            <p>This installer will set up your Alerta backend in just a few clicks.</p>
            
            <div class="step">
                <h3>Pre-Installation Checklist:</h3>
                <ul class="checklist">
                    <li>All Laravel files uploaded to your hosting</li>
                    <li>.env file configured with database credentials</li>
                    <li>Database created in cPanel</li>
                    <li>Folder permissions set (storage & bootstrap/cache = 775)</li>
                </ul>
            </div>
            
            <form method="POST" action="?step=verify">
                <label>Installation Password (for security):</label>
                <input type="password" name="password" required placeholder="Enter: alerta2024install">
                
                <button type="submit" class="btn">Start Installation →</button>
            </form>
            
        <?php elseif ($step === 'verify' && $_SERVER['REQUEST_METHOD'] === 'POST'): ?>
            <?php
            if ($_POST['password'] !== INSTALL_PASSWORD) {
                echo '<div class="step error">❌ Incorrect password!</div>';
                echo '<a href="?" class="btn">← Go Back</a>';
                exit;
            }
            
            $_SESSION['authorized'] = true;
            ?>
            
            <h2>Step 1: Environment Check</h2>
            
            <?php
            // Check PHP version
            $phpVersion = PHP_VERSION;
            $phpOk = version_compare($phpVersion, '8.1.0', '>=');
            echo '<div class="step ' . ($phpOk ? 'success' : 'error') . '">';
            echo $phpOk ? '✓' : '✗';
            echo " PHP Version: $phpVersion " . ($phpOk ? '(OK)' : '(Need 8.1+)');
            echo '</div>';
            
            // Check .env file
            $envExists = file_exists(__DIR__ . '/.env');
            echo '<div class="step ' . ($envExists ? 'success' : 'error') . '">';
            echo $envExists ? '✓' : '✗';
            echo " .env file " . ($envExists ? 'found' : 'not found');
            echo '</div>';
            
            // Check database connection
            try {
                DB::connection()->getPdo();
                $dbOk = true;
                echo '<div class="step success">✓ Database connection successful</div>';
            } catch (\Exception $e) {
                $dbOk = false;
                echo '<div class="step error">✗ Database connection failed: ' . $e->getMessage() . '</div>';
            }
            
            // Check storage permissions
            $storageWritable = is_writable(__DIR__ . '/storage');
            echo '<div class="step ' . ($storageWritable ? 'success' : 'error') . '">';
            echo $storageWritable ? '✓' : '✗';
            echo " Storage folder " . ($storageWritable ? 'writable' : 'not writable - set to 775');
            echo '</div>';
            
            if ($phpOk && $envExists && $dbOk && $storageWritable) {
                echo '<a href="?step=install" class="btn">Continue to Installation →</a>';
            } else {
                echo '<div class="step error">Please fix the errors above before continuing.</div>';
                echo '<a href="?" class="btn">← Go Back</a>';
            }
            ?>
            
        <?php elseif ($step === 'install'): ?>
            <?php
            if (!isset($_SESSION['authorized'])) {
                header('Location: ?step=start');
                exit;
            }
            
            echo '<h2>Step 2: Running Installation</h2>';
            
            try {
                // Run migrations
                echo '<div class="step">Running database migrations...</div>';
                Artisan::call('migrate', ['--force' => true]);
                $output = Artisan::output();
                echo '<div class="step success">✓ Database tables created successfully</div>';
                echo '<pre>' . htmlspecialchars($output) . '</pre>';
                
                // Generate app key if not set
                if (empty(env('APP_KEY')) || env('APP_KEY') === 'base64:abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMN=') {
                    echo '<div class="step">Generating application key...</div>';
                    Artisan::call('key:generate', ['--force' => true]);
                    echo '<div class="step success">✓ Application key generated</div>';
                }
                
                // Cache config
                echo '<div class="step">Optimizing for production...</div>';
                Artisan::call('config:cache');
                Artisan::call('route:cache');
                Artisan::call('view:cache');
                echo '<div class="step success">✓ Application optimized</div>';
                
                echo '<div class="step success">🎉 Installation completed successfully!</div>';
                echo '<a href="?step=admin" class="btn">Create Admin User →</a>';
                
            } catch (\Exception $e) {
                echo '<div class="step error">Installation Error: ' . $e->getMessage() . '</div>';
                echo '<a href="?step=verify" class="btn">← Try Again</a>';
            }
            ?>
            
        <?php elseif ($step === 'admin'): ?>
            <?php
            if (!isset($_SESSION['authorized'])) {
                header('Location: ?step=start');
                exit;
            }
            ?>
            
            <h2>Step 3: Create Admin Account</h2>
            
            <?php if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create_admin'])): ?>
                <?php
                try {
                    $admin = User::create([
                        'name' => $_POST['admin_name'],
                        'email' => $_POST['admin_email'],
                        'phone' => $_POST['admin_phone'],
                        'password' => Hash::make($_POST['admin_password']),
                        'is_admin' => true,
                        'is_active' => true,
                        'subscription_tier' => 'premium',
                        'trial_started_at' => now(),
                    ]);
                    
                    echo '<div class="step success">✓ Admin account created successfully!</div>';
                    echo '<div class="step">';
                    echo '<strong>Login Credentials:</strong><br>';
                    echo 'Email: ' . htmlspecialchars($_POST['admin_email']) . '<br>';
                    echo 'Password: [Your chosen password]';
                    echo '</div>';
                    echo '<a href="/admin" class="btn">Go to Admin Panel →</a>';
                    echo '<a href="?step=complete" class="btn">Finish Installation →</a>';
                } catch (\Exception $e) {
                    echo '<div class="step error">Error creating admin: ' . $e->getMessage() . '</div>';
                }
                ?>
            <?php else: ?>
                <form method="POST">
                    <input type="hidden" name="create_admin" value="1">
                    
                    <label>Admin Name:</label>
                    <input type="text" name="admin_name" required value="Admin">
                    
                    <label>Admin Email:</label>
                    <input type="email" name="admin_email" required value="admin@alertasecure.com">
                    
                    <label>Admin Phone:</label>
                    <input type="tel" name="admin_phone" required value="08012345678">
                    
                    <label>Admin Password:</label>
                    <input type="password" name="admin_password" required placeholder="Choose a strong password">
                    
                    <button type="submit" class="btn">Create Admin Account</button>
                </form>
            <?php endif; ?>
            
        <?php elseif ($step === 'complete'): ?>
            <h2>🎉 Installation Complete!</h2>
            
            <div class="step success">
                <h3>Your Alerta backend is now ready!</h3>
            </div>
            
            <div class="step">
                <h3>Important URLs:</h3>
                <p><strong>API Base URL:</strong> <code><?php echo env('APP_URL'); ?>/api</code></p>
                <p><strong>Admin Panel:</strong> <code><?php echo env('APP_URL'); ?>/admin</code></p>
            </div>
            
            <div class="step">
                <h3>Next Steps:</h3>
                <ol style="padding-left: 2rem;">
                    <li>Test API: Visit <code><?php echo env('APP_URL'); ?>/api/user</code></li>
                    <li>Access Admin Panel: <code><?php echo env('APP_URL'); ?>/admin</code></li>
                    <li>Update mobile app with API URL</li>
                    <li><strong style="color: #ef4444;">DELETE install.php for security!</strong></li>
                </ol>
            </div>
            
            <div class="step error">
                <h3>⚠️ SECURITY WARNING</h3>
                <p>Delete <code>install.php</code> from your server NOW to prevent unauthorized access!</p>
            </div>
            
            <a href="/admin" class="btn">Go to Admin Panel</a>
            
        <?php endif; ?>
    </div>
</body>
</html>
