# UI Design Spec — "Operational green"

Visual reference: the Design canvas "Cakrasoft Order Station — UI Redesign" (11 artboards). The HTML sources of every artboard are copied to `docs/design/*.dc.html` and use inline styles, so exact px values and colours can be read straight from the markup. The static boards (Main, Login, Home, COList, Tablet-CO, States) open as-is in a browser. The interactive boards (Order, CO, Payment, Printer, Tablet-Order) are templates (`{{hole}}`, `<sc-for>`, `<sc-if>` plus a small JS class at the bottom with the mock data and state logic): read them as markup, or use the canvas to click through. Where this document and an artboard disagree, **this document wins**.

Companion: `docs/ui_redesign_audit.md` (current-state audit, defects D1–D5, performance items P1–P9).

---

## 1. Principles

1. **The primary colour marks the next action.** `#027801` is used for primary buttons, the selected nav item, applied/selected states, and "in order" markers. It is not used for decoration, headers or category chips.
2. **Prices are the loudest text.** Amounts use tabular figures and weight 700–800.
3. **Every tap target is ≥ 48 × 48 dp**, and primary actions are 52–56 dp tall.
4. **Borders separate; shadows float.** Use 1 px borders for structure. Use shadows only on sheets, dialogs and the sticky cart bar.
5. **No new business logic.** Every number on screen comes from existing controllers (`summary`, `orderList`, `paymentList`, etc.).

---

## 2. Colour tokens → `lib/theme/app_colors.dart`

| Token | Hex | Use |
|---|---|---|
| `primary` | **#027801** (unchanged, = `Color.fromARGB(255, 2, 120, 1)`) | primary buttons, selected nav, applied states, `+` icons |
| `primaryPressed` | #015C01 | pressed / hover overlay base |
| `primaryContainer` | #E3F1E0 | in-order product rows, applied payment tile, nav indicator |
| `onPrimaryContainer` | #0B4A0A | text on `primaryContainer` |
| `background` | #F3F4F1 | scaffold |
| `surface` | #FFFFFF | cards, app bars, sheets |
| `surfaceMuted` | #F8F9F7 | side panels on tablet |
| `surfaceSunken` | #E8EAE5 | thumbnails, skeleton blocks |
| `border` | #E1E4DE | dividers, card borders |
| `borderStrong` | #C9CEC5 | input and secondary-button borders |
| `textPrimary` | #171A16 | body, prices (17.6:1 on white) |
| `textSecondary` | #545C52 | labels, captions (6.9:1) |
| `textTertiary` | #6B7368 | disabled text, strikethrough prices (4.9:1) |
| `ink` | #171A16 | **selected category chip** background |
| `danger` / `dangerContainer` | #B3261E / #FCE9E7 | remove, discount amounts, auth errors |
| `warning` / `warningContainer` / `onWarningContainer` | #9A5B00 / #FFF2DC / #5E3800 | open-order counts, item notes, "payment not confirmed" banner, COMPLIMENT badge |
| `disabledFill` | #E1E4DE | disabled button fill (text `textTertiary`) |
| `scrim` | #171A16 @ 42 % | sheet / dialog barrier |

Keep `Styles.primaryColor` working by pointing it at `AppColors.primary`, so old code compiles during migration. Also keep `flutter_native_splash.color: "#027801"`.

The app is **light theme only**. The current app has no dark mode and the brief does not ask for one.

## 3. Typography → `lib/theme/app_text.dart`

Family: **Plus Jakarta Sans** (OFL). Bundle Regular 400, Medium 500, SemiBold 600, Bold 700 and ExtraBold 800 as `.ttf` assets under `fonts/` in `pubspec.yaml`. Do not use `google_fonts` (no new runtime dependency, works offline). The current Inter Regular-only bundle forces faux-bold. Fallback: the platform default.

