/// Sprüche-Katalog, gruppiert nach Berufsgruppe.
///
/// Reine Daten (keine Flutter-Abhängigkeit). Erweiterbar: einfach neue
/// Berufsgruppe + Liste ergänzen. „Allgemein" ist der Default.
abstract final class Sprueche {
  /// Reihenfolge = Anzeige-Reihenfolge im Auswahl-Overlay. „Allgemein" zuerst.
  static const List<String> berufsgruppen = [
    'Allgemein',
    'Büro',
    'Handwerk',
    'IT',
    'Pflege & Gesundheit',
    'Lehrkraft',
    'Gastro',
    'Einzelhandel',
    'Schicht',
  ];

  static const String defaultGruppe = 'Allgemein';

  static const Map<String, List<String>> katalog = {
    'Allgemein': [
      'Noch kurz durchhalten – der Feierabend ruft schon.',
      'Gleich gehört der Tag wieder dir.',
      'Arbeit ist die Zeit zwischen zwei Feierabenden.',
      'Der frühe Vogel kann mich mal – Hauptsache Feierabend.',
      'Countdown läuft. Sofa und Snacks warten.',
      'Feierabend ist der schönste Teil des Arbeitstags.',
      'Gleich ist Schluss – und dann: nichts müssen.',
    ],
    'Büro': [
      'Noch drei Mails, dann rollt der Bürostuhl in den Feierabend.',
      'Excel schließt sich gleich von selbst – versprochen.',
      'Das Meeting hätte eine E-Mail sein können. Der Feierabend nicht.',
      'Kaffee leer, Akku leer – Zeit für Feierabend.',
    ],
    'Handwerk': [
      'Werkzeug weg, Hände wusch – gleich ist Feierabend.',
      'Nach getaner Arbeit schmeckt das Feierabendbier am besten.',
      'Maß genommen, Feierabend passt genau.',
      'Erst der Kunde, dann das Sofa.',
    ],
    'IT': [
      'Gleich noch deployen, dann in den Feierabend mergen.',
      'Ticket zu, Rechner aus, Feierabend committed.',
      'Works on my Feierabend.',
      'Ctrl + S für den Tag – und ab ins Wochenende-Branch.',
    ],
    'Pflege & Gesundheit': [
      'Schicht bald geschafft – du machst das großartig.',
      'Noch eine Runde, dann hast du es dir verdient.',
      'Dienst zu Ende, jetzt bist du dran.',
      'Herz gezeigt – jetzt Feierabend gönnen.',
    ],
    'Lehrkraft': [
      'Pausenklingel für dich: gleich Feierabend.',
      'Hausaufgaben für heute: entspannen.',
      'Stundenplan sagt jetzt – frei.',
      'Kreide weg, Füße hoch.',
    ],
    'Gastro': [
      'Letzte Bestellung raus, gleich Feierabend rein.',
      'Bon abgerissen, Schürze ab – geschafft.',
      'Nach dem Service ist vor dem Sofa.',
      'Gäste satt, du gleich frei.',
    ],
    'Einzelhandel': [
      'Kasse gleich zu, Feierabend offen.',
      'Regal voll, Akku leer – gleich Schluss.',
      'Letzter Kunde, dann gehört der Laden dir – zum Gehen.',
      'Rollladen runter, Laune rauf.',
    ],
    'Schicht': [
      'Schicht im Schacht – gleich ist Feierabend.',
      'Nacht wird Tag, Arbeit wird frei.',
      'Noch ein bisschen, dann übernimmt das Bett.',
      'Durchgehalten – jetzt kommt die Ruhe.',
    ],
  };

  /// Liefert die Spruchliste einer Gruppe (Fallback: Allgemein).
  static List<String> forGruppe(String gruppe) =>
      katalog[gruppe] ?? katalog[defaultGruppe]!;
}
