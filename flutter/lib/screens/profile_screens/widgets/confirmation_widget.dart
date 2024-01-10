import 'package:flutter/material.dart';

import '../../../models/classes/user.dart';
import '../../../models/universal_widgets/close_button.dart';
import '../../../services/node_services/user_service.dart';

class ConfirmationOverlayWidget extends StatefulWidget {
  final Function callback;
  final Function confirmationButton;
  final String text;
  final String confirmationText;
  const ConfirmationOverlayWidget({Key? key, required this.callback, required this.confirmationButton, this.text = '', required this.confirmationText}) : super(key: key);

  @override
  State<ConfirmationOverlayWidget> createState() => _ConfirmationOverlayWidgetState();
}

class _ConfirmationOverlayWidgetState extends State<ConfirmationOverlayWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white)
          ),
          height: 200,
            width: 400,
            child: Stack(
              children: [
                Positioned(
                  top: -25,
                    right: 10,
                    child: closeButton(callback: widget.callback)
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: SizedBox(
                        width: 200,
                        child: Text(
                          widget.text,
                        style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: (MediaQuery.of(context).size.width * 0.6),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.redAccent,
                              ),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () => widget.confirmationButton(),
                                  child: Center(
                                      child: Text(
                                          widget.confirmationText,
                                          style: const TextStyle(color: Colors.red)
                                      )
                                  )
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
        ),
      ),
    );
  }
}

