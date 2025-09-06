import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metro_project/station.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stations_data.dart';
import 'details_page.dart';
import 'location_fun.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Station? fromStation;
  Station? toStation;
  Station? nearestStationFromCurrent;
  Station? nearestStationFromDestination;
  final showLocationField = false.obs;
  final answer1 = TextEditingController();
  final answer2 = TextEditingController();
  final answer3 = TextEditingController();
  final answer4 = TextEditingController();
  final locationController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    answer1.dispose();
    answer2.dispose();
    answer3.dispose();
    answer4.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),
              _buildStationInputSection(),
              const SizedBox(height: 24),
              _buildPassengerDetailsSection(),
              const SizedBox(height: 32),
              _buildMainActionButton(),
              const SizedBox(height: 32),
              _buildLocationServicesSection(),
              const SizedBox(height: 16),
              Obx(() => _buildDestinationAddressSection()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Metro Navigator',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF2D3748),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.directions_subway_rounded,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Plan Your Journey',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find the fastest route between stations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationInputSection() {
    return Column(
      children: [
        _buildAnimatedStationCard(
          controller: answer1,
          label: 'Departure Station',
          icon: Icons.location_pin,
          iconColor: const Color(0xFFEF4444),
          onMapPressed: () => _openStationOnMap(answer1, fromStation),
          onSelected: (station) => fromStation = station,
        ),
        const SizedBox(height: 16),
        _buildAnimatedStationCard(
          controller: answer2,
          label: 'Arrival Station',
          icon: Icons.location_pin,
          iconColor: const Color(0xFF10B981),
          onMapPressed: () => _openStationOnMap(answer2, toStation),
          onSelected: (station) => toStation = station,
        ),
      ],
    );
  }

  Widget _buildAnimatedStationCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onMapPressed,
    required Function(Station?) onSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  DropdownMenu<Station>(
                    controller: controller,
                    width: MediaQuery.of(context).size.width * 0.5,
                    menuHeight: 200,
                    hintText: 'Select station',
                    enableFilter: true,
                    enableSearch: true,
                    requestFocusOnTap: true,
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSelected: (station) => onSelected(station),
                    dropdownMenuEntries: [
                      for (var station in metroStations)
                        DropdownMenuEntry<Station>(
                          value: station,
                          label: station.name,
                          leadingIcon: const Icon(Icons.train),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.map_outlined, color: Color(0xFF4F46E5)),
              onPressed: onMapPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSENGER DETAILS',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailInputField(
                  controller: answer3,
                  hintText: 'Age',
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailInputField(
                  controller: answer4,
                  hintText: 'Accessibility',
                  icon: Icons.accessible_outlined,
                  iconColor: const Color(0xFF10B981),
                  isDropdown: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    bool isDropdown = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: isDropdown
                ? DropdownMenu(
              controller: controller,
              width: MediaQuery.of(context).size.width * 0.3,
              hintText: hintText,
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'yes', label: 'Disabled'),
                DropdownMenuEntry(value: 'no', label: 'Not Disabled'),
              ],
            )
                : TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 12),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    return ElevatedButton(
      onPressed: _handleShowDetails,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
        shadowColor: const Color(0xFF4F46E5).withOpacity(0.3),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            'FIND BEST ROUTE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATION SERVICES',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLocationServiceButton(
                text: 'Nearest Station',
                icon: Icons.near_me,
                color: const Color(0xFF10B981),
                onPressed: () async {
                  nearestStationFromCurrent = await findNearestStationFromCurrent();
                  if (nearestStationFromCurrent != null) {
                    answer1.text = nearestStationFromCurrent!.name;
                    fromStation = nearestStationFromCurrent;
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLocationServiceButton(
                text: 'Enter Destination',
                icon: Icons.location_searching,
                color: const Color(0xFFF59E0B),
                onPressed: () {
                  showLocationField.value = !showLocationField.value;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationServiceButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationAddressSection() {
    return showLocationField.value
        ? Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DESTINATION ADDRESS',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          hintText: "Enter destination address",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildLocationActionButton(
                      text: 'Find Station',
                      icon: Icons.search,
                      color: const Color(0xFF3B82F6),
                      onPressed: () async {
                        if (locationController.text.isEmpty) {
                          _showErrorSnackbar('Please enter a location first');
                          return;
                        }
                        nearestStationFromDestination =
                        await findNearestToEnteredAddress(locationController);
                        if (nearestStationFromDestination != null) {
                          answer2.text = nearestStationFromDestination!.name;
                          toStation = nearestStationFromDestination;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLocationActionButton(
                      text: 'Show Map',
                      icon: Icons.map,
                      color: const Color(0xFF8B5CF6),
                      onPressed: () {
                        if (locationController.text.isNotEmpty) {
                          final url = Uri.parse(
                            'geo:0,0?q=${locationController.text}+Cairo+Egypt',
                          );
                          launchUrl(url);
                        } else {
                          _showErrorSnackbar('Please enter a location first');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    )
        : const SizedBox.shrink();
  }

  Widget _buildLocationActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openStationOnMap(TextEditingController controller, Station? station) {
    if (station != null) {
      launchUrl(Uri.parse(
        'geo:0,0?q=${controller.text}+metro+station+egypt',
      ));
    } else {
      _showErrorSnackbar('Please select a station first');
    }
  }

  void _handleShowDetails() {
    if (answer1.text.isEmpty ||
        answer2.text.isEmpty ||
        answer3.text.isEmpty ||
        answer4.text.isEmpty) {
      _showErrorSnackbar('Please fill all required fields');
      return;
    }

    Get.to(
      const DetailsPage(),
      arguments: {
        'from': answer1.text,
        'to': answer2.text,
        'age': answer3.text,
        'disabled': answer4.text,
      },
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}