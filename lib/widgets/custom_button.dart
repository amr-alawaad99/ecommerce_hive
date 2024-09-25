import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final String innerText;
  final void Function()? onPressed;
  final bool havePrefix;
  final double borderRadius;
  final Color color;

  const CustomButton({
    super.key,
    required this.innerText,
    required this.onPressed,
    this.havePrefix = false,
    this.borderRadius = 26,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (havePrefix)
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                  Text(
                    innerText,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
