#!/usr/bin/env python3
"""Creates test data in the Stubswap Firebase project.

Signs in a test seller (creating the account if needed), gives it a profile
and a payout method, and lists test tickets for the visible upcoming events
(events are created by an admin in the app). Safe to run again: existing
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
DOCS_NAME = f'projects/{PROJECT}/databases/(default)/documents'
DOCS = f'https://firestore.googleapis.com/v1/{DOCS_NAME}'


def post(url, body, token=None, method='POST'):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data, headers, method=method)
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


def plain(v):
    """A Firestore REST value as Python (only the types events use)."""
    if 'timestampValue' in v:
        return datetime.datetime.fromisoformat(v['timestampValue'].replace('Z', '+00:00'))
    if 'integerValue' in v:
        return int(v['integerValue'])
    if 'booleanValue' in v:
        return v['booleanValue']
    return v.get('stringValue')


def upcoming_events(token):
    """(id, event map) of the visible events that haven't happened yet."""
    query = {'structuredQuery': {
        'from': [{'collectionId': 'events'}],
        'where': {'fieldFilter': {'field': {'fieldPath': 'status'}, 'op': 'EQUAL',
                                  'value': {'stringValue': 'active'}}},
    }}
    status, res = post(f'{DOCS}:runQuery', query, token)
    if status != 200:
        sys.exit(f'Reading events failed ({status}): {res}')
    now = datetime.datetime.now(datetime.timezone.utc)
    events = []
    for row in res:
        d = row.get('document')
        if not d:
            continue
        f = {k: plain(v) for k, v in d['fields'].items()}
        if f['date'] <= now:
            continue
        events.append((d['name'].split('/')[-1],
                       {k: f[k] for k in ('name', 'venue', 'city', 'date', 'category')}))
    return sorted(events, key=lambda e: e[1]['date'])


def current_fees():
    """The (buyer, seller) fee percents new listings must carry."""
    status, res = post(f'{DOCS}/config/fees', None, method='GET')
    if status != 200:
        return 10, 10
    f = {k: plain(v) for k, v in res['fields'].items()}
    return f.get('buyerPercent', 10), f.get('sellerPercent', 10)


def create_with_times(token, path, data):
    """Creates the document unless it exists, with createdAt/updatedAt set
    by the server (the rules want the request time)."""
    write = {
        'update': {'name': f'{DOCS_NAME}/{path}', 'fields': {k: value(v) for k, v in data.items()}},
        'currentDocument': {'exists': False},
        'updateTransforms': [
            {'fieldPath': 'createdAt', 'setToServerValue': 'REQUEST_TIME'},
            {'fieldPath': 'updatedAt', 'setToServerValue': 'REQUEST_TIME'},
        ],
    }
    status, res = post(f'{DOCS}:commit', {'writes': [write]}, token)
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

    print('Listings for the upcoming events')
    events = upcoming_events(token)
    if not events:
        print('  no visible upcoming events: an admin creates them in the app first')
    fees = current_fees()
    offers = [(4, 3500, 'Parter', '', ''), (6, 3000, 'Sjever', '8', ''), (2, 5500, '', '', ''),
              (2, 2500, 'Balkon', '2', '14–15')]
    for i, (eid, event) in enumerate(events[:8]):
        qty, price, section, row, seats = offers[i % len(offers)]
        create_with_times(token, f'listings/test-{eid}', {
            'sellerId': uid, 'eventId': eid, 'event': event,
            'buyerFeePercent': fees[0], 'sellerFeePercent': fees[1],
            'ticketType': 'eTicket', 'quantity': qty, 'quantitySold': 0,
            'priceMinor': price, 'currency': 'BAM', 'status': 'active',
            'section': section, 'row': row, 'seats': seats,
            'note': 'Testna ponuda (Stubswap test).',
        })
    print('Done.')


if __name__ == '__main__':
    main()
