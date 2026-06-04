class CategorySeed {
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Alimentation', 'icon': 'restaurant', 'color': 0xFFF59E0B, 'type': 'expense', 'sortOrder': 1},
    {'name': 'Transport', 'icon': 'directions_car', 'color': 0xFF3B82F6, 'type': 'expense', 'sortOrder': 2},
    {'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFFEC4899, 'type': 'expense', 'sortOrder': 3},
    {'name': 'Loisirs', 'icon': 'movie', 'color': 0xFF8B5CF6, 'type': 'expense', 'sortOrder': 4},
    {'name': 'Santé', 'icon': 'favorite', 'color': 0xFFEF4444, 'type': 'expense', 'sortOrder': 5},
    {'name': 'Éducation', 'icon': 'school', 'color': 0xFF06B6D4, 'type': 'expense', 'sortOrder': 6},
    {'name': 'Logement', 'icon': 'home', 'color': 0xFF10B981, 'type': 'expense', 'sortOrder': 7},
    {'name': 'Énergies', 'icon': 'bolt', 'color': 0xFFF97316, 'type': 'expense', 'sortOrder': 8},
    {'name': 'Salaire', 'icon': 'work', 'color': 0xFF22C55E, 'type': 'income', 'sortOrder': 9},
    {'name': 'Freelance', 'icon': 'computer', 'color': 0xFF6366F1, 'type': 'income', 'sortOrder': 10},
    {'name': 'Cadeaux', 'icon': 'card_giftcard', 'color': 0xFFF43F5E, 'type': 'income', 'sortOrder': 11},
    {'name': 'Autres', 'icon': 'more_horiz', 'color': 0xFF71717A, 'type': 'expense', 'sortOrder': 12},
  ];

  static const List<Map<String, dynamic>> onboardingSlides = [
    {
      'title': 'Bienvenue sur Économe',
      'subtitle': 'Prenez le contrôle de vos finances. Simple, rapide, efficace.',
      'icon': 'savings',
      'color': 0xFFF59E0B,
    },
    {
      'title': 'Suivez vos dépenses',
      'subtitle': 'Ajoutez vos transactions en un tap. Catégories, montants, dates — tout est organisé.',
      'icon': 'receipt_long',
      'color': 0xFF3B82F6,
    },
    {
      'title': 'Épargnez intelligemment',
      'subtitle': 'Fixez des objectifs d\'épargne et suivez vos progrès en temps réel.',
      'icon': 'trending_up',
      'color': 0xFF22C55E,
    },
    {
      'title': 'Arrêtez les impulsions',
      'subtitle': 'La règle des 24h : ajoutez un achat à votre liste d\'attente. Si vous le voulez encore demain, foncez.',
      'icon': 'timer',
      'color': 0xFF8B5CF6,
    },
  ];
}
