'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"manifest.json": "af41de9caa20f79859295647740b71a1",
"main.dart.js": "e0e991b87ec3c388f6f809681567e017",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"index.html": "eda1daa967bb91b982bf99f2763227c6",
"/": "eda1daa967bb91b982bf99f2763227c6",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "a2eb084b706ab40c90610942d98886ec",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/AssetManifest.bin.json": "11309a1ccc4add5626ce9b259a77236a",
"assets/AssetManifest.bin": "8074efb1d609d6b728e431a08827d538",
"assets/NOTICES": "5469af9e7e5182ce4fb1f7b99c63d1bd",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/data/projects.json": "3284d7910babeb93236cd94ca22141fb",
"assets/assets/data/experiences.json": "eb65ace1a7764c3caa472ecc3e02ed2e",
"assets/assets/data/services.json": "1946e516e59ae39724d00e3c5c643b38",
"assets/assets/fonts/Noto_Sans/NotoSans-Italic-VariableFont_wdth,wght.ttf": "57b81d1ff243238df110e225d8891400",
"assets/assets/fonts/Noto_Sans/static/NotoSans-Italic.ttf": "a6d070775dd5e6bfff61870528c6248a",
"assets/assets/fonts/Noto_Sans/static/NotoSans-Regular.ttf": "f46b08cc90d994b34b647ae24c46d504",
"assets/assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth,wght.ttf": "b72e420edb95cdf06e6e0a27bc0d964d",
"assets/assets/images/Darty-Logo.png": "4b938630dae990310a8cf5223ce5ba2c",
"assets/assets/images/keym-frame.png": "5a331c9dfb315a0bd4ca4d106c01c607",
"assets/assets/images/logos/express-js.png": "a85b8fd52725944c88c6c21d66c31e73",
"assets/assets/images/logos/mongoDb-logo.png": "753bf493c86c4a690c55dd0da101ad14",
"assets/assets/images/logos/css3.png": "73e16a82ed3cc3d0438467f2004391fa",
"assets/assets/images/logos/ci-cd-logo.png": "bcbf51e45935444ef1f71e190c7eae53",
"assets/assets/images/logos/angular-logo.png": "7f71b6d9d20afefcdaf1849bcba8cf6d",
"assets/assets/images/logos/dart-logo.png": "1bbc3d5f8b260453e47c957088fe64a5",
"assets/assets/images/logos/postgresql-logo.png": "a561e34d7afe344c96b3e06622461064",
"assets/assets/images/logos/jquery-logo.png": "ee029dbf90c94940a0cac9b98a78bad8",
"assets/assets/images/logos/mysql-logo.png": "a604ec860ec3d898bf7308c6ac70f7a2",
"assets/assets/images/logos/hive-logo.png": "3789bf746845f4114fa54ed40e6beb04",
"assets/assets/images/logos/smarty.png": "bec2993eb9376b9ec8e1abb23c1a4544",
"assets/assets/images/logos/node-js-logo.png": "9d43cce9f3e5d61105cfda18ffbdbe58",
"assets/assets/images/logos/laravel-logo.png": "3d8548c2c46513cf95d623610c483e40",
"assets/assets/images/logos/ionic-logo.png": "253a6cfb641505bd8c37e296f087176e",
"assets/assets/images/logos/ftp-ssh-logo.png": "4fec24cb97c56edf152c94119b12db69",
"assets/assets/images/logos/javascript-logo.png": "f0b6b60f7b64783699326a37ebf6c4a7",
"assets/assets/images/logos/prestashop-logo.png": "bf1572e4063146036725d9f255530641",
"assets/assets/images/logos/flutter-logo.png": "839042c83529d6f7d4f6b9844850caef",
"assets/assets/images/logos/html-logo.png": "e4580099a8a29c7bbfa48fc3001636d6",
"assets/assets/images/logos/firebase-hosting-logo.png": "ec704f9d2500310c7e38872fda138480",
"assets/assets/images/logos/php-logo.png": "8ca932006af18df1af28dd647ebea71b",
"assets/assets/images/logos/git-logo.png": "a99a06c1f8eec8fd40fd5b7752ba8867",
"assets/assets/images/logos/firebase-logo.png": "d5c79b19b926ca37487d292097e0140f",
"assets/assets/images/flutter-image.png": "d3b153c558ebb8abd54708a3a9b7e81b",
"assets/assets/images/armatis-logo.png": "0c2e961bc208b79234b7a8c55b4f778a",
"assets/assets/images/uts31-logo.png": "251ab280a2be49fbf78f8a60809e67e7",
"assets/assets/images/apside-logo.png": "708378cfccbd4df097da1eebd7ffb81a",
"assets/assets/images/keym.png": "4f37778dbe7910dff23f46557075edc9",
"assets/assets/images/wayma-logo.png": "7a1db6671189f6aeff9a2df36feb1099",
"assets/assets/images/zodiac-logo.png": "85bccb234a93c0e27ab379c41c80ad83",
"assets/assets/images/continental-logo.png": "8395568a2969432a0545f7a1f17cc6f9",
"assets/assets/images/2rouesvertes-logo.png": "4bcb0fc90f6c5e510285317d4238d92e",
"assets/assets/images/aubry-logo.png": "e74b2efa34dbfe5c2f505c4e62bef266",
"assets/assets/images/medimail-app.png": "404a382cd3d0832dabdc84402585f9ab",
"assets/assets/images/logo_godzyken.png": "2398781bfeeb48c99987a2fb92a9f900",
"assets/assets/images/tme-logo.png": "65d7eaa5ba15040697ef0305315b5bbb",
"assets/assets/images/ui-ux-design-service.png": "78ec757f972b0951d40147059b5d2665",
"assets/assets/images/urbalyon-logo.png": "19cc1bf4370930ab4cf650d52fba30bf",
"assets/assets/images/dedienne-logo.png": "164d0c9059d66009bb6fb5f7aed48199",
"assets/assets/images/coy.jpg": "e4db6d573bb615a0dd2fbd528c4c6cf9",
"assets/assets/images/egote-foto.png": "ec1c239e7bc77b74fde65d86809d27a6",
"assets/assets/images/sig-lyon.png": "f25ac2f2709da27bfdd9c788bce21a11",
"assets/assets/images/sunpower.png": "0f598d8a88cfb29738aadbfdce2d6490",
"assets/assets/images/vitrine.png": "36f892d224ddb456a2053e2447ab16f3",
"assets/assets/images/api-img.png": "3c280e3728cb48dd68b7e46591f49096",
"assets/assets/images/thales-logo.jpg": "f7e3304977b8229e2ddef48523f6258e",
"assets/assets/images/asics-logo.png": "8e0cc24b464ff42c9dac6e1251a458a6",
"assets/AssetManifest.json": "ef838bb17a3848b6d5b88dce718ccb2a",
"assets/fonts/MaterialIcons-Regular.otf": "90afbe590aaab1544334e8038bb316ea",
"assets/FontManifest.json": "ac6ccc1b8faac445eaad2fc7cd15acc8",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter_bootstrap.js": "7ee90c1be7adba75b907f07a155cf47f",
"version.json": "ca86be704e88e7dd29f7dc6d903045ec"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
