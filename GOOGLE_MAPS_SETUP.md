# Configuration Google Maps

## Étapes pour configurer Google Maps dans votre application Flutter

### 1. Obtenir une clé API Google Maps

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API "Maps SDK for Android" et "Maps SDK for iOS"
4. Allez dans "Identifiants" et créez une clé API
5. Configurez les restrictions de votre clé API :
   - Pour Android : ajoutez le nom de votre package (ex: `com.example.projet_flutter`)
   - Pour iOS : ajoutez l'ID de votre bundle (ex: `com.example.projetFlutter`)

### 2. Configuration Android

Remplacez `YOUR_GOOGLE_MAPS_API_KEY_HERE` dans le fichier `android/app/src/main/AndroidManifest.xml` par votre vraie clé API :

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="VOTRE_CLE_API_ICI" />
```

### 3. Configuration iOS

Remplacez `YOUR_GOOGLE_MAPS_API_KEY_HERE` dans le fichier `ios/Runner/AppDelegate.swift` par votre vraie clé API :

```swift
GMSServices.provideAPIKey("VOTRE_CLE_API_ICI")
```

### 4. Installation des dépendances

Exécutez la commande suivante pour installer les nouvelles dépendances :

```bash
flutter pub get
```

### 5. Nettoyage et reconstruction

```bash
flutter clean
flutter pub get
flutter run
```

## Notes importantes

- Ne commitez jamais votre clé API dans le contrôle de version
- Utilisez des variables d'environnement ou des fichiers de configuration séparés pour la production
- Configurez les restrictions appropriées sur votre clé API pour la sécurité
