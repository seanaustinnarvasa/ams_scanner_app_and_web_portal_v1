import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assets_model.dart';

class CollectionViewer extends StatelessWidget {
  const CollectionViewer({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'entry');
    final memberController = TextEditingController(text: 'Walk-in');
    final photoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Event Type'),
              ),
              TextField(
                controller: memberController,
                decoration: const InputDecoration(labelText: 'Member Type'),
              ),
              TextField(
                controller: photoController,
                decoration: const InputDecoration(labelText: 'Photo URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('assets').add({
                'name': nameController.text.trim(),
                'event_type': typeController.text.trim().isEmpty
                    ? 'entry'
                    : typeController.text.trim(),
                'member_type': memberController.text.trim().isEmpty
                    ? 'Guest'
                    : memberController.text.trim(),
                'photo_url': photoController.text.trim().isEmpty
                    ? null
                    : photoController.text.trim(),
                'timestamp': FieldValue.serverTimestamp(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    nameController.dispose();
    typeController.dispose();
    memberController.dispose();
    photoController.dispose();
  }

  Future<void> _deleteDoc(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await FirebaseFirestore.instance.collection('assets').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $docId'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editDoc(BuildContext context, Assets event) async {
    final nameController = TextEditingController(text: event.name);
    final typeController = TextEditingController(text: event.eventType);
    final memberController = TextEditingController(text: event.memberType);
    final photoController = TextEditingController(text: event.photoUrl ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Event Type'),
              ),
              TextField(
                controller: memberController,
                decoration: const InputDecoration(labelText: 'Member Type'),
              ),
              TextField(
                controller: photoController,
                decoration: const InputDecoration(labelText: 'Photo URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await FirebaseFirestore.instance
                  .collection('assets')
                  .doc(event.id)
                  .update({
                'name': nameController.text.trim(),
                'event_type': typeController.text.trim(),
                'member_type': memberController.text.trim(),
                'photo_url': photoController.text.trim().isEmpty
                    ? null
                    : photoController.text.trim(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    typeController.dispose();
    memberController.dispose();
    photoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirestoreService().getEventsRealtime();
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactHeader = screenWidth < 640;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(isCompactHeader ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row(
              //   children: [
              //     if (!isCompactHeader) ...[
              //       const Icon(Icons.history_rounded, size: 28),
              //       const SizedBox(width: 12),
              //     ],
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Live Events Stream',
              //             style: Theme.of(context).textTheme.titleLarge,
              //           ),
              //           Text(
              //             'Updates automatically from Firestore without page refresh',
              //             style:
              //                 Theme.of(context).textTheme.bodyMedium?.copyWith(
              //                       color: Theme.of(context)
              //                           .colorScheme
              //                           .onSurfaceVariant,
              //                     ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     // if (!isCompactHeader)
              //     //   FilledButton.icon(
              //     //     onPressed: () => _showAddDialog(context),
              //     //     icon: const Icon(Icons.add),
              //     //     label: const Text('Add'),
              //     //   ),
              //   ],
              // ),
              // if (isCompactHeader) ...[
              //   const SizedBox(height: 12),
              //   FilledButton.icon(
              //     onPressed: () => _showAddDialog(context),
              //     icon: const Icon(Icons.add),
              //     label: const Text('Add Event'),
              //   ),
              // ],
              // const SizedBox(height: 16),
              _RealtimeTable(
                stream: stream,
                // onDelete: _deleteDoc,
                // onEdit: _editDoc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RealtimeTable extends StatefulWidget {
  final Stream<List<Assets>> stream;
  // final Future<void> Function(BuildContext, String) onDelete;
  // final Future<void> Function(BuildContext, Assets) onEdit;

  const _RealtimeTable({
    required this.stream,
    // required this.onDelete,
    // required this.onEdit,
  });

  @override
  State<_RealtimeTable> createState() => _RealtimeTableState();
}

class _RealtimeTableState extends State<_RealtimeTable> {
  final _firestoreService = FirestoreService();
  final List<int> _rowsPerPageOptions = const [10, 25, 50, 100];

  int _rowsPerPage = 10;
  int _page = 0;
  int _totalRecords = 0;
  int _lastEventCount = -1;
  bool _isLoadingTotal = true;
  String? _totalError;

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
    // DataColumn(label: Text('Actions')),
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

  String _totalLabel() {
    if (_isLoadingTotal) return 'Loading total records...';
    if (_totalError != null) return 'Total records unavailable';
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

        if (events.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No assets found.'),
            ),
          );
        }

        final effectiveTotalRecords = _isLoadingTotal || _totalError != null
            ? events.length
            : _totalRecords;
        final pagedEvents =
            events.skip(_safePage * _rowsPerPage).take(_rowsPerPage).toList();

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
        // assets.timestamp
        DateFormat("yyyy-MM-dd hh:mm:ss").format(assets.timestamp.toDate())
      )),//assetDateCreated)),
      // DataCell(
      //   event.photoUrl == null || event.photoUrl!.isEmpty
      //       ? const Text('No photo')
      //       : SizedBox(
      //           width: 220,
      //           child: Text(
      //             event.photoUrl!,
      //             overflow: TextOverflow.ellipsis,
      //           ),
      //         ),
      // ),
      // DataCell(_actionRow(context, event)),
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
      // DataCell(Text(time)),
      // DataCell(Text(event.eventType)),
      // DataCell(_mobileDetails(context, event)),
      // DataCell(_actionRow(context, event)),
    ];
  }

  Widget _mobileDetails(BuildContext context, Assets event) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Member: ${event.memberType}',
          style: theme.textTheme.bodySmall,
        ),
        if (event.photoUrl != null && event.photoUrl!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'Photo: ${event.photoUrl}',
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ],
    );
  }

  // Widget _actionRow(BuildContext context, Assets event) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       IconButton(
  //         padding: EdgeInsets.zero,
  //         constraints: const BoxConstraints(
  //           minWidth: 36,
  //           minHeight: 36,
  //         ),
  //         icon: const Icon(Icons.edit, size: 18),
  //         onPressed: () => widget.onEdit(context, event),
  //         tooltip: 'Edit',
  //       ),
  //       IconButton(
  //         padding: EdgeInsets.zero,
  //         constraints: const BoxConstraints(
  //           minWidth: 36,
  //           minHeight: 36,
  //         ),
  //         icon: const Icon(Icons.delete, size: 18, color: Colors.red),
  //         onPressed: () => widget.onDelete(context, event.id),
  //         tooltip: 'Delete',
  //       ),
  //     ],
  //   );
  // }
  
}
