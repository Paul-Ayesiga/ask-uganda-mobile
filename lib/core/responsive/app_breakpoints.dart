enum AppWindowClass { mobile, tablet, desktop }

abstract final class AppBreakpoints {
  static const mobile = 600.0;
  static const desktop = 1024.0;

  static AppWindowClass fromWidth(double width) {
    if (width < mobile) {
      return AppWindowClass.mobile;
    }

    if (width < desktop) {
      return AppWindowClass.tablet;
    }

    return AppWindowClass.desktop;
  }
}
