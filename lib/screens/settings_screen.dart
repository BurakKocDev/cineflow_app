import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/localization/app_localizations.dart';
import 'package:cineflow_app/localization/locale_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'tr';
  bool _notificationsEnabled = true;
  bool _autoPlayEnabled = false;
  String _videoQuality = '1080p';

  @override
  void initState() {
    super.initState();
    // Uygulama başladığında mevcut dil ayarını al
    _selectedLanguage = Get.locale?.languageCode ?? 'tr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              _buildSectionHeader('language'.tr),
              _buildLanguageSection(),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionHeader('notifications'.tr),
              _buildNotificationsSection(),
              const SizedBox(height: 24),

              // Playback Section
              _buildSectionHeader('playback'.tr),
              _buildPlaybackSection(),
              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('about'.tr),
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Get.textTheme.headlineMedium?.copyWith(
          color: AppColors.onBackground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Tema tamamen koyu moda sabitlendi, ek tema seçenekleri kaldırıldı.

  Widget _buildLanguageSection() {
    return Container(
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
      child: Column(
        children: [
          _buildLanguageOption(
            title: 'Türkçe',
            subtitle: 'Turkish',
            flag: '🇹🇷',
            isSelected: _selectedLanguage == 'tr',
            onTap: () {
              setState(() {
                _selectedLanguage = 'tr';
              });
              const locale = AppLocalizations.turkish;
              Get.updateLocale(locale);
              LocaleService.saveLocale(locale);
            },
          ),
          _buildDivider(),
          _buildLanguageOption(
            title: 'English',
            subtitle: 'İngilizce',
            flag: '🇺🇸',
            isSelected: _selectedLanguage == 'en',
            onTap: () {
              setState(() {
                _selectedLanguage = 'en';
              });
              const locale = AppLocalizations.english;
              Get.updateLocale(locale);
              LocaleService.saveLocale(locale);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
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
      child: Column(
        children: [
          _buildSwitchOption(
            title: 'notifications'.tr,
            subtitle: 'Tüm bildirimleri göster',
            icon: Icons.notifications,
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchOption(
            title: 'new_release'.tr,
            subtitle: 'new_release'.tr,
            icon: Icons.movie,
            value: _notificationsEnabled,
            onChanged: (value) {},
          ),
          _buildDivider(),
          _buildSwitchOption(
            title: 'favorite_actor_movie'.tr,
            subtitle: 'favorite_actor_movie'.tr,
            icon: Icons.person,
            value: _notificationsEnabled,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackSection() {
    return Container(
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
      child: Column(
        children: [
          _buildSwitchOption(
            title: 'auto_play_trailer'.tr,
            subtitle: 'Fragmanları otomatik oynat',
            icon: Icons.play_circle,
            value: _autoPlayEnabled,
            onChanged: (value) {
              setState(() {
                _autoPlayEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildQualityOption(
            title: 'video_quality'.tr,
            subtitle: 'Tercih edilen video kalitesi',
            icon: Icons.high_quality,
            currentValue: _videoQuality,
            options: ['720p', '1080p', '4K'],
            onChanged: (value) {
              setState(() {
                _videoQuality = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
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
      child: Column(
        children: [
          _buildAboutOption(
            title: '${'app_title'.tr} Versiyonu',
            subtitle: '1.0.0',
            icon: Icons.info,
            onTap: () {
              _showAppInfoBottomSheet();
            },
          ),
          _buildDivider(),
          _buildAboutOption(
            title: 'privacy_policy'.tr,
            subtitle: 'Gizlilik ayarları ve politikası',
            icon: Icons.privacy_tip,
            onTap: () {
              _showSimpleInfoDialog(
                title: 'privacy_policy'.tr,
                message:
                    'Kullanıcı verilerini sadece uygulama deneyimini iyileştirmek için kullanıyoruz. Herhangi bir kişisel veriyi üçüncü şahıslarla paylaşmıyoruz.',
              );
            },
          ),
          _buildDivider(),
          _buildAboutOption(
            title: 'terms_of_use'.tr,
            subtitle: 'Uygulama kullanım şartları',
            icon: Icons.description,
            onTap: () {
              _showSimpleInfoDialog(
                title: 'terms_of_use'.tr,
                message:
                    'CineFlow yalnızca tanıtım ve keşif amaçlıdır. İçerikler TheMovieDB API üzerinden sağlanır ve yayın hakları ilgili platformlara aittir.',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAppInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.movie, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'CineFlow',
                    style: Get.textTheme.headlineMedium?.copyWith(
                      color: AppColors.onCard,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Filmleri ve dizileri keşfetmek, fragman izlemek ve favori listeni yönetmek için tasarlanmış modern bir keşif uygulaması.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sürüm: 1.0.0',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onCard,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Geliştirici: CineFlow',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Veri kaynağı: TheMovieDB (Resmi olmayan istemci)',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSimpleInfoDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSelected
              ? AppColors.primary
              // ignore: deprecated_member_use
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          flag,
          style: const TextStyle(fontSize: 24),
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
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 24,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildQualityOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
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
      trailing: DropdownButton<String>(
        value: currentValue,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.onCard),
      ),
    );
  }

  Widget _buildAboutOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
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
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.grey600,
      height: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
