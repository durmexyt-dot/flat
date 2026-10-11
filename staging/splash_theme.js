// Match the theme the app will use (stored by shared_preferences), so the
// loading splash doesn't flash in the wrong colors.
(function () {
  var mode = null;
  try { mode = JSON.parse(localStorage.getItem('flutter.themeMode')); } catch (e) {}
  var dark = mode === 'dark' ||
    (mode !== 'light' && window.matchMedia('(prefers-color-scheme: dark)').matches);
  document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light');
  // The user's theme color, saved by the app as a JSON string.
  try {
    var colors = JSON.parse(JSON.parse(localStorage.getItem('flutter.splashColors')));
    var c = colors && colors[dark ? 'dark' : 'light'];
    if (c) {
      var root = document.documentElement.style;
      root.setProperty('--surface', c.surface);
      root.setProperty('--on-surface', c.onSurface);
      root.setProperty('--primary', c.primary);
      root.setProperty('--on-primary', c.onPrimary);
    }
  } catch (e) {}
})();
