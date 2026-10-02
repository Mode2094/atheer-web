import 'package:flutter/material.dart';
import 'package:perfume/core/localization/localization_helper.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/features/admin/users/users_controller.dart';
import 'package:perfume/features/admin/users/widgets/user_card.dart';
import 'package:perfume/features/admin/users/widgets/user_details_screen.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersController>(context, listen: false).loadAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(context.loc.usersTitle),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<UsersController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.users.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: ThemeConstants.accentColor,
              ),
            );
          }

          if (controller.users.isEmpty) {
            return Center(
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, color: Colors.white70, size: 60),
                    SizedBox(height: 20),
                    _NoUsersText(),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return UserCard(
                user: user,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailsScreen(user: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NoUsersText extends StatelessWidget {
  const _NoUsersText();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.loc.noUsersYet,
      style: const TextStyle(color: Colors.white70),
    );
  }
}
