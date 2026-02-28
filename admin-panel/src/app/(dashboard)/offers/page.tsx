'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import {
  Plus,
  Edit,
  Trash2,
  Power,
  PowerOff,
  Copy,
  Gift,
  Percent,
  Zap,
  CreditCard,
  Clock,
  TrendingUp,
  Eye,
  ChevronDown,
  ChevronUp,
  LayoutGrid,
  List,
} from 'lucide-react';

interface OfferTemplate {
  id: string;
  slug: string;
  triggerEvent: string;
  triggerCondition: Record<string, any>;
  title: { en: string; th: string };
  description: { en: string; th: string };
  ctaText: { en: string; th: string };
  icon: string;
  rewardType: string;
  rewardConfig: Record<string, any>;
  expiresAfterHours: number | null;
  priority: number;
  maxClaimsPerUser: number;
  isActive: boolean;
  createdAt: string | null;
  updatedAt: string | null;
}

const ENERGY_PRODUCTS: Record<string, { name: string; energy: number; price: string }> = {
  energy_100: { name: 'Starter Kick', energy: 100, price: '$0.99' },
  energy_550: { name: 'Value Pack', energy: 550, price: '$4.99' },
  energy_1200: { name: 'Power User', energy: 1200, price: '$7.99' },
  energy_2000: { name: 'Ultimate Saver', energy: 2000, price: '$9.99' },
  energy_first_purchase_200: { name: 'Starter Deal', energy: 200, price: '$0.99' },
};

const REWARD_TYPE_CONFIG: Record<string, { label: string; color: string; bgColor: string; icon: any }> = {
  special_product: { label: 'Special Product', color: 'text-orange-700', bgColor: 'bg-orange-50 border-orange-200', icon: CreditCard },
  bonus_rate: { label: 'Bonus Rate', color: 'text-purple-700', bgColor: 'bg-purple-50 border-purple-200', icon: Percent },
  free_energy: { label: 'Free Energy', color: 'text-green-700', bgColor: 'bg-green-50 border-green-200', icon: Zap },
  subscription_deal: { label: 'Sub Deal', color: 'text-blue-700', bgColor: 'bg-blue-50 border-blue-200', icon: Gift },
};

const TRIGGER_LABELS: Record<string, string> = {
  first_energy_use: 'First Energy Use',
  energy_use_milestone: 'Energy Milestone',
  tier_up: 'Tier Up',
  first_app_open: 'First App Open',
  meals_logged_milestone: 'Meals Milestone',
  first_purchase_complete: 'After Purchase',
};

