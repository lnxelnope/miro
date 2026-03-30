# Phase 18 — Plan 03 summary (app redeem)

- `lib/core/services/promo_code_service.dart`: POST ไป `redeemPromoCode`, `PromoRedeemException` + parse error key
- `profile_screen.dart`: `_PromoCodeSection` ใต้ Recovery Key — TextField, FilledButton, `_isRedeeming`, SnackBar success/error (AppColors), map error → L10n (`redeemErrorInvalid` ฯลฯ)
- หลังสำเร็จ: `syncBalanceWithServer`, `invalidate(currentEnergyProvider)`, `gamificationProvider.notifier.refresh()` เพื่อ energy + freepass UI
