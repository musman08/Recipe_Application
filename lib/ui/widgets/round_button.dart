import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/providerScenes.dart';

bool loading = false;

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.title,
    required this.ontapMethod,
  });

  final String title;
  final VoidCallback ontapMethod;

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<ProviderScene>(context, listen: false);
    return InkWell(
      onTap: ontapMethod,
      child: Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(10)),
          child: Consumer<ProviderScene>(builder: ((context, value, child) {
            return Center(
                child: (value.buttonLoading == true)
                    ? const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      )
                    : Text(
                        title,
                         style: const TextStyle(color: Colors.white),
                      ));
          }))),
    );
  }
}
