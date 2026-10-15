# UI Redesign Audit — Cakrasoft Order Station Mobile v2

Branch: `ui-redesign` · Audited commit: `d2f19e5` · Date: 2026-10-15

## 1. Project facts

| Item | Value |
|---|---|
| Package | `point_of_sales` 1.0.1+1 |
| Dart SDK constraint | `>=3.0.0 <4.0.0` (uses `WidgetStateProperty` and `DropdownButtonFormField.initialValue`, so it needs a recent Flutter stable; check `flutter --version` before upgrading anything) |
| Flutter version | Not pinned (no `.fvmrc` / `.metadata` channel lock) |
| State management | GetX 4.6 — `GetxController` + `Rx*` + `Obx`, a few `GetBuilder`, `Get.put` called from widget field initialisers |
| Routing | `GetMaterialApp` named routes (`/splash`, `/login`, `/`, `/setting`, `/urlSetup`, …) + one nested `Navigator` for the Orders tab (`OrdersNavigation`, id 0) + many `Get.to(() => Screen())` |
| Theme | **No real ThemeData.** `ThemeData(primarySwatch: Colors.blueGrey, scaffoldBackgroundColor: Styles.bgColor)`. All styling is per-widget via the static `Styles` class in `lib/utils/app_utils.dart`. |
| Font | `Inter` (only Regular + Italic `.otf` bundled; all "bold" text is synthesised) |
| Hardware | Wi-Fi ESC/POS printers (`esc_pos_printer`, port 9100, discovery via `ping_discover_network_forked`), Bluetooth printers (vendored `third_party/bluetooth_print`), kitchen print via local "Printer Service" on port 55678 |
| Storage | `shared_preferences` (host, user, defaultOutlet), `flutter_secure_storage` (token), `PendingPayment` journal |
| Tests | `test/guards_test.dart`, `test/validators_test.dart` (unit tests for MutationGuard, PendingPayment, Request, validators) |

### Primary color (must not change)

```dart
// lib/utils/app_utils.dart
Color primary = const Color.fromARGB(255, 2, 120, 1);   // #027801
```
Also hard-coded in `splash_screen.dart` and `pubspec.yaml` (`flutter_native_splash.color: "#027801"`).
**#027801 is preserved exactly** in the new design system (`AppColors.primary`).

## 2. What the app is

A hotel/restaurant **captain-order station** (waiter + cashier) for Cakrasoft PMS/POS, not a retail scanner POS. The core loop:

1. Waiter builds an order (outlet → category → products, notes per item) → **Create Captain Order** form (customer, adults/children, compliment type, sub-department, outlet, table, waitress, market, remark).
2. Order lands in a **Captain Order (CO)** with server-priced lines (tax, service, discount computed server-side).
3. Cashier opens the CO → adjusts qty / removes / discounts / overrides price (supervisor authorisation) → prints to kitchen / prints CO.
4. **Payment**: picks method(s) by sub-group (Cash `PYMT`, EDC `CRDB`, Bank transfer `BKTR`, Compliment `CMPL`, City ledger `ACRV`, Other `OTPY`, Transfer to folio `TRAN`, Discount `DSCN`) → split payments allowed → **Finish Sale** → success screen → print receipt.

## 3. Screen inventory

| # | Screen / surface | File | Frequency | Notes |
|---|---|---|---|---|
| 1 | Splash | `splash_screen/splash_screen.dart` | every launch | fixed 3 s delay before `TestConnection` |
| 2 | Service API (host/port/HTTPS) | `config/url_screen.dart` | setup | |
| 3 | Login (user, password, shift A–D) | `login/login_screen.dart` | every shift | |
| 4 | Default outlet | `setting/setting_screen.dart` | setup | only setting that exists |
| 5 | Dashboard shell (bottom nav: Home / Orders / CO) | `dashboard/dashboard.dart` | always | |
| 6 | Home (Finished/Pending/Cancelled counts, cash balance, weekly outlet revenue chart, logout) | `home/home_screen.dart` | per shift | |
| 7 | Categories (outlet chips + search + list) | `order/category/category_screen.dart` | **very high** | |
| 8 | Products (search + list, add / qty / notes) | `order/product/product_screen.dart` | **very high** | |
| 9 | New order list (cart) + Create/Update CO dialog | `order/orders_page.dart` | **very high** | |
| 10 | Captain Orders list (outlet dropdown, tap → open, long-press → cancel with authorisation + reason) | `captain_order/captain_order_screen.dart` | **very high** | acts as "open orders / history" |
| 11 | CO transaction (header info, lines, qty, line options, summary sheet, print kitchen/CO, delete all, add items, Payment/Finish Sale) | `captain_order/transaction/captain_order_transaction_screen.dart` (1 689 lines) | **highest** | |
| 12 | Payment methods (list, per-method amount, summary sheet, Finish Sale) | `transaction/payment_method/payment_methods_screen.dart` | high | |
| 13 | Cash / Bank transfer / Other / Discount payment (numpad) | `payment/cash/cash_payment_screen.dart` | high | |
| 14 | EDC card payment | `payment/edc/edc_payment_screen.dart` | medium | |
| 15 | City ledger / Compliment | `payment/city_ledger/city_ledger_payment_screen.dart` | low | |
| 16 | Transfer to folio (room folio list) | `payment/transfer_folio/transfer_folio_screen.dart` | medium | |
| 17 | Payment success (change, print receipt) | `payment/payment_success_screen.dart` | high | |
| — | Dialogs/sheets: Authorise (supervisor), Discount, Override price, Item notes, Line options, Summary, Printer picker (Wi-Fi/Bluetooth), Reason input, confirm dialogs, exit (AwesomeDialog) | various | high | 3 near-identical copies of the Authorise sheet, 2 copies of Summary sheet, 3 copies of printer picker |
| ✗ | Table view | `table_view/*` | **unused** (commented out of nav) | |

