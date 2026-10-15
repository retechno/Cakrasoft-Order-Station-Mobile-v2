# Prompt for Claude Code (CLI): implement the POS UI redesign

> How to use: open a terminal at the repo root on the `ui-redesign` branch (or copy `docs/` into your branch), run `claude`, and paste **everything below the line**. It is written to be worked through in phases; Claude will stop after each phase for review. You can also paste one phase at a time.

---

You are a senior Flutter engineer implementing an approved UI redesign of this existing Android POS app (Cakrasoft Order Station, GetX). This is **not** a rewrite: preserve all business logic, API calls, routes, printing and hardware behaviour. The design is already decided — implement it, don't redesign it.

## Read first (in this order)
1. `docs/ui_redesign_audit.md` — what exists, what must not change, defects D1–D5, performance items P1–P9, non-UI delays N1–N5.
2. `docs/ui_design_spec.md` — the binding spec: tokens, ThemeData, components, every screen for phone and tablet, interaction states, accessibility, performance rules.
3. `docs/design/*.dc.html` — the visual reference (HTML artboards with inline styles; read exact px/colours from markup; the JS class at the bottom of interactive boards holds the mock data/state). Map: `Main` = tokens & components, `Phone-Login`, `Phone-Home`, `Phone-Order` (new order + cart sheet + create-CO form), `Phone-CO` (captain order + options/menu/discount sheets), `Phone-Payment` (methods → cash numpad → confirm → success), `Phone-COList`, `Phone-Printer`, `Tablet-Order`, `Tablet-CO`, `States`.
4. Then inspect the code paths named in the audit before touching them.

## Hard rules
- **Primary colour stays exactly `#027801`** (`Color.fromARGB(255, 2, 120, 1)`). Override it explicitly in the ColorScheme; never let `fromSeed` change it. Keep `flutter_native_splash.color: "#027801"`.
- Do **not** change: endpoints, request payloads, `Request`/`isUncertain` handling, `MutationGuard` keys, `PendingPayment`, `SpecialAccessController` flow and validators (password ≥ 6), the 1.5 s qty debounce, "CO closed by other user" checks, `summary`/`totalPrices()` math, payment routing by `subGroupCode`, refund/charge sign, `utils/printer.dart` receipt layout, ESC/POS ports (9100, 55678), Bluetooth calls, GetX bindings, named routes, logout state clearing, exit confirmation.
- No new client-side money math. Every amount shown comes from existing controller state.
- No new runtime dependencies. Allowed asset change: bundle Plus Jakarta Sans (400/500/600/700/800 `.ttf`, OFL) under `fonts/` — download the files from the official Google Fonts / tokotype GitHub release; if you can't download, keep Inter and tell me. You may *remove* `awesome_dialog`, `flutter_switch`, `toggle_switch`, `flutter_spinkit`, `modal_progress_hud_nsn`, `dropdown_button2` only after their last usage is gone.
- Don't remove features. The only removals allowed: the no-op "Preview Receipt" button (D3) and unused `table_view/` (leave the files, it's not routed — don't delete).
- Don't fix defects silently: D1, D2, D5 fixes are approved; anything else you find goes into `docs/ui_redesign_audit.md` §5 as a new item first.
- Keep changes incremental and reviewable: one phase = one commit (or a few), conventional message, no unrelated reformatting of files you don't otherwise touch.
- Respect the existing SDK constraint (`>=3.0.0 <4.0.0`) and the Flutter version that `flutter --version` reports; don't bump packages unless required for a build error, and say so.
- Never claim a check passed unless you ran it. If you can't run the emulator or a device, list exactly what wasn't verified.

## Phase 0 — baseline (no code changes)
- `flutter --version`, `flutter pub get`, `flutter analyze` (record the count), `flutter test`, `flutter build apk --debug` — record results in `docs/ui_redesign_progress.md` as the baseline.
- If DevTools/profile mode is available on a device, record a baseline: open Products for a 20+ item category and scroll; tap +/− 10× on the CO screen; note frame build/raster times (P1, P2, P7). Otherwise write "not measured".
- Stop and show me the baseline.

## Phase 1 — design system foundation (no screen changes yet)
Create `lib/theme/` with `app_colors.dart`, `app_text.dart`, `app_space.dart`, `app_theme.dart` exactly per spec §2–§5, plus `Formats.money()` (display-only, §3). Wire `theme: AppTheme.light()` into `GetMaterialApp`. Point `Styles.primaryColor`/`textColor`/`bgColor`/`dangerColor` at the new tokens so legacy code keeps compiling and immediately picks up the palette. Add the font assets. Run analyze/test/build. Stop for review with a screenshot list of what visibly changed (defaults only).

## Phase 2 — shared components
Build `lib/widget/ui/` per spec §6: `AppBarX`, `AppButton` (variants + loading + amount), `AppSearchField` (150 ms debounce), `CategoryChips`, `CategoryRail`, `ProductTile` (list/grid), `QtyStepper`, `CartLine`, `CartBar`, `CartPanel`, `TransactionLine`, `OrderSummary`, `PaymentMethodTile`, `DueBanner`, `AppSheet`, `AuthorizeSheet` (single shared one, returns `Future<bool>`; callers keep their existing follow-ups), `ActionSheet`, `ConfirmDialog`, `AppEmptyState`, `AppErrorState`, `WarningBanner`, `SegmentedToggle`, restyled `NumPad` (+ quick-amount chips) and restyled `ItemListSkeleton`, `PrinterPicker` (one widget replacing the three printer dialogs; it must call the exact same `printController`/`Printer`/`bluetoothPrint` methods in the same order as today). Add `lib/utils/breakpoints.dart` (`compact <600`, `medium 600–839`, `expanded ≥840`, width-based).
Write widget tests for: `QtyStepper` (callbacks, min state), `AppButton` (null onPressed = not tappable, loading), `OrderSummary` (Charge vs Refund label from sign), `AuthorizeSheet` (validators: empty ID, password < 6), `PaymentMethodTile` (applied state), `CartBar` hidden when empty. Stop for review.

