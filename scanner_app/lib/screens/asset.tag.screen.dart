import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';

class AssetTagScreen extends StatelessWidget {
  static const routeName = App.assetTagScreen;

  const AssetTagScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1A1A2E),
      backgroundColor: const Color(0xFF210007),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Routes.goBack(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Asset Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: App.fontSecondary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDetailsContainer(context),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Routes.goBack(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFcb9f48),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Scan Again',
                    style: TextStyle(
                      color: Color(0xFF320100),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: App.fontSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCards(),
              // const SizedBox(height: 16),
              // _buildWhiteQrCard(
              //   title: 'Asset Details',
              //   subtitle: 'Registered Item',
              //   qrSize: 220,
              // ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetHeaderDetails() {
    return const Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            child: Icon(
              Icons.laptop_chromebook,
              color: Colors.black,
              size: 30,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Laptop Asset',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'U20512393',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.normal,
              fontFamily: App.montserrat,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Asset Status',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.w100,
              fontFamily: App.montserrat,
            ),
          ),
          Text(
            'OUT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
          // _buildStatusBadge(true),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF00D9FF), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00D9FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: App.fontSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        _buildInfoCard(
          icon: Icons.edit_outlined,
          label: 'Edit Asset',
        ),
        const SizedBox(width: 10),
        _buildInfoCard(
          icon: Icons.flag_outlined,
          label: 'Report Issue',
        ),
        const SizedBox(width: 10),
        _buildInfoCard(
          icon: CupertinoIcons.person_circle,
          label: 'Assign to User',
        ),
      ],
    );
  }

  Widget _buildDetailsContainer(BuildContext context) {
    return Container(
        width: double.infinity,
        // padding: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF906b65)),
        ),
        child: Column(
          children: [
            _buildAssetHeaderDetails(),
            const SizedBox(height: 16),
            _horizontalDivider(),
            const SizedBox(height: 8),
            _buildCenteredDetail(
              label: 'Asset Assignee',
              value: 'Juan Dela Cruz',
              hasSecondaryLabel: false
              ),
            const SizedBox(height: 8),
            _buildCenteredDetail(
              label: 'Asset Assignee ID Number',
              value: 'EMR-JCR-0223',
              hasSecondaryLabel: false
            ),
            _buildCenteredDetail(
              label: 'Asset Assignee Department',
              value: 'Information Technology',
              hasSecondaryLabel: false
            ),
            _horizontalDivider(),
            _buildCenteredDetailWithAction(
              context: context,
              label: 'Asset Serial Number',
              value: '15012039120391203JGCHT541241',
              icon: Icons.copy,
            ),
            _buildCenteredDetail(
              label: 'Created Date',
              value: 'June 15, 2026 05:30:04 PM',
              hasSecondaryLabel: false
            ),
          ],
        ),
      );
  }

  Widget _horizontalDivider() {
    return const SizedBox(
      width: 300,
      child: Divider(
        color: Color(0xFF906b65),
        thickness: 1,
      ),
    );
  }

  Widget _buildCenteredDetailWithAction({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          const Text(
            'Secondary Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.w100,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFe7bd9c),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: App.montserrat,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Serial number copied'),
                      backgroundColor: Color(0xFF390b16),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    icon,
                    color: const Color(0xFFe7bd9c),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredDetail(
      {required String label,
      required String value,
      required bool hasSecondaryLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 16,
              fontWeight: FontWeight.w100,
              fontFamily: App.montserrat,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFe7bd9c),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: App.montserrat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        height: 80,
        // color: const Color(0xFF390b16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF390b16),
          borderRadius: BorderRadius.circular(14),
          // border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFe7bd9c), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFe7bd9c),
                fontSize: 14,
                fontWeight: FontWeight.w100,
                fontFamily: App.montserrat,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
