import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  static String routeName = 'welcome_screen';
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildGradientOverlay(),
          _buildContent(context),
        ],
      ),
    );
  }
  Widget _buildBackgroundImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Widget _buildGradientOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
    );
  }
  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            _buildLogo(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildTitle(context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _buildSubtitle(context),
            const Spacer(),
            _buildGetStartedButton(context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ],
        ),
      ),
    );
  }
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.explore,
        color: Colors.white,
        size: 40,
      ),
    );
  }
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Discover\nThe World',
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.1,
        letterSpacing: -1,
      ),
    );
  }
  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Explore new places and create unforgettable memories with our travel app.',
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.04,
        color: Colors.white.withOpacity(0.8),
        height: 1.5,
      ),
    );
  }
  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}