#!/usr/bin/env python3
"""Fills STAGING with one example of every case, to look at the app.

Three accounts take part (passwords from the environment, never stored):

    SHOWCASE_SELLER_EMAIL / SHOWCASE_SELLER_PASSWORD  seller, needs a CONFIRMED email
    SHOWCASE_BUYER_EMAIL  / SHOWCASE_BUYER_PASSWORD   buyer
    SHOWCASE_STAFF_EMAIL  / SHOWCASE_STAFF_PASSWORD   support account (an admin
                                                      adds it in the app: Tim)

Missing accounts are created; an unconfirmed seller gets a confirmation email
and the script stops until the link was opened. Safe to run again: what
exists is left alone (documents have fixed "showcase-" ids).

What it creates (staging only, the rules decide everything):
- events: confirmed with picture (concert, football), unconfirmed added by
  the seller (jazz, Mostar), confirmed without offers (festival), hidden
- per event a sold/bought listing and an open one; orders paid (tickets to
  send), tickets sent, cancelled by the seller (refund), failed payment,
  waiting for payment; a sold-out and a withdrawn listing
- support requests: open, answered by the team (unread), closed, with picture
- seller profile with username, photo and payout method
"""
import base64
import datetime
import io
import json
import os
import random
import sys
import urllib.error
import urllib.request

API_KEY = 'AIzaSyA82cbUD2VX44KOdMO5RD_w2wkooTCC340'
PROJECT = 'stubswap-eda59'
DOCS_NAME = f'projects/{PROJECT}/databases/(default)/documents'
DOCS = f'https://firestore.googleapis.com/v1/{DOCS_NAME}'
AUTH = 'https://identitytoolkit.googleapis.com/v1/accounts'
UTC = datetime.timezone.utc


# ---- HTTP and Firestore REST ------------------------------------------------

def call(url, body=None, token=None, method=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data, headers, method=method or ('POST' if body is not None else 'GET'))
    try:
        with urllib.request.urlopen(req) as res:
            return res.status, json.load(res)
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read() or b'{}')


def value(v):
    if isinstance(v, bool):
        return {'booleanValue': v}
    if isinstance(v, int):
        return {'integerValue': str(v)}
    if isinstance(v, datetime.datetime):
        return {'timestampValue': v.astimezone(UTC).isoformat().replace('+00:00', 'Z')}
    if isinstance(v, dict):
        return {'mapValue': {'fields': {k: value(x) for k, x in v.items()}}}
    if isinstance(v, list):
        return {'arrayValue': {'values': [value(x) for x in v]}}
    if v is None:
        return {'nullValue': None}
    return {'stringValue': str(v)}


def plain(v):
    if 'timestampValue' in v:
        return datetime.datetime.fromisoformat(v['timestampValue'].replace('Z', '+00:00'))
    if 'integerValue' in v:
        return int(v['integerValue'])
    if 'booleanValue' in v:
        return v['booleanValue']
    if 'mapValue' in v:
        return {k: plain(x) for k, x in v['mapValue'].get('fields', {}).items()}
    if 'arrayValue' in v:
        return [plain(x) for x in v['arrayValue'].get('values', [])]
    if 'nullValue' in v:
        return None
    return v.get('stringValue')


def get(token, path):
    status, res = call(f'{DOCS}/{path}', token=token)
    # The rules deny reading a document that doesn't exist yet when access
    # depends on its data: treat it as missing (a real lack of rights shows
    # up when writing).
    if status in (403, 404):
        return None
    if status != 200:
        sys.exit(f'Reading {path} failed ({status}): {res.get("error", res)}')
    return {k: plain(v) for k, v in res.get('fields', {}).items()}


def set_op(path, fields, *, new=True, times=(), mask=None, append=None):
    """One write for a commit: create (new) or update (mask) a document.
    [times] are set to the request time; [append] adds array elements."""
    w = {'update': {'name': f'{DOCS_NAME}/{path}', 'fields': {k: value(v) for k, v in fields.items()}}}
    w['currentDocument'] = {'exists': not new}
    if mask is not None:
        w['updateMask'] = {'fieldPaths': mask}
    transforms = [{'fieldPath': t, 'setToServerValue': 'REQUEST_TIME'} for t in times]
    for field, items in (append or {}).items():
        transforms.append({'fieldPath': field, 'appendMissingElements': {'values': [value(x) for x in items]}})
    if transforms:
        w['updateTransforms'] = transforms
    return w


