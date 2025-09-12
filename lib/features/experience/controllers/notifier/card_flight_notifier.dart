import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/enum_global.dart';

class CardFlightNotifier extends StateNotifier<Map<String, CardFlightState>> {
  CardFlightNotifier() : super({});

  /// Initialiser l'état d'une carte
  void initCard(String id) {
    if (!state.containsKey(id)) {
      state = {...state, id: CardFlightState.inPile};
    }
  }

  /// Mettre à jour l'état d'une carte
  void setStateForCard(String id, CardFlightState newState) {
    state = {...state, id: newState};
  }

  /// Récupérer l'état d'une carte (utile dans les Widgets)
  CardFlightState getState(String id) {
    return state[id] ?? CardFlightState.inPile;
  }

  /// Marquer toutes les cartes liées à un tag comme "flyingUp"
  void flyCardsUp(List<String> cardIds) {
    final newState = {...state};
    for (var id in cardIds) {
      newState[id] = CardFlightState.flyingUp;
    }
    state = newState;
  }

  /// Faire revenir toutes les cartes vers la pile
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
}
