import 'package:flutter/material.dart';
import 'package:projet_flutter/controller/ride_controller.dart';
import 'package:provider/provider.dart';
import '../../models/app_ride_models.dart';
import '../../state/app_state.dart';
//import 'package:url_launcher/url_launcher.dart';

class PublishRidePage extends StatefulWidget {
  static const String routeName = '/publish';

  final Ride? rideToEdit; // null = nouveau trajet
  const PublishRidePage({super.key, this.rideToEdit});

  @override
  State<PublishRidePage> createState() => _PublishRidePageState();
}

class _PublishRidePageState extends State<PublishRidePage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    final app = Provider.of<AppState>(context, listen: false);

    if (widget.rideToEdit != null) {
      final ride = widget.rideToEdit!;
      _fromController.text = ride.origin.label;
      _toController.text = ride.destination.label;
      _priceController.text = ride.pricePerSeat.toString();
      _seatsController.text = ride.availableSeats.toString();
      _dateTime = ride.departureTime;
    } else {
      if (app.origin != null) _fromController.text = app.origin!.label;
      if (app.destination != null) _toController.text = app.destination!.label;
      _priceController.text = '10';
      _seatsController.text = '3';
    }

    _distanceController.text = app.distanceKm?.toStringAsFixed(1) ?? '';
    _durationController.text = app.formattedDuration;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isEdit = widget.rideToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: Text(isEdit ? 'Modifier le trajet' : 'Publier votre trajet'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ----------------- Barre bleue : départ et destination -----------------
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
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
                const SizedBox(height: 12),
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

          // ----------------- Formulaire -----------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Prix et Places ---
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
                                if (val == null || val <= 0)
                                  return "Entrer un prix valide";
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
                                if (n == null || n <= 0 || n > 4)
                                  return 'Entre 1 et 4';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Distance et Durée (readonly) ---
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _distanceController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Distance (km)',
                                prefixIcon: const Icon(Icons.straighten),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Durée',
                                prefixIcon: const Icon(Icons.timer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- Date et Heure ---
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.schedule,
                            color: Colors.blue,
                          ),
                          title: const Text('Date et heure de départ'),
                          subtitle: Text(
                            "${_dateTime.day.toString().padLeft(2, '0')}/${_dateTime.month.toString().padLeft(2, '0')} ${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}",
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

          // ----------------- Bouton Publier / Modifier -----------------
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
                  elevation: 5,
                ),
                icon: Icon(isEdit ? Icons.edit : Icons.publish, size: 24),
                label: Text(
                  isEdit ? 'Modifier le trajet' : 'Publier le trajet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (app.destination == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez sélectionner une destination !',
                        ),
                      ),
                    );
                    return;
                  }

                  final ride = Ride(
                    id: isEdit
                        ? widget.rideToEdit!.id
                        : DateTime.now().millisecondsSinceEpoch.toString(),
                    driverId: app.currentUser!.id,
                    origin: widget.rideToEdit?.origin ?? app.origin!,
                    destination:
                        widget.rideToEdit?.destination ?? app.destination!,
                    departureTime: _dateTime,
                    availableSeats: int.parse(_seatsController.text),
                    pricePerSeat: double.parse(_priceController.text),
                    reserverSeats: 0,
                    distanceKm: app.distanceKm?.roundToDouble() ?? 0,
                    durationMin: app.durationMin?.roundToDouble() ?? 0.0,
                  );

                  final rideController = RideController();
                  try {
                    if (isEdit) {
                      await rideController.updateRide(ride);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ride modifié avec succès !'),
                        ),
                      );
                    } else {
                      await rideController.addRide(ride);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ride ajouté avec succès !'),
                        ),
                      );
                    }
                    Navigator.pushNamed(context, '/userRides');
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