def update_op(path, fields, *, times=(), append=None):
    return set_op(path, fields, new=False, times=times,
                  mask=list(fields), append=append)


def delete_op(path):
    return {'delete': f'{DOCS_NAME}/{path}'}


def commit(token, writes, what):
    status, res = call(f'{DOCS}:commit', {'writes': writes}, token)
    if status != 200:
        sys.exit(f'{what} failed ({status}): {res.get("error", res)}')
    print(f'  {what}')


def create(token, path, fields, what, times=('createdAt', 'updatedAt')):
    if get(token, path) is not None:
        print(f'  exists: {what}')
        return False
    commit(token, [set_op(path, fields, times=times)], what)
    return True


# ---- Accounts ----------------------------------------------------------------

class Account:
    def __init__(self, role, name):
        self.email = os.environ.get(f'SHOWCASE_{role}_EMAIL')
        self.password = os.environ.get(f'SHOWCASE_{role}_PASSWORD')
        self.name = name
        if not self.email or not self.password:
            sys.exit(f'Set SHOWCASE_{role}_EMAIL and SHOWCASE_{role}_PASSWORD.')
        body = {'email': self.email, 'password': self.password, 'returnSecureToken': True}
        status, res = call(f'{AUTH}:signInWithPassword?key={API_KEY}', body)
        if status != 200:
            status, res = call(f'{AUTH}:signUp?key={API_KEY}', body)
            if status != 200:
                sys.exit(f'{self.email}: sign-in failed: {res.get("error", res)}')
            call(f'{AUTH}:update?key={API_KEY}', {'idToken': res['idToken'], 'displayName': name})
            print(f'Created account {self.email}')
        self.token, self.uid = res['idToken'], res['localId']
        _, info = call(f'{AUTH}:lookup?key={API_KEY}', {'idToken': self.token})
        self.verified = info['users'][0].get('emailVerified', False)

    def send_verification(self):
        call(f'{AUTH}:sendOobCode?key={API_KEY}', {'requestType': 'VERIFY_EMAIL', 'idToken': self.token})


def ensure_profile(a, *, username=None, photo=None, payout=False):
    now = datetime.datetime.now(UTC)
    create(a.token, f'users/{a.uid}', {
        'displayName': a.name, 'email': a.email, 'visibility': 'public',
        'notifications': {'orderUpdates': True, 'saleUpdates': True, 'payoutUpdates': True,
                          'priceAlerts': True, 'eventReminders': True, 'newsletter': False,
                          'email': True, 'push': False},
        'createdAt': now,
    }, f'profile {a.name}', times=())
    create(a.token, f'publicProfiles/{a.uid}', {'displayName': a.name, 'visibility': 'public'},
           f'public profile {a.name}', times=())
    if photo and get(a.token, f'users/{a.uid}').get('photo') is None:
        commit(a.token, [update_op(f'users/{a.uid}', {'photo': photo}),
                         update_op(f'publicProfiles/{a.uid}', {'photo': photo})], f'photo {a.name}')
    if username and get(a.token, f'users/{a.uid}').get('username') is None \
            and get(a.token, f'usernames/{username}') is None:
        commit(a.token, [
            set_op(f'usernames/{username}', {'uid': a.uid}),
            update_op(f'users/{a.uid}', {'username': username}),
            update_op(f'publicProfiles/{a.uid}', {'username': username}),
        ], f'username @{username}')
    if payout:
        create(a.token, f'users/{a.uid}/private/payoutMethod',
               {'accountHolder': a.name, 'iban': 'BA391290079401028494'},
               'payout method', times=('updatedAt',))


# ---- Pictures (made here, no stock photos) ----------------------------------

