// Shows the app's system notifications. Phone browsers (Chrome on Android,
// Safari on a home-screen app) allow them only through a service worker.
// No fetch handler: nothing is cached, the app loads as before.
'use strict';

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

// A tap brings the app to the front and tells it which notification it was.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const tag = event.notification.tag;
  event.waitUntil((async () => {
    const windows = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    const client = windows.find((c) => c.url.startsWith(self.registration.scope)) ?? windows[0];
    if (client) {
      await client.focus();
      client.postMessage({ type: 'notificationclick', tag });
    } else {
      await self.clients.openWindow(self.registration.scope);
    }
  })());
});
