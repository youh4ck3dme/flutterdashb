import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/auth_provider.dart';
import '../../core/google_cloud_access.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class EmailSenderScreen extends StatelessWidget {
  const EmailSenderScreen({super.key});

  static const int importedContactRows = 15833;
  static const String localSourcePath =
      '/Users/erikbabcan/Documents/mailgun_emails.csv';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hasAccess = auth.hasPaidGoogleCloudAccess;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _Header(hasAccess: hasAccess, currentEmail: auth.user?.email),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Responsive(
                    mobile: Column(
                      children: [
                        _AccessPanel(hasAccess: hasAccess),
                        const SizedBox(height: 16),
                        const _MetricGrid(),
                      ],
                    ),
                    desktop: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _AccessPanel(hasAccess: hasAccess),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(flex: 3, child: _MetricGrid()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Responsive(
                    mobile: const Column(
                      children: [
                        _PipelinePanel(),
                        SizedBox(height: 16),
                        _SecurityPanel(),
                      ],
                    ),
                    desktop: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _PipelinePanel()),
                        SizedBox(width: 16),
                        Expanded(child: _SecurityPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _ProviderPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool hasAccess;
  final String? currentEmail;

  const _Header({required this.hasAccess, required this.currentEmail});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 460;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0x0AFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0x15FFFFFF))),
      ),
      child: Flex(
        direction: isCompact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isCompact
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: AppTheme.activeGlassDecoration(borderRadius: 8),
                child: const Icon(
                  LucideIcons.mail,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Sender',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasAccess
                          ? 'Google Cloud / Firebase platený profil je aktívny'
                          : 'Platené funkcie sú dostupné iba pre $googleCloudOwnerEmail',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isCompact) ...[
            const SizedBox(height: 12),
            _StatusPill(
              label: hasAccess ? 'ACCESS OK' : 'LOCKED',
              color: hasAccess ? AppTheme.success : AppTheme.warning,
              icon: hasAccess
                  ? Icons.verified_user_outlined
                  : Icons.lock_outline,
            ),
          ] else ...[
            const Spacer(),
            _StatusPill(
              label: hasAccess ? 'ACCESS OK' : 'LOCKED',
              color: hasAccess ? AppTheme.success : AppTheme.warning,
              icon: hasAccess
                  ? Icons.verified_user_outlined
                  : Icons.lock_outline,
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessPanel extends StatelessWidget {
  final bool hasAccess;

  const _AccessPanel({required this.hasAccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration(borderRadius: 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Prístup a profil',
            subtitle: 'Jeden schválený Google/Firebase billing profil.',
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Povolený profil', value: googleCloudOwnerEmail),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Stav sekcie',
            value: hasAccess
                ? 'Odomknuté pre platené funkcie'
                : 'Read-only prehľad',
          ),
          const SizedBox(height: 16),
          _GuardNotice(hasAccess: hasAccess),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        'Kontakty v zdroji',
        '${EmailSenderScreen.importedContactRows}',
        Icons.people_alt_outlined,
      ),
      _MetricData('Import', 'CSV -> Storage', Icons.upload_file_outlined),
      _MetricData('Queue', 'Cloud Tasks', Icons.low_priority_outlined),
      _MetricData('Sender', 'Mailgun API', Icons.outgoing_mail),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 520 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth < 520 ? 1.28 : 1.35,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return Container(
              decoration: AppTheme.glassDecoration(borderRadius: 8),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(metric.icon, size: 18, color: AppTheme.primary),
                  const SizedBox(height: 10),
                  Text(
                    metric.value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    metric.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PipelinePanel extends StatelessWidget {
  const _PipelinePanel();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _PipelineStep(
        'Cloud Storage',
        'Bezpečný import CSV bez uloženia do Gitu.',
      ),
      _PipelineStep(
        'Dedupe + validate',
        'Normalizácia emailov, duplicity a suppression kontrola.',
      ),
      _PipelineStep(
        'Firestore / Cloud SQL',
        'Segmenty, kampane, audit a stav odosielania.',
      ),
      _PipelineStep('Cloud Tasks', 'Rate limit, retry a kontrolované dávky.'),
      _PipelineStep(
        'Cloud Run worker',
        'Odosielanie cez Mailgun API bez lokálnych SMTP hackov.',
      ),
    ];

    return Container(
      decoration: AppTheme.glassDecoration(borderRadius: 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.account_tree_outlined,
            title: 'Pipeline',
            subtitle: 'Rýchly stroj na triedenie a dávkové odosielanie.',
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < steps.length; i++) ...[
            _TimelineStep(
              index: i + 1,
              title: steps[i].title,
              subtitle: steps[i].subtitle,
            ),
            if (i != steps.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SecurityPanel extends StatelessWidget {
  const _SecurityPanel();

  @override
  Widget build(BuildContext context) {
    const controls = [
      'Secret Manager pre API kľúče',
      'Suppression list pred každým send taskom',
      'Webhook signature verification',
      'Audit log každého importu a kampane',
      'Žiadne kontakty ani secrets v Gite',
    ];

    return Container(
      decoration: AppTheme.glassDecoration(borderRadius: 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.shield_outlined,
            title: 'Security model',
            subtitle: 'Anonymita ako privacy, kontrola a minimálne dáta.',
          ),
          const SizedBox(height: 18),
          for (final control in controls) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    control,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ProviderPanel extends StatelessWidget {
  const _ProviderPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration(borderRadius: 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.api_outlined,
            title: 'Napojenie',
            subtitle:
                'Google/Firebase riadi systém, email provider rieši doručiteľnosť.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _IntegrationChip(label: 'Firebase Auth'),
              _IntegrationChip(label: 'Cloud Storage'),
              _IntegrationChip(label: 'Firestore / Cloud SQL'),
              _IntegrationChip(label: 'Cloud Tasks'),
              _IntegrationChip(label: 'Cloud Run'),
              _IntegrationChip(label: 'Cloud Scheduler'),
              _IntegrationChip(label: 'Mailgun API'),
            ],
          ),
          const SizedBox(height: 16),
          const _InfoRow(
            label: 'Lokálny zdroj',
            value: EmailSenderScreen.localSourcePath,
          ),
        ],
      ),
    );
  }
}

class _GuardNotice extends StatelessWidget {
  final bool hasAccess;

  const _GuardNotice({required this.hasAccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (hasAccess ? AppTheme.success : AppTheme.warning).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (hasAccess ? AppTheme.success : AppTheme.warning).withValues(
            alpha: 0.26,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasAccess ? Icons.lock_open_outlined : Icons.lock_outline,
            size: 18,
            color: hasAccess ? AppTheme.success : AppTheme.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasAccess
                  ? 'Sekcia je pripravená pre platené Google Cloud/Firebase funkcie.'
                  : 'Na live operácie sa musí použiť prihlásenie cez schválený Google profil.',
              style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;

  const _TimelineStep({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.28)),
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegrationChip extends StatelessWidget {
  final String label;

  const _IntegrationChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x15FFFFFF)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;

  const _MetricData(this.label, this.value, this.icon);
}

class _PipelineStep {
  final String title;
  final String subtitle;

  const _PipelineStep(this.title, this.subtitle);
}
