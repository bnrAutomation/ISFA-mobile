import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/campaign_module/services/campaign_offline_service.dart';

class OfflineIndicator extends StatelessWidget {
  final CampaignOfflineService offlineService;
  
  const OfflineIndicator({required this.offlineService, super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        final pendingCount = offlineService.getPendingSubmissionCount();
        
        if (pendingCount > 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange,
            child: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$pendingCount campaign(s) pending offline submission',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<CampaignBloc>().add(SyncOfflineSubmissionsEvent());
                  },
                  child: const Text(
                    'Sync Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}