Screens from the brief that **do not exist** and will not be invented: product variants/packages selector, a separate transaction-history screen (the CO list is the closest), a dedicated printer-settings page (printer is chosen per print).

## 4. Current UI problems

**Visual system**
- No `ThemeData` — default Material widgets (dialogs, inputs, `TextButton`s) render in `blueGrey`, clashing with the green primary.
- Colours chosen ad hoc: `Colors.blue` for the active outlet chip, `Colors.amber/red/green` stats, `Colors.green` refund, pure `Colors.black` icons. 71 × `Colors.white`, 11 × `Colors.green`.
- Type scale is 10/11/12/13 px for most content — **too small for a cashier at arm's length**; prices are in 10 px grey (`textDetailStyle`) on product rows.
- Only one Inter weight bundled; bold is faux-bold.
- `TitleHeaderWidget` is 100 px tall with 35 px top padding on every screen → wastes ~12 % of a phone screen; the 24 px title is right-aligned and the back arrow is a 24 px tap target.
- Cards inside padded containers inside Scaffold backgrounds; inconsistent card heights (58 px fixed) clip two-line product names.

**Touch targets / ergonomics**
- Qty +/- icons are **25 px** (`changeQuantityButtonSize`), delete-all is a bare icon, add-item button 38 px, primary buttons 38 px high. Material guidance is 48 dp; cashier use wants ≥ 48.
- Product "ADD" is a 5 px-padded text chip.
- Line options (remove/discount/override) hidden behind a 24 px chevron; CO cancel hidden behind **long-press** (undiscoverable).
- Order total and the "expand summary" affordance are a 13 px text + chevron.

**Workflow**
- Building an order requires **Category list → Product list → back → another category → … → Order list** — at least 2 screen transitions per category; the running cart is only visible as a count on a button.
- On the Products screen the order list total and the "Order (n)" button are present, but no way to see/edit lines without leaving.
- Payment-method list shows no "remaining to pay"; Finish Sale button looks disabled (grey) but **is still tappable** (`onPressed` is always set).
- "Finish Sale" on the CO screen (compliment COs) and on the payment list share the same generic "Are you sure ?" dialog with no amount.
- Success screen labels the change as "Refund"; "Preview Receipt" button has **no action**.
- Dashboard tab switch to Home/CO always triggers a full reload.

**Phone vs tablet**
- No responsive code at all: every screen is a single column stretched to full width. On a 10" tablet the product list is a 1 200 px-wide row with a 45 px thumbnail.
- `AppLayout.getSize(context).width / 3`-style sizing for buttons, `height: size.height - 100` on login/settings (breaks with keyboard & landscape).

## 5. Performance concerns (from code inspection)

Rendering issues (UI thread):

| # | Evidence | Impact |
|---|---|---|
| P1 | `ProductScreen` wraps the whole scaffold in one `Obx`; quantity taps call `controller.updateUI()` which toggles a dummy `updateUIText` string to force a rebuild of **every** row. | Full list rebuild per tap. |
| P2 | `ProductController.productImages` is an `RxMap`; `fetchProductImages()` fetches images **sequentially** and assigns each into the RxMap → **N full-list rebuilds** while images trickle in. | Jank while scrolling a new category. |
| P3 | `Image.memory(bytes, width: 45)` / `Image.network(...)` without `cacheWidth` → images decoded at full resolution. | Memory + decode time. |
| P4 | `buttonAdd` does `orderList.indexWhere` per row (O(n·m)); `getTotalItemEachCategory` loops the order list per category row. | Minor, grows with order size. |
| P5 | `changeQuantityButton` (products) allocates two `TextEditingController`s **per row per build**, never disposed. | Leak + GC pressure. |
| P6 | CO list, order list, CO transaction lines and payment methods use `ListView(children: List.generate(...))` (non-lazy); CO list also `shrinkWrap: true`. | All rows built up front. |
| P7 | CO transaction screen: entire 1 689-line screen in one `Obx` (header, list, footer, HUD). Each `isLoadingIndicator` flip (every qty change triggers a status check) rebuilds everything. | Rebuild storm on qty changes. |
| P8 | Printer picker: `FutureBuilder(future: printController.discoverPrinters())` created **inside build** → every `setState` in the dialog restarts a network scan. | Repeated subnet scans; slow, flaky picker. |
| P9 | `filterProduct()` runs on every keystroke and re-triggers `fetchProductImages()`. | Cheap filter, but extra async work; debounce 150 ms. |

