<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class NotificationService
{
    protected string $telegramToken;
    protected $messaging;

    public function __construct()
    {
        $this->telegramToken = config('services.telegram.bot_token', env('TELEGRAM_BOT_TOKEN'));
        
        try {
            $this->messaging = app('firebase.messaging');
        } catch (\Exception $e) {
            Log::warning("Firebase Messaging not initialized: " . $e->getMessage());
        }
    }

    /**
     * Send emergency notification via multiple channels
     */
    public function sendEmergencyAlert($user, $alert)
    {
        $contacts = $user->trustedContacts;
        
        foreach ($contacts as $contact) {
            // 1. Attempt Push (If contact has the app and a token)
            $targetUser = $contact->contactUser;
            if ($contact->notify_push && $targetUser && $targetUser->fcm_token) {
                $this->sendPush($targetUser->fcm_token, $user, $alert);
            }

            // 2. Attempt Telegram (If contact has connected telegram)
            if ($contact->notify_telegram && $contact->telegram_chat_id) {
                $this->sendTelegram($contact->telegram_chat_id, $user, $alert);
            }
        }
    }

    protected function sendPush($token, $user, $alert)
    {
        if (!$this->messaging) {
            Log::info("Push Placeholder (Firebase disabled): SOS from {$user->name}");
            return;
        }

        $title = "🚨 EMERGENCY: {$user->name} needs help!";
        $body = "Type: " . ucfirst($alert->alert_type) . ". Location: {$alert->latitude}, {$alert->longitude}";

        $notification = Notification::create($title, $body);
        $message = CloudMessage::withTarget('token', $token)
            ->withNotification($notification)
            ->withData([
                'type' => 'emergency',
                'alert_id' => (string) $alert->id,
                'user_name' => $user->name,
                'latitude' => (string) $alert->latitude,
                'longitude' => (string) $alert->longitude,
            ])
            ->withHighestPriority();

        try {
            $this->messaging->send($message);
            Log::info("FCM SOS Sent to device token.");
        } catch (\Exception $e) {
            Log::error("FCM Send Failed: " . $e->getMessage());
        }
    }
// ... rest of file (Telegram part)

    protected function sendTelegram($chatId, $user, $alert)
    {
        if (!$this->telegramToken) return;

        $message = "🆘 *ALERTA SOS*\n\n";
        $message .= "*Name:* {$user->name}\n";
        $message .= "*Type:* " . ucfirst($alert->alert_type) . "\n";
        $message .= "*Battery:* {$alert->battery_level}%\n";
        $message .= "*Location:* [View on Google Maps](https://www.google.com/maps/search/?api=1&query={$alert->latitude},{$alert->longitude})\n\n";
        $message .= "🚨 _This is a zero-cost automated alert from the Alerta Secure Mesh Network._";

        try {
            Http::post("https://api.telegram.org/bot{$this->telegramToken}/sendMessage", [
                'chat_id' => $chatId,
                'text' => $message,
                'parse_mode' => 'Markdown',
            ]);
            Log::info("Telegram SOS Sent to {$chatId}");
        } catch (\Exception $e) {
            Log::error("Telegram Send Failed: " . $e->getMessage());
        }
    }
}
