'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';

interface OffersTabProps {
  user: any;
  deviceId: string;
  onRefresh: () => void;
}

export function OffersTab({ user, deviceId, onRefresh }: OffersTabProps) {
  const [loading, setLoading] = useState(false);

  const offers = user?.offers || {};
  const promotions = user?.promotions || {};

  const handleResetOffers = async () => {
    if (!confirm('Reset all offers? User will see promotions again.')) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/reset-offers`, {
        method: 'POST',
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert('✅ All offers reset successfully!');
        onRefresh();
      } else {
        alert('❌ Failed: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('❌ Error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const offersList = [
    {
      name: '$1 Deal (First Purchase)',
      key: 'firstPurchase',
      description: '200E for $0.99 - Triggered at 10E spent',
      available: offers.firstPurchaseAvailable,
      claimed: offers.firstPurchaseClaimed,
      expiry: offers.firstPurchaseExpiry,
      claimedAt: offers.firstPurchaseClaimedAt,
    },
    {
      name: '40% Bonus (Welcome Bonus)',
      key: 'welcomeBonus',
      description: '40% extra energy - Shown 24hr after first purchase',
      available: offers.welcomeBonusAvailable,
      claimed: offers.welcomeBonusClaimed,
      expiry: offers.welcomeBonusExpiry,
      claimedAt: offers.welcomeBonusClaimedAt,
    },
    {
      name: 'Welcome Offer (V2 - Old)',
      key: 'welcomeOffer',
      description: 'Legacy welcome offer',
      available: false,
      claimed: promotions.welcomeOfferClaimed,
      expiry: null,
      claimedAt: null,
    },
  ];

  return (
    <div className="space-y-6">
      {/* Summary */}
      <div className="bg-gradient-to-br from-yellow-50 to-orange-50 rounded-lg p-4 border border-yellow-200">
        <h3 className="font-semibold mb-2">🎁 Offers & Promotions State</h3>
        <p className="text-sm text-gray-600">
          View and manage promotion visibility and purchase status for testing
        </p>
      </div>

      {/* Actions */}
      <div className="flex gap-2">
        <Button onClick={handleResetOffers} variant="outline" disabled={loading}>
          🔄 Reset All Offers
        </Button>
      </div>

      {/* Offers Table */}
      <div className="bg-white rounded-lg border overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="text-left p-3 text-sm font-semibold">Promotion</th>
              <th className="text-center p-3 text-sm font-semibold">Available?</th>
              <th className="text-center p-3 text-sm font-semibold">Purchased?</th>
              <th className="text-left p-3 text-sm font-semibold">Details</th>
            </tr>
          </thead>
          <tbody>
            {offersList.map((offer) => (
              <tr key={offer.key} className="border-b hover:bg-gray-50">
                <td className="p-3">
                  <p className="font-semibold">{offer.name}</p>
                  <p className="text-xs text-gray-600">{offer.description}</p>
                </td>
                <td className="text-center p-3">
                  {offer.available ? (
                    <span className="inline-block px-2 py-1 bg-green-100 text-green-700 rounded text-xs font-semibold">
                      ✅ Yes
                    </span>
                  ) : (
                    <span className="inline-block px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs">
                      ❌ No
                    </span>
                  )}
                </td>
                <td className="text-center p-3">
                  {offer.claimed ? (
                    <span className="inline-block px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-semibold">
                      ✅ Purchased
                    </span>
                  ) : (
                    <span className="inline-block px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs">
                      ❌ Not Purchased
                    </span>
                  )}
                </td>
                <td className="p-3 text-xs text-gray-600">
                  {offer.claimedAt && (
                    <div>
                      Purchased: {new Date(offer.claimedAt).toLocaleString()}
                    </div>
                  )}
                  {offer.expiry && (
                    <div>
                      Expires: {new Date(offer.expiry).toLocaleString()}
                    </div>
                  )}
                  {!offer.claimedAt && !offer.expiry && <div>-</div>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Tier Promotions */}
      <div className="bg-white rounded-lg p-4 border">
        <h3 className="font-semibold mb-3">🎯 Tier Promotions (V2 - Legacy)</h3>
        <div className="space-y-2">
          {Object.keys(promotions.tierPromoClaimed || {}).length === 0 ? (
            <p className="text-sm text-gray-500">No tier promotions claimed</p>
          ) : (
            Object.entries(promotions.tierPromoClaimed || {}).map(([tier, claimed]) => (
              <div key={tier} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                <span className="text-sm capitalize font-medium">{tier} Tier Promo</span>
                <span className={`text-sm ${claimed ? 'text-green-600' : 'text-gray-500'}`}>
                  {claimed ? '✅ Claimed' : '❌ Not Claimed'}
                </span>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Winback Offer */}
      {user?.winbackOfferAvailable && (
        <div className="bg-purple-50 rounded-lg p-4 border border-purple-200">
          <h3 className="font-semibold mb-2">🔙 Winback Offer</h3>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm">Ex-subscriber winback promotion</p>
              <p className="text-xs text-gray-600">
                Expires: {user.winbackOfferExpiry ? new Date(user.winbackOfferExpiry).toLocaleString() : 'N/A'}
              </p>
            </div>
            <span className="px-3 py-1 bg-purple-100 text-purple-700 rounded font-semibold text-sm">
              Active
            </span>
          </div>
        </div>
      )}

      {/* Testing Notes */}
      <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
        <h4 className="font-semibold mb-2">💡 Testing Notes</h4>
        <ul className="text-sm space-y-1 text-gray-700">
          <li>• Reset offers to test promotion flow again</li>
          <li>• First Purchase offer triggers at 10E total spent</li>
          <li>• Welcome Bonus shows 24 hours after first purchase</li>
          <li>• Check Energy History tab to simulate spending</li>
        </ul>
      </div>
    </div>
  );
}
