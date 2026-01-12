# Diagnostic - Ogasso Employé

**Date :** 19 décembre 2024
**Projet :** ogasso_employe
**Version actuelle :** 1.0.0+1

---

## Résumé de la situation actuelle

### Ce qui a été fait
- Installation de FlutterFire CLI (`flutterfire_cli 1.3.1`)
- Ajout du PATH pour pub-cache dans `~/.zshrc`
- Tentative de configuration Firebase avec `flutterfire configure`

### Problèmes rencontrés
1. **Firebase CLI manquant** - FlutterFire CLI nécessite la CLI Firebase officielle
2. **Aucun projet Firebase trouvé** lors de la tentative de configuration
3. **Erreur `compdef` dans zsh** après modification du `.zshrc`

---

## État actuel du projet

### Configuration Firebase

| Élément | Android | iOS |
|---------|---------|-----|
| Config Firebase | ✅ `google-services.json` présent | ❌ `GoogleService-Info.plist` **MANQUANT** |
| Projet Firebase | `ogasso-1b960` | Non configuré |
| App ID | `com.example.ogasso_employe` | `com.example.ogassoEmploye` |

### Fichier manquant critique
- ❌ **`lib/firebase_options.dart`** - Ce fichier doit être généré par `flutterfire configure`

### Problèmes de configuration Android

| Paramètre | Valeur actuelle | Valeur requise (2024) |
|-----------|-----------------|----------------------|
| `compileSdkVersion` | 30 | **34** |
| `minSdkVersion` | 16 | **21** (minimum pour Firebase moderne) |
| `targetSdkVersion` | 30 | **34** (requis Play Store) |
| `key.properties` | ❌ Manquant | Requis pour la signature release |

### Problèmes de configuration iOS
- ❌ `GoogleService-Info.plist` manquant
- ⚠️ Bundle identifier `com.example.ogassoEmploye` à changer pour production

### Problèmes d'environnement local
- ❌ Flutter n'est pas dans le PATH
- ❌ Homebrew n'est pas configuré (`/opt/homebrew/bin/brew` introuvable)

---

## Plan d'action - Prochaines étapes

### Étape 1 : Corriger l'environnement de développement

```bash
# 1. Installer Homebrew (si pas installé)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Ajouter Homebrew au PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile

# 3. Vérifier/réinstaller Flutter
brew install flutter

# 4. Installer Firebase CLI
brew install firebase-cli
# OU via npm
npm install -g firebase-tools

# 5. Se connecter à Firebase
firebase login

# 6. Vérifier l'installation
firebase --version
flutter doctor
```

### Étape 2 : Configurer Firebase correctement

```bash
# 1. Activer FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. S'assurer que le PATH inclut pub-cache
export PATH="$PATH":"$HOME/.pub-cache/bin"

# 3. Configurer Firebase pour le projet
cd "/Users/eerg/Desktop/Archive ogasso/ogasso-employe-master"
flutterfire configure --project=ogasso-1b960
```

Cette commande va :
- Générer `lib/firebase_options.dart`
- Créer/mettre à jour `GoogleService-Info.plist` pour iOS
- Mettre à jour `google-services.json` pour Android

### Étape 3 : Mettre à jour les SDK versions (Android)

Modifier `android/app/build.gradle` :

```gradle
android {
    compileSdkVersion 34  // Était 30

    defaultConfig {
        applicationId "com.ogasso.employe"  // Changer de com.example
        minSdkVersion 21    // Était 16
        targetSdkVersion 34 // Était 30
        // ...
    }
}
```

### Étape 4 : Configuration de la signature Android (Release)

1. **Générer un keystore** (si pas existant) :
```bash
keytool -genkey -v -keystore ~/ogasso-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ogasso
```

2. **Créer `android/key.properties`** :
```properties
storePassword=<votre_mot_de_passe>
keyPassword=<votre_mot_de_passe>
keyAlias=ogasso
storeFile=/Users/eerg/ogasso-upload-key.jks
```

### Étape 5 : Configuration iOS

1. **Ouvrir Xcode** :
```bash
open ios/Runner.xcworkspace
```

2. **Dans Xcode** :
   - Changer le Bundle Identifier : `com.ogasso.employe`
   - Configurer le Signing Team (compte Apple Developer)
   - Ajouter les capabilities Push Notifications

3. **Après `flutterfire configure`**, vérifier que `GoogleService-Info.plist` est ajouté au projet Xcode

### Étape 6 : Mettre à jour main.dart

```dart
import 'package:ogasso_employe/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Ajouter cette ligne
  );
  // ...
}
```

---

## Checklist avant publication

### Android (Play Store)
- [ ] `compileSdkVersion` = 34
- [ ] `targetSdkVersion` = 34
- [ ] `minSdkVersion` >= 21
- [ ] `key.properties` configuré avec keystore valide
- [ ] Application ID changé (pas `com.example.*`)
- [ ] `google-services.json` à jour
- [ ] Icône de l'app configurée
- [ ] Version incrémentée dans `pubspec.yaml`

### iOS (App Store)
- [ ] Bundle Identifier changé (pas `com.example.*`)
- [ ] `GoogleService-Info.plist` présent dans Runner
- [ ] Signing configuré avec compte Apple Developer
- [ ] Push Notifications capability ajoutée
- [ ] Icône de l'app configurée
- [ ] Version incrémentée

### Firebase
- [ ] `firebase_options.dart` généré
- [ ] Projet Firebase `ogasso-1b960` accessible
- [ ] Apps iOS et Android enregistrées dans Firebase Console

---

## Estimation des tâches

| Tâche | Complexité |
|-------|------------|
| Configuration environnement | Faible |
| Firebase setup complet | Moyenne |
| Mise à jour SDK Android | Faible |
| Configuration signature Android | Moyenne |
| Configuration iOS/Xcode | Moyenne |
| Tests et validation | Variable |

---

## Ressources utiles

- [FlutterFire CLI Documentation](https://firebase.flutter.dev/docs/cli/)
- [Firebase CLI Installation](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- [Android App Signing](https://docs.flutter.dev/deployment/android#signing-the-app)
- [iOS Deployment](https://docs.flutter.dev/deployment/ios)

---

## Notes importantes

1. **Le projet Firebase `ogasso-1b960` existe déjà** - Il faut s'assurer d'avoir accès à ce projet dans la Firebase Console

2. **Le `google-services.json` actuel contient 2 apps** :
   - `com.example.ogasso_client`
   - `com.example.ogasso_employe`

   Cela suggère qu'il y a probablement une autre app (client) liée au même projet Firebase.

3. **API Key exposée** dans `google-services.json` - C'est normal pour Firebase, mais assurez-vous que les règles de sécurité Firebase sont correctement configurées.
