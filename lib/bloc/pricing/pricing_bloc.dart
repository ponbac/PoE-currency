import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:poe_currency/bloc/stash/stash_bloc.dart';
import 'package:poe_currency/models/item.dart';
import 'package:poe_currency/repositories/pricing_repository.dart';

part 'pricing_event.dart';
part 'pricing_state.dart';

class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final PricingRepository pricingRepository;

  final StashBloc stashBloc;
  StreamSubscription stashBlocSubscription;

  PricingBloc({@required this.pricingRepository, @required this.stashBloc})
      : assert(pricingRepository != null && stashBloc != null),
        super(PricingInitial()) {
    // TODO: Solve this in a better way? https://github.com/felangel/bloc/issues/1512
    if (stashBloc.state is StashLoadSuccess) {
      StashLoadSuccess successState = stashBloc.state;
      this.add(PricingRequested(
          username: successState.stash.owner,
          itemsToPrice: successState.stash.allItems));
    }

    stashBlocSubscription = stashBloc.listen((state) {
      if (state is StashLoadSuccess) {
        this.add(PricingRequested(
            username: state.stash.owner, itemsToPrice: state.stash.allItems));
      }
    });
  }

  @override
  Stream<PricingState> mapEventToState(
    PricingEvent event,
  ) async* {
    if (event is PricingRequested) {
      yield PricingInProgress();

      //print('Pricing in progress!');

      List<Item> itemsToPrice = event.itemsToPrice;
      List<Item> pricedItems = [];
      double totalValue = 0;

      try {
        HashMap<String, double> pricesMap =
            await pricingRepository.getPricesForCurrency();

        itemsToPrice.forEach((item) {
          item.value = pricesMap[item.typeLine];

          if (item.value == null) {
            item.value = pricesMap[item.name] ?? 0.0;
          }

          totalValue += item.totalValue;
          pricedItems.add(item);
        });

        pricingRepository.saveSnapshot(
            event.username, totalValue.round()); // Save snapshot in DB!
        yield PricingSuccess(pricedItems: pricedItems);
      } catch (_) {
        print(_.toString()); //TODO REMOVE AND MAKE PART OF UI RESPONSE
        yield PricingFailure();
      }
    }
  }

  @override
  Future<void> close() {
    stashBlocSubscription.cancel();
    return super.close();
  }
}