| Style | Size / line | Weight | Notes |
|---|---|---|---|
| `amountXL` | 32/38 | 800 | tabular (`FontFeature.tabularFigures()`); cash balance, change to give (40/46 on success) |
| `amountL` | 26/32 | 800 | tabular; charge in CO footer, remaining |
| `title` | 24/30 | 700–800 | dialog titles, success |
| `screenTitle` | 20/26 (phone) · 22/28 (tablet) | 800 | app bar title |
| `heading` | 18/24 | 800 | sheet titles, section heads |
| `itemTitle` | 16/22 | 600 | product and line names |
| `price` | 16/22 | 700–800 | tabular |
| `body` | 15/22 | 400 | summary rows, paragraphs |
| `button` | 15–17 | 700 | 17 on 52–56 px buttons |
| `caption` | 13/18 | 500 | secondary info; **13 is the minimum anywhere a cashier reads** |
| `overline` | 12/16 | 700, +0.06em, UPPERCASE | section labels |
| `navLabel` | 12/16 | 600 (700 selected) | |

### Money formatting

Add `Formats.money(num)` for display only. It uses the `id_ID` grouping (`543.833`) and shows decimals only when the fraction is non-zero (`12.500,50`). Keep `Formats.formatNumber` unchanged for any code that parses its output.

## 4. Spacing, radius, elevation, motion → `lib/theme/app_space.dart`

- Spacing scale: 4, 8, 12, 16, 20, 24, 32. Screen gutter is 16 on phone and 24 on tablet. Row padding is 12 vertical × 16 horizontal. Gap between sibling cards is 8.
- Radius: `sm` 6, `md` 10 (buttons, inputs, cards, tiles), `lg` 14 (summary cards), `sheet` 16 (top corners), `pill` 20 (chips).
- Elevation: none on cards. Sheets use `0 -8 24 rgba(23,26,22,.12)`. The sticky cart bar uses `0 8 24 rgba(2,120,1,.28)`. Dialogs use `0 16 40 rgba(23,26,22,.2)`.
- Motion: sheets slide 200 ms `easeOutCubic`. No other decorative animation. Remove `AwesomeDialog` bottom-slide and `SpinKitWave` from the critical path (the splash can keep one spinner).

## 5. ThemeData → `lib/theme/app_theme.dart`

Build one `ThemeData` (Material 3) and pass it to `GetMaterialApp.theme`:

- `colorScheme`: `ColorScheme.fromSeed(seedColor: #027801)`, then **override** `primary: #027801`, `onPrimary: white`, `primaryContainer`, `onPrimaryContainer`, `surface`, `error: #B3261E`, `outline: #C9CEC5`, `outlineVariant: #E1E4DE`. Overriding guarantees the exact primary.
- `scaffoldBackgroundColor: background`, `fontFamily: 'PlusJakartaSans'`, `textTheme` mapped from §3.
- `filledButtonTheme` / `elevatedButtonTheme`: height 52, radius 10, `primary` fill, 17/700 label, disabled = `disabledFill` + `textTertiary`.
- `outlinedButtonTheme`: border `borderStrong`, height 48.
- `textButtonTheme`: `primary` text, min 48 × 48.
- `inputDecorationTheme`: outlined, radius 10, `borderStrong` 1 px, focused `primary` 2 px, error `danger` 2 px, content padding 14 h, label 13/600 `textSecondary` **above** the field (`floatingLabelBehavior: always`), min height 48–52.
- `appBarTheme`: white, elevation 0, scrolledUnderElevation 0, bottom border via `shape`, left-aligned title, toolbarHeight 56.
- `navigationBarTheme`: height 64, white, indicator `primaryContainer`, labels always shown.
- `navigationRailTheme` (tablet): width 88, same indicator.
- `bottomSheetTheme`: white, top radius 16, `showDragHandle: true`.
- `dialogTheme`: radius 16, title 20/800.
- `snackBarTheme`: floating, `ink` background, action colour #9CD69A.
- `chipTheme`, `dividerTheme` (1 px `border`), `listTileTheme` (min height 56), `progressIndicatorTheme` (`primary`).

