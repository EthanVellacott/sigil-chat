import 'package:flutter/material.dart';

/// A unique "Sigil" style text field
class SigilEntryField extends StatelessWidget {
  const SigilEntryField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.obscureText = false,
      this.autofillHints,
      this.onSubmit});

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final Function(String)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofillHints: autofillHints,
      onSubmitted: onSubmit,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: BorderRadius.circular(30)),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(5))),
      obscureText: obscureText,
    );
  }
}

/// A unique "Sigil" style button
class SigilEntryButton extends StatelessWidget {
  const SigilEntryButton(
      {super.key,
      required this.text,
      required this.onPress,
      this.mini = false,
      this.color,
      this.leadingIcon});

  final String text;
  final Function()? onPress;
  final bool mini;
  final Color? color;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    // assign colour if none
    var outColour = color;
    outColour ??= Theme.of(context).colorScheme.secondary;

    Widget content = Center(child: Text(text));
    if (leadingIcon != null) {
      content = Row(
        children: [
          leadingIcon!,
          Expanded(
            child: content,
          )
        ],
      );
    }

    if (mini) {
      return Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 200),
          decoration: BoxDecoration(
              color: outColour, borderRadius: BorderRadius.circular(30)),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: onPress,
                  child: Container(
                      padding: const EdgeInsets.all(5), child: content))));
    }

    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: outColour, borderRadius: BorderRadius.circular(30)),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onPress,
                child: Container(
                    padding: const EdgeInsets.all(20), child: content))));
  }
}
