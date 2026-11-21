import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

import '../controllers/profile_controller.dart';
import 'components/profile_header.dart';
import 'components/profile_infocard.dart';
import '../models/profile.dart';

class ProfileView extends StatefulWidget {
  final ProfileController? profileController;
  const ProfileView({super.key, this.profileController});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Profile profile;
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = widget.profileController ?? ProfileController();
    _profileController.loadprofile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      body: ListenableBuilder(
        listenable: _profileController,
        builder: (context, _) {
          if (_profileController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = _profileController.profile;
          if (profile == null) {
            return Center(
              child: Text(
                _profileController.errorMessage ?? 'Chưa tải được hồ sơ',
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(profile: profile),
                    const SizedBox(height: 16),
                    ProfileInfoCard(
                      profile: profile,
                      profileController: _profileController,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          print('Change password button pressed');
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.red),
                        ),

                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
