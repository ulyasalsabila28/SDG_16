
import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/async_view.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'create_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String filter = '';
  bool grid = false;

  static const List<(String, String)> _tabs = [
    ('', 'Semua'),
    ('belum', 'Belum Diverifikasi'),
    ('sedang', 'Sedang Diverifikasi'),
    ('selesai', 'Sudah Ditangani'),
  ];

  Widget _tab(String value, String title) {
    final bool selected = filter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          filter = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? C.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.gold),
        ),
        child: Text(
          selected && value.isEmpty ? '✓ $title' : title,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            color: selected ? Colors.white : C.text,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _count(String status, int count) {
    return Expanded(
      child: Box(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    statusLabel[status] ?? status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: C.text,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: C.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _detail(Map report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 +
                  MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['code']?.toString() ?? '',
                  style: const TextStyle(
                    color: C.gold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report['title']?.toString() ?? '-',
                  style: const TextStyle(
                    color: C.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                StatusChip(
                  statusLabel[report['status']] ??
                      report['status']?.toString() ??
                      '-',
                  statusColor(report['status']),
                ),
                const SizedBox(height: 12),
                Text(
                  report['description'] == null ||
                          report['description'].toString().isEmpty
                      ? 'Tidak ada deskripsi.'
                      : report['description'].toString(),
                  style: const TextStyle(
                    color: C.text,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 13,
                      color: C.gold,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report['location']?.toString() ?? '-',
                        style: const TextStyle(
                          color: C.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dikirim: ${report['created_at'] ?? '-'}',
                  style: const TextStyle(
                    color: C.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _listCard(Map report) {
    final String code = report['code']?.toString() ?? '';
    final String status = report['status']?.toString() ?? '';
    final String title = report['title']?.toString() ?? '-';
    final String location =
        report['location']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: Box(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 75,
                        child: Text(
                          code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: C.gold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      StatusChip(
                        statusLabel[status] ?? status,
                        statusColor(status),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _detail(report),
                  child: const DetailBtn('Lihat detail'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: const TextStyle(
                color: C.text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: C.gold,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: C.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridCard(Map report) {
    final String code = report['code']?.toString() ?? '';
    final String status = report['status']?.toString() ?? '';
    final String title = report['title']?.toString() ?? '-';
    final String location =
        report['location']?.toString() ?? '-';

    return GestureDetector(
      onTap: () => _detail(report),
      child: Box(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: C.gold,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                statusLabel[status] ?? status,
                statusColor(status),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: C.text,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 11,
                  color: C.gold,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: C.grey,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: DetailBtn('Lihat detail'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        'LAPORAN SAYA',
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateReportScreen(),
                ),
              );
            },
            child: const RoundIcon(Icons.add),
          ),
        ],
      ),
      body: AsyncView(
        key: ValueKey(filter),
        load: () => Api.get(
          '/reports${filter.isEmpty ? '' : '?status=$filter'}',
        ),
        builder: (context, data) {
          final counts =
              data['counts'] as Map? ?? <String, dynamic>{};
          final List reports = data['reports'] as List? ?? [];

          int getCount(String key) {
            final value = counts[key];
            if (value is int) return value;
            if (value is num) return value.toInt();
            return int.tryParse(value?.toString() ?? '') ?? 0;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double horizontalPadding =
                  width < 360 ? 10 : 16;

              return ListView(
                padding: EdgeInsets.all(horizontalPadding),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final tab in _tabs)
                          _tab(tab.$1, tab.$2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _count('belum', getCount('belum')),
                      const SizedBox(width: 8),
                      _count('sedang', getCount('sedang')),
                      const SizedBox(width: 8),
                      _count('selesai', getCount('selesai')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    'LAPORAN TERBARU',
                    grid: grid,
                    onChanged: (value) {
                      setState(() {
                        grid = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  if (reports.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'Belum ada laporan',
                          style: TextStyle(color: C.grey),
                        ),
                      ),
                    ),
                  if (grid && reports.isNotEmpty)
                    RGrid(
                      cols: 2,
                      wideCols: 3,
                      gap: 10,
                      children: [
                        for (final report in reports)
                          _gridCard(report as Map),
                      ],
                    ),
                  if (!grid)
                    for (final report in reports)
                      _listCard(report as Map),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
