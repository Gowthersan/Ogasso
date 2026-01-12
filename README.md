# Ogasso Collaborateur

Application Flutter utilisée par les employé·es Ogasso pour gérer le menu, les réservations et la messagerie avec les clients. L’app consomme l’API Ogasso (`https://ogasso.pivot40.tech`) et s’appuie sur Firebase (FCM) pour les notifications.

## Prérequis
- Flutter SDK 2.x (Dart `>=2.7.0 <3.0.0`)
- Xcode / Android SDK configurés (émulateur ou appareil physique)
- Compte Firebase avec Firebase Messaging et fichiers de config ajoutés :
  - Android : `android/app/google-services.json`
  - iOS : `ios/Runner/GoogleService-Info.plist`
- Accès réseau vers l’API Ogasso (`ogasso.pivot40.tech`)

## Installation et lancement
1. Installer les dépendances :
   ```bash
   flutter pub get
   ```
2. Ajouter les fichiers Firebase (voir prérequis) et placer l’icône `assets/ogasso.png` (déjà référencée).
3. Démarrer l’application :
   ```bash
   flutter run
   ```
   Utilisez un appareil réel ou un émulateur avec accès réseau.

## Fonctionnalités principales
- **Authentification** : formulaire de login (`/pages/login`) qui appelle `/api/account/login` puis stocke le `access_token` dans `SharedPreferences`.
- **Accueil** : affiche le profil collaborateur (restaurant, adresse) et un menu d’actions. Un badge signale les notifications locales non lues.
- **Menu** : consultation du menu du jour et ajustement des quantités en temps réel (`MenuPage`, `MenuDetailPage`). Seuils d’alerte/avertissement configurables dans les paramètres.
- **Réservations & commandes** :
  - Vue calendrier avec compteurs par jour (`ReservationPage`)
  - Détail d’une réservation/commande : statut, QR code, produits, coût total, infos livraison/retrait, paiement, confirmation (`ReservationDetailGeneralPage`)
  - Fiche client associée (historique, plats favoris) (`ReservationClientPage`)
- **Messagerie** : fil de messages lié à une réservation (`MessagerieWidget`), envoi et lecture via l’API chat.
- **Notifications** :
  - FCM en foreground/background (`PushNotificationService`) avec stockage local (`SharedPreferences`) et affichage local (`flutter_local_notifications`).
  - Tapping ouvre directement la réservation concernée.
- **Paramètres** : définition des seuils d’alerte/avertissement pour les stocks (`SettingPage`), persistés localement.

## Architecture & organisation
- **Gestion d’état** : BLoC/Cubit (`flutter_bloc`, `bloc`). Chaque page principale dispose de son `Cubit` dédié (auth, home, menu, réservation, messagerie, paramètres).
- **Services HTTP** (`lib/services/repository/`) :
  - `api_service.dart` : hôte API (`ogasso.pivot40.tech`)
  - `auth_service.dart` : login, profil, mise à jour device token
  - `menu_service.dart` : menu du jour, modifications de quantités
  - `reservation_service.dart` : réservations/commandes, produits, confirmation/annulation, favoris
  - `chat_service.dart` : messagerie liée à une réservation
  - `push_notification_service.dart` & `local_notification_service.dart` : FCM + notifications locales
  - `setting_service.dart` : seuils persistés localement
- **Entités** : modèles JSON dans `lib/services/entities/` (profil, menu, produit, réservation, etc.).
- **Widgets partagés** : `lib/shared/` (utilitaires couleur/date, avatar circulaire, listes de produits).

## Flux clés
1. **Démarrage** (`SplashScreenPage`) :
   - Vérifie le token stocké.
   - Si valide : récupère le profil via `/api/profil/search/by-account`, enregistre le device token FCM via `updateAccount`, puis redirige vers l’accueil.
   - Si invalide/expiré : efface le token et renvoie vers le login.
2. **Notifications** :
   - Background : `_firebaseMessagingBackgroundHandler` initialise Firebase + notifications locales, persiste la notification et la publie dans le flux.
   - Foreground : `PushNotificationService.onMessage` affiche une notif locale et ajoute l’entrée au store local.
   - L’écran notifications ouvre la réservation correspondante (`NotificationCubit.openReservation`).
3. **Menu** :
   - Récupère le menu du jour du restaurant connecté.
   - Incrémente/décrémente ou saisie directe d’une quantité (`MenuCubit`, `MenuDetailCubit`), avec feedback immédiat puis synchro API.
4. **Réservation/commande** :
   - Liste par date, détail complet, confirmation, vue client, messagerie.
   - Gestion des produits d’une commande (ajout/retrait, gratuités possibles) via `ProduitListCubit`.

## Configuration & personnalisation
- **Hôte API** : modifier `APIService.URL` si l’API change d’environnement.
- **Seuils d’alerte stock** : via l’écran Paramètre, valeurs stockées en local (par défaut `alert=0`, `warning=5`).
- **Icônes notifications Android** : `local_notification_service.dart` utilise l’icône `ogasso` (prévoir la ressource dans `android/app/src/main/res` si changée).
- **Couleurs avatars** : palette dans `UserAccount.AVATAR_COLOR` (utilisée pour badges et avatars).

## Tests et qualité
- Aucun test automatisé fourni. Recommandation : ajouter des tests widget pour les vues critiques (login, menu, réservation) et des tests d’intégration réseau mockés pour les services.

## Résolution de problèmes
- **Token invalide/401** : l’app efface le token et renvoie au login ; vérifier les identifiants et la disponibilité de l’API.
- **FCM non reçu** : vérifier les fichiers Firebase, les autorisations de notification, et que le device token est bien mis à jour (`SplashScreenPage`).
- **Images produits** : l’URL est construite à partir du champ `photoURL`. Si l’image ne s’affiche pas, vérifier le champ et l’accessibilité `http://ogasso.pivot40.tech/upload/...`.

## Structure des dossiers (extrait)
- `lib/main.dart` : bootstrap, init Firebase/FCM, observateur BLoC.
- `lib/pages/` : écrans (login, splash, home, menu, réservation, notifications, paramètres).
- `lib/services/` : appels API, modèles, notifications locales/FCM.
- `lib/shared/` : widgets et utilitaires réutilisables.
