import 'package:bloc/bloc.dart';

/// The tabs of the bottom navigation bar, in display order.
enum HomeTab { prayers, qibla, statistics }

/// Tracks the selected tab. Nothing else — tab content owns its own state.
class HomeNavCubit extends Cubit<HomeTab> {
  HomeNavCubit() : super(HomeTab.prayers);

  void selectTab(HomeTab tab) {
    if (tab == state) return;
    emit(tab);
  }

  void selectIndex(int index) {
    if (index < 0 || index >= HomeTab.values.length) return;
    selectTab(HomeTab.values[index]);
  }
}
