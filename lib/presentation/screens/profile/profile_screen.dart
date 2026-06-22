import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      context.read<AuthBloc>().add(
            UpdateProfilePictureRequested(imagePath: pickedFile.path),
          );
    }
  }

  ImageProvider _avatarImage(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        return NetworkImage(avatarUrl);
      }
      return FileImage(File(avatarUrl));
    }
    return const NetworkImage('https://i.pravatar.cc/150?img=11');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DesignTokens.error,
              ),
            );
          } else if (state is AuthProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated'),
                backgroundColor: DesignTokens.success,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;
            final displayName = user != null
                ? (user.prenom?.isNotEmpty == true ? '${user.prenom} ${user.nom}' : user.nom)
                : 'John Doe';
            final email = user?.email ?? 'john.doe@bankapp.com';
            final avatarUrl = user?.avatarUrl;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ── Avatar with edit button ──
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DesignTokens.teal300,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: DesignTokens.teal500,
                          backgroundImage: _avatarImage(avatarUrl),
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? const Icon(Icons.person, size: 48, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: DesignTokens.teal400,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: DesignTokens.navy900,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Theme Toggle ──
                  _buildSection(
                    context,
                    'Appearance',
                    [
                      _buildThemeToggle(context, isDark, themeProvider),
                    ],
                  ),

                  // ── Account Settings ──
                  _buildSection(
                    context,
                    'Account Settings',
                    [
                      _buildMenuItem(Icons.person_outline, 'Personal Information', () {}),
                      _buildMenuItem(Icons.security, 'Security & 2FA', () {}),
                      _buildMenuItem(Icons.fingerprint, 'Biometric Authentication', () {}),
                      _buildMenuItem(Icons.notifications_outlined, 'Notification Preferences', () {}),
                    ],
                  ),

                  // ── App Settings ──
                  _buildSection(
                    context,
                    'Application',
                    [
                      _buildMenuItem(Icons.language, 'Language', () {}),
                      _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
                      _buildMenuItem(Icons.info_outline, 'About', () {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Logout Button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: DesignTokens.navy800,
                            title: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  context.read<AuthBloc>().add(LogoutRequested());
                                },
                                style: TextButton.styleFrom(foregroundColor: DesignTokens.error),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: AppTheme.errorColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: DesignTokens.navy800.withValues(alpha: 0.95),
        selectedItemColor: DesignTokens.teal300,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Activité'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/transactions');
          if (index == 2) context.go('/activity');
          if (index == 3) context.go('/profile');
        },
      ),
    );
  }

  // ── Theme Toggle Widget ──
  Widget _buildThemeToggle(BuildContext context, bool isDark, ThemeProviderState themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: DesignTokens.glassWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.glassBorder),
      ),
      child: ListTile(
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            key: ValueKey(isDark),
            color: isDark ? DesignTokens.teal300 : Colors.amber.shade700,
          ),
        ),
        title: const Text(
          'Dark Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          isDark ? 'Enabled' : 'Disabled',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Switch.adaptive(
          value: isDark,
          activeTrackColor: DesignTokens.teal500.withValues(alpha: 0.5),
          activeThumbColor: DesignTokens.teal300,
          onChanged: (value) {
            themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          },
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: DesignTokens.teal500.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: DesignTokens.teal300,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        onTap: onTap,
      ),
    );
  }
}
