import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/screens/settings_screen.dart';
// Removed non-functional menu screens
import 'package:cineflow_app/screens/favorites_screen.dart';
import 'package:cineflow_app/controllers/favorite_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'CineFlow User';
  String userEmail = 'user@cineflow.com';
  String? avatarPath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);

    Get.dialog(
      AlertDialog(
        title: Text('edit'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'İsim',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userName = nameController.text.trim().isEmpty
                    ? 'CineFlow User'
                    : nameController.text.trim();
                userEmail = emailController.text.trim().isEmpty
                    ? 'user@cineflow.com'
                    : emailController.text.trim();
              });
              _saveProfile();
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('profile_name') ?? userName;
      userEmail = prefs.getString('profile_email') ?? userEmail;
      avatarPath = prefs.getString('profile_avatar');
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', userName);
    await prefs.setString('profile_email', userEmail);
    if (avatarPath != null) {
      await prefs.setString('profile_avatar', avatarPath!);
    }
    Get.snackbar(
      'Başarılı',
      'Profil güncellendi!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        avatarPath = picked.path;
      });
      await _saveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              const SizedBox(height: 24),
              // Menu Items
              _buildMenuItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: ClipOval(
                child: avatarPath != null
                    ? Image.file(
                        File(avatarPath!),
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.onPrimary,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            userName,
            style: Get.textTheme.headlineLarge?.copyWith(
              color: AppColors.onCard,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            userEmail,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: 16),

          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () {
              _showEditProfileDialog();
            },
            icon: const Icon(Icons.edit),
            label: Text('edit'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'icon': Icons.favorite,
        'title': 'favorites'.tr,
        'subtitle': 'Favori filmlerin ve dizilerin',
        'onTap': () {
          Get.to(
            () => const FavoritesScreen(),
            binding: BindingsBuilder(() {
              Get.put(FavoriteController());
            }),
          );
        },
      },
    ];

    return Column(
      children: menuItems
          .map((item) => _buildMenuItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                onTap: item['onTap'] as VoidCallback,
              ))
          .toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Get.textTheme.titleLarge?.copyWith(
            color: AppColors.onCard,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.grey400,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.grey400,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
