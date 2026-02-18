# HOSTINGER INSTALLATION - READ ME FIRST!

## Quick Steps:

1. **Rename** this folder from `alerta_backend` to `laravel`

2. **Upload** the `laravel` folder to your hosting ROOT (same level as public_html)

3. **Upload** everything inside `public/` folder to your `public_html/` folder

4. **Visit** https://alertasecure.com/install.php

See HOSTINGER_INSTALL.md for detailed instructions.

---

## File Structure After Upload:

```
/ (root directory)
├── laravel/              ← This whole folder
└── public_html/          ← Contents of public/ go here
    ├── index.php
    ├── install.php
    └── .htaccess
```

The index.php is already configured to point to ../laravel/
