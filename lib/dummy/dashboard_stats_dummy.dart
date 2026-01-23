import 'package:flutter/material.dart';

class DashboardStat {
  final IconData icon;
  final String title;
  final int value;
  final String subtitle;

  DashboardStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

final adminStatsDummy = [
  DashboardStat(
    icon: Icons.build_outlined,
    title: 'Tools',
    value: 6,
    subtitle: '1 damaged',
  ),
  DashboardStat(
    icon: Icons.group_outlined,
    title: 'User',
    value: 4,
    subtitle: '',
  ),
  DashboardStat(
    icon: Icons.outbond,
    title: 'Borrowed',
    value: 3,
    subtitle: '',
  ),
  DashboardStat(
    icon: Icons.attach_money,
    title: 'Penalty',
    value: 1,
    subtitle: '',
  ),
];

final officerBorrowerStatsDummy = [
  DashboardStat(
    icon: Icons.access_time,
    title: 'Pending',
    value: 5,
    subtitle: '',
  ),
  DashboardStat(
    icon: Icons.calendar_month,
    title: 'Approved',
    value: 8,
    subtitle: '',
  ),
  DashboardStat(
    icon: Icons.outbond,
    title: 'Borrowed',
    value: 12,
    subtitle: '',
  ),
  DashboardStat(
    icon: Icons.attach_money,
    title: 'Penalty',
    value: 2,
    subtitle: '',
  ),
];