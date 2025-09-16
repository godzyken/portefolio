import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/enum_global.dart';

class CardFlightNotifier extends StateNotifier<Map<String, CardFlightState>> {
  CardFlightNotifier() : super({});

  /// Mettre à jour l'état d'une carte
  void setStateForCard(String entreprise, CardFlightState state) {
    state = state;
    this.state = {...this.state, entreprise: state};
  }

  /// Récupérer l'état d'une carte (utile dans les Widgets)
  CardFlightState getState(String id) {
    return state[id] ?? CardFlightState.inPile;
  }

  /// Marquer toutes les cartes liées à un tag comme "flyingUp"
  void flyCardUp(List<String> cardIds) {
    final newState = {...state};
    for (var id in cardIds) {
      newState[id] = CardFlightState.flyingUp;
    }
    state = newState;
  }

  /// Lancer l'animation de plusieurs cartes vers le haut
  void flyCardsUp(List<String> entreprises) {
    final newState = Map<String, CardFlightState>.from(state);
    for (var e in entreprises) {
      newState[e] = CardFlightState.flyingUp;
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

  /// 🔹 Nouvelle méthode pour réinitialiser toutes les cartes
  void resetAllCards() {
    final newState = <String, CardFlightState>{};
    for (var key in state.keys) {
      newState[key] = CardFlightState.inPile;
    }
    state = newState;
  }
}
