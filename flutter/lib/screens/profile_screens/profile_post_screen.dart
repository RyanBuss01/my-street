import 'package:flutter/material.dart';
import '../../models/universal_widgets/close_button.dart';
import '../../screens/profile_screens/widgets/ProfilePostPage.dart';

import '../../models/classes/post.dart';

class ProfilePostScreen extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;
  const ProfilePostScreen({Key? key, required this.posts, required this.initialIndex}) : super(key: key);

  @override
  State<ProfilePostScreen> createState() => _ProfilePostScreenState();
}

class _ProfilePostScreenState extends State<ProfilePostScreen> {
  late List<Post> posts = widget.posts;
  late int pageIndex = widget.initialIndex;

  late PageController _pageController = PageController(initialPage: widget.initialIndex);
  bool showCloseButton = true;
  bool _canPageScroll = true;

  callback(bool set) => setState(() {showCloseButton = set; _canPageScroll = set;});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Stack(
            children: [
              PageView.builder(
                itemCount: posts.length,
                  physics: _canPageScroll ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) {
                  setState(() {
                    pageIndex = i;
                  });
                  },
                  controller: _pageController,
                  itemBuilder: (context, index) {
                  return ProfilePostPage(posts[index], callback: callback,);
                  }
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: posts.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 10
                            ),
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                  color: index == pageIndex
                                      ? Colors.white
                                      : Colors.grey,
                                  shape: BoxShape.circle
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
          showCloseButton ? closeButton(
            callback: () => Navigator.of(context).pop(),
          ) : const SizedBox(),
        ],
      ),
    );
  }


}
