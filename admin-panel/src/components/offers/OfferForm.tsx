'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';

interface OfferTemplate {
  id?: string;
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
}

interface OfferFormProps {
  initialData?: OfferTemplate;
  onSubmit: (data: OfferTemplate) => Promise<void>;
  isLoading: boolean;
}

const TRIGGER_EVENTS = [
  { value: 'first_energy_use', label: 'First Energy Use (ใช้ Energy ครั้งแรก)' },
  { value: 'energy_use_milestone', label: 'Energy Use Milestone (ใช้ Energy ถึง X)' },
  { value: 'tier_up', label: 'Tier Up (เลื่อน Tier)' },
  { value: 'first_app_open', label: 'First App Open (เปิด App ครั้งแรก)' },
  { value: 'meals_logged_milestone', label: 'Meals Logged Milestone (Log อาหารถึง X ครั้ง)' },
  { value: 'first_purchase_complete', label: 'First Purchase Complete (ซื้อ offer product สำเร็จ)' },
];

const REWARD_TYPES = [
  { value: 'special_product', label: 'Special Product (สินค้าพิเศษ IAP)' },
  { value: 'bonus_rate', label: 'Bonus Rate (โบนัส %)' },
  { value: 'free_energy', label: 'Free Energy (Energy ฟรี)' },
  { value: 'subscription_deal', label: 'Subscription Deal (ส่วนลด subscription)' },
];

const TIER_OPTIONS = [
  { value: '', label: 'Any Tier (ทุก Tier)' },
  { value: 'bronze', label: 'Bronze' },
  { value: 'silver', label: 'Silver' },
  { value: 'gold', label: 'Gold' },
  { value: 'diamond', label: 'Diamond' },
];

