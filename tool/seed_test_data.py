#!/usr/bin/env python3
"""Creates test data in the Stubswap Firebase project.

Signs in a test seller (creating the account if needed), gives it a profile
and a payout method, and lists a few test events. Safe to run again: existing
documents are left alone.

    STUBSWAP_SELLER_PASSWORD=... tool/seed_test_data.py

Needs the Firestore rules from firestore.rules to be published.
"""
import datetime
import json
import os
import sys
import urllib.error
import urllib.request

API_KEY = 'AIzaSyA82cbUD2VX44KOdMO5RD_w2wkooTCC340'
PROJECT = 'stubswap-eda59'
EMAIL = os.environ.get('STUBSWAP_SELLER_EMAIL', 'test.prodavac@stubswap.test')
PASSWORD = os.environ.get('STUBSWAP_SELLER_PASSWORD')
NAME = 'Test Prodavac'
DOCS = f'https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents'


def post(url, body, token=None, method='POST'):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    req = urllib.request.Request(url, json.dumps(body).encode(), headers, method=method)
    try:
        with urllib.request.urlopen(req) as res:
            return res.status, json.load(res)
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read() or b'{}')


def sign_in():
    base = 'https://identitytoolkit.googleapis.com/v1/accounts'
    body = {'email': EMAIL, 'password': PASSWORD, 'returnSecureToken': True}
    status, res = post(f'{base}:signInWithPassword?key={API_KEY}', body)
    if status != 200:
        status, res = post(f'{base}:signUp?key={API_KEY}', {**body, 'displayName': NAME})
        if status != 200:
            sys.exit(f'Sign-in failed: {res}')
        print(f'Created account {EMAIL}')
    return res['idToken'], res['localId']


def value(v):
    if isinstance(v, bool):
        return {'booleanValue': v}
    if isinstance(v, int):
        return {'integerValue': str(v)}
    if isinstance(v, datetime.datetime):
        return {'timestampValue': v.astimezone(datetime.timezone.utc).isoformat().replace('+00:00', 'Z')}
    if isinstance(v, dict):
        return {'mapValue': {'fields': {k: value(x) for k, x in v.items()}}}
    if v is None:
        return {'nullValue': None}
    return {'stringValue': str(v)}


def create(token, path, data):
    """Creates the document unless it exists."""
    url = f'{DOCS}/{path}?currentDocument.exists=false'
    status, res = post(url, {'fields': {k: value(v) for k, v in data.items()}}, token, 'PATCH')
    if status == 200:
        print(f'  created {path}')
    elif res.get('error', {}).get('status') in ('ALREADY_EXISTS', 'FAILED_PRECONDITION'):
        print(f'  exists  {path}')
    else:
        sys.exit(f'Writing {path} failed ({status}): {res.get("error", res)}')


def main():
    if not PASSWORD:
        sys.exit('Set STUBSWAP_SELLER_PASSWORD.')
    token, uid = sign_in()
    now = datetime.datetime.now(datetime.timezone.utc)

    def day(d, hour=20):
        local = (now + datetime.timedelta(days=d)).replace(hour=hour - 2, minute=0, second=0, microsecond=0)
        return local

    print('Profile and payout method')
    create(token, f'users/{uid}', {
        'displayName': NAME, 'email': EMAIL, 'visibility': 'public',
        'notifications': {'orderUpdates': True, 'saleUpdates': True, 'payoutUpdates': True,
                          'priceAlerts': True, 'eventReminders': True, 'newsletter': False,
                          'email': True, 'push': False},
        'createdAt': now,
    })
    create(token, f'publicProfiles/{uid}', {'displayName': NAME, 'visibility': 'public'})
    create(token, f'users/{uid}/private/payoutMethod', {
        'accountHolder': NAME, 'iban': 'BA391290079401028494', 'updatedAt': now,
    })

    print('Listings')
    listings = [
        ('test-jazz', 'Test: Sarajevo Jazz Festival', 'Dom mladih', 'Sarajevo', day(21), 'festivals', 4, 3500, 'Parter', '', ''),
        ('test-derby', 'Test: FK Sarajevo – FK Željezničar', 'Koševo', 'Sarajevo', day(12, 18), 'sports', 6, 3000, 'Sjever', '8', ''),
        ('test-dubioza', 'Test: Dubioza kolektiv', 'Zetra', 'Sarajevo', day(30), 'concerts', 2, 5500, '', '', ''),
        ('test-hamlet', 'Test: Hamlet', 'Kamerni teatar 55', 'Sarajevo', day(9, 19), 'theater', 2, 2500, 'Balkon', '2', '14–15'),
    ]
    for (lid, name, venue, city, date, cat, qty, price, section, row, seats) in listings:
        create(token, f'listings/{lid}', {
            'sellerId': uid,
            'event': {'name': name, 'venue': venue, 'city': city, 'date': date, 'category': cat},
            'ticketType': 'eTicket', 'quantity': qty, 'quantitySold': 0,
            'priceMinor': price, 'currency': 'BAM', 'status': 'active',
            'section': section, 'row': row, 'seats': seats,
            'note': 'Testna ponuda (Stubswap test).',
            'createdAt': now, 'updatedAt': now,
        })
    print('Done.')


if __name__ == '__main__':
    main()
