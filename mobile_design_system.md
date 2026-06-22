# Mobile Application Design System Specification

Ce document définit les jetons de design, les composants graphiques et les règles d'ergonomie (UI/UX) de l'application mobile afin de permettre leur réplication exacte sur la plateforme Web (React/Vite/Tailwind).

---

## 🎨 Palette de Couleurs (Color Tokens)

### 1. Couleurs Primaires & Thème
| Rôle | Couleur Flutter | Code Hexadécimal | Équivalent Tailwind | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Primary (Dark Blue)** | `Color(0xFF1E3A8A)` | `#1E3A8A` | `bg-blue-900` | Barres d'outils, boutons principaux, splash screen |
| **Secondary (Emerald)** | `Color(0xFF10B981)` | `#10B981` | `bg-emerald-500` | Validation, boutons secondaires, gains / crédits |
| **Error (Red)** | `Color(0xFFEF4444)` | `#EF4444` | `bg-red-500` | Erreurs, alertes, déconnexions, débits / retraits |
| **Background (Light)** | `Color(0xFFF3F4F6)` | `#F3F4F6` | `bg-gray-100` | Arrière-plan général des pages |
| **Surface** | `Colors.white` | `#FFFFFF` | `bg-white` | Fonds de cartes, listes, formulaires |

### 2. Dégradés des Cartes Bancaires (Account Card Gradients)
Selon le type de compte, les cartes de solde possèdent des dégradés distincts :
- **COMPTE COURANT (Green Gradient) :**
  - Départ : `Colors.green.shade700` (`#2E7D32`)
  - Fin : `Colors.green.shade400` (`#66BB6A`)
- **COMPTE ÉPARGNE (Blue Gradient) :**
  - Départ : `Colors.blue.shade700` (`#1565C0`)
  - Fin : `Colors.blue.shade400` (`#42A5F5`)
- **MOBILE MONEY (Orange Gradient) :**
  - Départ : `Colors.orange.shade700` (`#E67E22`)
  - Fin : `Colors.orange.shade400` (`#F39C12`)

---

## 🔤 Typographie (Typography)

L'application utilise des polices géométriques modernes et hautement lisibles. Sur le Web, nous recommandons d'utiliser la police **Inter** ou **Roboto** (Google Fonts).

### Échelle Typographique
- **Titres de Page (Large Headers) :**
  - Style : `FontSize: 28px`, `FontWeight: Bold (900)`, `LetterSpacing: 4.0px` (utilisé sur le Splash / Logo)
- **Titres de Section :**
  - Style : `FontSize: 20px`, `FontWeight: Bold (700)`
- **Libellés de Cartes / Sous-titres importants :**
  - Style : `FontSize: 16px`, `FontWeight: Medium (500)`
- **Soldes Monétaires :**
  - Style : `FontSize: 28px`, `FontWeight: Bold (700)`
- **Corps de texte secondaire / Dates :**
  - Style : `FontSize: 12px` / `14px`, `FontWeight: Regular (400)`, `Color: Slate/Gray`

---

## 📐 Règles de Layout et Espacements (UI/UX Layout)

- **Border Radius (Coins arrondis) :**
  - Cartes bancaires de solde : `16px`
  - Cartes et panneaux secondaires : `12px`
  - Boutons et champs de formulaires : `8px`
- **Marges & Padding :**
  - Marges externes des écrans : `24px`
  - Padding interne des cartes principales : `24px`
  - Marges entre les sections : `32px`
- **Ombres (Box Shadows) :**
  - Les cartes possèdent une élévation légère (`elevation: 2` de Material Design).
  - Équivalent Tailwind : `shadow-md` avec un flou léger.

---

## 🧱 Composants Graphiques Communs (Common Components)

### 1. Boutons (`AppButton`)
- **Style :** Hauteur de `50px`, coins arrondis de `8px`, police grasse de `16px`.
- **Comportement au clic :** Si un chargement est actif, remplacer le texte par un loader rotatif blanc de `20px` x `20px`.
- ** Tailwind :**
  ```html
  <button class="w-full h-[50px] bg-blue-900 text-white rounded-lg font-bold text-lg hover:bg-blue-800 transition duration-150 flex items-center justify-center">
    Valider
  </button>
  ```

### 2. Champs de Formulaires (`AppTextField`)
- **Style :** Rempli (`filled: true`), arrière-plan blanc, bordure grise claire de `8px` de rayon.
- **Icônes :** Présence systématique d'icône d'action au début (`prefixIcon` : e.g., cadenas, enveloppe).
- ** Tailwind :**
  ```html
  <div class="relative">
    <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
      <i class="fas fa-envelope"></i>
    </span>
    <input type="email" placeholder="Email" class="w-full pl-10 pr-4 py-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-900" />
  </div>
  ```

### 3. Liste des Transactions (`TransactionTile`)
Chaque transaction doit être représentée par une ligne claire :
- **Leading (Gauche) :** Icône circulaire entourée d'un cercle avec opacité `10%` de la couleur du type (Vert = Dépôt, Rouge = Retrait, Bleu = Transfert).
- **Title (Centre) :** Intitulé de la transaction (gras, 1 ligne, ellipse si trop long).
- **Subtitle (Centre-Bas) :** Date relative (ex: *"Hier"*, *"Il y a 3 heures"*).
- **Trailing (Droite) :** Montant en gras (coloré en vert si positif, rouge si négatif). S'il y a une erreur ou attente de validation, afficher le statut en petit dessous.

---

## 📱 Structure d'un Écran Principal (Dashboard)

Pour l'application Web, conservez le layout logique suivant :
1. **Header constant :** Avec la marque en haut à gauche et les raccourcis (notifications, profil) en haut à droite.
2. **Carousel/Grille horizontale de comptes :** Affichage des cartes de solde en haut de page.
3. **Zone d'actions rapides :** Boutons iconographiques simplifiés pour lancer un transfert, faire un dépôt ou demander un prêt.
4. **Flux principal :** Liste chronologique des dernières transactions avec possibilité de filtrage direct par type.
