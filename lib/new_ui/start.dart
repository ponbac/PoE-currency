import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poe_currency/bloc/pricing_bloc.dart';
import 'package:poe_currency/bloc/stash_bloc.dart';
import 'package:poe_currency/constants.dart';
import 'package:poe_currency/new_ui/main_area.dart';
import 'package:poe_currency/new_ui/menu_bar.dart';
import 'package:poe_currency/new_ui/top_bar.dart';
import 'package:poe_currency/repositories/pricing_repository.dart';

// Inspiration: https://dribbble.com/shots/11663910--Exploration-Bookmark-App
//              https://www.youtube.com/watch?v=E6fLm5XlJDY
//              https://github.com/abuanwar072/Protfolio-Website-Flutter-Web

class Start extends StatelessWidget {
  const Start({@required this.pricingRepository})
      : assert(pricingRepository != null);

  final PricingRepository pricingRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Row(
        children: [
          Expanded(flex: 1, child: MenuBar()),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(flex: 1, child: TopBar()),
                BlocProvider<PricingBloc>(
                    create: (context) => PricingBloc(
                        pricingRepository: pricingRepository,
                        stashBloc: BlocProvider.of<StashBloc>(context)),
                    child: Expanded(flex: 4, child: MainArea()))
              ],
            ),
          )
        ],
      ),
    );
  }
}
