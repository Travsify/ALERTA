<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class CreateAdminCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:make-admin {email} {password?}';

    protected $description = 'Create or upgrade a user to administrator status';

    public function handle()
    {
        $email = $this->argument('email');
        $password = $this->argument('password');

        $user = \App\Models\User::where('email', $email)->first();

        if ($user) {
            $user->update(['is_admin' => true]);
            $this->info("User {$email} has been promoted to Admin.");
        } else {
            if (!$password) {
                $password = \Illuminate\Support\Str::random(12);
                $this->warn("No password provided. Generated: {$password}");
            }

            $user = \App\Models\User::create([
                'name' => 'Administrator',
                'email' => $email,
                'phone' => '0000000000', // Default placeholder
                'password' => \Illuminate\Support\Facades\Hash::make($password),
                'is_admin' => true,
                'is_active' => true,
            ]);

            $this->info("Admin user created successfully with email: {$email}");
        }

        return 0;
    }
}
