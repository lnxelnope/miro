'use client';

import { useState } from 'react';
import { Send, Users, User, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export default function NotificationsPage() {
  const [deviceId, setDeviceId] = useState('');
  const [miroId, setMiroId] = useState('');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [sendToAll, setSendToAll] = useState(false);
  const [isSending, setIsSending] = useState(false);
  const [result, setResult] = useState<{
    success: boolean;
    sent: number;
    failed: number;
    total: number;
    errors?: string[];
  } | null>(null);

  const handleSend = async () => {
    if (!title || !body) {
      alert('Please fill in title and body');
      return;
    }

    if (!sendToAll && !deviceId && !miroId) {
      alert('Please specify deviceId, miroId, or select "Send to All Users"');
      return;
    }

    if (sendToAll && !confirm('Are you sure you want to send this notification to ALL users?')) {
      return;
    }

    try {
      setIsSending(true);
      setResult(null);

      const response = await fetch('/api/notifications/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          deviceId: deviceId || undefined,
          miroId: miroId || undefined,
          title,
          body,
          sendToAll,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to send notification');
      }

      setResult(data);
      
      // Reset form if successful
      if (data.success) {
        setTitle('');
        setBody('');
        setDeviceId('');
        setMiroId('');
        setSendToAll(false);
      }
    } catch (error: any) {
      console.error('Send notification error:', error);
      setResult({
        success: false,
        sent: 0,
        failed: 0,
        total: 0,
        errors: [error.message],
      });
    } finally {
      setIsSending(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
            <Send className="w-8 h-8 text-blue-600" />
            Send Notification
          </h1>
          <p className="text-gray-600 mt-2">
            Send push notifications to specific users or all users
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Notification Details</CardTitle>
            <CardDescription>
              Fill in the notification content and select recipients
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Recipient Selection */}
            <div className="space-y-4">
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="sendToAll"
                  checked={sendToAll}
                  onChange={(e) => {
                    setSendToAll(e.target.checked);
                    if (e.target.checked) {
                      setDeviceId('');
                      setMiroId('');
                    }
                  }}
                  className="w-4 h-4 text-blue-600 rounded"
                />
                <Label htmlFor="sendToAll" className="flex items-center gap-2 cursor-pointer">
                  <Users className="w-5 h-5" />
                  <span className="font-medium">Send to All Users</span>
                </Label>
              </div>

              {!sendToAll && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="deviceId">Device ID (Optional)</Label>
                    <Input
                      id="deviceId"
                      placeholder="Enter device ID"
                      value={deviceId}
                      onChange={(e) => setDeviceId(e.target.value)}
                      disabled={isSending}
                    />
                  </div>
                  <div>
                    <Label htmlFor="miroId">MiRO ID (Optional)</Label>
                    <Input
                      id="miroId"
                      placeholder="Enter MiRO ID"
                      value={miroId}
                      onChange={(e) => setMiroId(e.target.value)}
                      disabled={isSending}
                    />
                  </div>
                </div>
              )}
            </div>

            {/* Notification Content */}
            <div className="space-y-4">
              <div>
                <Label htmlFor="title">Title *</Label>
                <Input
                  id="title"
                  placeholder="Notification title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  disabled={isSending}
                  required
                />
              </div>

              <div>
                <Label htmlFor="body">Message *</Label>
                <textarea
                  id="body"
                  placeholder="Notification message"
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  disabled={isSending}
                  required
                  rows={4}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>

            {/* Result Message */}
            {result && (
              <div
                className={`p-4 rounded-lg ${
                  result.success
                    ? 'bg-green-50 border border-green-200'
                    : 'bg-red-50 border border-red-200'
                }`}
              >
                <div className="flex items-start gap-3">
                  {result.success ? (
                    <AlertCircle className="w-5 h-5 text-green-600 mt-0.5" />
                  ) : (
                    <AlertCircle className="w-5 h-5 text-red-600 mt-0.5" />
                  )}
                  <div className="flex-1">
                    <p
                      className={`font-medium ${
                        result.success ? 'text-green-800' : 'text-red-800'
                      }`}
                    >
                      {result.success
                        ? `✅ Notification sent successfully!`
                        : '❌ Failed to send notification'}
                    </p>
                    {result.success && (
                      <div className="mt-2 text-sm text-green-700">
                        <p>Sent: {result.sent}</p>
                        <p>Failed: {result.failed}</p>
                        <p>Total: {result.total}</p>
                      </div>
                    )}
                    {result.errors && result.errors.length > 0 && (
                      <div className="mt-2 text-sm text-red-700">
                        <p className="font-medium">Errors:</p>
                        <ul className="list-disc list-inside mt-1">
                          {result.errors.slice(0, 5).map((error, idx) => (
                            <li key={idx}>{error}</li>
                          ))}
                          {result.errors.length > 5 && (
                            <li>... and {result.errors.length - 5} more errors</li>
                          )}
                        </ul>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Send Button */}
            <Button
              onClick={handleSend}
              disabled={isSending || !title || !body || (!sendToAll && !deviceId && !miroId)}
              className="w-full"
              size="lg"
            >
              {isSending ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Sending...
                </>
              ) : (
                <>
                  <Send className="w-5 h-5 mr-2" />
                  Send Notification
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* Quick Templates */}
        <Card className="mt-6">
          <CardHeader>
            <CardTitle>Quick Templates</CardTitle>
            <CardDescription>
              Click to use pre-filled notification templates
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <Button
                variant="outline"
                onClick={() => {
                  setTitle('🔥 Streak Reminder');
                  setBody('อย่าลืมเข้า MIRO วันนี้เพื่อรักษา streak ของคุณ!');
                }}
                disabled={isSending}
                className="justify-start"
              >
                Streak Reminder
              </Button>
              <Button
                variant="outline"
                onClick={() => {
                  setTitle('🎯 Challenge Update');
                  setBody('คุณใกล้จะทำ challenge สำเร็จแล้ว! ตรวจสอบความคืบหน้าของคุณ');
                }}
                disabled={isSending}
                className="justify-start"
              >
                Challenge Update
              </Button>
              <Button
                variant="outline"
                onClick={() => {
                  setTitle('💎 Tier Unlocked');
                  setBody('ยินดีด้วย! คุณได้ unlock tier ใหม่แล้ว ตรวจสอบรางวัลของคุณ');
                }}
                disabled={isSending}
                className="justify-start"
              >
                Tier Unlocked
              </Button>
              <Button
                variant="outline"
                onClick={() => {
                  setTitle('🎁 Special Offer');
                  setBody('มีข้อเสนอพิเศษสำหรับคุณ! เปิด app เพื่อดูรายละเอียด');
                }}
                disabled={isSending}
                className="justify-start"
              >
                Special Offer
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
