# Système de Gestion de Bibliothèque avec XQuery

Ce projet implémente un système complet de gestion de bibliothèque utilisant BaseX (moteur de base de données XML) et XQuery pour les opérations CRUD sur les livres, utilisateurs et prêts.

## Table des matières

- [Architecture du projet](#architecture-du-projet)
- [Prérequis et installation](#prérequis-et-installation)
- [Configuration de l'environnement](#configuration-de-lenvironnement)
- [Structure de la base de données](#structure-de-la-base-de-données)
- [Mise en place de la base de données](#mise-en-place-de-la-base-de-données)
- [Exécution des requêtes](#exécution-des-requêtes)
- [Documentation des modules](#documentation-des-modules)
- [Exemples d'utilisation](#exemples-dutilisation)

## Architecture du projet

```text
EXAMEN_XML/
├── data/
│   └── v2/
│       ├── bibliotheque.xml
│       └── bibliotheque.xsd
├── queries/
│   ├── livre/
│   │   ├── create_livre.xq
│   │   ├── delete_livre.xq
│   │   ├── est_emprunte.xq
│   │   ├── rechercher_livres.xq
│   │   └── update_livre.xq
│   ├── pret/
│   │   ├── emprunter_livre.xq
│   │   ├── historique_utilisateur.xq
│   │   ├── prets_en_cours.xq
│   │   ├── prets_en_retard.xq
│   │   └── retourner_livre.xq
│   ├── setup/
│   │   └── create_database.xq
│   └── utilisateur/
│       ├── create_utilisateur.xq
│       ├── delete_utilisateur.xq
│       ├── rechercher_utilisateurs.xq
│       └── update_utilisateur.xq
└── README.md
```

## Prérequis et installation

### Outils requis

#### BaseX (Moteur XQuery)

- **Windows** : Télécharger depuis [BaseX.org](https://basex.org/download/)
- **macOS** :

  ```bash
  brew install basex
  ```

- **Linux (Ubuntu/Debian)** :

  ```bash
  sudo apt-get install basex
  ```

#### Visual Studio Code (Éditeur recommandé)

- **Tous OS** : Télécharger depuis [code.visualstudio.com](https://code.visualstudio.com/)

#### Extensions VS Code recommandées

- **XML Tools** : Pour la validation et formatage XML/XSD
- **XQuery** : Support syntaxique pour XQuery
- **XML Language Support** : IntelliSense pour XML

#### xq (Formateur de sortie)

- **Installation** :

  ```bash
  # macOS
  brew install python-yq
  
  # Linux
  pip install yq
  
  # Windows
  pip install yq
  ```

### Alternatives par OS

| Outil | Windows | macOS | Linux |
|-------|---------|--------|-------|
| BaseX | .exe installer | Homebrew / .jar | apt-get / .jar |
| VS Code | .exe installer | .dmg / Homebrew | .deb / snap |
| xq | pip install | brew / pip | pip install |

## Configuration de l'environnement

### 1. Configuration BaseX

Après installation, créer la structure dans le dossier BaseX :

```text
[BaseX_Installation]/
├── data/
│   ├── v1/
│   └── v2/
│       ├── bibliotheque.xml
│       └── bibliotheque.xsd
└── queries/
    ├── livre/
    ├── pret/
    ├── setup/
    └── utilisateur/
```

### 2. Variables d'environnement

Ajouter BaseX au PATH :

**Windows** :

```cmd
set PATH=%PATH%;C:\BaseX\bin
```

**macOS/Linux** :

```bash
export PATH=$PATH:/path/to/basex/bin
```

### 3. Configuration VS Code

Créer `.vscode/settings.json` :

```json
{
    "files.associations": {
        "*.xq": "xquery",
        "*.xquery": "xquery"
    },
    "xml.validation.enabled": true,
    "xml.format.enabled": true
}
```

## Structure de la base de données

### Schéma XSD

Le fichier `bibliotheque.xsd` définit :

- **Livres** : ISBN (unique), titre, auteur, genre, année, disponibilité, prix
- **Utilisateurs** : ID (unique), nom, prénom, email (unique)
- **Prêts** : ID (unique), références livre/utilisateur, dates, statut

### Contraintes de validation

- Prix livre > 0
- Email unique par utilisateur
- ID prêt unique
- Statut prêt : "en cours" ou "retourné"

## Mise en place de la base de données

### Méthode 1 : Script automatique

```bash
basex queries/setup/create_database.xq
```

### Méthode 2 : Commandes BaseX manuelles

```bash
# Lancer BaseX en mode interactif
basex

# Dans BaseX :
CREATE DB isi_bibliotheque data/v2/bibliotheque.xml
```

### Méthode 3 : GUI BaseX

#### Lancement du GUI

**Windows** :

```cmd
basexgui.bat
```

**macOS** :

```bash
basexgui
```

**Linux** :

```bash
basexgui
```

#### Étapes dans le GUI

1. **Database** → **New...**
2. Nom : `isi_bibliotheque`
3. Sélectionner `data/v2/bibliotheque.xml`
4. **OK**

## Exécution des requêtes

### 1. Ligne de commande avec variables externes

#### Recherche multi-critères livres

```bash
basex -b auteur="George" -b prix-min="10.0" queries/livre/rechercher_livres.xq | xq
```

#### Création livre

```bash
basex -c "OPEN isi_bibliotheque" -b isbn="L004" -b titre="Nouveau Livre" -b auteur="Nouvel Auteur" -b genre="Roman" -b annee="2023" -b disponible="true" -b prix="19.99" queries/livre/create_livre.xq
```

#### Création utilisateur

```bash
basex -w -b id="U004" -b nom="Doe" -b prenom="John" -b email="john.doe@example.com" queries/utilisateur/create_utilisateur.xq
```

#### Emprunt livre

```bash
basex -b utilisateur-id="U004" -b livre-isbn="L006" queries/pret/emprunter_livre.xq | xq
```

### 2. GUI BaseX

1. Ouvrir la base `isi_bibliotheque`
2. Dans l'éditeur, copier le code XQuery
3. Utiliser **Variables** → **External Variables** pour définir les paramètres
4. **Query** → **Execute**

### 3. Options de formatage

- `| xq` : Formatage XML coloré
- `-w` : Mode écriture (pour les mises à jour)
- `-c "OPEN database"` : Ouverture de base spécifique

## Documentation des modules

### Module `livre`

#### `create_livre.xq`

Création d'un nouveau livre avec validation XSD.
**Variables** : `isbn`, `titre`, `auteur`, `genre`, `annee`, `disponible`, `prix`

#### `est_emprunte.xq`

Module fonction vérifiant le statut d'emprunt d'un livre.
**Fonction** : `livre:est-emprunte($isbn)`

#### `rechercher_livres.xq`

Recherche multi-critères avec pagination.
**Variables** : `isbn`, `titre`, `auteur`, `genre`, `annee-min`, `annee-max`, `disponible`, `prix-min`, `prix-max`, `page`, `page-size`

### Module `utilisateur`

#### `create_utilisateur.xq`

Création utilisateur avec validation email unique.
**Variables** : `id`, `nom`, `prenom`, `email`

#### `rechercher_utilisateurs.xq`

Recherche utilisateurs multi-critères.
**Variables** : `id`, `nom`, `prenom`, `email`, `page`, `page-size`

### Module `pret`

#### `emprunter_livre.xq`

Enregistrement d'un emprunt avec vérifications.
**Variables** : `livre-isbn`, `utilisateur-id`, `duree-jours`

#### `retourner_livre.xq`

Traitement du retour d'un livre.
**Variables** : `pret-id`

#### `prets_en_retard.xq`

Liste des prêts en retard.
**Variables** : `jours-retard-min`, `page`, `page-size`

## Exemples d'utilisation

### Workflow complet

1. **Créer la base** :

```bash
basex queries/setup/create_database.xq
```

2. **Ajouter un livre** :

```bash
basex -w -b isbn="L005" -b titre="Dune" -b auteur="Frank Herbert" -b genre="Science-Fiction" -b annee="1965" -b prix="18.99" queries/livre/create_livre.xq
```

3. **Créer un utilisateur** :

```bash
basex -w -b id="U005" -b nom="Smith" -b prenom="Alice" -b email="alice.smith@example.com" queries/utilisateur/create_utilisateur.xq
```

4. **Emprunter le livre** :

```bash
basex -w -b utilisateur-id="U005" -b livre-isbn="L005" queries/pret/emprunter_livre.xq
```

5. **Vérifier les prêts en cours** :

```bash
basex queries/pret/prets_en_cours.xq | xq
```

### Requêtes de recherche

```bash
# Livres par auteur
basex -b auteur="George" queries/livre/rechercher_livres.xq | xq

# Utilisateurs par nom
basex -b nom="Dupont" queries/utilisateur/rechercher_utilisateurs.xq | xq

# Prêts en retard
basex -b jours-retard-min="1" queries/pret/prets_en_retard.xq | xq
```

## Validation et intégrité

Toutes les opérations de création/modification incluent :

- **Validation XSD** contre le schéma
- **Vérification d'unicité** (ISBN, email, ID prêt)
- **Contraintes métier** (prix positif, dates cohérentes)
- **Gestion d'erreurs** avec messages explicites

Le système utilise `update:output()` pour les opérations de mise à jour et retourne des résultats structurés avec statut de succès/erreur.
