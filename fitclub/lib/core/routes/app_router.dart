import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/ana_sayfa.dart';
import '../../features/egzersiz/presentation/pages/egzersiz_ana_ekran.dart';
import '../../features/beslenme/presentation/pages/beslenme_ana_ekran.dart';
import '../../features/beslenme/presentation/pages/gunluk_takip_ekrani.dart';
import '../../features/antrenman_takibi/presentation/pages/rutinler_ekrani.dart';
import '../../features/antrenman_takibi/presentation/pages/gecmis_kayitlar_ekrani.dart';

// Alt Sayfaların Importları
import '../../features/antrenman_takibi/presentation/pages/yeni_rutin_ekrani.dart';
import '../../features/antrenman_takibi/presentation/pages/aktif_rutin_ekrani.dart';
import '../../features/antrenman_takibi/presentation/pages/rutin_hareket_secim_ekrani.dart';
import '../../features/antrenman_takibi/domain/entities/antrenman_entity.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/egzersizler',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AnaSayfa(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/egzersizler',
              builder: (context, state) => const EgzersizAnaEkran(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/kesfet',
              builder: (context, state) => const BeslenmeAnaEkran(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ozet',
              builder: (context, state) => const GunlukTakipEkrani(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rutinler',
              builder: (context, state) => const RutinlerEkrani(),
              // Rutinler sekmesinin ALT sayfaları
              routes: [
                GoRoute(
                  path: 'yeni-rutin',
                  builder: (context, state) => const YeniRutinEkrani(),
                ),
                GoRoute(
                  path: 'hareket-secim',
                  builder: (context, state) => const RutinHareketSecimEkrani(),
                ),
                GoRoute(
                  path: 'aktif-rutin',
                  builder: (context, state) {
                    // Rutini ekstra veri olarak sayfaya gönderiyoruz
                    final rutin = state.extra as AntrenmanRutini;
                    return AktifRutinEkrani(rutin: rutin);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gecmis',
              builder: (context, state) => const GecmisKayitlarEkrani(),
            ),
          ],
        ),
      ],
    ),
  ],
);