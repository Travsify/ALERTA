<?php

namespace App\Console\Commands;

use App\Models\PanicAlert;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class MonitorHeartbeats extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'alerts:monitor-heartbeats';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Monitor proactive alerts and escalate if heartbeats expire';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Checking for expired heartbeats...');

        $expiredAlerts = PanicAlert::where('status', 'pending_proactive')
            ->where('heartbeat_expires_at', '<', now())
            ->get();

        if ($expiredAlerts->isEmpty()) {
            $this->info('No expired heartbeats found.');
            return;
        }

        foreach ($expiredAlerts as $alert) {
            $this->info("Escalating alert #{$alert->id} for user #{$alert->user_id}");
            
            $alert->update([
                'status' => 'active',
                'is_proactive' => true,
                'triggered_at' => now(), // Update trigger time to now for real-time tracking
            ]);

            // Trigger notifications
            try {
                (new NotificationService())->sendEmergencyAlert($alert->user, $alert);
                Log::info("Auto-escalated Proactive Alert #{$alert->id} for user {$alert->user->name}");
            } catch (\Exception $e) {
                Log::error("Failed to notify for escalated alert #{$alert->id}: " . $e->getMessage());
            }
        }

        $this->info('Done.');
    }
}