def picture(text, color, size=(1280, 720), max_chars=380000):
    from PIL import Image, ImageDraw, ImageFont
    img = Image.new('RGB', size, color)
    draw = ImageDraw.Draw(img)
    w, h = size
    # A few neutral shapes, so the picture isn't a flat block.
    for i in range(6):
        r = int(h * (0.25 + 0.12 * i))
        draw.ellipse((w - r - 40 * i, h - r // 2, w + r - 40 * i, h + r * 1.5), outline=(255, 255, 255), width=3)
    font = None
    for path in ('/usr/share/fonts/opentype/inter/Inter-Bold.otf',
                 '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'):
        if os.path.exists(path):
            font = ImageFont.truetype(path, int(h * 0.11))
            break
    draw.text((int(w * 0.06), int(h * 0.62)), text, fill=(255, 255, 255), font=font or ImageFont.load_default())
    for quality in (82, 70, 60, 50):
        buf = io.BytesIO()
        img.save(buf, 'JPEG', quality=quality)
        data = base64.b64encode(buf.getvalue()).decode()
        if len(data) <= max_chars:
            return data
    return data


# ---- Events, listings, orders ----------------------------------------------

def day(d, hour):
    now = datetime.datetime.now(UTC)
    local = now + datetime.timedelta(days=d)
    # Event times in Sarajevo (UTC+1/+2): store at hour-2 UTC, rounded.
    return local.replace(hour=(hour - 2) % 24, minute=0, second=0, microsecond=0)


def event_info(e):
    return {k: e[k] for k in ('name', 'venue', 'city', 'date', 'category')}


def ensure_event(a, eid, e, *, status, reader, image=None):
    """Creates the event (and picture) as [a]: the team adds confirmed ones,
    users pending ones. [reader] (the team) checks whether it exists: users
    may not read events that don't exist yet."""
    existing = get(reader.token, f'events/{eid}')
    if existing is not None:
        print(f'  exists: event {e["name"]} ({existing.get("status")})')
        return existing
    fields = {**e, 'status': 'confirmed' if status == 'hidden' else status, 'createdBy': a.uid,
              'hasImage': image is not None, 'imageVersion': 1}
    writes = [set_op(f'events/{eid}', fields, times=('createdAt', 'updatedAt'))]
    if image:
        writes.append(set_op(f'eventImages/{eid}', {'data': image}, times=('updatedAt',)))
    commit(a.token, writes, f'event {e["name"]} ({fields["status"]})')
    if status == 'hidden':
        commit(a.token, [update_op(f'events/{eid}', {'status': 'hidden'}, times=('updatedAt',))],
               f'event {e["name"]} hidden')
    return get(reader.token, f'events/{eid}')


def ensure_listing(seller, lid, eid, e, fees, *, quantity, price, section='', row='', seats='', note=''):
    create(seller.token, f'listings/{lid}', {
        'sellerId': seller.uid, 'eventId': eid, 'event': event_info(e),
        'buyerFeePercent': fees[0], 'sellerFeePercent': fees[1],
        'ticketType': 'eTicket', 'quantity': quantity, 'quantitySold': 0,
        'priceMinor': price, 'currency': 'BAM', 'status': 'active',
        'section': section, 'row': row, 'seats': seats, 'note': note,
    }, f'listing {lid}')
    return get(seller.token, f'listings/{lid}')


def order_number():
    chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    return 'SSW-' + ''.join(random.choice(chars) for _ in range(6))


def step(status):
    return {'status': status, 'at': datetime.datetime.now(UTC)}


def ensure_order(buyer, oid, lid, quantity):
    order = get(buyer.token, f'orders/{oid}')
    if order is not None:
        return order
    listing = get(buyer.token, f'listings/{lid}')
    data = {
        'number': order_number(), 'listingId': lid, 'buyerId': buyer.uid,
        'sellerId': listing['sellerId'], 'event': listing['event'],
        'buyerFeePercent': listing.get('buyerFeePercent', 10),
        'sellerFeePercent': listing.get('sellerFeePercent', 10),
        'quantity': quantity, 'unitPriceMinor': listing['priceMinor'], 'currency': listing['currency'],
        'ticketType': listing['ticketType'], 'section': listing.get('section', ''),
        'row': listing.get('row', ''), 'seats': listing.get('seats', ''),
        'status': 'pendingPayment', 'history': [step('pendingPayment')], 'testMode': True,
        'createdAt': datetime.datetime.now(UTC),
    }
    commit(buyer.token, [set_op(f'orders/{oid}', data)], f'order {oid} ({data["number"]})')
    return get(buyer.token, f'orders/{oid}')


def pay(buyer, oid):
    """The payment simulator's transaction: order paid, tickets taken off the
    listing, seller payout started."""
    o = get(buyer.token, f'orders/{oid}')
    if o['status'] != 'pendingPayment':
        return
    l = get(buyer.token, f'listings/{o["listingId"]}')
    sold = l['quantitySold'] + o['quantity']
    sub = o['unitPriceMinor'] * o['quantity']
    fee = o.get('sellerFeePercent', 10)
    earnings = sub - int(sub * fee / 100 + 0.5)
    commit(buyer.token, [
        update_op(f'orders/{oid}', {'status': 'paid', 'paymentId': f'pi_test_{oid}',
                                   'paymentMethod': 'Visa •••• 4242'},
                  times=('updatedAt',), append={'history': [step('paid')]}),
        update_op(f'listings/{o["listingId"]}', {
            'quantitySold': sold,
            'status': 'soldOut' if sold == l['quantity'] else l['status'],
            'lastOrderId': oid}, times=('updatedAt',)),
        set_op(f'payouts/{oid}', {
            'sellerId': o['sellerId'], 'orderId': oid, 'orderNumbers': [o['number']],
            'amountMinor': earnings, 'currency': o['currency'], 'status': 'pending',
            'expectedAt': o['event']['date'] + datetime.timedelta(days=5),
            'history': [step('pending')], 'testMode': True,
            'createdAt': datetime.datetime.now(UTC)}),
    ], f'order {oid} paid')


def fail_payment(buyer, oid):
    o = get(buyer.token, f'orders/{oid}')
    if o['status'] != 'pendingPayment':
        return
    commit(buyer.token, [update_op(f'orders/{oid}', {'status': 'cancelled', 'failureReason': 'cardDeclined'},
                                   times=('updatedAt',), append={'history': [step('cancelled')]})],
           f'order {oid} payment failed')


def send_tickets(seller, oid):
    o = get(seller.token, f'orders/{oid}')
    if o['status'] != 'paid':
        return
    commit(seller.token, [update_op(f'orders/{oid}', {'status': 'ticketsSent'}, times=('updatedAt',),
                                    append={'history': [step('ticketsSent')]})], f'order {oid} tickets sent')


def cancel_sale(seller, oid):
    o = get(seller.token, f'orders/{oid}')
    if o['status'] not in ('paid', 'ticketsSent'):
        return
    l = get(seller.token, f'listings/{o["listingId"]}')
    commit(seller.token, [
        update_op(f'orders/{oid}', {'status': 'refunded', 'cancelledBy': 'seller'}, times=('updatedAt',),
                  append={'history': [step('refunded')]}),
        update_op(f'listings/{o["listingId"]}', {
            'quantitySold': l['quantitySold'] - o['quantity'],
            'status': 'active' if l['status'] == 'soldOut' else l['status'],
            'lastOrderId': oid}, times=('updatedAt',)),
        delete_op(f'payouts/{oid}'),
    ], f'order {oid} cancelled by the seller')


def withdraw(seller, lid):
    l = get(seller.token, f'listings/{lid}')
    if l['status'] != 'active':
        return
    commit(seller.token, [update_op(f'listings/{lid}', {'status': 'withdrawn'}, times=('updatedAt',))],
           f'listing {lid} withdrawn')


# ---- Support ---------------------------------------------------------------

def ensure_ticket(a, tid, *, topic, reference, text, images=()):
    if get(a.token, f'supportTickets/{tid}') is not None:
        print(f'  exists: support request {tid}')
        return False
    subject = ' '.join(text.split())
    subject = subject if len(subject) <= 80 else subject[:79] + '…'
    number = 'SUP-' + ''.join(random.choice('ABCDEFGHJKLMNPQRSTUVWXYZ23456789') for _ in range(6))
    commit(a.token, [
        set_op(f'supportTickets/{tid}', {
            'number': number, 'uid': a.uid, 'email': a.email, 'name': a.name, 'topic': topic,
            'reference': reference, 'subject': subject, 'status': 'open',
            'unreadForUser': False, 'unreadForStaff': True, 'appVersion': 'showcase'},
            times=('createdAt', 'lastMessageAt')),
        set_op(f'supportTickets/{tid}/messages/m1', {
            'authorId': a.uid, 'authorRole': 'user', 'authorName': a.name, 'text': text,
            'images': list(images)}, times=('createdAt',)),
    ], f'support request {tid} ({number})')
    return True


def staff_answer(staff, tid, text):
    commit(staff.token, [
        set_op(f'supportTickets/{tid}/messages/m2', {
            'authorId': staff.uid, 'authorRole': 'staff', 'authorName': staff.name, 'text': text,
            'images': []}, times=('createdAt',)),
        update_op(f'supportTickets/{tid}', {'status': 'answered', 'unreadForUser': True,
                                           'unreadForStaff': False}, times=('lastMessageAt',)),
    ], f'support request {tid} answered')


def user_close(a, tid):
    commit(a.token, [update_op(f'supportTickets/{tid}', {
        'status': 'closed', 'closedBy': 'user', 'unreadForStaff': False, 'unreadForUser': False})],
        f'support request {tid} closed by the user')


# ---- The showcase ----------------------------------------------------------

def main():
    seller = Account('SELLER', 'Test Prodavac')
    buyer = Account('BUYER', 'Test Kupac')
    staff = Account('STAFF', 'Test Podrška')

    blocked = False
    if not seller.verified:
        seller.send_verification()
        print(f'{seller.email}: email not confirmed. A confirmation email was sent: open the link, then run again.')
        blocked = True
    role = get(staff.token, f'roles/{staff.uid}')
    if not role or role.get('role') not in ('admin', 'support'):
        print(f'{staff.email} is not in the team yet: in the app, Administracija → Tim i podrška → '
              f'add "{staff.email}" as support (it has signed in now, so it can be found). Then run again.')
        ensure_profile(staff)
        blocked = True
    if blocked:
        sys.exit(1)

    random.seed(7)
    print('Profiles')
    ensure_profile(seller, username='test_prodavac', photo=picture('TP', (79, 70, 229), (256, 256), 150000),
                   payout=True)
    ensure_profile(buyer)
    ensure_profile(staff)
    fees_doc = get(seller.token, 'config/fees') or {}
    fees = (fees_doc.get('buyerPercent', 10), fees_doc.get('sellerPercent', 10))

    print('Events')
    concert = {'name': 'Test: Dubioza kolektiv', 'venue': 'Zetra', 'city': 'Sarajevo',
               'date': day(24, 20), 'category': 'concerts', 'genre': 'rock'}
    derby = {'name': 'Test: FK Sarajevo – FK Željezničar', 'venue': 'Koševo', 'city': 'Sarajevo',
             'date': day(12, 18), 'category': 'sports', 'genre': 'football'}
    jazz = {'name': 'Test: Mostar Jazz Night', 'venue': 'Stari most', 'city': 'Mostar',
            'date': day(30, 21), 'category': 'concerts', 'genre': 'jazz'}
    film = {'name': 'Test: Sarajevo Film Festival – Otvaranje', 'venue': 'Narodno pozorište',
            'city': 'Sarajevo', 'date': day(45, 19), 'category': 'festivals', 'genre': 'filmFestival'}
    hidden = {'name': 'Test: Skriveni događaj (duplikat)', 'venue': 'Skenderija', 'city': 'Sarajevo',
              'date': day(20, 20), 'category': 'other', 'genre': 'otherEvent'}
    ensure_event(staff, 'showcase-concert', concert, status='confirmed', reader=staff, image=picture('Dubioza kolektiv', (124, 58, 237)))
    ensure_event(staff, 'showcase-derby', derby, status='confirmed', reader=staff, image=picture('Sarajevo – Željezničar', (22, 101, 52)))
    ensure_event(seller, 'showcase-jazz', jazz, status='pending', reader=staff, image=picture('Mostar Jazz Night', (30, 64, 175)))
    ensure_event(staff, 'showcase-film', film, status='confirmed', reader=staff)
    ensure_event(staff, 'showcase-hidden', hidden, status='hidden', reader=staff)

    print('Listings and orders')
    # Concert: one sold (tickets still to send), one open.
    ensure_listing(seller, 'showcase-concert-sold', 'showcase-concert', concert, fees,
                   quantity=2, price=4500, section='Parter', note='Prodano – karte treba poslati.')
    ensure_listing(seller, 'showcase-concert-open', 'showcase-concert', concert, fees,
                   quantity=4, price=5000, section='Tribina', row='3', seats='10–13')
    ensure_order(buyer, 'showcase-o-paid', 'showcase-concert-sold', 1)
    pay(buyer, 'showcase-o-paid')

    # Derby: one bought and delivered, one open; plus a withdrawn one.
    ensure_listing(seller, 'showcase-derby-sent', 'showcase-derby', derby, fees,
                   quantity=2, price=3000, section='Sjever', row='8')
    ensure_listing(seller, 'showcase-derby-open', 'showcase-derby', derby, fees,
                   quantity=6, price=3500, section='Istok')
    ensure_listing(seller, 'showcase-derby-withdrawn', 'showcase-derby', derby, fees,
                   quantity=2, price=2500, section='Jug', note='Povučena ponuda.')
    ensure_order(buyer, 'showcase-o-sent', 'showcase-derby-sent', 2)
    pay(buyer, 'showcase-o-sent')
    send_tickets(seller, 'showcase-o-sent')
    withdraw(seller, 'showcase-derby-withdrawn')

    # Jazz (unconfirmed): a sale the seller cancelled, an open listing with a
    # failed payment and one waiting for payment.
    ensure_listing(seller, 'showcase-jazz-refunded', 'showcase-jazz', jazz, fees,
                   quantity=2, price=2500)
    ensure_listing(seller, 'showcase-jazz-open', 'showcase-jazz', jazz, fees,
                   quantity=3, price=2800, section='Balkon')
    ensure_order(buyer, 'showcase-o-refunded', 'showcase-jazz-refunded', 1)
    pay(buyer, 'showcase-o-refunded')
    cancel_sale(seller, 'showcase-o-refunded')
    ensure_order(buyer, 'showcase-o-failed', 'showcase-jazz-open', 1)
    fail_payment(buyer, 'showcase-o-failed')
    ensure_order(buyer, 'showcase-o-pending', 'showcase-jazz-open', 1)

    # Film festival: a sold-out listing.
    ensure_listing(seller, 'showcase-film-soldout', 'showcase-film', film, fees,
                   quantity=1, price=8000, section='Parter')
    ensure_order(buyer, 'showcase-o-soldout', 'showcase-film-soldout', 1)
    pay(buyer, 'showcase-o-soldout')

    print('Support')
    paid = get(buyer.token, 'orders/showcase-o-paid')
    if ensure_ticket(buyer, 'showcase-t-open', topic='order', reference=paid['number'],
                     text='Platio sam kartu prije dva dana, a prodavac još nije poslao karte. Šta da radim?'):
        pass
    if ensure_ticket(buyer, 'showcase-t-answered', topic='account',
                     text='Kako mogu promijeniti svoje korisničko ime?', reference=''):
        staff_answer(staff, 'showcase-t-answered',
                     'Zdravo! Korisničko ime mijenjaš u Postavke → Uredi profil. Javi se ako zapne.')
    if ensure_ticket(buyer, 'showcase-t-closed', topic='other', reference='',
                     text='Da li mogu platiti karticom iz inostranstva?'):
        staff_answer(staff, 'showcase-t-closed', 'Da, prihvatamo sve Visa i Mastercard kartice.')
        user_close(buyer, 'showcase-t-closed')
    ensure_ticket(seller, 'showcase-t-picture', topic='sale', reference='',
                  text='Kupac kaže da QR kod ne radi. Šaljem snimak ekrana karte.',
                  images=[picture('QR', (55, 65, 81), (800, 800), 280000)])
    print('Done.')


if __name__ == '__main__':
    main()
