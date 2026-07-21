import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/notifications/notification_service.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/l10n/generated/app_localizations.dart';

/// Bottom sheet that lets the user turn on/off the opt-in daily reminder
/// and pick what time it fires. Kept deliberately simple (no dedicated
/// settings page yet) — reachable from the bell icon on the Home hero.
Future<void> showReminderSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ReminderSettingsSheet(),
  );
}

class _ReminderSettingsSheet extends StatefulWidget {
  const _ReminderSettingsSheet();

  @override
  State<_ReminderSettingsSheet> createState() =>
      _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState extends State<_ReminderSettingsSheet> {
  final NotificationService _notifications = di.sl<NotificationService>();
  late bool _enabled = _notifications.isEnabled;
  late TimeOfDay _time = _notifications.reminderTime;
  bool _busy = false;
  String? _error;

  Future<void> _toggle(bool value) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    if (value) {
      final granted = await _notifications.enableReminder(time: _time);
      if (!mounted) return;
      setState(() {
        _enabled = granted;
        _busy = false;
        if (!granted) {
          _error = AppLocalizations.of(context).reminderPermissionError;
        }
      });
    } else {
      await _notifications.disableReminder();
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _busy = false;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: '¿A qué hora te recordamos?',
    );
    if (picked == null) return;
    setState(() => _time = picked);
    if (_enabled) {
      setState(() => _busy = true);
      await _notifications.enableReminder(time: picked);
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: PremiumDesign.premiumShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: Color(0xFFD4AF37)),
                const SizedBox(width: 10),
                Text(
                  l10n.reminderTitle,
                  style: PremiumDesign.serifSubHeading.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.reminderSubtitle,
              style: PremiumDesign.sansBody.copyWith(
                fontSize: 13,
                color: PremiumDesign.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.reminderEnable,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: PremiumDesign.softText,
                  ),
                ),
                Switch(
                  value: _enabled,
                  onChanged: _busy ? null : _toggle,
                  activeTrackColor: const Color(0xFFD4AF37),
                ),
              ],
            ),
            if (_enabled) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: _busy ? null : _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 18, color: PremiumDesign.secondaryText),
                      const SizedBox(width: 10),
                      Text(
                        l10n.reminderTimeLabel(_time.format(context)),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: PremiumDesign.softText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.reminderChange,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFFB3261E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
