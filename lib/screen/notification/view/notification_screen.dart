import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> notifications = [
    {
      'type': 'Low Stock',
      'title': 'Low Stock Alert - Iphone 16 pro',
      'subtitle': 'Iphone 16 pro stock is below its threshold level',
      'timeAgo': '5 mins ago',
      'buttonColor': Colors.deepOrange,
    },
    {
      'type': 'New Arrivals',
      'title': 'New Arrivals - Samsung Galaxy S22',
      'subtitle': 'Samsung Galaxy S22 available in your inventory',
      'timeAgo': '15 mins ago',
      'buttonColor': Colors.orange,
    },
    {
      'type': 'Product Expiry',
      'title': 'Product Expiry Alert - Iphone 16 pro',
      'subtitle': 'Iphone 16 pro stock is about to get expired',
      'timeAgo': '3 days ago',
      'buttonColor': Colors.red,
    },
    {
      'type': 'Low Stock',
      'title': 'Low Stock Alert - Iphone 16 pro',
      'subtitle': 'Iphone 16 pro stock is below its threshold level',
      'timeAgo': '5 mins ago',
      'buttonColor': Colors.deepOrange,
    },
    {
      'type': 'Low Stock',
      'title': 'Low Stock Alert - Iphone 16 pro',
      'subtitle': 'Iphone 16 pro stock is below its threshold level',
      'timeAgo': '7 mins ago',
      'buttonColor': Colors.deepOrange,
    },
  ];

  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate fetching more notifications
    final List<Map<String, dynamic>> moreNotifications = [
      {
        'type': 'Low Stock',
        'title': 'Low Stock Alert - Samsung Galaxy S22',
        'subtitle': 'Samsung Galaxy S22 stock is below its threshold level',
        'timeAgo': '10 mins ago',
        'buttonColor': Colors.deepOrange,
      },
      {
        'type': 'New Arrivals',
        'title': 'New Arrivals - Google Pixel 9',
        'subtitle': 'Google Pixel 9 available in your inventory',
        'timeAgo': '20 mins ago',
        'buttonColor': Colors.orange,
      },
      {
        'type': 'Product Expiry',
        'title': 'Product Expiry Alert - Samsung Galaxy S22',
        'subtitle': 'Samsung Galaxy S22 stock is about to get expired',
        'timeAgo': '4 days ago',
        'buttonColor': Colors.red,
      },
    ];

    // Check if we have more data to load
    if (notifications.length >= 15) {
      setState(() {
        _hasMoreData = false;
        _isLoading = false;
      });
    } else {
      setState(() {
        notifications.addAll(moreNotifications);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      notifications = [
        {
          'type': 'Low Stock',
          'title': 'Low Stock Alert - Iphone 16 pro',
          'subtitle': 'Iphone 16 pro stock is below its threshold level',
          'timeAgo': '5 mins ago',
          'buttonColor': Colors.deepOrange,
        },
        {
          'type': 'New Arrivals',
          'title': 'New Arrivals - Samsung Galaxy S22',
          'subtitle': 'Samsung Galaxy S22 available in your inventory',
          'timeAgo': '15 mins ago',
          'buttonColor': Colors.orange,
        },
        {
          'type': 'Product Expiry',
          'title': 'Product Expiry Alert - Iphone 16 pro',
          'subtitle': 'Iphone 16 pro stock is about to get expired',
          'timeAgo': '3 days ago',
          'buttonColor': Colors.red,
        },
        {
          'type': 'Low Stock',
          'title': 'Low Stock Alert - Iphone 16 pro',
          'subtitle': 'Iphone 16 pro stock is below its threshold level',
          'timeAgo': '5 mins ago',
          'buttonColor': Colors.deepOrange,
        },
        {
          'type': 'Low Stock',
          'title': 'Low Stock Alert - Iphone 16 pro',
          'subtitle': 'Iphone 16 pro stock is below its threshold level',
          'timeAgo': '7 mins ago',
          'buttonColor': Colors.deepOrange,
        },
      ];
      _hasMoreData = true;
      _isLoading = false;
    });
  }

  // New method to mark all notifications as read
  void _markAllAsRead() {
    // Logic to mark all notifications as read
    setState(() {
      // Here you would typically update a 'read' status for each notification
      // For this example, we'll just return a count of 0 to indicate all are read
    });

    // Return 0 (or updated count) to the previous screen
    Navigator.pop(context, 0);
  }

  // Method to dismiss a specific notification
  void _dismissNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });

    // If all notifications are dismissed, return 0 to the previous screen
    if (notifications.isEmpty) {
      Navigator.pop(context, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, notifications.length),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: notifications.length + (_hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < notifications.length) {
              final notification = notifications[index];
              return _buildNotificationItem(
                context,
                index: index,
                type: notification['type'],
                title: notification['title'],
                subtitle: notification['subtitle'],
                timeAgo: notification['timeAgo'],
                buttonColor: notification['buttonColor'],
              );
            } else if (_isLoading) {
              return _buildLoadingIndicator();
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more notifications...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, {
        required int index,
        required String type,
        required String title,
        required String subtitle,
        required String timeAgo,
        required Color buttonColor,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: buttonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: buttonColor,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _dismissNotification(index),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}