Non-rendering delays (not fixable in UI, documented only):
- **N1** Splash waits a fixed **3 s** before testing the connection.
- **N2** Every qty change waits 1.5 s debounce → `IsCaptainOrderStatusOpen` → `ChangeQuantity` → full `CaptainOrderTransactions` reload (3 round trips).
- **N3** Opening any line option first does a blocking `IsCaptainOrderStatusOpen` round trip (with HUD).
- **N4** Each dashboard tab switch reloads Home/CO from the server.
- **N5** Remove item calls `loadCaptainOrderTransactionList()` **twice** (`_removeItem` lines 418 and 433).

Functional defects found (reported, not silently changed):
- **D1** `HomeScreen`: stat counters, cash balance and chart are **outside** the `Obx` → they don't update when `loadData()` completes (only the header row is reactive).
- **D2** Payment-methods "Finish Sale" is styled disabled when unpaid but still tappable.
- **D3** "Preview Receipt" has an empty handler.
- **D4** N5 double reload.
- **D5** `DropdownButtonFormField` for Outlet in the CO form is permanently disabled (`disabled: true`) — intended, but renders as an error-looking greyed field.

## 6. Proposed design improvements

1. **Real design system**: `AppColors`/`AppText`/`AppSpace`/`AppRadius` tokens + a complete `ThemeData` (ColorScheme from #027801, inputs, buttons, dialogs, sheets, snackbars, nav bar) so every default Material widget is on-brand without per-widget styling.
2. **Compact app bar** (56 px, left-aligned title + context subtitle, 48 px back target) replacing the 100 px `TitleHeaderWidget`.
3. **Single order-building screen**: category chips across the top + product grid/list in one place, a sticky cart bar on phones and a **persistent cart panel on tablets (≥ 840 px)**. The existing category → product route stays working (routes preserved) but both screens share the new components.
4. **CO transaction redesign**: info strip (table · guests · customer · compliment), larger line rows with 48 px qty stepper and a visible "⋯" for options, an always-visible totals block (Grand total, Paid, Charge/Refund) and a primary Pay/Finish button. Tablet: lines left, totals + actions right.
5. **Payment**: methods as a grid of large tiles with the amount already applied per method, a "Remaining" banner, Finish Sale enabled only when covered (styling = behaviour). Cash numpad with quick-amount chips (exact amount, rounded notes) — still calls the same `confirmPayment`.
6. **Success**: big change amount, primary "Print receipt", secondary "New order".
7. **CO list**: lazy list, status-free compact rows with table as the lead, explicit "⋯" menu for Cancel CO (long-press kept).
8. **States**: shared `AppEmptyState`, `AppErrorState`, skeleton rows sized to the real rows, and one shared Authorise sheet.

## 7. Behaviour that must not change

- All API endpoints, payloads, `MutationGuard` keys, `PendingPayment` handling, `Request.isUncertain` handling.
- Server-side pricing: totals displayed come from `summary` computed in `CaptainOrderTransactionController.totalPrices()` — **no new client math**.
- Supervisor authorisation flow (`SpecialAccessController`) for remove/discount/override/reduce-qty/cancel CO, including the 6-char password validator.
- Qty debounce (1.5 s per line) and "CO closed by other user" checks.
- Payment routing by `subGroupCode`; split payments; refund/charge sign logic.
- Kitchen print (`GetPrintToKitchenData` → service :55678), Wi-Fi ESC/POS (:9100, 80 mm), Bluetooth print, receipt layout in `utils/printer.dart` (untouched).
- Routes and GetX bindings; logout clearing state; exit confirmation.
- Shift selection, default outlet, host/port/HTTPS config.

## 8. Implementation priorities

1. Design tokens + `AppTheme` + core components (no behaviour change, immediate app-wide uplift).
2. CO transaction screen (highest-frequency cashier surface) + shared Authorise / Discount / Override sheets.
3. Order building (categories + products + cart) with tablet two-pane.
4. Payment methods, cash numpad, success.
5. CO list, Home, Login, URL setup, Settings, Splash.
6. Evidenced performance fixes P1–P9 (scoped `Obx`, lazy lists, `cacheWidth`, parallel image fetch with a single batched update, no controllers in build, picker future cached, search debounce).
7. Remaining payment sub-screens (EDC, city ledger, folio) re-skinned through the theme.
