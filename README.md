# Treasure Pot 🏴‍☠️

Application Flutter hors ligne pour accompagner un enfant de 2 à 4 ans dans l'apprentissage de la propreté grâce à une chasse au trésor ludique.

## V1

- Un seul enfant, deux parcours indépendants : **Pipi** et **Caca**.
- Nombre de réussites configurable séparément, minimum 1.
- Valeurs par défaut : 20 pipis et 5 cacas.
- Progressions et réglages persistés localement avec `SharedPreferences`.
- Aucun compte, serveur, Firebase, synchronisation, publicité ou achat intégré.
- Cinq étapes proportionnelles : skate, vélo, voiture, Monster Truck, avion.
- Coffre + confettis à la dernière case, puis remise à zéro automatique du parcours.

## Installation

```bash
git clone https://github.com/plsg78/treasure-pot.git
cd treasure-pot
flutter pub get
flutter run
```

Tests et analyse :

```bash
flutter analyze
flutter test
```

APK local :

```bash
flutter build apk --debug
```

## GitHub Actions

`.github/workflows/android.yml` installe Flutter stable, génère les fichiers Android nécessaires, récupère les dépendances, lance `flutter analyze`, `flutter test`, construit l'APK et publie `app-debug.apk` comme artifact.

Pour récupérer l'APK : **GitHub → Actions → Flutter Android → une exécution réussie → Artifacts → `treasure-pot-debug-apk`**.

Le workflow génère les fichiers de plateforme Android au moment du build afin de garder le dépôt minimal. Le code Flutter est portable Android/iOS.

## Structure

La V1 reste volontairement simple : `lib/main.dart` contient l'interface, les parcours et les animations ; `lib/settings.dart` contient les réglages ; `test/treasure_pot_test.dart` couvre le calcul des véhicules. Aucun BLoC, Provider, Riverpod ou serveur n'est utilisé.
