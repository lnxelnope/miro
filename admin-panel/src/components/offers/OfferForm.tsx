'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import {
  OFFER_LOCALES,
  LOCALE_LABELS,
  LOCALE_TITLES,
  normalizeOfferLocaleStrings,
  type OfferLocale,
} from '@/lib/offer-locales';

interface OfferTemplate {
  id?: string;
  slug: string;
  triggerEvent: string;
  triggerCondition: Record<string, any>;
  title: Record<OfferLocale, string>;
  description: Record<OfferLocale, string>;
  ctaText: Record<OfferLocale, string>;
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
  { value: 'bonus_rate', label: 'Bonus Rate (โบนัส % เมื่อซื้อ IAP)' },
  { value: 'free_energy', label: 'Free Energy (Energy ฟรี)' },
  { value: 'freepass', label: 'Freepass (ใช้ AI ฟรี N วัน)' },
];

const IAP_PRODUCTS = [
  { value: '', label: 'All products (ทุกแพ็ก)' },
  { value: 'energy_100', label: 'Starter Kick — 100E ($0.99)' },
  { value: 'energy_550', label: 'Value Pack — 550E ($4.99)' },
  { value: 'energy_1200', label: 'Power User — 1200E ($7.99)' },
  { value: 'energy_2000', label: 'Ultimate Saver — 2000E ($9.99)' },
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
    title: normalizeOfferLocaleStrings(initialData?.title),
    description: normalizeOfferLocaleStrings(initialData?.description),
    ctaText: normalizeOfferLocaleStrings(initialData?.ctaText),
    icon: initialData?.icon || '🎁',
    rewardType: initialData?.rewardType || 'bonus_rate',
    rewardConfig: initialData?.rewardConfig || {},
    expiresAfterHours: initialData?.expiresAfterHours ?? null,
    priority: initialData?.priority || 1,
    maxClaimsPerUser: initialData?.maxClaimsPerUser || 1,
    isActive: initialData?.isActive ?? true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [activeLocale, setActiveLocale] = useState<string>('en');
  const [translateBusy, setTranslateBusy] = useState(false);
  const [translateError, setTranslateError] = useState<string | null>(null);

  async function handleTranslateFromEnglish() {
    if (!formData.title.en.trim()) {
      setTranslateError('กรอก English title ก่อน');
      return;
    }
    setTranslateError(null);
    setTranslateBusy(true);
    try {
      const res = await fetch('/api/offers/translate-preview', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          titleEn: formData.title.en,
          descriptionEn: formData.description.en,
          ctaEn: formData.ctaText.en.trim() ? formData.ctaText.en : 'Claim',
        }),
      });
      const data = await res.json();
      if (!data.success) {
        setTranslateError(data.error || 'แปลไม่สำเร็จ');
        return;
      }
      setFormData((prev) => ({
        ...prev,
        title: normalizeOfferLocaleStrings(data.title),
        description: normalizeOfferLocaleStrings(data.description),
        ctaText: normalizeOfferLocaleStrings(data.ctaText),
      }));
    } catch {
      setTranslateError('เรียก API ไม่สำเร็จ');
    } finally {
      setTranslateBusy(false);
    }
  }

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

    if (formData.rewardType === 'bonus_rate') {
      if (!formData.rewardConfig?.bonusRate || formData.rewardConfig.bonusRate < 0.01 || formData.rewardConfig.bonusRate > 10.0) {
        newErrors['rewardConfig.bonusRate'] = 'Bonus rate must be 0.01-10.0 (e.g. 1.0 = +100%)';
      }
    } else if (formData.rewardType === 'free_energy') {
      if (!formData.rewardConfig?.amount || formData.rewardConfig.amount < 1) {
        newErrors['rewardConfig.amount'] = 'Amount must be >= 1';
      }
    } else if (formData.rewardType === 'freepass') {
      if (!formData.rewardConfig?.days || formData.rewardConfig.days < 1) {
        newErrors['rewardConfig.days'] = 'Days must be >= 1';
      }
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
          <div className="space-y-4">
            <div>
              <Label htmlFor="afterProductId">After Product ID (optional)</Label>
              <Input
                id="afterProductId"
                value={formData.triggerCondition?.afterProductId || ''}
                onChange={(e) => updateNestedField(['triggerCondition', 'afterProductId'], e.target.value || undefined)}
                placeholder="energy_100"
              />
            </div>
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="requiresStarterBonus"
                checked={formData.triggerCondition?.requiresStarterEnergy100Bonus || false}
                onChange={(e) => updateNestedField(['triggerCondition', 'requiresStarterEnergy100Bonus'], e.target.checked || undefined)}
                className="w-4 h-4"
              />
              <Label htmlFor="requiresStarterBonus">
                Requires Starter Deal bonus (energy_100 + starter_deal only)
              </Label>
            </div>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="space-y-4">
        <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <h2 className="text-xl font-semibold">Content</h2>
            <p className="text-sm text-muted-foreground mt-1">
              กด Translate เพื่อเติมทุกภาษาจากช่องภาษาอังกฤษ แล้วตรวจแก้ทีละแท็บก่อน Save
            </p>
          </div>
          <Button
            type="button"
            variant="secondary"
            disabled={translateBusy || !formData.title.en.trim()}
            onClick={handleTranslateFromEnglish}
            className="shrink-0"
          >
            {translateBusy ? 'กำลังแปล…' : 'Translate from English'}
          </Button>
        </div>
        {translateError && (
          <p className="text-sm text-red-600" role="alert">
            {translateError}
          </p>
        )}
        <Tabs value={activeLocale} onValueChange={setActiveLocale}>
          <TabsList className="flex h-auto w-full max-w-full flex-wrap justify-start gap-1">
            {OFFER_LOCALES.map((loc) => (
              <TabsTrigger
                key={loc}
                value={loc}
                title={LOCALE_TITLES[loc]}
                className="text-xs sm:text-sm"
              >
                {LOCALE_LABELS[loc]}
              </TabsTrigger>
            ))}
          </TabsList>
          {OFFER_LOCALES.map((loc) => (
            <TabsContent key={loc} value={loc} className="space-y-4 mt-4">
              <p className="text-xs text-muted-foreground">{LOCALE_TITLES[loc]}</p>
              <div>
                <Label htmlFor={`title-${loc}`}>Title</Label>
                <Input
                  id={`title-${loc}`}
                  value={formData.title[loc]}
                  onChange={(e) => updateNestedField(['title', loc], e.target.value)}
                  placeholder={loc === 'en' ? '⚡ Starter Deal' : ''}
                  className={loc === 'en' && errors['title.en'] ? 'border-red-500' : ''}
                />
                {loc === 'en' && errors['title.en'] && (
                  <p className="text-sm text-red-500 mt-1">{errors['title.en']}</p>
                )}
              </div>
              <div>
                <Label htmlFor={`description-${loc}`}>Description</Label>
                <textarea
                  id={`description-${loc}`}
                  value={formData.description[loc]}
                  onChange={(e) => updateNestedField(['description', loc], e.target.value)}
                  placeholder={loc === 'en' ? '200 Energy for just $1!' : ''}
                  className="w-full min-h-[80px] rounded-md border border-input bg-transparent px-3 py-2 text-sm"
                />
              </div>
              <div>
                <Label htmlFor={`cta-${loc}`}>CTA Text</Label>
                <Input
                  id={`cta-${loc}`}
                  value={formData.ctaText[loc]}
                  onChange={(e) => updateNestedField(['ctaText', loc], e.target.value)}
                  placeholder={loc === 'en' ? 'Buy Now' : ''}
                />
              </div>
            </TabsContent>
          ))}
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
        {formData.rewardType === 'bonus_rate' && (
          <div className="space-y-4">
            <div>
              <Label htmlFor="bonusRate">Bonus Rate (e.g. 0.4 = +40%, 1.0 = +100%)</Label>
              <Input
                id="bonusRate"
                type="number"
                step="0.01"
                min="0.01"
                max="10.0"
                value={formData.rewardConfig?.bonusRate || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'bonusRate'], parseFloat(e.target.value) || 0)}
                className={errors['rewardConfig.bonusRate'] ? 'border-red-500' : ''}
              />
              {errors['rewardConfig.bonusRate'] && (
                <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.bonusRate']}</p>
              )}
              {formData.rewardConfig?.bonusRate > 0 && (
                <p className="text-sm text-purple-600 mt-1">
                  = +{Math.round((formData.rewardConfig.bonusRate || 0) * 100)}% bonus
                </p>
              )}
            </div>
            <div>
              <Label htmlFor="applyToProductId">Apply to Product (optional)</Label>
              <select
                id="applyToProductId"
                value={formData.rewardConfig?.applyToProductId || ''}
                onChange={(e) => updateNestedField(['rewardConfig', 'applyToProductId'], e.target.value || undefined)}
                className="w-full h-9 rounded-md border border-input bg-transparent px-3 py-1 text-sm"
              >
                {IAP_PRODUCTS.map((p) => (
                  <option key={p.value} value={p.value}>{p.label}</option>
                ))}
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Leave empty to apply bonus to any IAP purchase
              </p>
            </div>
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

        {formData.rewardType === 'freepass' && (
          <div>
            <Label htmlFor="days">Freepass Days</Label>
            <Input
              id="days"
              type="number"
              value={formData.rewardConfig?.days || ''}
              onChange={(e) => updateNestedField(['rewardConfig', 'days'], parseInt(e.target.value) || 0)}
              min={1}
              placeholder="3"
              className={errors['rewardConfig.days'] ? 'border-red-500' : ''}
            />
            {errors['rewardConfig.days'] && (
              <p className="text-sm text-red-500 mt-1">{errors['rewardConfig.days']}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              User gets N days of unlimited AI usage (no energy cost)
            </p>
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
