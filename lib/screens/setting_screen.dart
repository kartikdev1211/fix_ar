import 'package:fix_ar/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final bool showNav;
  const SettingsScreen({super.key, this.showNav = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // ── TOGGLE STATES
  bool _voiceGuidance = true;
  bool _arOverlays = true;
  bool _safetyWarnings = true;
  bool _notifications = false;
  bool _hapticFeedback = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSectionTitle('AR Experience'),
            _buildArSettings(),
            _buildSectionTitle('App Preferences'),
            _buildAppSettings(),
            _buildSectionTitle('Account'),
            _buildAccountSettings(),
            _buildSectionTitle('About'),
            _buildAboutSettings(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Settings', style: GoogleFonts.syne(
            fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
          )),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.teal.withOpacity(0.1),
              border: Border.all(
                color: AppColors.teal.withOpacity(0.25),
              ),
            ),
            child: const Icon(Icons.settings_rounded,
                color: AppColors.teal, size: 18),
          ),
        ],
      ),
    );
  }

  // ── AR EXPERIENCE SETTINGS
  Widget _buildArSettings() {
    return _SettingsGroup(children: [
      _ToggleTile(
        icon: Icons.mic_rounded,
        iconColor: AppColors.teal,
        title: 'Voice guidance',
        subtitle: 'Read repair steps aloud',
        value: _voiceGuidance,
        onChanged: (v) => setState(() => _voiceGuidance = v),
      ),
      _Divider(),
      _ToggleTile(
        icon: Icons.view_in_ar_rounded,
        iconColor: AppColors.blue,
        title: 'AR overlays',
        subtitle: 'Show component labels on camera',
        value: _arOverlays,
        onChanged: (v) => setState(() => _arOverlays = v),
      ),
      _Divider(),
      _ToggleTile(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.warning,
        title: 'Safety warnings',
        subtitle: 'Alert before risky steps',
        value: _safetyWarnings,
        onChanged: (v) => setState(() => _safetyWarnings = v),
      ),
    ]);
  }

  // ── APP PREFERENCES
  Widget _buildAppSettings() {
    return _SettingsGroup(children: [
      _ToggleTile(
        icon: Icons.notifications_rounded,
        iconColor: AppColors.purple,
        title: 'Notifications',
        subtitle: 'Repair reminders & updates',
        value: _notifications,
        onChanged: (v) => setState(() => _notifications = v),
      ),
      _Divider(),
      _ToggleTile(
        icon: Icons.vibration_rounded,
        iconColor: AppColors.teal,
        title: 'Haptic feedback',
        subtitle: 'Vibrate on AR detection',
        value: _hapticFeedback,
        onChanged: (v) => setState(() => _hapticFeedback = v),
      ),
      _Divider(),
      _ToggleTile(
        icon: Icons.dark_mode_rounded,
        iconColor: AppColors.blue,
        title: 'Dark mode',
        subtitle: 'Always use dark theme',
        value: _darkMode,
        onChanged: (v) => setState(() => _darkMode = v),
      ),
    ]);
  }

  // ── ACCOUNT SETTINGS
  Widget _buildAccountSettings() {
    return _SettingsGroup(children: [
      _NavTile(
        icon: Icons.person_rounded,
        iconColor: AppColors.teal,
        title: 'Edit profile',
        onTap: () {},
      ),
      _Divider(),
      _NavTile(
        icon: Icons.lock_rounded,
        iconColor: AppColors.blue,
        title: 'Change password',
        onTap: () {},
      ),
      _Divider(),
      _NavTile(
        icon: Icons.logout_rounded,
        iconColor: AppColors.danger,
        title: 'Sign out',
        titleColor: AppColors.danger,
        onTap: () => _showSignOutDialog(),
      ),
    ]);
  }

  // ── ABOUT SETTINGS
  Widget _buildAboutSettings() {
    return _SettingsGroup(children: [
      _NavTile(
        icon: Icons.info_outline_rounded,
        iconColor: AppColors.teal,
        title: 'App version',
        trailing: Text('v1.0.0', style: GoogleFonts.dmSans(
          fontSize: 12, color: Colors.white.withOpacity(0.3),
        )),
        onTap: () {},
      ),
      _Divider(),
      _NavTile(
        icon: Icons.shield_outlined,
        iconColor: AppColors.blue,
        title: 'Privacy policy',
        onTap: () {},
      ),
      _Divider(),
      _NavTile(
        icon: Icons.description_outlined,
        iconColor: AppColors.purple,
        title: 'Terms of service',
        onTap: () {},
      ),
    ]);
  }

  // ── SIGN OUT DIALOG
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign out?', style: GoogleFonts.syne(
          fontWeight: FontWeight.w800, color: Colors.white,
        )),
        content: Text(
          'You will be returned to the login screen.',
          style: GoogleFonts.dmSans(
            color: Colors.white.withOpacity(0.45), fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(
              color: Colors.white38,
            )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sign out', style: GoogleFonts.dmSans(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
  }

  // ── SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(title, style: GoogleFonts.syne(
        fontSize: 13, fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 0.5,
      )),
    );
  }
}

// ── REUSABLE WIDGETS

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: iconColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.syne(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
              )),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.dmSans(
                fontSize: 10, color: Colors.white.withOpacity(0.3),
              )),
            ],
          )),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.teal,
            activeTrackColor: AppColors.teal.withOpacity(0.25),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white.withOpacity(0.08),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon, required this.iconColor,
    required this.title, required this.onTap,
    this.titleColor, this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: iconColor.withOpacity(0.1),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: GoogleFonts.syne(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: titleColor ?? Colors.white,
            ))),
            trailing ?? Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1, thickness: 1,
      indent: 62, endIndent: 0,
      color: Colors.white.withOpacity(0.05),
    );
  }
}