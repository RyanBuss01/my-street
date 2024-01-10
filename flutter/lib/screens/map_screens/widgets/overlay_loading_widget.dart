import 'package:flutter/material.dart';

import '../../../models/custom_classes/shimmer.dart';

class OverlayLoadingWidget extends StatefulWidget {
  const OverlayLoadingWidget({Key? key}) : super(key: key);

  @override
  State<OverlayLoadingWidget> createState() => _OverlayLoadingWidgetState();
}

class _OverlayLoadingWidgetState extends State<OverlayLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (context, index) => _buildShimmerCard()
      ),
    );
  }

  Widget _buildShimmerCard() {
    return ShimmerLoading(
      isLoading: true,
      child: geoShimmerCard(),
    );
  }



  Widget geoShimmerCard() {
    return Padding(
        padding:  const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const MediaContainerItem(),
            const SizedBox(height: 10,),
            infoWidget(),
            const Divider(height: 2, color: Colors.white,)
          ],
        )
    );
  }








  Widget infoWidget() {
      return Row(
          children: const [
            CircleListItem()
        ]
      );
  }



}

class MediaContainerItem extends StatelessWidget {
  const MediaContainerItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Center(
        child: Container(
            width: MediaQuery.of(context).size.width ,
            height: 500,
          decoration:  BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}


class CircleListItem extends StatelessWidget {
  const CircleListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const ClipOval(),
      ),
    );
  }
}

