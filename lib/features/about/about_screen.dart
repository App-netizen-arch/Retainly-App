import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.appName ?? 'Retainly')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.school_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.appName ?? 'Retainly',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Retainly',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Retainly is an offline-first study planner designed for Pakistani Matric (Class 9-10) students. It helps you build adaptive daily study plans, track focus sessions, and revise effectively using spaced repetition.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'License',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Retainly is licensed under the Apache License, Version 2.0. You may use, modify, and distribute this app for personal, educational, and commercial purposes, provided you include the license and notices.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Third-Party Licenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app uses open-source software. For a full list of third-party licenses, check the legal section in Settings.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/legal/privacy_policy'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/legal/terms_of_service'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_clock),
            title: const Text('Data Retention Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/legal/data_retention_policy'),
          ),
          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text('Age & Minor Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/legal/age_minor_policy'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Threat Model'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/legal/threat_model'),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2026 CodeSym. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
