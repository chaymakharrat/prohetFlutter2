import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../models/ride.dart';

class PublishRidePage extends StatefulWidget {
  static const String routeName = '/publish';
  const PublishRidePage({super.key});

  @override
  State<PublishRidePage> createState() => _PublishRidePageState();
}

class _PublishRidePageState extends State<PublishRidePage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController(text: '10');
  final _seatsController = TextEditingController(text: '3');
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    final app = Provider.of<AppState>(context, listen: false);
    // Pré-remplir départ et destination depuis AppState
    if (app.origin != null) {
      _fromController.text = app.origin!.label ?? '';
    }
    if (app.destination != null) {
      _toController.text = app.destination!.label ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: const Text('Publier votre trajet'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Barre bleue : départ et destination ---
          Container(
            color: Colors.blue.shade700,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLocationField(
                  controller: _fromController,
                  hint: 'Lieu de départ',
                  icon: Icons.circle_outlined,
                  color: Colors.white,
                  isReadOnly: true,
                ),
                const SizedBox(height: 8),
                _buildLocationField(
                  controller: _toController,
                  hint: 'Destination',
                  icon: Icons.location_on,
                  color: Colors.white,
                  isReadOnly: true,
                ),
              ],
            ),
          ),

          // --- Corps principal ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 10),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Prix et nombre de places côte à côte ---
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Prix/place (DT)',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requis';
                                final val = double.tryParse(v);
                                if (val == null || val <= 0) {
                                  return 'Entrer un prix valide';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _seatsController,
                              decoration: InputDecoration(
                                labelText: 'Places (max 4)',
                                prefixIcon: const Icon(Icons.event_seat),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requis';
                                final n = int.tryParse(v);
                                if (n == null || n <= 0 || n > 4) {
                                  return 'Entre 1 et 4';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --- Date et heure ---
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.schedule,
                            color: Colors.blue,
                          ),
                          title: const Text('Date et heure de départ'),
                          subtitle: Text(
                            "${_dateTime.day.toString().padLeft(2, '0')}/${_dateTime.month.toString().padLeft(2, '0')} "
                            "${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}",
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                              initialDate: _dateTime,
                            );
                            if (date == null) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_dateTime),
                            );
                            if (time == null) return;
                            setState(() {
                              _dateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Bouton Publier ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.publish, size: 24),
                label: const Text(
                  'Publier le trajet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  if (app.origin == null || app.destination == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez choisir départ et destination sur la carte',
                        ),
                      ),
                    );
                    return;
                  }

                  final ride = Ride(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    driver: const UserProfile(id: 'me', name: 'Moi'),
                    origin: app.origin!,
                    destination: app.destination!,
                    departureTime: _dateTime,
                    availableSeats: int.parse(_seatsController.text),
                    pricePerSeat: double.parse(_priceController.text),
                  );

                  app.rideService.addRide(ride);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trajet publié ✅')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets réutilisables ---
  Widget _buildLocationField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    bool isReadOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    );
  }
}
