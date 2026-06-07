import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/soft_icon_button.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/share_service.dart';
import 'share_card.dart';

/// Pushes the full-screen share preview.
Future<void> openSharePreview(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const SharePreviewScreen()),
  );
}

class SharePreviewScreen extends ConsumerStatefulWidget {
  const SharePreviewScreen({super.key});

  @override
  ConsumerState<SharePreviewScreen> createState() =>
      _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure the logo is decoded before the card is rasterised for sharing.
    precacheImage(const AssetImage('assets/branding/logo.png'), context);
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final health = ref.read(financialHealthProvider);
    setState(() => _sharing = true);
    try {
      await ShareService.instance.shareCard(
        _cardKey,
        caption: l10n.shareCaption(health.score),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final health = ref.watch(financialHealthProvider);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Row(
                children: [
                  SoftIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(l10n.shareSheetTitle,
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: ShareCard(health: health),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, 0, AppSpacing.page, AppSpacing.page),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _sharing ? null : _share,
                      icon: _sharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.ios_share_rounded),
                      label: Text(l10n.shareToFeed),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
