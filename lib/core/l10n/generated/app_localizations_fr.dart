// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Oufoq Platform';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCategories => 'Rubriques';

  @override
  String get navBookmarks => 'Favoris';

  @override
  String get navSettings => 'Réglages';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get clear => 'Effacer';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get loading => 'Chargement…';

  @override
  String get errorNoInternet =>
      'Aucune connexion Internet. Vérifiez votre réseau et réessayez.';

  @override
  String get errorServer =>
      'Le serveur est actuellement inaccessible. Veuillez réessayer plus tard.';

  @override
  String get errorTimeout => 'Délai de connexion dépassé. Veuillez réessayer.';

  @override
  String get errorUnknown =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get errorEmptyCache => 'Aucune donnée enregistrée pour le moment.';

  @override
  String get errorViewTitle => 'Une erreur est survenue';

  @override
  String get errorViewBody =>
      'Impossible de charger le contenu. Vous pouvez réessayer.';

  @override
  String get emptyDefaultTitle => 'Rien ici pour le moment';

  @override
  String get emptyDefaultBody =>
      'Les dernières actualités apparaîtront ici dès qu\'elles seront disponibles.';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int count) {
    return 'il y a $count minutes';
  }

  @override
  String hoursAgo(int count) {
    return 'il y a $count heures';
  }

  @override
  String daysAgo(int count) {
    return 'il y a $count jours';
  }

  @override
  String readingTimeMinutes(int count) {
    return '$count min de lecture';
  }

  @override
  String get breakingLabel => 'Urgent';

  @override
  String get featuredSection => 'À la une';

  @override
  String get latestNews => 'Dernières actualités';

  @override
  String get categoryAllChip => 'Tout';

  @override
  String get offlineBanner =>
      'Vous êtes hors ligne — affichage du dernier contenu enregistré';

  @override
  String get searchButtonLabel => 'Rechercher';

  @override
  String get searchHint => 'Rechercher dans les actualités…';

  @override
  String get searchHistoryTitle => 'Recherches récentes';

  @override
  String get clearHistory => 'Effacer l\'historique';

  @override
  String get searchEmptyTitle => 'Aucun résultat correspondant';

  @override
  String get searchEmptyBody =>
      'Essayez d\'autres mots-clés pour trouver ce que vous cherchez.';

  @override
  String get bookmarksTitle => 'Favoris';

  @override
  String get bookmarksEmptyTitle => 'Aucun article enregistré';

  @override
  String get bookmarksEmptyBody =>
      'Enregistrez les articles qui vous intéressent pour les lire hors ligne.';

  @override
  String get bookmarkAdded => 'Article enregistré dans les favoris';

  @override
  String get bookmarkRemoved => 'Article retiré des favoris';

  @override
  String get saveArticle => 'Enregistrer l\'article';

  @override
  String get removeBookmark => 'Retirer des favoris';

  @override
  String get articleNotFound => 'Article introuvable';

  @override
  String get relatedArticles => 'Articles associés';

  @override
  String get fontScaleTitle => 'Taille de la police de lecture';

  @override
  String get fontSmall => 'Petite';

  @override
  String get fontMedium => 'Moyenne';

  @override
  String get fontLarge => 'Grande';

  @override
  String get fontExtraLarge => 'Très grande';

  @override
  String get fontPreviewText =>
      'Ceci est un texte d\'exemple pour prévisualiser la taille de la police de lecture sur Oufoq Platform.';

  @override
  String get shareArticle => 'Partager l\'article';

  @override
  String get openInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get openImage => 'Ouvrir l\'image';

  @override
  String get adLabel => 'Publicité';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get appearanceSection => 'Apparence et lecture';

  @override
  String get themeModeLabel => 'Thème';

  @override
  String get themeSystem => 'Par défaut du système';

  @override
  String get themeLight => 'Mode clair';

  @override
  String get themeDark => 'Mode sombre';

  @override
  String get fontScaleSection => 'Taille de police des articles';

  @override
  String get languageSection => 'Langue';

  @override
  String get languageLabel => 'Langue de l\'application';

  @override
  String get notificationsSection => 'Notifications et données';

  @override
  String get breakingNotificationsLabel =>
      'Notifications d\'actualités urgentes';

  @override
  String get dataSection => 'Données et stockage';

  @override
  String get clearCacheLabel => 'Effacer le cache';

  @override
  String get cacheClearedMessage =>
      'Cache effacé avec succès. Vos favoris sont conservés.';

  @override
  String get aboutSection => 'Oufoq Platform';

  @override
  String get aboutUs => 'À propos et rédaction';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String get privacyPolicy =>
      'Politique de confidentialité et conditions d\'utilisation';

  @override
  String get adsPrivacyOptions => 'Options de confidentialité des publicités';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get notificationsEnabled =>
      'Notifications d\'actualités urgentes activées';

  @override
  String get notificationsDisabled =>
      'Notifications d\'actualités urgentes désactivées';

  @override
  String get aboutTitle => 'À propos et rédaction';

  @override
  String get aboutBody =>
      'Oufoq Platform est une organisation de presse arabe indépendante engagée à fournir des informations précises et des reportages approfondis avec rapidité et professionnalisme, dans le respect de l\'éthique journalistique et du temps du lecteur.';

  @override
  String get editorialBody =>
      'L\'équipe de rédaction applique une politique stricte de vérification des faits avant publication et sépare clairement actualités, opinions et publicité.';

  @override
  String get contactTitle => 'Nous contacter';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get websiteLabel => 'Site web';

  @override
  String get categoriesTitle => 'Rubriques';

  @override
  String articlesCount(int count) {
    return '$count articles';
  }

  @override
  String get notificationChannelName => 'Actualités urgentes - Oufoq Platform';

  @override
  String get notificationChannelDescription =>
      'Alertes instantanées pour les événements urgents';
}
