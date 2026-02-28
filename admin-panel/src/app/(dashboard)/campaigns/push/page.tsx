'use client';

import { useState, useEffect } from 'react';

interface CampaignHistory {
  id: string;
  title: string;
  body: string;
  targetSegment: string;
  sentCount: number;
  failedCount: number;
  totalTokens: number;
  createdAt: { seconds: number; nanoseconds: number };
  status: 'success' | 'partial' | 'failed';
}

interface SeasonalQuest {
  id: string;
  title: string;
  description: string;
  icon: string;
  scheduleType: 'fixed_date' | 'duration';
  startDate: string;
  endDate: string;
  durationDays: number;
  claimType: 'daily' | 'one_time';
  rewardPerClaim: number;
  status: 'active' | 'paused';
  createdAt: string;
}

export default function PushCampaignPage() {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [targetSegment, setTargetSegment] = useState('all');
  const [sending, setSending] = useState(false);
  const [result, setResult] = useState<{ sentCount?: number; failedCount?: number; error?: string } | null>(null);
  const [history, setHistory] = useState<CampaignHistory[]>([]);
  const [loadingHistory, setLoadingHistory] = useState(true);

  // ─── NEW: Tab state ───
  const [activeTab, setActiveTab] = useState<'push' | 'seasonal'>('push');

  // ─── NEW: Seasonal Quest state ───
  const [sqTitle, setSqTitle] = useState('');
  const [sqDescription, setSqDescription] = useState('');
  const [sqIcon, setSqIcon] = useState('🎁');
  const [sqScheduleType, setSqScheduleType] = useState<'fixed_date' | 'duration'>('duration');
  const [sqStartDate, setSqStartDate] = useState('');
  const [sqEndDate, setSqEndDate] = useState('');
  const [sqDurationDays, setSqDurationDays] = useState(7);
  const [sqClaimType, setSqClaimType] = useState<'daily' | 'one_time'>('daily');
  const [sqRewardPerClaim, setSqRewardPerClaim] = useState(2);
  const [sqCreating, setSqCreating] = useState(false);
  const [sqQuests, setSqQuests] = useState<SeasonalQuest[]>([]);
  const [sqLoading, setSqLoading] = useState(false);

  useEffect(() => {
    fetchHistory();
    fetchSeasonalQuests();
  }, []);

  async function fetchHistory() {
    setLoadingHistory(true);
    try {
      const response = await fetch('/api/campaigns/push/history');
      const data = await response.json();
      
      if (data.success) {
        setHistory(data.history || []);
      }
    } catch (error) {
      console.error('Error fetching campaign history:', error);
    } finally {
      setLoadingHistory(false);
    }
  }

  async function sendPushNotification() {
    if (!title.trim() || !body.trim()) {
      alert('Please fill in both title and body');
      return;
    }

    setSending(true);
    setResult(null);

    try {
      const response = await fetch('/api/campaigns/push', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title,
          body,
          targetSegment,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setResult({
          sentCount: data.sentCount,
          failedCount: data.failedCount,
        });
        // Clear form after successful send
        setTitle('');
        setBody('');
        // Refresh history
        fetchHistory();
      } else {
        setResult({
          error: data.error || 'Failed to send push notification',
        });
      }
    } catch (error: any) {
      setResult({
        error: error.message || 'Network error occurred',
      });
    } finally {
      setSending(false);
    }
  }

  // ─── NEW: Seasonal Quest functions ───
  async function fetchSeasonalQuests() {
    setSqLoading(true);
    try {
      const response = await fetch('/api/seasonal-quests');
      const data = await response.json();
      if (data.success) {
        setSqQuests(data.quests || []);
      }
    } catch (error) {
      console.error('Error fetching seasonal quests:', error);
    } finally {
      setSqLoading(false);
    }
  }

  async function createSeasonalQuest() {
    if (!sqTitle.trim()) {
      alert('Please enter a title');
      return;
    }
    setSqCreating(true);
    try {
      const response = await fetch('/api/seasonal-quests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: sqTitle,
          description: sqDescription,
          icon: sqIcon,
          scheduleType: sqScheduleType,
          startDate: sqScheduleType === 'fixed_date' ? sqStartDate : undefined,
          endDate: sqScheduleType === 'fixed_date' ? sqEndDate : undefined,
          durationDays: sqScheduleType === 'duration' ? sqDurationDays : undefined,
          claimType: sqClaimType,
          rewardPerClaim: sqRewardPerClaim,
        }),
      });
      const data = await response.json();
      if (data.success) {
        // Reset form
        setSqTitle('');
        setSqDescription('');
        setSqIcon('🎁');
        setSqDurationDays(7);
        setSqRewardPerClaim(2);
        fetchSeasonalQuests();
      } else {
        alert(data.error || 'Failed to create');
      }
    } catch (error) {
      console.error('Error creating seasonal quest:', error);
    } finally {
      setSqCreating(false);
    }
  }

  async function toggleQuestStatus(id: string, currentStatus: string) {
    const newStatus = currentStatus === 'active' ? 'paused' : 'active';
    try {
      await fetch(`/api/seasonal-quests/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus }),
      });
      fetchSeasonalQuests();
    } catch (error) {
      console.error('Error toggling quest status:', error);
    }
  }

  async function deleteQuest(id: string) {
    if (!confirm('Are you sure you want to delete this quest?')) return;
    try {
      await fetch(`/api/seasonal-quests/${id}`, { method: 'DELETE' });
      fetchSeasonalQuests();
    } catch (error) {
      console.error('Error deleting quest:', error);
    }
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Campaigns</h1>

      {/* ─── Tab Bar ─── */}
      <div className="flex border-b border-gray-200 mb-6">
        <button
          className={`px-4 py-2 font-medium border-b-2 transition-colors ${
            activeTab === 'push'
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
          onClick={() => setActiveTab('push')}
        >
          Push Notification
        </button>
        <button
          className={`px-4 py-2 font-medium border-b-2 transition-colors ${
            activeTab === 'seasonal'
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
          onClick={() => setActiveTab('seasonal')}
        >
          Seasonal Quests
        </button>
      </div>

      {/* ─── Push Notification Tab (ของเดิมทั้งหมด wrap ด้วย condition) ─── */}
      {activeTab === 'push' && (
        <div>

      <div className="max-w-2xl space-y-6">
        <div>
          <label className="block mb-2 font-medium">Title</label>
          <input
            type="text"
            className="border border-gray-300 rounded-lg p-2 w-full focus:outline-none focus:ring-2 focus:ring-blue-500"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g., 🎉 Flash Sale!"
            disabled={sending}
          />
        </div>

        <div>
          <label className="block mb-2 font-medium">Body</label>
          <textarea
            className="border border-gray-300 rounded-lg p-2 w-full focus:outline-none focus:ring-2 focus:ring-blue-500"
            rows={4}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder="e.g., Get 50% off all Energy packages for the next 24 hours!"
            disabled={sending}
          />
        </div>

        <div>
          <label className="block mb-2 font-medium">Target Segment</label>
          <select
            className="border border-gray-300 rounded-lg p-2 w-full focus:outline-none focus:ring-2 focus:ring-blue-500"
            value={targetSegment}
            onChange={(e) => setTargetSegment(e.target.value)}
            disabled={sending}
          >
            <option value="all">All Users</option>
            <option value="subscribers">Subscribers Only</option>
            <option value="non_subscribers">Non-Subscribers Only</option>
            <option value="bronze">Bronze Tier</option>
            <option value="silver">Silver Tier</option>
            <option value="gold">Gold Tier</option>
            <option value="diamond">Diamond Tier</option>
          </select>
        </div>

        <button
          className="bg-blue-500 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
          onClick={sendPushNotification}
          disabled={sending || !title.trim() || !body.trim()}
        >
          {sending ? 'Sending...' : 'Send Push Notification'}
        </button>

        {result && (
          <div
            className={`p-4 rounded-lg ${
              result.error
                ? 'bg-red-50 border border-red-200'
                : 'bg-green-50 border border-green-200'
            }`}
          >
            {result.error ? (
              <p className="text-red-800">
                <strong>Error:</strong> {result.error}
              </p>
            ) : (
              <div className="text-green-800">
                <p className="font-semibold mb-2">✅ Push notification sent successfully!</p>
                <p>Sent to: {result.sentCount?.toLocaleString()} users</p>
                {result.failedCount && result.failedCount > 0 && (
                  <p className="text-yellow-700 mt-1">
                    Failed: {result.failedCount} users
                  </p>
                )}
              </div>
            )}
          </div>
        )}

        <div className="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
          <p className="text-sm text-yellow-800">
            <strong>⚠️ Warning:</strong> Push notifications will be sent immediately to all users in the selected segment.
            Please double-check the message before sending.
          </p>
        </div>
      </div>

      {/* Campaign History */}
      <div className="mt-8">
        <h2 className="text-xl font-bold mb-4">Campaign History</h2>
        
        {loadingHistory ? (
          <div className="text-center py-8">Loading history...</div>
        ) : history.length === 0 ? (
          <div className="text-center py-8 text-gray-500">No campaigns sent yet</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full border border-gray-300">
              <thead>
                <tr className="bg-gray-100">
                  <th className="border border-gray-300 p-2 text-left">Date</th>
                  <th className="border border-gray-300 p-2 text-left">Title</th>
                  <th className="border border-gray-300 p-2 text-left">Target</th>
                  <th className="border border-gray-300 p-2 text-right">Sent</th>
                  <th className="border border-gray-300 p-2 text-right">Failed</th>
                  <th className="border border-gray-300 p-2 text-right">Status</th>
                </tr>
              </thead>
              <tbody>
                {history.map((campaign) => {
                  const date = new Date(campaign.createdAt.seconds * 1000);
                  return (
                    <tr key={campaign.id} className="hover:bg-gray-50">
                      <td className="border border-gray-300 p-2">
                        {date.toLocaleString()}
                      </td>
                      <td className="border border-gray-300 p-2">
                        <div className="font-medium">{campaign.title}</div>
                        <div className="text-sm text-gray-600">{campaign.body}</div>
                      </td>
                      <td className="border border-gray-300 p-2">
                        {campaign.targetSegment === 'all' ? 'All Users' :
                         campaign.targetSegment === 'subscribers' ? 'Subscribers' :
                         campaign.targetSegment === 'non_subscribers' ? 'Non-Subscribers' :
                         campaign.targetSegment.charAt(0).toUpperCase() + campaign.targetSegment.slice(1) + ' Tier'}
                      </td>
                      <td className="border border-gray-300 p-2 text-right">
                        {campaign.sentCount.toLocaleString()}
                      </td>
                      <td className="border border-gray-300 p-2 text-right">
                        {campaign.failedCount > 0 ? (
                          <span className="text-red-600">{campaign.failedCount.toLocaleString()}</span>
                        ) : (
                          <span className="text-gray-400">0</span>
                        )}
                      </td>
                      <td className="border border-gray-300 p-2 text-right">
                        <span
                          className={`px-2 py-1 rounded text-xs font-medium ${
                            campaign.status === 'success'
                              ? 'bg-green-100 text-green-800'
                              : campaign.status === 'partial'
                              ? 'bg-yellow-100 text-yellow-800'
                              : 'bg-red-100 text-red-800'
                          }`}
                        >
                          {campaign.status === 'success' ? '✅ Success' :
                           campaign.status === 'partial' ? '⚠️ Partial' :
                           '❌ Failed'}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
        </div>
      )}

      {/* ─── Seasonal Quests Tab ─── */}
      {activeTab === 'seasonal' && (
        <div>
          {/* Create Form */}
          <div className="max-w-2xl space-y-4 mb-8">
            <h2 className="text-xl font-bold">Create New Seasonal Quest</h2>

            {/* Title */}
            <div>
              <label className="block mb-1 font-medium text-sm">Title *</label>
              <input
                type="text"
                className="border border-gray-300 rounded-lg p-2 w-full"
                value={sqTitle}
                onChange={(e) => setSqTitle(e.target.value)}
                placeholder="e.g., Happy New Year 2027"
              />
            </div>

            {/* Description */}
            <div>
              <label className="block mb-1 font-medium text-sm">Description</label>
              <input
                type="text"
                className="border border-gray-300 rounded-lg p-2 w-full"
                value={sqDescription}
                onChange={(e) => setSqDescription(e.target.value)}
                placeholder="e.g., Celebrate with free energy!"
              />
            </div>

            {/* Icon */}
            <div>
              <label className="block mb-1 font-medium text-sm">Icon (emoji)</label>
              <input
                type="text"
                className="border border-gray-300 rounded-lg p-2 w-20"
                value={sqIcon}
                onChange={(e) => setSqIcon(e.target.value)}
                maxLength={4}
              />
            </div>

            {/* Schedule Type */}
            <div>
              <label className="block mb-1 font-medium text-sm">Schedule Type</label>
              <div className="flex gap-4">
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="scheduleType"
                    checked={sqScheduleType === 'fixed_date'}
                    onChange={() => setSqScheduleType('fixed_date')}
                  />
                  Fixed Date (pick start & end)
                </label>
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="scheduleType"
                    checked={sqScheduleType === 'duration'}
                    onChange={() => setSqScheduleType('duration')}
                  />
                  Duration (X days from now)
                </label>
              </div>
            </div>

            {/* Date inputs (conditional) */}
            {sqScheduleType === 'fixed_date' ? (
              <div className="flex gap-4">
                <div className="flex-1">
                  <label className="block mb-1 font-medium text-sm">Start Date</label>
                  <input
                    type="date"
                    className="border border-gray-300 rounded-lg p-2 w-full"
                    value={sqStartDate}
                    onChange={(e) => setSqStartDate(e.target.value)}
                  />
                </div>
                <div className="flex-1">
                  <label className="block mb-1 font-medium text-sm">End Date</label>
                  <input
                    type="date"
                    className="border border-gray-300 rounded-lg p-2 w-full"
                    value={sqEndDate}
                    onChange={(e) => setSqEndDate(e.target.value)}
                  />
                </div>
              </div>
            ) : (
              <div>
                <label className="block mb-1 font-medium text-sm">Duration (days)</label>
                <input
                  type="number"
                  className="border border-gray-300 rounded-lg p-2 w-32"
                  value={sqDurationDays}
                  onChange={(e) => setSqDurationDays(parseInt(e.target.value) || 1)}
                  min={1}
                  max={365}
                />
              </div>
            )}

            {/* Claim Type */}
            <div>
              <label className="block mb-1 font-medium text-sm">Claim Type</label>
              <div className="flex gap-4">
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="claimType"
                    checked={sqClaimType === 'daily'}
                    onChange={() => setSqClaimType('daily')}
                  />
                  Daily Claim (claim ได้ทุกวัน, ไม่ claim = หายไป)
                </label>
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="claimType"
                    checked={sqClaimType === 'one_time'}
                    onChange={() => setSqClaimType('one_time')}
                  />
                  One-Time Claim (claim ครั้งเดียวตลอด event)
                </label>
              </div>
            </div>

            {/* Reward */}
            <div>
              <label className="block mb-1 font-medium text-sm">Reward per Claim (Energy)</label>
              <input
                type="number"
                className="border border-gray-300 rounded-lg p-2 w-32"
                value={sqRewardPerClaim}
                onChange={(e) => setSqRewardPerClaim(parseInt(e.target.value) || 1)}
                min={1}
                max={100}
              />
            </div>

            {/* Create button */}
            <button
              className="bg-green-500 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-600 disabled:bg-gray-300 disabled:cursor-not-allowed"
              onClick={createSeasonalQuest}
              disabled={sqCreating || !sqTitle.trim()}
            >
              {sqCreating ? 'Creating...' : 'Create Quest'}
            </button>
          </div>

          {/* Quest List */}
          <div>
            <h2 className="text-xl font-bold mb-4">All Seasonal Quests</h2>
            {sqLoading ? (
              <div className="text-center py-8">Loading...</div>
            ) : sqQuests.length === 0 ? (
              <div className="text-center py-8 text-gray-500">No seasonal quests yet</div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full border border-gray-300">
                  <thead>
                    <tr className="bg-gray-100">
                      <th className="border border-gray-300 p-2 text-left">Icon</th>
                      <th className="border border-gray-300 p-2 text-left">Title</th>
                      <th className="border border-gray-300 p-2 text-left">Period</th>
                      <th className="border border-gray-300 p-2 text-left">Type</th>
                      <th className="border border-gray-300 p-2 text-right">Reward</th>
                      <th className="border border-gray-300 p-2 text-center">Status</th>
                      <th className="border border-gray-300 p-2 text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sqQuests.map((quest) => {
                      const isExpired = quest.endDate < new Date().toISOString().split('T')[0];
                      return (
                        <tr key={quest.id} className="hover:bg-gray-50">
                          <td className="border border-gray-300 p-2 text-2xl text-center">
                            {quest.icon}
                          </td>
                          <td className="border border-gray-300 p-2">
                            <div className="font-medium">{quest.title}</div>
                            {quest.description && (
                              <div className="text-sm text-gray-500">{quest.description}</div>
                            )}
                          </td>
                          <td className="border border-gray-300 p-2 text-sm">
                            {quest.startDate} → {quest.endDate}
                            <div className="text-xs text-gray-500">
                              ({quest.durationDays} days, {quest.scheduleType})
                            </div>
                          </td>
                          <td className="border border-gray-300 p-2">
                            {quest.claimType === 'daily' ? 'Daily' : 'One-Time'}
                          </td>
                          <td className="border border-gray-300 p-2 text-right">
                            {quest.rewardPerClaim}E
                            {quest.claimType === 'daily' && '/day'}
                          </td>
                          <td className="border border-gray-300 p-2 text-center">
                            <span
                              className={`px-2 py-1 rounded text-xs font-medium ${
                                isExpired
                                  ? 'bg-gray-100 text-gray-600'
                                  : quest.status === 'active'
                                  ? 'bg-green-100 text-green-800'
                                  : 'bg-yellow-100 text-yellow-800'
                              }`}
                            >
                              {isExpired ? 'Expired' : quest.status === 'active' ? 'Active' : 'Paused'}
                            </span>
                          </td>
                          <td className="border border-gray-300 p-2 text-center">
                            <div className="flex gap-2 justify-center">
                              {!isExpired && (
                                <button
                                  className="text-sm px-3 py-1 rounded bg-blue-100 text-blue-700 hover:bg-blue-200"
                                  onClick={() => toggleQuestStatus(quest.id, quest.status)}
                                >
                                  {quest.status === 'active' ? 'Pause' : 'Resume'}
                                </button>
                              )}
                              <button
                                className="text-sm px-3 py-1 rounded bg-red-100 text-red-700 hover:bg-red-200"
                                onClick={() => deleteQuest(quest.id)}
                              >
                                Delete
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
