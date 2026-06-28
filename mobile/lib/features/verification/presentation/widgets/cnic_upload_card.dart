import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

/// CNIC front/back upload drop zone — mock capture/upload.
class CnicUploadCard extends StatelessWidget {
  const CnicUploadCard({
    super.key,
    required this.title,
    required this.isUploaded,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final String title;
  final bool isUploaded;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: isUploaded
              ? AppColors.primaryDisplay.withValues(alpha: 0.4)
              : AppColors.borderSubtle,
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: textTheme.headlineSmall),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDisplay.withValues(alpha: 0.1),
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Text(
                  isUploaded ? 'Uploaded' : 'Required',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryDisplay,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _UploadActionButton(
                      icon: Icons.photo_camera_outlined,
                      onTap: onCameraTap,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _UploadActionButton(
                      icon: Icons.upload_file_outlined,
                      onTap: onGalleryTap,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isUploaded
                      ? 'Document captured successfully'
                      : 'Click to capture or upload',
                  style: textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Supported: JPG, PNG (Max 5MB)',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadActionButton extends StatelessWidget {
  const _UploadActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceBright.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(icon, color: AppColors.onSurface),
        ),
      ),
    );
  }
}