## Phase 3 — Captain order transaction (highest priority)
Rebuild `captain_order_transaction_screen.dart` UI on the new components per spec §7 "Captain order" + "Line options" + "Discount/Override sheets": app bar with print-to-kitchen + ⋯ menu, info strip, `TransactionLine` list (`ListView.builder`), "+ Add items" row, collapsible `OrderSummary` footer, primary Pay / Finish sale (same condition on `ComplimentTypeCode == "N"`). Replace the three `showModalAccess` copies with `AuthorizeSheet`. Keep every controller call identical. Fix P7 (split the screen-wide `Obx` into scoped ones; remove full-screen HUD except while printing), P8 (store the discovery future), N5/D4 only if trivially safe (document either way). Tablet ≥840: 3-pane per `Tablet-CO` with payment methods inline in the right panel (reuse `PaymentMethodController`; tapping a method runs the same `_openPaymentMethod` routing). Add a "Saving…" indicator driven by whether the line's debounce timer is pending (expose a read-only `RxSet<int> pendingQtyIds` from the controller — UI-state only). Stop for review.

## Phase 4 — Order building
Implement the single "New order" screen per `Phone-Order` / `Tablet-Order`: header with outlet (switch disabled while cart non-empty — same rule as today), search, category chips (phone) / rail (tablet), product list/grid, `CartBar` → Order sheet → Create-CO sheet (phone) / `CartPanel` → CO form dialog (tablet). Keep `OrdersNavigation` routes registered; `/categories` and `/products` render this screen with the right category preselected. Keep `OrdersController` add/remove/totalPrices and notes (`remark`) exactly; the Create-CO form keeps all fields, validators, `loadDropdown`/`loadTables`, `isSavingOrder` and `_saveCaptainOrder` navigation. "Add items" from a CO (`captainOrderId > 0`) shows "Add items · CO #n". Fix P1–P6 and P9 here (no `updateUI()` hack — make the cart reactive per row; parallel image fetch with one batched RxMap update; `cacheWidth`; no controllers in build). Stop for review.

## Phase 5 — Payment flow
Payment methods (grid + `DueBanner`; Finish sale disabled until `totalPayment() >= totalTransactionPrice` — same condition the colour uses today, now also the `onPressed`), `ConfirmDialog` with Charge/Paid/Change, Cash/BKTR/OTPY/DSCN numpad screen with quick amounts (still calls `paymentController.confirmPayment(context, amount, paymentData)`), success screen (`PopScope(canPop:false)`, Print receipt → `PrinterPicker`, New order → `popUntil(isFirst)`), then re-skin EDC, City ledger, Transfer-to-folio through the theme and `AppBarX` (fields unchanged). Stop for review.

## Phase 6 — Remaining screens
Captain orders list (`Phone-COList`; outlet chips from `outletList`, ⋯ action sheet + long-press both open the existing cancel flow), Home (`Phone-Home`; fix D1 by wrapping stats/cash/chart in `Obx`; restyle the chart), shell (`NavigationBar` / `NavigationRail` by width; Open-count badge from `pending`), Login (`Phone-Login`; shift as `SegmentedToggle`, honour `shiftDisabled`), Service API, Default outlet (+ entry from Home settings icon), Splash (visual only). States per `States` artboard everywhere a list can be loading/empty/error. Stop for review.

## Phase 7 — Performance verification
Re-run the Phase 0 measurements if a device/profile mode is available and record before/after in `docs/ui_redesign_progress.md`, **separating measured numbers from expectations**. Confirm with code search that no `ListView(children: List.generate` and no `TextEditingController(` inside `build` remain in redesigned screens.

## Phase 8 — Validation and handover
- `flutter analyze` (no new warnings vs baseline), `flutter test` (all green), `flutter build apk --release` (or the project's usual flavour) — report APK path.
- Layout checks with widget tests or golden-free `tester.binding.setSurfaceSize` at 360×640, 390×844, 600×960, 800×1280 (portrait tablet), 1280×800: no overflow exceptions on New order, CO, Payment methods, Cash, Success, CO list, Login (with keyboard inset simulated via `viewInsets`).
- Manual checklist (mark each as done / not done — never assume): login + shift; create CO with notes; add items to existing CO; qty +/− incl. authorisation path; line discount, bill discount, override price, remove item, remove all (all with supervisor); print to kitchen; print CO via Wi-Fi and Bluetooth; split payment cash + EDC; transfer to folio; city ledger; finish sale; refund/change display; pending-payment warning after a forced timeout; cancel CO; logout clears state; tablet landscape + portrait.
- Final report in `docs/ui_redesign_progress.md`: files created/modified, UI/UX improvements, performance issues found and fixes (measured vs expected), test results with real status, APK path, remaining issues / untested workflows.
