import 'package:flutter/material.dart';
import 'package:food_delivery_app/theme/app_colors.dart';
import 'package:nb_utils/nb_utils.dart';

class AppDefaultLoader extends StatelessWidget {
  final bool loading;
  final Color? color;

  const AppDefaultLoader({Key? key, required this.loading, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.05,
                color: Colors.transparent,
                child: /*Lottie.asset('assets/json/circular_loader.json'),*/
                    const Loader(
                  color: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                )),
          )
        : Container();
  }
}
