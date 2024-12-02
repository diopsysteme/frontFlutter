// schedule_page.dart
import 'package:flutter/material.dart';
import './widget/header.dart';
import './widget/trans_butt.dart';
import './widget/trans_list.dart';
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ScheduleAppBar(),
      body: const ScheduleBody(),
    );
  }
}

class ScheduleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScheduleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Schedule Transfer',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            // Ajouter la logique d'aide ici
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ScheduleBody extends StatelessWidget {
  const ScheduleBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            HeaderSection(),
            SizedBox(height: 20),
            NewTransferButton(),
            SizedBox(height: 20),
            Expanded(child:  TransfersList()),
          ],
        ),
      ),
    );
  }
}
