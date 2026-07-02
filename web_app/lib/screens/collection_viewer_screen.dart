import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/assets_model.dart';
import '../providers/theme_provider.dart';

enum FilterOption { allRecords, currentlyOut }

List<Assets> getCurrentlyOutAssets(List<Assets> events) {
  if (events.isEmpty) return const [];

  final latestByAsset = <String, Assets>{};
  for (final event in events) {
    final current = latestByAsset[event.assetTagId];
    if (current == null || event.timestamp.compareTo(current.timestamp) > 0) {
      latestByAsset[event.assetTagId] = event;
    }
  }

  final outAssets = latestByAsset.values.where((asset) {
    final type = asset.eventType.trim().toLowerCase();
    return type == 'out' || type.contains('exit') || type.contains('checkout');
  }).toList();

  outAssets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return outAssets;
}

class CollectionViewer extends StatelessWidget {
  const CollectionViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirestoreService().getEventsRealtime();

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CollectionHeader(),
            const SizedBox(height: 16),
            _RealtimeTable(
              stream: stream,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.devices,
            size: 32,
            color: isDark
                ? Colors.white
                : Colors.black
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset Movement Log',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 26
                ),
              ),
              Text(
                'Real-time data monitoring',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 17
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealtimeTable extends StatefulWidget {
  final Stream<List<Assets>> stream;

  const _RealtimeTable({
    required this.stream,
  });

  @override
  State<_RealtimeTable> createState() => _RealtimeTableState();
}

class _RealtimeTableState extends State<_RealtimeTable> {
  final _firestoreService = FirestoreService();
  static const List<int> _rowsPerPageOptions = [10, 25, 50, 100];

  int _rowsPerPage = 10;
  int _page = 0;
  int _totalRecords = 0;
  int _lastEventCount = -1;
  bool _isLoadingTotal = true;
  String? _totalError;
  FilterOption _selectedFilter = FilterOption.allRecords;

  static const List<DataColumn> _desktopColumns = [
    DataColumn(label: Text('ASSET TAG ID')),
    DataColumn(label: Text('ASSET TAG NAME')),
    DataColumn(label: Text('ASSIGNEE NAME')),
    DataColumn(label: Text('DEPARTMENT')),
    DataColumn(label: Text('ASSET STATUS')),
    DataColumn(label: Text('SCANNED DATE & TIME')),
  ];

  static const List<DataColumn> _mobileColumns = [
    DataColumn(label: Text('ASSET TAG ID')),
    DataColumn(label: Text('ASSET TAG NAME')),
    DataColumn(label: Text('ASSIGNEE NAME')),
  ];

  @override
  void initState() {
    super.initState();
    _loadTotalRecords();
  }

  int get _totalPages => max(1, (_totalRecords / _rowsPerPage).ceil());

  int get _safePage => min(_page, _totalPages - 1);

  Future<void> _loadTotalRecords() async {
    if (!mounted) return;

    setState(() {
      _isLoadingTotal = true;
      _totalError = null;
    });

    try {
      final totalRecords = await _firestoreService.getTotalRecords();
      if (!mounted) return;
      setState(() {
        _totalRecords = totalRecords;
        _isLoadingTotal = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _totalError = e.toString();
        _isLoadingTotal = false;
      });
    }
  }

  void _changeRowsPerPage(int? value) {
    if (value == null) return;

    setState(() {
      _rowsPerPage = value;
      _page = 0;
    });
  }

  void _previousPage() {
    setState(() {
      _page = max(0, _page - 1);
    });
  }

  void _nextPage() {
    setState(() {
      _page = min(_page + 1, _totalPages - 1);
    });
  }

  void _onFilterChanged(FilterOption option) {
    setState(() {
      _selectedFilter = option;
      _page = 0;
    });
  }

  String _totalLabel() {
    if (_isLoadingTotal) return 'Loading total records...';
    if (_totalError != null) return 'Total records unavailable';
    if (_selectedFilter == FilterOption.currentlyOut) return 'Currently out assets';
    return '$_totalRecords total records';
  }

  String _rangeLabel(int visibleCount, int effectiveTotalRecords) {
    if (_isLoadingTotal) return 'Loading records...';
    if (_totalError != null) return '$visibleCount loaded records';
    if (effectiveTotalRecords == 0) return '0 of 0 records';
    if (visibleCount == 0) return '0 of $effectiveTotalRecords records';

    final start = _safePage * _rowsPerPage + 1;
    final end = min(start + visibleCount - 1, effectiveTotalRecords);
    return '$start-$end of $effectiveTotalRecords';
  }

  Widget _buildFilterChips() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        children: FilterOption.values.map((option) {
          final isSelected = _selectedFilter == option;
          final label = option == FilterOption.allRecords
              ? 'ALL RECORDS'
              : 'CURRENTLY OUT';

          return FilterChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => _onFilterChanged(option),
            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Assets>>(
      stream: widget.stream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final events = snapshot.data ?? [];

        if (_lastEventCount != events.length) {
          _lastEventCount = events.length;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadTotalRecords();
          });
        }

        final displayEvents = _selectedFilter == FilterOption.currentlyOut
            ? getCurrentlyOutAssets(events)
            : events;

        final effectiveTotalRecords = _selectedFilter == FilterOption.currentlyOut
            ? displayEvents.length
            : (_isLoadingTotal || _totalError != null ? events.length : _totalRecords);

        if (displayEvents.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                _selectedFilter == FilterOption.currentlyOut
                    ? 'No devices are currently out.'
                    : 'No assets found.',
              ),
            ),
          );
        }

        final pagedEvents =
            displayEvents.skip(_safePage * _rowsPerPage).take(_rowsPerPage).toList();

        return LayoutBuilder(
          builder: (layoutContext, constraints) {
            final availableWidth =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 900.0;
            final isCompact = availableWidth < 680;
            final tableWidth =
                isCompact ? availableWidth : max(900.0, availableWidth);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilterChips(),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: DataTable(
                      showCheckboxColumn: false,
                      showBottomBorder: true,
                      horizontalMargin: isCompact ? 8 : 12,
                      columnSpacing: isCompact ? 8 : 16,
                      headingRowHeight: isCompact ? 44 : 48,
                      dataRowMinHeight: isCompact ? 72 : 56,
                      dataRowMaxHeight: isCompact ? 128 : 64,
                      dividerThickness: 1,
                      columns: isCompact ? _mobileColumns : _desktopColumns,
                      rows: pagedEvents.map((event) {
                        final time = DateFormat('MMM dd, yyyy HH:mm:ss')
                            .format(event.timestamp.toDate());

                        return DataRow(
                          cells: isCompact
                              ? _mobileCells(context, event, time)
                              : _desktopCells(context, event, time),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildFooter(
                  isCompact: isCompact,
                  visibleCount: pagedEvents.length,
                  effectiveTotalRecords: effectiveTotalRecords,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFooter({
    required bool isCompact,
    required int visibleCount,
    required int effectiveTotalRecords,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(_totalLabel()),
        ),
        DropdownButton<int>(
          value: _rowsPerPage,
          isDense: true,
          underline: const SizedBox(),
          items: _rowsPerPageOptions.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
          onChanged: _changeRowsPerPage,
        ),
        const Text('rows'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(_rangeLabel(visibleCount, effectiveTotalRecords)),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          icon: const Icon(Icons.chevron_left),
          onPressed: _page <= 0 ? null : _previousPage,
          tooltip: 'Previous page',
        ),
        Text('Page ${_safePage + 1} of $_totalPages'),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          icon: const Icon(Icons.chevron_right),
          onPressed: _safePage >= _totalPages - 1 ? null : _nextPage,
          tooltip: 'Next page',
        ),
      ],
    );
  }

  List<DataCell> _desktopCells(
    BuildContext context,
    Assets assets,
    String time,
  ) {
    return [
      DataCell(Text(assets.assetTagId)),
      DataCell(Text(assets.assetTagName)),
      DataCell(Text(assets.assetAssignee)),
      DataCell(Text(assets.assetDepartment)),
      DataCell(Text(assets.assetStatus)),
      DataCell(Text(
        DateFormat("yyyy-MM-dd hh:mm:ss").format(assets.timestamp.toDate())
      )),
    ];
  }

  List<DataCell> _mobileCells(
    BuildContext context,
    Assets assets,
    String time,
  ) {
    return [
      DataCell(Text(assets.assetTagId)),
      DataCell(Text(assets.assetTagName)),
      DataCell(Text(assets.assetAssignee)),
    ];
  }
}
