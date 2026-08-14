import 'package:flutter/material.dart';
import '../core/theme/velvet_colors.dart';

class NetworkLatencyDisclaimerBanner extends StatelessWidget {
  final String? customMessage;

  const NetworkLatencyDisclaimerBanner({
    super.key,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final message = customMessage ??
        'If responses or news take longer to load, your internet connection or API endpoint may be slow. Pariyojana runs local zero-lag execution to keep your device smooth & responsive — please check your network or API endpoint.';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VelvetColors.periwinkle.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.bolt_rounded, color: VelvetColors.periwinkle, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: VelvetColors.textPrimary(context).withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