## 6. Components → `lib/widget/ui/`

Reuse existing widgets where they exist. Restyle `NumPadWidget` and `ItemListSkeleton` rather than duplicating them.

| Component | Spec | Replaces |
|---|---|---|
| `AppBarX` | 56 high, back button 48 × 48 (`Icons.arrow_back_ios_new` 22), title + optional subtitle (13 `textSecondary`), trailing icon buttons 48 × 48 | `TitleHeaderWidget` (100 px) |
| `AppButton.primary/secondary/tonal/text/danger` | heights 56 (primary footer) / 52 / 48. Optional trailing amount (`Pay · 543.833`). `loading` swaps the label for an 18 px spinner while keeping the width. **`onPressed == null` whenever the action is not allowed** (fixes D2). | ad-hoc `ElevatedButton` styles |
| `AppSearchField` | 48 high, `background` fill, no border, leading search icon, 150 ms debounce, clear button when non-empty | `SearchInput`, product `filter()` |
| `CategoryChips` | horizontal `ListView.builder`, chip 40 high, pill radius. Selected = `ink` fill + white text. Count badge 20 px (`primary` on unselected, white on selected) = number of distinct products from that category in the order | `outletList()` chips, `getTotalItemEachCategory` |
| `CategoryRail` (tablet) | vertical list, 52 high rows, same selected/badge rules | category list screen |
| `ProductTile.list` | whole row is the tap target (adds 1), min height 72, 52 px thumb (image with `cacheWidth: 104` or initials on `surfaceSunken`), name 16/600, price 16/700. Trailing: an outlined "+ Add" pill (40 high) or a 36 px `primary` qty badge. In-order rows use a `primaryContainer` background. | `productItem`, `buttonAdd`, `changeQuantityButton` (products) |
| `ProductTile.grid` (tablet) | 128 high card, name top, price bottom-left, add affordance bottom-right, qty badge top-right; in-order = 2 px `primary` border + `primaryContainer` | — |
| `QtyStepper` | 44 (dense) / 48 high, outlined `borderStrong`, 44 × 44 − / + buttons, value 16/800 tabular. "−" greys out at the minimum. Semantics labels "Decrease"/"Increase". | 25 px `remove_circle`/`add_circle` icons |
| `CartLine` | name + amount row, then `QtyStepper` + note button (dashed border, 44 high, shows note text or "Add note") | `itemList` in `orders_page.dart` |
| `CartBar` (phone) | floating 60 px bar 12 px above the nav: count chip, "Review order", total. Hidden when the cart is empty | `ButtonOrder` |
| `CartPanel` (tablet) | 384 wide persistent right panel: header with Clear, lines, footer total + "Continue to order details". Shows an empty state when there are no lines | `ButtonOrder` + `OrderDetailScreen` |
| `TransactionLine` (CO) | name 16/600, `qty × unit` caption, note in `warning` colour, amount right (strikethrough gross + net + "−discount" in `danger` when discounted), `QtyStepper`, "Saving…" indicator while the 1.5 s debounce timer is pending, "Options ▾" button 44 high | `itemList` + chevron in the CO screen |
| `OrderSummary` | rows: Sub total, Discount (`danger`, tappable → bill discount auth), Service, Tax, Grand total (700), Paid. Final row is **Charge** or **Refund** (sign from `summary["total"]`, as today) in `amountL`. Collapsible on phone (collapsed shows Charge + item count), always open on tablet | `bottomPaymentDetail` (2 copies) + `detailTextSummary` (2 copies) |
| `PaymentMethodTile` | 2-column grid, min height 72–76, name 15/700 + sub-label (method kind, or "<amount> applied" from `getDisplayAmount`). Applied = 2 px `primary` border + `primaryContainer` | `paymentMethodList` rows |
| `DueBanner` | Charge / Paid / **Remaining** (or **Change**/**Fully paid** in `primary` once covered) | footer of `PaymentMethodsScreen` |
| `AppSheet` | `showModalBottomSheet` wrapper: drag handle, title + subtitle, 20 px padding, safe-area + `viewInsets` padding (keyboard), `isScrollControlled`, max height 90 % | 6 ad-hoc sheets |
| `AuthorizeSheet` | **one** shared widget. Icon tile (`dangerContainer`), title "Supervisor needed", subtitle = action + target, Supervisor ID (uppercase formatter), Password (show/hide, ≥ 6 chars validator **unchanged**), inline error "You don't have access", Cancel / Authorise. Returns `bool` to the caller, which runs the existing follow-up | 3 copies of `showModalAccess` |
| `ActionSheet` | list of 56 px rows (icon 22 + label 16/600). Danger rows in `danger`. A lock glyph marks actions that will ask for authorisation | `showTransactionOption`, `showContextMenu`, the popup menu |
| `ConfirmDialog` | title, key amounts (Charge / Paid / Change for Finish sale), one-line consequence, Cancel (outlined) + primary | generic "Are you sure ?" dialogs, `AwesomeDialog` exit |
| `AppEmptyState` / `AppErrorState` | 72 px circle icon, heading 18/800, body 15 `textSecondary`, optional primary action | "No data found" texts |
| `WarningBanner` | `warningContainer`, triangle icon, bold title + body (`onWarningContainer`) | `PendingPayment` alert text |
| `SegmentedToggle` | 4 px inset track on `background`, selected segment white + small shadow, 44 high | shift dropdown, Wi-Fi/Bluetooth buttons, amount/percent `FlutterSwitch` |
| `NumPad` | 3 × 4 grid (1–9, 000, 0, ⌫) filling the available height, keys white on `background`, 26/700. Quick-amount chips above it: **Exact**, then the next round notes (50k / 100k steps), 44 high. Callbacks unchanged | `NumPadWidget` restyle |
| `PrinterPicker` | `AppSheet` with `SegmentedToggle` Wi-Fi / Bluetooth. Wi-Fi: "Found on <subnet> · port 9100", rows (IP 16/700 tabular, "Last used" hint, Print button), "Still scanning…" row, Scan again. Bluetooth: status banner (connected = `primaryContainer`), device rows with a check on the selected one, Connect/Disconnect + Print (Print disabled until connected) | 3 copies of `selectPrinterDialog(X)` |

## 7. Screens

Breakpoints are based on **available width** (`LayoutBuilder` / `MediaQuery.sizeOf`), not on device type:

- `compact` < 600: phone layouts below.
- `medium` 600–839: phone layouts with a 2-column product grid and a centred max-width 640 for forms.
- `expanded` ≥ 840: tablet two-pane layouts, `NavigationRail` instead of `NavigationBar`.

| Screen | Phone (artboard) | Tablet (artboard) |
|---|---|---|
| Splash | Primary fill + logo + one spinner. Do **not** change the 3 s timing in UI work; it is listed as N1 | same |
| Service API | `AppBarX` "Server", Host / Port fields, `SwitchListTile` HTTPS, Connect (loading state). Max-width 480 centred | same, centred |
| Login (`Phone-Login`) | Server shortcut top-right (48 px). Logo 56, "Sign in" 28/800, white card with User ID, Password (show/hide), **Shift as `SegmentedToggle` A–D** (disabled when `shiftDisabled`), Sign in 52. Footer shows connection status + "Change". Wrap in `SingleChildScrollView` with keyboard insets; no `size.height - 100` | card max-width 440 centred |
| Default outlet (settings) | `AppBarX` "Default outlet", radio list of outlets (56 rows), Save. Reachable from the Home app bar settings icon as well as after login | max-width 560 |
| Home (`Phone-Home`) | App bar: avatar initials, user, "role · Shift · outlet", settings, logout. Cash balance card (`amountXL`). 3 stat tiles Open / Finished / Cancelled (Open taps through to Captain orders). "New order" 56 primary. Weekly sales chart (keep `syncfusion`, restyle: primary + #8A9386 lines, light area, no data labels except max). **Wrap all stats/chart in `Obx` (fixes D1)** | 2-column: stats + chart side by side |
| Shell | `NavigationBar` 64: Home / New order / Captain orders (Open count badge in `warning`) | `NavigationRail` 88 |
| New order (`Phone-Order`) | One screen replaces the Category → Product hop. Header: title "New order" (or "Add items · CO #n" when `captainOrderId > 0`), outlet subtitle + Outlet button (disabled while the cart is non-empty, as today), `AppSearchField` (filters the selected category's loaded products, which is today's behaviour; the API loads products per category, so do not add a new endpoint). Placeholder: "Search {category}", `CategoryChips`. Body: `ProductTile.list` via `ListView.builder`. `CartBar` floats above the nav. Tapping it opens the **Order sheet** (`CartLine`s, Clear, total, "Continue to order details"), which opens the **Create captain order** sheet (full-height): Table + Waitress (2 columns), Adults + Children steppers, Customer, Compliment, Sub department (hidden when Compliment = `N`, as today), Market, Outlet (read-only row), Remark, sticky "Save captain order" with loading state. The existing `OrdersNavigation` routes stay registered, and `/categories` and `/products` both render this screen with the right category preselected | (`Tablet-Order`) rail · category rail 208 · product grid 3–4 columns · `CartPanel` 384. "Continue to order details" opens the CO form as a centred dialog (max-width 560) |
| Captain orders (`Phone-COList`) | Title + "n open". Outlet chips (from `outletList`, replaces the dropdown). Rows 76 high: table tile (TABLE / number, "—" when empty), "CO #id", caption `fullName · guests · waitressCode`, COMPLIMENT badge when `complimentTypeCode != 'N'`, total. "⋯" button → ActionSheet (Open, Cancel CO 🔒). **Long-press kept**. Lazy `ListView.builder`, pull-to-refresh | master/detail: list 280 left, the CO screen right (`Tablet-CO`) |
| Captain order (`Phone-CO`) | `AppBarX` "CO #id" + outlet, print-to-kitchen icon, "⋯" (Print to kitchen, Print captain order, Bill discount 🔒, Remove all items 🔒). Info strip: Table · Guests · Customer · Compliment. `TransactionLine`s, then a dashed "+ Add items" row. Footer: collapsible `OrderSummary` + primary **Pay** (or **Finish sale** when compliment ≠ `N`, as today). HUD/`ModalProgressHUD` is replaced by button-level loading + a thin `LinearProgressIndicator` under the app bar | 3-pane: open-order list · line table (Item / Qty / Amount / ⋯) · right 360 panel with `OrderSummary`, `PaymentMethodTile` grid and the Finish sale button (methods inline, so no extra screen) |
| Line options | `ActionSheet`: Discount 🔒, Override price 🔒, Remove item 🔒 (danger) → `AuthorizeSheet` → existing follow-up (discount sheet / override sheet / remove) | same, anchored as a sheet |
| Discount / Override sheets | `AppSheet`. Discount: `SegmentedToggle` Amount / Percent (percent disabled for bill discount type 3, as today), 56 px right-aligned amount input (24/800), Apply. Override: current price (read-only row), new price input, Save. Same validators | dialog max-width 480 |
| Payment methods (`Phone-Payment` step 1) | `AppBarX` "Payment" + "CO #id · Table n". `DueBanner`. "Choose a method" overline + `PaymentMethodTile` grid. Footer button: disabled "Remaining x" until covered, then primary "Finish sale" (fixes D2) → `ConfirmDialog` with Charge / Paid / Change → existing `finishSale` | inline in the tablet CO panel |
| Cash / Bank transfer / Other / Discount payment (`Phone-Payment` step 2) | `AppBarX` method name + "Remaining x". "Amount received" 64 px display (34/800, primary border). Change / Still due line. Quick chips (Exact · 550k · 600k · 1.000k, computed from remaining). `NumPad`. "Confirm cash" (disabled at 0) → existing `confirmPayment` | `NumPad` in a 420 wide sheet |
| EDC / City ledger / Transfer to folio | re-skin through the theme + `AppBarX`: same fields, 48 px inputs, 2-column rows on tablet; folio list rows 64 high with room number lead | same |
| Payment success (`Phone-Payment` step 3) | 80 px check in `primaryContainer`, "Sale completed", "CO #id · Check n" (use `checkNumber`), "Change to give" card (`amountXL` 40). Primary **Print receipt** → `PrinterPicker`, secondary **New order**. Remove the no-op "Preview Receipt" (D3), or keep it hidden behind a flag if product wants it later. Back is still blocked (`PopScope(canPop: false)`) | centred column, max-width 480 |
| Printer picker (`Phone-Printer`) | see `PrinterPicker` | same |
| States (`States`) | Loading = skeleton rows of the real row height. Empty = `AppEmptyState` with a primary action. Error = `AppErrorState` "Can't reach the server" + Try again; uncertain payments use `WarningBanner`; "closed by another user" uses a snackbar or dialog with OK. Authorise = `AuthorizeSheet` with an inline error | same |

## 8. Interaction states

- **Pressed:** Material ink with a `primary` 12 % overlay on surfaces and `primaryPressed` on filled buttons.
- **Focused** (hardware keyboard / scanner devices): 2 px `primary` outline.
- **Disabled:** `disabledFill` + `textTertiary`, and `onPressed: null`. Never style a control disabled while it still works.
- **Loading:** button shows a spinner with the width kept, and the button itself is disabled. List refresh keeps the old rows visible with a 2 px `LinearProgressIndicator` (no full-screen HUD except while printing).
- **Optimistic qty:** the stepper updates immediately (existing behaviour). Show "Saving…" until the debounced `ChangeQuantity` returns. On "Need Access First", open `AuthorizeSheet` (existing flow).
- **Feedback:** success and info messages use a floating snackbar (bottom, above the nav/cart bar). Blocking server messages use `ConfirmDialog`/alert.
- **Destructive actions** (Clear order, Remove all, Cancel CO) always confirm. Supervisor-gated ones show the lock glyph before the tap.

## 9. Accessibility and touch

- Minimum tap target is 48 × 48. Steppers use 44 × 44 inside a 44–48 container, with an 8 px gap to neighbours.
- Text contrast is ≥ 4.5:1 (all text tokens on white or `background` qualify). White on `#027801` is 5.7:1.
- Status is never shown by colour alone: Open/Finished/Cancelled have labels, the Applied tile has text, discount has a "−" sign.
- `Semantics` labels on icon-only buttons (Back, More actions, Print to kitchen, Decrease, Increase, Show password, Close).
- Respect `MediaQuery.textScaler` up to 1.3: rows grow in height (no fixed `height:` on text rows; use `minHeight`).
- Keyboard: forms sit in scroll views with `viewInsets` padding, and `TextInputAction.next/done` order is kept.
- Orientation: tablet layouts also work in portrait (≥ 840 portrait tablets get two panes; < 840 fall back to phone layouts with a 2-column grid).

## 10. Performance rules tied to the design

- Lists: `ListView.builder` / `SliverList` / `GridView.builder` everywhere. No `ListView(children: List.generate…)`, no `shrinkWrap` inside `Expanded`.
- Scope `Obx` to the smallest widget that reads the observable (row badge, totals block, button). No screen-wide `Obx`.
- Product thumbnails: `Image.memory(bytes, cacheWidth: 104, gaplessPlayback: true)`. Fetch images in parallel (max 4 concurrent), then write the results into `productImages` in **one** batch (`addAll` + a single `refresh()`), not per image.
- No `TextEditingController` creation inside `build`.
- Printer discovery `Future` is created once per sheet open and stored, not in `build`.
- Search debounce is 150 ms. No caching of prices, stock, totals or payments.