export default function OffersPage() {
  const router = useRouter();
  const [offers, setOffers] = useState<OfferTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [toggling, setToggling] = useState<string | null>(null);
  const [deleting, setDeleting] = useState<string | null>(null);
  const [duplicating, setDuplicating] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'cards' | 'table'>('cards');
  const [expandedPreview, setExpandedPreview] = useState<string | null>(null);
  const [filterRewardType, setFilterRewardType] = useState<string>('all');
  const [filterActive, setFilterActive] = useState<string>('all');

  useEffect(() => {
    fetchOffers();
  }, []);

  async function fetchOffers() {
    setLoading(true);
    try {
      const response = await fetch('/api/offers');
      const data = await response.json();
      if (data.success) {
        setOffers(data.offers || []);
      }
    } catch (error) {
      console.error('Error fetching offers:', error);
    } finally {
      setLoading(false);
    }
  }

  async function toggleActive(id: string, currentStatus: boolean) {
    setToggling(id);
    try {
      const response = await fetch(`/api/offers/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive: !currentStatus }),
      });
      const data = await response.json();
      if (data.success) {
        await fetchOffers();
      } else {
        alert(`Error: ${data.error}`);
      }
    } catch (error) {
      console.error('Error toggling offer:', error);
      alert('Failed to toggle offer');
    } finally {
      setToggling(null);
    }
  }

  async function handleDelete(id: string, slug: string) {
    if (!confirm(`Delete offer template "${slug}"? Users who already have this offer will keep it until expiry.`)) {
      return;
    }

    setDeleting(id);
    try {
      const response = await fetch(`/api/offers/${id}`, { method: 'DELETE' });
      const data = await response.json();
      if (data.success) {
        await fetchOffers();
      } else {
        alert(`Error: ${data.error}`);
      }
    } catch (error) {
      console.error('Error deleting offer:', error);
      alert('Failed to delete offer');
    } finally {
      setDeleting(null);
    }
  }

  async function handleDuplicate(offer: OfferTemplate) {
    setDuplicating(offer.id);
    try {
      const { id, createdAt, updatedAt, ...rest } = offer;
      const newSlug = `${rest.slug}_copy_${Date.now().toString(36)}`;
      const response = await fetch('/api/offers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...rest, slug: newSlug, isActive: false }),
      });
      const data = await response.json();
      if (data.success) {
        await fetchOffers();
      } else {
        alert(`Error: ${data.error}`);
      }
    } catch (error) {
      console.error('Error duplicating offer:', error);
      alert('Failed to duplicate offer');
    } finally {
      setDuplicating(null);
    }
  }

  function formatTrigger(offer: OfferTemplate): string {
    const { triggerEvent, triggerCondition } = offer;
    const base = TRIGGER_LABELS[triggerEvent] || triggerEvent;
    if (triggerEvent === 'energy_use_milestone' && triggerCondition?.minTotalSpent) {
      return `${base} (${triggerCondition.minTotalSpent}E)`;
    }
    if (triggerEvent === 'tier_up' && triggerCondition?.tier) {
      return `${base} → ${triggerCondition.tier}`;
    }
    if (triggerEvent === 'meals_logged_milestone' && triggerCondition?.minMealsLogged) {
      return `${base} (${triggerCondition.minMealsLogged})`;
    }
    if (triggerEvent === 'first_purchase_complete' && triggerCondition?.afterProductId) {
      return `${base}: ${triggerCondition.afterProductId}`;
    }
    return base;
  }

  function formatReward(offer: OfferTemplate): string {
    const { rewardType, rewardConfig } = offer;
    if (rewardType === 'special_product') {
      return `$${rewardConfig.displayPrice || '?'} → ${rewardConfig.energyAmount || '?'}E`;
    }
    if (rewardType === 'bonus_rate') {
      return `+${Math.round((rewardConfig.bonusRate || 0) * 100)}% Bonus`;
    }
    if (rewardType === 'free_energy') {
      return `${rewardConfig.amount || '?'}E Free`;
    }
    if (rewardType === 'subscription_deal') {
      return `Sub: ${rewardConfig.offerId || '?'}`;
    }
    return rewardType;
  }

  function formatDuration(offer: OfferTemplate): string {
    if (offer.expiresAfterHours === null || offer.expiresAfterHours === undefined) {
      return 'Never expires';
    }
    if (offer.expiresAfterHours < 24) {
      return `${offer.expiresAfterHours}h`;
    }
    const days = Math.round(offer.expiresAfterHours / 24);
    return `${days} day${days > 1 ? 's' : ''}`;
  }

  const filteredOffers = offers.filter((o) => {
    if (filterRewardType !== 'all' && o.rewardType !== filterRewardType) return false;
    if (filterActive === 'active' && !o.isActive) return false;
    if (filterActive === 'inactive' && o.isActive) return false;
    return true;
  });

  const stats = {
    total: offers.length,
    active: offers.filter((o) => o.isActive).length,
    bonusRate: offers.filter((o) => o.rewardType === 'bonus_rate').length,
    specialProduct: offers.filter((o) => o.rewardType === 'special_product').length,
    freeEnergy: offers.filter((o) => o.rewardType === 'free_energy').length,
  };

  return (
    <div className="p-8 max-w-[1400px] mx-auto">
      {/* Header */}
      <div className="flex justify-between items-start mb-8">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-3">
            <span className="bg-gradient-to-r from-purple-600 to-blue-600 text-transparent bg-clip-text">
              Offer Templates
            </span>
          </h1>
          <p className="text-gray-500 mt-1">
            Manage dynamic offers shown to users in the Energy Store
          </p>
        </div>
        <Button
          onClick={() => router.push('/offers/create')}
          className="bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700"
        >
          <Plus className="w-4 h-4 mr-2" />
          Create Offer
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
        <StatCard label="Total" value={stats.total} color="gray" />
        <StatCard label="Active" value={stats.active} color="green" />
        <StatCard label="Bonus Rate" value={stats.bonusRate} color="purple" />
        <StatCard label="Special Product" value={stats.specialProduct} color="orange" />
        <StatCard label="Free Energy" value={stats.freeEnergy} color="emerald" />
      </div>

      {/* Filters + View Toggle */}
      <div className="flex flex-wrap items-center justify-between gap-4 mb-6">
        <div className="flex items-center gap-3">
          <select
            value={filterRewardType}
            onChange={(e) => setFilterRewardType(e.target.value)}
            className="h-9 rounded-lg border border-gray-200 bg-white px-3 text-sm shadow-sm"
          >
            <option value="all">All Types</option>
            <option value="bonus_rate">Bonus Rate</option>
            <option value="special_product">Special Product</option>
            <option value="free_energy">Free Energy</option>
            <option value="subscription_deal">Subscription Deal</option>
          </select>

          <select
            value={filterActive}
            onChange={(e) => setFilterActive(e.target.value)}
            className="h-9 rounded-lg border border-gray-200 bg-white px-3 text-sm shadow-sm"
          >
            <option value="all">All Status</option>
            <option value="active">Active Only</option>
            <option value="inactive">Inactive Only</option>
          </select>

          <span className="text-sm text-gray-500">
            {filteredOffers.length} of {offers.length} offers
          </span>
        </div>

        <div className="flex items-center gap-1 bg-gray-100 rounded-lg p-1">
          <button
            onClick={() => setViewMode('cards')}
            className={`p-2 rounded-md transition ${viewMode === 'cards' ? 'bg-white shadow-sm' : 'hover:bg-gray-200'}`}
          >
            <LayoutGrid className="w-4 h-4" />
          </button>
          <button
            onClick={() => setViewMode('table')}
            className={`p-2 rounded-md transition ${viewMode === 'table' ? 'bg-white shadow-sm' : 'hover:bg-gray-200'}`}
          >
            <List className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <div className="bg-white rounded-xl shadow-sm border p-12 text-center">
          <div className="animate-spin w-8 h-8 border-4 border-purple-200 border-t-purple-600 rounded-full mx-auto" />
          <p className="mt-4 text-gray-500">Loading offers...</p>
        </div>
      ) : filteredOffers.length === 0 ? (
        <div className="bg-white rounded-xl shadow-sm border p-12 text-center">
          <Gift className="w-12 h-12 text-gray-300 mx-auto" />
          <p className="text-gray-500 mt-4">No offers found</p>
          <Button
            onClick={() => router.push('/offers/create')}
            variant="outline"
            className="mt-4"
          >
            <Plus className="w-4 h-4 mr-2" />
            Create your first offer
          </Button>
        </div>
      ) : viewMode === 'cards' ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {filteredOffers.map((offer) => (
            <OfferCard
              key={offer.id}
              offer={offer}
              isExpanded={expandedPreview === offer.id}
              onToggleExpand={() =>
                setExpandedPreview(expandedPreview === offer.id ? null : offer.id)
              }
              onEdit={() => router.push(`/offers/${offer.id}/edit`)}
              onToggle={() => toggleActive(offer.id, offer.isActive)}
              onDuplicate={() => handleDuplicate(offer)}
              onDelete={() => handleDelete(offer.id, offer.slug)}
              isToggling={toggling === offer.id}
              isDuplicating={duplicating === offer.id}
              isDeleting={deleting === offer.id}
              formatTrigger={formatTrigger}
              formatReward={formatReward}
              formatDuration={formatDuration}
            />
          ))}
        </div>
      ) : (
        <TableView
          offers={filteredOffers}
          toggling={toggling}
          deleting={deleting}
          duplicating={duplicating}
          onEdit={(id) => router.push(`/offers/${id}/edit`)}
          onToggle={toggleActive}
          onDuplicate={handleDuplicate}
          onDelete={handleDelete}
          formatTrigger={formatTrigger}
          formatReward={formatReward}
          formatDuration={formatDuration}
        />
      )}
    </div>
  );
}

function StatCard({ label, value, color }: { label: string; value: number; color: string }) {
  const colorMap: Record<string, string> = {
    gray: 'bg-gray-50 border-gray-200 text-gray-700',
    green: 'bg-green-50 border-green-200 text-green-700',
    purple: 'bg-purple-50 border-purple-200 text-purple-700',
    orange: 'bg-orange-50 border-orange-200 text-orange-700',
    emerald: 'bg-emerald-50 border-emerald-200 text-emerald-700',
  };
  return (
    <div className={`rounded-xl border p-4 ${colorMap[color] || colorMap.gray}`}>
      <div className="text-2xl font-bold">{value}</div>
      <div className="text-sm opacity-80">{label}</div>
    </div>
  );
}

function OfferCard({
  offer,
  isExpanded,
  onToggleExpand,
  onEdit,
  onToggle,
  onDuplicate,
  onDelete,
  isToggling,
  isDuplicating,
  isDeleting,
  formatTrigger,
  formatReward,
  formatDuration,
}: {
  offer: OfferTemplate;
  isExpanded: boolean;
  onToggleExpand: () => void;
  onEdit: () => void;
  onToggle: () => void;
  onDuplicate: () => void;
  onDelete: () => void;
  isToggling: boolean;
  isDuplicating: boolean;
  isDeleting: boolean;
  formatTrigger: (o: OfferTemplate) => string;
  formatReward: (o: OfferTemplate) => string;
  formatDuration: (o: OfferTemplate) => string;
}) {
  const rtConfig = REWARD_TYPE_CONFIG[offer.rewardType] || REWARD_TYPE_CONFIG.bonus_rate;
  const RewardIcon = rtConfig.icon;

  return (
    <div
      className={`bg-white rounded-xl shadow-sm border overflow-hidden transition-all ${
        !offer.isActive ? 'opacity-60' : ''
      }`}
    >
      {/* Card Header */}
      <div className="p-5">
        <div className="flex items-start justify-between mb-3">
          <div className="flex items-center gap-3">
            <span className="text-2xl">{offer.icon}</span>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-semibold text-lg">{offer.title.en || offer.slug}</h3>
                <span className="text-xs text-gray-400 font-mono">#{offer.priority}</span>
              </div>
              <p className="text-sm text-gray-500 font-mono">{offer.slug}</p>
            </div>
          </div>
          <button
            onClick={onToggle}
            disabled={isToggling}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold transition ${
              offer.isActive
                ? 'bg-green-100 text-green-700 hover:bg-green-200'
                : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
            }`}
          >
            {isToggling ? '...' : offer.isActive ? 'ACTIVE' : 'OFF'}
          </button>
        </div>

        {/* Info Grid */}
        <div className="grid grid-cols-3 gap-3 mb-4">
          {/* Reward Type Badge */}
          <div className={`rounded-lg border p-3 ${rtConfig.bgColor}`}>
            <div className="flex items-center gap-1.5 mb-1">
              <RewardIcon className={`w-3.5 h-3.5 ${rtConfig.color}`} />
              <span className={`text-xs font-medium ${rtConfig.color}`}>{rtConfig.label}</span>
            </div>
            <div className={`text-sm font-bold ${rtConfig.color}`}>{formatReward(offer)}</div>
          </div>

          {/* Trigger */}
          <div className="rounded-lg border border-gray-200 bg-gray-50 p-3">
            <div className="flex items-center gap-1.5 mb-1">
              <TrendingUp className="w-3.5 h-3.5 text-gray-500" />
              <span className="text-xs font-medium text-gray-500">Trigger</span>
            </div>
            <div className="text-sm font-semibold text-gray-700 truncate">{formatTrigger(offer)}</div>
          </div>

          {/* Duration */}
          <div className="rounded-lg border border-gray-200 bg-gray-50 p-3">
            <div className="flex items-center gap-1.5 mb-1">
              <Clock className="w-3.5 h-3.5 text-gray-500" />
              <span className="text-xs font-medium text-gray-500">Duration</span>
            </div>
            <div className="text-sm font-semibold text-gray-700">{formatDuration(offer)}</div>
          </div>
        </div>

        {/* Bonus Rate Impact Preview */}
        {offer.rewardType === 'bonus_rate' && offer.rewardConfig?.bonusRate > 0 && (
          <div className="mb-4">
            <button
              onClick={onToggleExpand}
              className="flex items-center gap-1.5 text-sm text-purple-600 hover:text-purple-800 font-medium"
            >
              <Eye className="w-4 h-4" />
              Impact Preview
              {isExpanded ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
            </button>

            {isExpanded && (
              <div className="mt-3 bg-gradient-to-br from-purple-50 to-blue-50 rounded-lg border border-purple-200 p-4">
                <p className="text-xs text-purple-600 font-medium mb-3">
                  +{Math.round(offer.rewardConfig.bonusRate * 100)}% bonus applied to all IAP packages:
                </p>
                <div className="space-y-2">
                  {Object.entries(ENERGY_PRODUCTS)
                    .filter(([pid]) => !pid.includes('first_purchase') && !pid.includes('welcome'))
                    .map(([productId, product]) => {
                      const bonus = Math.floor(product.energy * offer.rewardConfig.bonusRate);
                      const total = product.energy + bonus;
                      return (
                        <div
                          key={productId}
                          className="flex items-center justify-between bg-white rounded-lg px-3 py-2 border border-purple-100"
                        >
                          <div className="flex items-center gap-2">
                            <span className="text-sm font-medium text-gray-700">{product.name}</span>
                            <span className="text-xs text-gray-400">{product.price}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className="text-sm text-gray-400 line-through">{product.energy}E</span>
                            <span className="text-sm font-bold text-purple-700">{total}E</span>
                            <span className="text-xs bg-purple-100 text-purple-700 px-1.5 py-0.5 rounded font-medium">
                              +{bonus}
                            </span>
                          </div>
                        </div>
                      );
                    })}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Description */}
        {offer.description.en && (
          <p className="text-sm text-gray-500 mb-4 line-clamp-2">{offer.description.en}</p>
        )}

        {/* Actions */}
        <div className="flex items-center gap-2 pt-2 border-t border-gray-100">
          <Button
            variant="outline"
            size="sm"
            onClick={onEdit}
            className="text-blue-600 border-blue-200 hover:bg-blue-50"
          >
            <Edit className="w-3.5 h-3.5 mr-1.5" />
            Edit
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={onDuplicate}
            disabled={isDuplicating}
            className="text-purple-600 border-purple-200 hover:bg-purple-50"
          >
            {isDuplicating ? '...' : <><Copy className="w-3.5 h-3.5 mr-1.5" />Duplicate</>}
          </Button>
          <div className="flex-1" />
          <Button
            variant="outline"
            size="sm"
            onClick={onDelete}
            disabled={isDeleting}
            className="text-red-600 border-red-200 hover:bg-red-50"
          >
            {isDeleting ? '...' : <Trash2 className="w-3.5 h-3.5" />}
          </Button>
        </div>
      </div>
    </div>
  );
}

function TableView({
  offers,
  toggling,
  deleting,
  duplicating,
  onEdit,
  onToggle,
  onDuplicate,
  onDelete,
  formatTrigger,
  formatReward,
  formatDuration,
}: {
  offers: OfferTemplate[];
  toggling: string | null;
  deleting: string | null;
  duplicating: string | null;
  onEdit: (id: string) => void;
  onToggle: (id: string, status: boolean) => void;
  onDuplicate: (offer: OfferTemplate) => void;
  onDelete: (id: string, slug: string) => void;
  formatTrigger: (o: OfferTemplate) => string;
  formatReward: (o: OfferTemplate) => string;
  formatDuration: (o: OfferTemplate) => string;
}) {
  return (
    <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
      <table className="w-full">
        <thead className="bg-gray-50 border-b">
          <tr>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">#</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Offer</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Type</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Trigger</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Reward</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Duration</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y">
          {offers.map((offer) => {
            const rtConfig = REWARD_TYPE_CONFIG[offer.rewardType] || REWARD_TYPE_CONFIG.bonus_rate;
            const RewardIcon = rtConfig.icon;

            return (
              <tr key={offer.id} className={`hover:bg-gray-50 ${!offer.isActive ? 'opacity-50' : ''}`}>
                <td className="px-4 py-3 text-sm text-gray-400">{offer.priority}</td>
                <td className="px-4 py-3">
                  <button
                    onClick={() => onEdit(offer.id)}
                    className="flex items-center gap-2 text-left hover:text-blue-600"
                  >
                    <span className="text-lg">{offer.icon}</span>
                    <div>
                      <div className="text-sm font-medium">{offer.title.en || offer.slug}</div>
                      <div className="text-xs text-gray-400 font-mono">{offer.slug}</div>
                    </div>
                  </button>
                </td>
                <td className="px-4 py-3">
                  <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium border ${rtConfig.bgColor} ${rtConfig.color}`}>
                    <RewardIcon className="w-3 h-3" />
                    {rtConfig.label}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm text-gray-600">{formatTrigger(offer)}</td>
                <td className="px-4 py-3 text-sm font-medium">{formatReward(offer)}</td>
                <td className="px-4 py-3 text-sm text-gray-500">{formatDuration(offer)}</td>
                <td className="px-4 py-3">
                  <button
                    onClick={() => onToggle(offer.id, offer.isActive)}
                    disabled={toggling === offer.id}
                    className={`px-3 py-1 rounded-full text-xs font-semibold transition ${
                      offer.isActive
                        ? 'bg-green-100 text-green-700 hover:bg-green-200'
                        : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
                    }`}
                  >
                    {toggling === offer.id ? '...' : offer.isActive ? 'ON' : 'OFF'}
                  </button>
                </td>
                <td className="px-4 py-3">
                  <div className="flex gap-1.5">
                    <button
                      onClick={() => onEdit(offer.id)}
                      className="p-1.5 text-blue-600 hover:bg-blue-50 rounded-lg"
                      title="Edit"
                    >
                      <Edit className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => onDuplicate(offer)}
                      disabled={duplicating === offer.id}
                      className="p-1.5 text-purple-600 hover:bg-purple-50 rounded-lg disabled:opacity-50"
                      title="Duplicate"
                    >
                      {duplicating === offer.id ? (
                        <span className="w-4 h-4 block text-xs">...</span>
                      ) : (
                        <Copy className="w-4 h-4" />
                      )}
                    </button>
                    <button
                      onClick={() => onDelete(offer.id, offer.slug)}
                      disabled={deleting === offer.id}
                      className="p-1.5 text-red-600 hover:bg-red-50 rounded-lg disabled:opacity-50"
                      title="Delete"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
