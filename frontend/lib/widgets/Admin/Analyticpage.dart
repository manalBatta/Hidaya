import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // خلفية فاتحة
      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: const Color(0xFF166534), // islamicGreen800
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Dashboard Overview",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Stats Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Total Questions", "120", Icons.help_outline),
                _buildStatCard("Total Answers", "350", Icons.question_answer),
                _buildStatCard("Flagged", "15", Icons.flag),
                _buildStatCard("Hidden", "8", Icons.visibility_off),
              ],
            ),
            const SizedBox(height: 30),

            // Activity Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Activity (Last 7 Days)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 5),
                              FlSpot(1, 6),
                              FlSpot(2, 4),
                              FlSpot(3, 8),
                              FlSpot(4, 7),
                              FlSpot(5, 9),
                              FlSpot(6, 6),
                            ],
                            isCurved: true,
                            color: const Color(0xFF166534),
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  "Mon",
                                  "Tue",
                                  "Wed",
                                  "Thu",
                                  "Fri",
                                  "Sat",
                                  "Sun"
                                ];
                                return Text(days[value.toInt()],
                                    style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Top Volunteers Table
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Top Volunteers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Answers")),
                      DataColumn(label: Text("Flags")),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text("Ali")),
                        DataCell(Text("45")),
                        DataCell(Text("2")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("Sara")),
                        DataCell(Text("39")),
                        DataCell(Text("1")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("Omar")),
                        DataCell(Text("32")),
                        DataCell(Text("3")),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF166534)),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
