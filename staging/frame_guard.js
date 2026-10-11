// Stubswap must never run inside another site's frame: a hidden frame could
// trick users into clicks (clickjacking). Break out, or stay blank.
if (window.top !== window.self) {
  document.documentElement.style.display = 'none';
  try {
    window.top.location = window.self.location.href;
  } catch (e) {}
}
