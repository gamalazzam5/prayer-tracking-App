# صلاتك اولا — Salaty

A prayer-tracking app: daily prayer times, a record of how each prayer was
performed, a qibla compass, and progress statistics.

## Architecture

Clean Architecture with **Cubit/Bloc** for state and **Hive** for local storage.

```
presentation  →  domain  ←  data
```

The domain layer depends on nothing and contains no Flutter imports. Cubits
depend only on use cases; use cases depend only on repository interfaces; the
data layer implements those interfaces and is the only place third-party SDKs
appear.

```
Screen → Cubit → UseCase → RepoInterface → RepoImpl → DataSource → device/storage
  ↓                                                                       ↓
 UI   ←  State  ←  Entity   ←   Entity   ←  Model(→Entity)  ←  PrayerRecord
```

### Layout

```
lib/
├── core/                        # shared across 2+ features
│   ├── constants/               # box names, prefs keys, Kaaba coordinates
│   ├── di/                      # get_it wiring (single injection container)
│   ├── error/                   # typed Failures + data-layer Exceptions
│   ├── location/                # LocationService (prayer times + qibla)
│   ├── resources/               # asset paths
│   ├── routing/                 # named routes + router
│   ├── storage/                 # PrayerLocalStorage contract + Hive impl
│   ├── theme/                   # colours, text styles
│   ├── utils/                   # date & Hijri formatting
│   └── widgets/                 # AppCard, AppLoader, AppErrorView, SectionTitle
└── features/
    ├── prayer/                  # prayer times + status tracking (home tab)
    ├── qibla/                   # compass (qibla tab)
    ├── statistics/              # progress breakdown (statistics tab)
    ├── onboarding/              # intro pages
    ├── splash/                  # start-up + first-route decision
    └── home/                    # tab shell + bottom navigation
```

Each feature follows `data/ · domain/ · presentation/`.

### Conventions

- **No code generation.** No Freezed, no `build_runner`. States are Dart 3
  `sealed class`es matched with exhaustive `switch` expressions; Hive stores
  plain `Map`s serialised by hand in `PrayerRecord`.
- **Errors** are typed. Data sources throw; repositories catch at the boundary
  and return `Either<Failure, T>` (dartz); the presentation layer maps failures
  to Arabic messages and UI states.
- **Identifiers are stable.** Prayers and statuses persist as English ids
  (`fajr`, `congregation`), never as display text.
- **DI** is `get_it`: lazy singletons for services, repositories and use cases;
  factories for cubits.

## Running

```bash
flutter pub get
flutter run
```

Location permission is required for prayer times and the qibla; the last known
fix is cached so both keep working offline.

## Tests

```bash
flutter test
```

Covers the domain logic (qibla bearing against known real-world bearings, next-prayer
resolution), the data layer (Hive storage, repositories, location fallbacks),
the cubits, and key widgets.
