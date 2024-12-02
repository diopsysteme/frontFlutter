import 'package:flutter/material.dart';
import 'package:flutter3/app/modules/schedule/schedule/schedule_page.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import './account_card.dart';
import './quick_transfer.dart';
import './services_grid.dart';
import './user_header.dart';
import '../../transaction/views/transaction_view.dart';
import '../../schedule/views/schedule_view.dart'; // Ajout de l'import

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  
  // Cache the pages to avoid rebuilding
  final Map<int, Widget> _pageCache = {};

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: UserHeader()),
        SliverToBoxAdapter(child: AccountCard()),
        SliverToBoxAdapter(child: ServicesList()),
        SliverFillRemaining(child: TransactionView()),
      ],
    );
  }

  Widget _getPage(int index) {
    return _pageCache.putIfAbsent(index, () {
      switch (index) {
        case 0:
          return _buildHomeContent();
        case 1:
          return SchedulePage(); // Modification ici pour afficher ScheduleView
        case 2:
          return _buildHomeContent();
        case 3:
          return _buildHomeContent();
        default:
          return _buildHomeContent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getPage(controller.currentIndex.value),
        )),
      ),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.currentIndex.value,
        onDestinationSelected: (int index) {
          controller.onItemTapped(index);
          // Remove navigation logic since we're handling it with _getPage
          /*switch (index) {
            case 0:
              Get.toNamed('/home');
              break;
            case 1:
              Get.toNamed('/schedule');
              break;
            case 2:
              Get.toNamed('/dashboard');
              break;
            default:
              break;
          }*/
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      )),
    );
  }
}