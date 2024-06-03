import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vedanta_frontend/src/widgets/avatar_widget.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int index;
  final String name;
  final String profilePicture;
  const AppBarWidget({
    super.key,
    required this.scaffoldKey,
    required this.index,
    required this.name,
    required this.profilePicture,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    Widget userAvatar = Row(
      children: [
        AvatarWidget(
          avatarUrl: profilePicture == 'null' ? null : profilePicture,
          name: name,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Text(
              "Siswa",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );

    Widget ganabot = Row(
      children: [
        Image.asset(
          fit: BoxFit.fill,
          'lib/assets/images/ganabot.png',
          width: 30,
          height: 30,
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GaneshaBot',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              "Online",
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );

    List<Widget> actions = [
      // Notification button with image
      Row(
        children: [
          Image.asset(
            fit: BoxFit.fill,
            'lib/assets/images/star.png',
            width: 24,
            height: 24,
          ),
          const Text(
            '25',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(width: 16),
      Row(
        children: [
          Image.asset(
            fit: BoxFit.fill,
            'lib/assets/images/medal.png',
            width: 24,
            height: 24,
          ),
          const Text(
            '4',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
      TextButton(
        onPressed: () {},
        child: Image.asset(
          fit: BoxFit.fill,
          'lib/assets/images/notification.png',
          width: 18,
          height: 18,
        ),
      )
    ];

    bool shouldShowDrawer(int index) {
      // Define the indexes that should show the Drawer
      const drawerIndexes = [
        1,
      ]; // Add the indexes for which you want to show the Drawer

      return drawerIndexes.contains(index);
    }

    return AppBar(
      leading: shouldShowDrawer(index)
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
            )
          : null,
      title: shouldShowDrawer(index) ? ganabot : userAvatar,
      actions: shouldShowDrawer(index) ? null : actions,
    );
  }
}