export function OfferForm({ initialData, onSubmit, isLoading }: OfferFormProps) {
  const [formData, setFormData] = useState<OfferTemplate>({
    slug: initialData?.slug || '',
    triggerEvent: initialData?.triggerEvent || 'first_energy_use',
    triggerCondition: initialData?.triggerCondition || {},
    title: initialData?.title || { en: '', th: '' },
    description: initialData?.description || { en: '', th: '' },
    ctaText: initialData?.ctaText || { en: '', th: '' },
    icon: initialData?.icon || '🎁',
    rewardType: initialData?.rewardType || 'bonus_rate',
    rewardConfig: initialData?.rewardConfig || {},
    expiresAfterHours: initialData?.expiresAfterHours ?? null,
    priority: initialData?.priority || 1,
    maxClaimsPerUser: initialData?.maxClaimsPerUser || 1,
    isActive: initialData?.isActive ?? true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [activeLocale, setActiveLocale] = useState<'en' | 'th'>('en');

  function updateField(field: string, value: any) {
    setFormData((prev) => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors((prev) => {
        const next = { ...prev };
        delete next[field];
        return next;
      });
    }
  }

  function updateNestedField(path: string[], value: any) {
    setFormData((prev) => {
      const next = { ...prev };
      let current: any = next;
      for (let i = 0; i < path.length - 1; i++) {
        if (!current[path[i]]) current[path[i]] = {};
        current = current[path[i]];
      }
      current[path[path.length - 1]] = value;
      return next;
    });
  }

  function validate(): boolean {
    const newErrors: Record<string, string> = {};

    if (!formData.slug.trim()) {
      newErrors.slug = 'Slug is required';
    } else if (!/^[a-z0-9_]+$/.test(formData.slug)) {
      newErrors.slug = 'Slug must be lowercase + underscore only';
    }

    if (!formData.title.en.trim()) {
      newErrors['title.en'] = 'English title is required';
    }

    if (!formData.triggerEvent) {
      newErrors.triggerEvent = 'Select a trigger event';
    }

    if (!formData.rewardType) {
      newErrors.rewardType = 'Select a reward type';
    }

    if (formData.priority < 1) {
      newErrors.priority = 'Priority must be >= 1';
    }

    if (formData.maxClaimsPerUser < 1) {
      newErrors.maxClaimsPerUser = 'Max claims must be >= 1';
    }

    // Conditional validation
    if (formData.rewardType === 'special_product') {
      if (!formData.rewardConfig?.productId) newErrors['rewardConfig.productId'] = 'Product ID required';
      if (!formData.rewardConfig?.energyAmount) newErrors['rewardConfig.energyAmount'] = 'Energy amount required';
    } else if (formData.rewardType === 'bonus_rate') {
      if (!formData.rewardConfig?.bonusRate || formData.rewardConfig.bonusRate < 0.01 || formData.rewardConfig.bonusRate > 1.0) {
        newErrors['rewardConfig.bonusRate'] = 'Bonus rate must be 0.01-1.0';
      }
    } else if (formData.rewardType === 'free_energy') {
      if (!formData.rewardConfig?.amount || formData.rewardConfig.amount < 1) {
        newErrors['rewardConfig.amount'] = 'Amount must be >= 1';
      }
    } else if (formData.rewardType === 'subscription_deal') {
      if (!formData.rewardConfig?.productId) newErrors['rewardConfig.productId'] = 'Product ID required';
      if (!formData.rewardConfig?.basePlanId) newErrors['rewardConfig.basePlanId'] = 'Base Plan ID required';
      if (!formData.rewardConfig?.offerId) newErrors['rewardConfig.offerId'] = 'Offer ID required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validate()) return;
    await onSubmit(formData);
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Basic Info */}
      <div className="space-y-4">
        <h2 className="text-xl font-semibold">Basic Info</h2>
        <div>
          <Label htmlFor="slug">Slug</Label>
          <Input
            id="slug"
            value={formData.slug}
            onChange={(e) => updateField('slug', e.target.value)}
            placeholder="starter_deal"
            className={errors.slug ? 'border-red-500' : ''}
          />
          {errors.slug && <p className="text-sm text-red-500 mt-1">{errors.slug}</p>}
        </div>

        <div>
          <Label htmlFor="icon">Icon (Emoji)</Label>
          <Input
            id="icon"
            value={formData.icon}
            onChange={(e) => updateField('icon', e.target.value)}
            placeholder="⚡"
            maxLength={2}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label htmlFor="priority">Priority</Label>
            <Input
              id="priority"
              type="number"
              value={formData.priority}
              onChange={(e) => updateField('priority', parseInt(e.target.value) || 1)}
              min={1}
              className={errors.priority ? 'border-red-500' : ''}
            />
            {errors.priority && <p className="text-sm text-red-500 mt-1">{errors.priority}</p>}
          </div>

          <div className="flex items-center gap-2 pt-6">
            <input
              type="checkbox"
              id="isActive"
              checked={formData.isActive}
              onChange={(e) => updateField('isActive', e.target.checked)}
              className="w-4 h-4"
            />
            <Label htmlFor="isActive">Active</Label>
          </div>
        </div>
      </div>

      {/* Trigger */}
      <div className="space-y-4">
        <h2 className="text-xl font-semibold">Trigger</h2>
        <div>
          <Label htmlFor="triggerEvent">Event</Label>
          <select
            id="triggerEvent"
            value={formData.triggerEvent}
            onChange={(e) => {
              updateField('triggerEvent', e.target.value);
              updateField('triggerCondition', {});
            }}
            className="w-full h-9 rounded-md border border-input bg-transparent px-3 py-1 text-sm"
          >
            {TRIGGER_EVENTS.map((ev) => (
              <option key={ev.value} value={ev.value}>
                {ev.label}
              </option>
            ))}
          </select>
        </div>

        {/* Dynamic Condition Fields */}
        {formData.triggerEvent === 'energy_use_milestone' && (
          <div>
            <Label htmlFor="minTotalSpent">Min Total Spent</Label>
            <Input
              id="minTotalSpent"
              type="number"
              value={formData.triggerCondition?.minTotalSpent || ''}
              onChange={(e) =>
                updateNestedField(['triggerCondition', 'minTotalSpent'], parseInt(e.target.value) || 0)
              }
              min={0}
            />
          </div>
        )}

        {formData.triggerEvent === 'tier_up' && (
          <div>
            <Label htmlFor="tier">Tier</Label>
            <select
              id="tier"
              value={formData.triggerCondition?.tier || ''}
              onChange={(e) => updateNestedField(['triggerCondition', 'tier'], e.target.value || undefined)}
              className="w-full h-9 rounded-md border border-input bg-transparent px-3 py-1 text-sm"
            >
              {TIER_OPTIONS.map((t) => (
                <option key={t.value} value={t.value}>
                  {t.label}
                </option>
              ))}
            </select>
          </div>
        )}

        {formData.triggerEvent === 'meals_logged_milestone' && (
          <div>
            <Label htmlFor="minMealsLogged">Min Meals Logged</Label>
            <Input
              id="minMealsLogged"
              type="number"
              value={formData.triggerCondition?.minMealsLogged || ''}
              onChange={(e) =>
                updateNestedField(['triggerCondition', 'minMealsLogged'], parseInt(e.target.value) || 0)
              }
              min={0}
            />
          </div>
        )}

        {formData.triggerEvent === 'first_purchase_complete' && (
          <div>
            <Label htmlFor="afterProductId">After Product ID</Label>
            <Input
              id="afterProductId"
              value={formData.triggerCondition?.afterProductId || ''}
              onChange={(e) => updateNestedField(['triggerCondition', 'afterProductId'], e.target.value)}
              placeholder="energy_first_purchase_200"
            />
          </div>
        )}
      </div>

      {/* Content */}
      <div className="space-y-4">
        <h2 className="text-xl font-semibold">Content</h2>
        <Tabs value={activeLocale} onValueChange={(v) => setActiveLocale(v as 'en' | 'th')}>
          <TabsList>
            <TabsTrigger value="en">English</TabsTrigger>
            <TabsTrigger value="th">ไทย</TabsTrigger>
          </TabsList>
          <TabsContent value="en" className="space-y-4">
            <div>
              <Label htmlFor="title-en">Title</Label>
              <Input
                id="title-en"
                value={formData.title.en}
                onChange={(e) => updateNestedField(['title', 'en'], e.target.value)}
                placeholder="⚡ Starter Deal"
                className={errors['title.en'] ? 'border-red-500' : ''}
              />
              {errors['title.en'] && <p className="text-sm text-red-500 mt-1">{errors['title.en']}</p>}
            </div>
            <div>
              <Label htmlFor="description-en">Description</Label>
              <textarea
                id="description-en"
                value={formData.description.en}
                onChange={(e) => updateNestedField(['description', 'en'], e.target.value)}
                placeholder="200 Energy for just $1!"
                className="w-full min-h-[80px] rounded-md border border-input bg-transparent px-3 py-2 text-sm"
              />
            </div>
            <div>
              <Label htmlFor="cta-en">CTA Text</Label>
              <Input
                id="cta-en"
                value={formData.ctaText.en}
                onChange={(e) => updateNestedField(['ctaText', 'en'], e.target.value)}
                placeholder="Buy Now"
              />
            </div>
          </TabsContent>
          <TabsContent value="th" className="space-y-4">
            <div>
              <Label htmlFor="title-th">Title</Label>
              <Input
                id="title-th"
                value={formData.title.th}
                onChange={(e) => updateNestedField(['title', 'th'], e.target.value)}
                placeholder="⚡ ดีลสตาร์ทเตอร์"
              />
            </div>
            <div>
              <Label htmlFor="description-th">Description</Label>
              <textarea
                id="description-th"
                value={formData.description.th}
                onChange={(e) => updateNestedField(['description', 'th'], e.target.value)}
                placeholder="200 Energy แค่ $1!"
                className="w-full min-h-[80px] rounded-md border border-input bg-transparent px-3 py-2 text-sm"
              />
            </div>
            <div>
              <Label htmlFor="cta-th">CTA Text</Label>
              <Input
                id="cta-th"
                value={formData.ctaText.th}
                onChange={(e) => updateNestedField(['ctaText', 'th'], e.target.value)}
                placeholder="ซื้อเลย"
              />
            </div>
          </TabsContent>
        </Tabs>
      </div>

      {/* Reward */}
      <div className="space-y-4">
        <h2 className="text-xl font-semibold">Reward</h2>
        <div>
          <Label htmlFor="rewardType">Type</Label>
          <select
            id="rewardType"
            value={formData.rewardType}
            onChange={(e) => {
              updateField('rewardType', e.target.value);
              updateField('rewardConfig', {}); // Reset config when type changes
            }}
            className="w-full h-9 rounded-md border border-input bg-transparent px-3 py-1 text-sm"
          >
            {REWARD_TYPES.map((rt) => (
              <option key={rt.value} value={rt.value}>
                {rt.label}
              </option>
            ))}
          </select>
        </div>

        {/* Dynamic Reward Config */}
        {formData.rewardType === 'special_product' && (
          <div className="space-y-4">
            <div>
              <Label htmlFor="productId">Product ID</Label>
              <Input
                id="productId"
                value={formData.rewardConfig?.productId || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'productId'], e.target.value)}
                placeholder="energy_first_purchase_200"
                className={errors['rewardConfig.productId'] ? 'border-red-500' : ''}
              />
              {errors['rewardConfig.productId'] && (
                <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.productId']}</p>
              )}
            </div>
            <div>
              <Label htmlFor="energyAmount">Energy Amount</Label>
              <Input
                id="energyAmount"
                type="number"
                value={formData.rewardConfig?.energyAmount || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'energyAmount'], parseInt(e.target.value) || 0)}
                min={1}
                className={errors['rewardConfig.energyAmount'] ? 'border-red-500' : ''}
              />
              {errors['rewardConfig.energyAmount'] && (
                <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.energyAmount']}</p>
              )}
            </div>
            <div>
              <Label htmlFor="displayPrice">Display Price</Label>
              <Input
                id="displayPrice"
                value={formData.rewardConfig?.displayPrice || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'displayPrice'], e.target.value)}
                placeholder="$1.00"
              />
            </div>
          </div>
        )}

        {formData.rewardType === 'bonus_rate' && (
          <div>
            <Label htmlFor="bonusRate">Bonus Rate (0.01-1.0, e.g., 0.4 = 40%)</Label>
            <Input
              id="bonusRate"
              type="number"
              step="0.01"
              min="0.01"
              max="1.0"
              value={formData.rewardConfig?.bonusRate || ''}
              onChange={(e) => updateNestedField(['rewardConfig', 'bonusRate'], parseFloat(e.target.value) || 0)}
              className={errors['rewardConfig.bonusRate'] ? 'border-red-500' : ''}
            />
            {errors['rewardConfig.bonusRate'] && (
              <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.bonusRate']}</p>
            )}
          </div>
        )}

        {formData.rewardType === 'free_energy' && (
          <div>
            <Label htmlFor="amount">Amount (Energy)</Label>
            <Input
              id="amount"
              type="number"
              value={formData.rewardConfig?.amount || ''}
              onChange={(e) => updateNestedField(['rewardConfig', 'amount'], parseInt(e.target.value) || 0)}
              min={1}
              className={errors['rewardConfig.amount'] ? 'border-red-500' : ''}
            />
            {errors['rewardConfig.amount'] && (
              <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.amount']}</p>
            )}
          </div>
        )}

        {formData.rewardType === 'subscription_deal' && (
          <div className="space-y-4">
            <div>
              <Label htmlFor="subProductId">Product ID</Label>
              <Input
                id="subProductId"
                value={formData.rewardConfig?.productId || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'productId'], e.target.value)}
                placeholder="miro_normal_subscription"
                className={errors['rewardConfig.productId'] ? 'border-red-500' : ''}
              />
              {errors['rewardConfig.productId'] && (
                <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.productId']}</p>
              )}
            </div>
            <div>
              <Label htmlFor="basePlanId">Base Plan ID</Label>
              <Input
                id="basePlanId"
                value={formData.rewardConfig?.basePlanId || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'basePlanId'], e.target.value)}
                placeholder="energy-pass-monthly"
                className={errors['rewardConfig.basePlanId'] ? 'border-red-500' : ''}
              />
              {errors['rewardConfig.basePlanId'] && (
                <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.basePlanId']}</p>
              )}
            </div>
            <div>
              <Label htmlFor="offerId">Offer ID</Label>
              <Input
                id="offerId"
                value={formData.rewardConfig?.offerId || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'offerId'], e.target.value)}
                placeholder="winback-3usd"
                className={errors['rewardConfig.offerId'] ? 'border-red-500' : ''}
              />
              {errors['rewardConfig.offerId'] && (
                <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.offerId']}</p>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Duration & Limits */}
      <div className="space-y-4">
        <h2 className="text-xl font-semibold">Duration & Limits</h2>
        <div>
          <Label htmlFor="expiresAfterHours">Expires After (hours, leave empty = no expiry)</Label>
          <Input
            id="expiresAfterHours"
            type="number"
            value={formData.expiresAfterHours ?? ''}
            onChange={(e) => updateField('expiresAfterHours', e.target.value ? parseInt(e.target.value) : null)}
            min={1}
            placeholder="4"
          />
        </div>
        <div>
          <Label htmlFor="maxClaimsPerUser">Max Claims Per User</Label>
          <Input
            id="maxClaimsPerUser"
            type="number"
            value={formData.maxClaimsPerUser}
            onChange={(e) => updateField('maxClaimsPerUser', parseInt(e.target.value) || 1)}
            min={1}
            className={errors.maxClaimsPerUser ? 'border-red-500' : ''}
          />
          {errors.maxClaimsPerUser && <p className="text-sm text-red-500 mt-1">{errors.maxClaimsPerUser}</p>}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-4 pt-4">
        <Button type="submit" disabled={isLoading}>
          {isLoading ? 'Saving...' : 'Save'}
        </Button>
        <Button
          type="button"
          variant="outline"
          onClick={() => window.history.back()}
          disabled={isLoading}
        >
          Cancel
        </Button>
      </div>
    </form>
  );
}
