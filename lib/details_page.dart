import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'station.dart';
import 'stations_data.dart';
import 'logic.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final graph = buildGraph(metroLines);
    final Route = findShortestPath(graph, args['from'], args['to']);
    final details = getDetails(
      Route,
      metroLines,
      args['from'],
      args['to'],
      int.parse(args['age']),
      args['disabled'],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text(
          'Trip Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
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
      ),
      body: Column(
        children: [
          // Header Section with Gradient
          _buildHeaderSection(args, details),

          // Content Section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Information Section
                  _buildTripInformationSection(details),
                  const SizedBox(height: 24),

                  // Route Stations Section
                  _buildRouteStationsSection(Route, metroLines),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> args, Map<String, dynamic> details) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
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
          // From-To Row with Animation
          _buildFromToRow(args),
          const SizedBox(height: 24),

          // Summary Cards Row
          _buildSummaryCards(details),
        ],
      ),
    );
  }

  Widget _buildFromToRow(Map<String, dynamic> args) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // From Station
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DEPARTURE",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  args['from'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Arrow Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          // To Station
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "DESTINATION",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  args['to'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard(
          icon: Icons.access_time_rounded,
          value: details["Time"] ?? "--",
          label: "Duration",
          color: Colors.blue[100]!,
          iconColor: Colors.blue[800]!,
        ),
        _buildSummaryCard(
          icon: Icons.directions_subway_rounded,
          value: details["Stations Count"] ?? "--",
          label: "Stations",
          color: Colors.purple[100]!,
          iconColor: Colors.purple[800]!,
        ),
        _buildSummaryCard(
          icon: Icons.attach_money_rounded,
          value: details["Ticket Price"] ?? "--",
          label: "Price",
          color: Colors.green[100]!,
          iconColor: Colors.green[800]!,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center
          ),
          const SizedBox(height: 4),
          Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  Widget _buildTripInformationSection(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TRIP INFORMATION",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Icons.directions_rounded,
          title: "Direction",
          value: details["Direction"]?.replaceAll(" then ", "\n") ?? "Unknown",
          color: const Color(0xFF4F46E5),
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Icons.swap_horiz_rounded,
          title: "Transfer Station",
          value: details["Transfer Station"] ?? "None",
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Icons.train_rounded,
          title: "Line",
          value: details["Lines"]?.replaceAll(" -> ", " ->\n") ?? "Unknown",
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Icons.palette_rounded,
          title: "Line Color",
          value: details["Color"] ?? "Unknown",
          color: getColorFromName(details["Color"] ?? ""),
          showColorIndicator: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool showColorIndicator = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (showColorIndicator)
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStationsSection(List<String>? route, Map<String, List<Station>> metroLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ROUTE STATIONS",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.list_rounded, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Stations List",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Stations List
              ..._buildRouteList(route ?? [], metroLines),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRouteList(List<String> route, Map<String, List<Station>> metroLines) {
    return List.generate(route.length, (index) {
      final station = route[index];
      final lineName = metroLines.entries
          .firstWhere((entry) => entry.value.any((s) => s.name == station))
          .key;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: index == route.length - 1
                ? BorderSide.none
                : BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          children: [
            // Station Indicator
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getStationColor(index, route.length),
                shape: BoxShape.circle,
              ),
              child: index == 0
                  ? const Icon(Icons.flag_rounded, color: Colors.white, size: 18)
                  : index == route.length - 1
                  ? const Icon(Icons.location_on_rounded, color: Colors.white, size: 18)
                  : Text(
                (index + 1).toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Station Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$lineName",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Transfer Indicator if needed
            if (index != 0 && index != route.length - 1 && _isTransferStation(station, route, metroLines))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "TRANSFER",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Color _getStationColor(int index, int total) {
    if (index == 0) return Colors.green; // Start station
    if (index == total - 1) return Colors.red; // End station
    return Colors.blue; // Intermediate stations
  }

  bool _isTransferStation(String station, List<String> route, Map<String, List<Station>> metroLines) {
    return metroLines.values.where((line) => line.any((s) => s.name == station)).length > 1;
  }

  Color getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'yellow':
        return Colors.yellow[600]!;
      case 'green':
        return Colors.green[600]!;
      case 'pink':
        return Colors.pink[400]!;
      case 'beige':
        return const Color(0xFFD2B48C);
      case 'red':
        return Colors.red[600]!;
      case 'blue':
        return Colors.blue[600]!;
      default:
        return Colors.grey;
    }
  }
}