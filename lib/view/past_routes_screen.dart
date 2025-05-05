import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/location_provider.dart';
import 'package:flutter_application_1/view/map_screen.dart';
import 'package:provider/provider.dart';

class PastRoutesScreen extends StatefulWidget {
  const PastRoutesScreen({super.key});

  @override
  State<PastRoutesScreen> createState() => _PastRoutesScreenState();
}

class _PastRoutesScreenState extends State<PastRoutesScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Geçmiş Rotalar'),
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tarih/Saat seçim alanı
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildButton(
                      text: selectedDate == null ? 'Tarih Seç' : 'Tarih: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                      icon: Icons.calendar_today,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                    ),
                    _buildButton(
                      text: startTime == null ? 'Başlangıç Saati' : 'Başla: ${startTime!.format(context)}',
                      icon: Icons.access_time,
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? const TimeOfDay(hour: 0, minute: 0),
                        );
                        if (picked != null) setState(() => startTime = picked);
                      },
                    ),
                    _buildButton(
                      text: endTime == null ? 'Bitiş Saati' : 'Bitiş: ${endTime!.format(context)}',
                      icon: Icons.access_time_filled,
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? const TimeOfDay(hour: 23, minute: 59),
                        );
                        if (picked != null) setState(() => endTime = picked);
                      },
                    ),
                    _buildButton(
                      text: 'Ara',
                      icon: Icons.search,
                      color: Colors.indigo,
                      onTap: () async {
                        if (selectedDate != null && startTime != null && endTime != null) {
                          await locationProvider.fetchRoutesByDateAndTime(
                            selectedDate!,
                            startTime!,
                            endTime!,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (locationProvider.pastRoutes.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapScreen(showFilteredRoute: true),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined, color: Colors.black87),
                label: const Text(
                  "Rotayı Haritada Göster",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.grey.withOpacity(0.2),
                  elevation: 2,
                ),
              ),

            const SizedBox(height: 10),

            // Listeleme alanı
            Expanded(
              child: locationProvider.pastRoutes.isEmpty
                  ? const Center(
                      child: Text(
                        'Hiç rota bulunamadı.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 20),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              selectedDate != null && startTime != null && endTime != null
                                  ? '${selectedDate!.toLocal().toString().split(' ')[0]} ${startTime!.format(context)} - ${endTime!.format(context)}'
                                  : 'Tarih/Saat seçilmedi',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              locationProvider.pastRoutes.map((route) {
                                final time = DateTime.parse(route['timestamp']);
                                return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} '
                                    '- (${route['latitude']}, ${route['longitude']})';
                              }).join('\n'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.blueGrey,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
