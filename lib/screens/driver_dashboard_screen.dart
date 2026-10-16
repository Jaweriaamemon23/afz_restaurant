import 'package:flutter/material.dart';

const Color afzOrange = Color(0xFFFF642F);
const Color pageBg = Color(0xFFF7F7F9);

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int selectedTab = 0;
  bool isOnline = true;

  final List<Map<String, dynamic>> deliveries = [
    {
      'id': 'AFZ-1024',
      'customer': 'Ahmed Khan',
      'address': 'Sukkur City, Main Road',
      'items': '2 items',
      'amount': 1250,
      'status': 'Assigned',
    },
    {
      'id': 'AFZ-1025',
      'customer': 'Sara Ali',
      'address': 'Military Road, Sukkur',
      'items': '3 items',
      'amount': 1850,
      'status': 'Assigned',
    },
    {
      'id': 'AFZ-1026',
      'customer': 'Usman Ahmed',
      'address': 'Airport Road, Sukkur',
      'items': '1 item',
      'amount': 650,
      'status': 'Delivered',
    },
  ];

  void updateStatus(int index, String status) {
    setState(() {
      deliveries[index]['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivery status updated: $status'),
        backgroundColor: afzOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            buildDashboard(),
            buildDeliveries(),
            buildHistory(),
            buildProfile(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) => setState(() => selectedTab = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: afzOrange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_rounded),
            label: 'Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildDashboard() {
    final active = deliveries.where((d) => d['status'] != 'Delivered').length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: afzOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                color: afzOrange,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AFZ Restaurant',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Driver Dashboard',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.circle,
                  size: 16,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'You are online' : 'You are offline',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline
                          ? 'Ready to receive deliveries'
                          : 'You will not receive new deliveries',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOnline,
                activeColor: afzOrange,
                onChanged: (value) => setState(() => isOnline = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Today at a glance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: statCard(
                'Active orders',
                '$active',
                Icons.delivery_dining,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                'Completed',
                '${deliveries.where((d) => d['status'] == 'Delivered').length}',
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: statCard(
                'Earnings',
                'Rs. 350',
                Icons.account_balance_wallet_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                'Rating',
                '4.8 ★',
                Icons.star_outline_rounded,
                Colors.amber.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assigned deliveries',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setState(() => selectedTab = 1),
              child: const Text('View all', style: TextStyle(color: afzOrange)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...List.generate(deliveries.length, (index) {
          if (deliveries[index]['status'] == 'Delivered') {
            return const SizedBox.shrink();
          }
          return deliveryCard(index);
        }),
      ],
    );
  }

  Widget buildDeliveries() {
    final activeOrders = deliveries
        .where((d) => d['status'] != 'Delivered')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Deliveries',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage your assigned restaurant orders.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        if (activeOrders.isEmpty)
          emptyState(
            'No active deliveries',
            'New assigned deliveries will appear here.',
          )
        else
          ...List.generate(deliveries.length, (index) {
            if (deliveries[index]['status'] == 'Delivered') {
              return const SizedBox.shrink();
            }
            return deliveryCard(index);
          }),
      ],
    );
  }

  Widget buildHistory() {
    final completed = deliveries
        .where((d) => d['status'] == 'Delivered')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Delivery History',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your completed deliveries.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        if (completed.isEmpty)
          emptyState(
            'No completed deliveries',
            'Completed orders will appear here.',
          )
        else
          ...completed.map(
            (order) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: whiteCard(),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE7F7EC),
                    child: Icon(Icons.check, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['id'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['customer'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs. ${order['amount']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Profile',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: whiteCard(),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFFFE7DF),
                child: Icon(Icons.person, size: 48, color: afzOrange),
              ),
              SizedBox(height: 12),
              Text(
                'Delivery Driver',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'AFZ Restaurant Delivery Team',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        profileOption(Icons.person_outline, 'Personal Information'),
        profileOption(Icons.phone_outlined, 'Contact Details'),
        profileOption(Icons.account_balance_wallet_outlined, 'My Earnings'),
        profileOption(Icons.help_outline, 'Help & Support'),
        profileOption(Icons.settings_outlined, 'Settings'),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connect your logout flow here.')),
            );
          },
          icon: const Icon(Icons.logout, color: afzOrange),
          label: const Text('Log Out', style: TextStyle(color: afzOrange)),
        ),
      ],
    );
  }

  Widget deliveryCard(int index) {
    final order = deliveries[index];
    final status = order['status'] as String;

    String buttonLabel;
    String nextStatus;

    if (status == 'Assigned') {
      buttonLabel = 'Accept Delivery';
      nextStatus = 'Accepted';
    } else if (status == 'Accepted') {
      buttonLabel = 'Start Delivery';
      nextStatus = 'On the way';
    } else {
      buttonLabel = 'Mark as Delivered';
      nextStatus = 'Delivered';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: afzOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: afzOrange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['id'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['items'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${order['amount']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_outline, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(child: Text(order['customer'])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: afzOrange),
              const SizedBox(width: 10),
              Expanded(child: Text(order['address'])),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: afzOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Map navigation will be connected next.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Location'),
                  style: OutlinedButton.styleFrom(foregroundColor: afzOrange),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => updateStatus(index, nextStatus),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: afzOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(buttonLabel, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget profileOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: whiteCard(),
      child: ListTile(
        leading: Icon(icon, color: afzOrange),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title will be connected next.')),
          );
        },
      ),
    );
  }

  Widget emptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: whiteCard(),
      child: Column(
        children: [
          const Icon(Icons.delivery_dining, size: 48, color: afzOrange),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  BoxDecoration whiteCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade100),
    );
  }
}
