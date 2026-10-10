// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get appTitle => 'Flat';

  @override
  String get loginTitle => 'Prijava';

  @override
  String get loginSubtitle => 'Prijavite se na svoj račun';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Lozinka';

  @override
  String get loginButton => 'Prijavi se';

  @override
  String get logoutButton => 'Odjavi se';

  @override
  String get emailRequired => 'Unesite e-mail adresu';

  @override
  String get emailInvalid => 'Unesite ispravnu e-mail adresu';

  @override
  String get passwordRequired => 'Unesite lozinku';

  @override
  String get errorInvalidCredentials => 'Pogrešan e-mail ili lozinka';

  @override
  String get errorUserDisabled => 'Ovaj račun je deaktiviran';

  @override
  String get errorTooManyRequests =>
      'Previše pokušaja. Pokušajte ponovo kasnije';

  @override
  String get errorNetwork => 'Nema internet konekcije';

  @override
  String get errorUnknown => 'Došlo je do greške. Pokušajte ponovo';

  @override
  String get dashboardTitle => 'Kontrolna tabla';

  @override
  String welcome(String email) {
    return 'Dobrodošli, $email';
  }

  @override
  String get dashboardEmpty => 'Ovdje još nema ničega.';

  @override
  String get language => 'Jezik';

  @override
  String get showPassword => 'Prikaži lozinku';

  @override
  String get hidePassword => 'Sakrij lozinku';
}
