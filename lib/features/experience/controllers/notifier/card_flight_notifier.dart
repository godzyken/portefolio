import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/enum_global.dart';

class CardFlightNotifier extends Notifier<Map<String, CardFlightState>> {
  @override
  Map<String, CardFlightState> build() {
    return {};
  }

  /// ✅ Mettre à jour l'état d'une carte (utilise maintenant l'ID)
  void setStateForCard(String cardId, CardFlightState newState) {
    state = {...state, cardId: newState};
  }

  /// ✅ Récupérer l'état d'une carte
  CardFlightState getState(String id) {
    return state[id] ?? CardFlightState.inPile;
  }

  /// ✅ Marquer plusieurs cartes comme "flyingUp"
  void flyCardUp(List<String> cardIds) {
    final newState = {...state};
    for (var id in cardIds) {
      newState[id] = CardFlightState.flyingUp;
    }
    state = newState;
  }

  /// ✅ Lancer l'animation de plusieurs cartes vers le haut
  void flyCardsUp(List<String> cardIds) {
    final newState = Map<String, CardFlightState>.from(state);
    for (var id in cardIds) {
      newState[id] = CardFlightState.flyingUp;
    }
    state = newState;
  }

  /// ✅ Faire revenir toutes les cartes vers la pile
  void resetCards(List<String> cardIds) {
    final newState = {...state};
    for (var id in cardIds) {
      newState[id] = CardFlightState.flyingDown;
    }
    state = newState;

    // Après l'animation, remettre à inPile
    Future.delayed(const Duration(milliseconds: 700), () {
      final finalState = {...state};
      for (var id in cardIds) {
        finalState[id] = CardFlightState.inPile;
      }
      state = finalState;
    });
  }

  /// ✅ Réinitialiser toutes les cartes
  void resetAllCards() {
    state = {};
  }
}

class ActiveTagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  void setTags(List<String> newTags) {
    state = newTags;
  }

  void addTag(String newTag) {
    if (!state.contains(newTag)) {
      state = [...state, newTag];
    }
  }

  void removeTag(String tagToRemove) {
    state = state.where((tag) => tag != tagToRemove).toList();
  }

  void clearTags() {
    state = [];
  }

  bool hasTag(String tag) {
    return state.contains(tag);
  }
}
