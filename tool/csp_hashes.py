#!/usr/bin/env python3
"""Prints the CSP script hashes for the inline scripts FlutterFire injects
to load the Firebase JS SDK (one per service, in two forms: with and without
Trusted Types). Put them into web/index.html and firebase.json after adding
a firebase_* package or upgrading them.

    tool/csp_hashes.py <firebase-js-version>      e.g. 12.19.0
"""
import base64
import hashlib
import sys

# FlutterFire's service name → the SDK module it imports.
SERVICES = [
    ('firebase_core', 'app'),
    ('firebase_auth', 'auth'),
    ('firebase_firestore', 'firestore-pipelines'),
    ('firebase_storage', 'storage'),
    ('firebase_functions', 'functions'),
    ('firebase_app_check', 'app-check'),
]


def trusted(name, url):
    return ('            window.ff_trigger_' + name + ' = async (callback) => {\n'
            '              console.debug("Initializing Firebase ' + name + '");\n'
            '              callback(await import("' + url + '"));\n'
            '            };\n          ')


def plain(name, url):
    return ('      window.ff_trigger_' + name + ' = async (callback) => {\n'
            '        console.debug("Initializing Firebase ' + name + '");\n'
            '        callback(await import("' + url + '"));\n'
            '      };\n    ')


def sha(text):
    return "'sha256-" + base64.b64encode(hashlib.sha256(text.encode()).digest()).decode() + "'"


def main():
    if len(sys.argv) != 2:
        sys.exit('Usage: tool/csp_hashes.py <firebase-js-version>, e.g. 12.19.0 '
                 '(see ".../firebasejs/<version>/" requests in the browser).')
    version = sys.argv[1]
    hashes = []
    for name, module in SERVICES:
        url = f'https://www.gstatic.com/firebasejs/{version}/firebase-{module}.js'
        hashes += [sha(trusted(name, url)), sha(plain(name, url))]
    print(' '.join(hashes))


if __name__ == '__main__':
    main()
