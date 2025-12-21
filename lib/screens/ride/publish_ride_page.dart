import 'package:flutter/material.dart';
import 'package:projet_flutter/controller/ride_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:projet_flutter/models/ride.dart';
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
  final rideController = RideController();
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));
  int _seats = 1;
  bool _hasReservations = false;
  bool _isTooLateToEdit = false;

  @override
  void initState() {
    super.initState();
    final app = Provider.of<AppState>(context, listen: false);
    if (widget.rideToEdit != null) {
      final ride = widget.rideToEdit!;
      _seats = ride.availableSeats;
      _hasReservations = ride.reserverSeats > 0;

      final nowTunisia = DateTime.now().add(const Duration(hours: 1));
      final diff = ride.departureTime.difference(nowTunisia);
      // Interdit si départ fait (diff ou négatif) ou < 2h ET qu'il y a des réservations
      if (_hasReservations && diff.inHours < 2) {
        _isTooLateToEdit = true;
        // Show message after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Modification interdite moins de 2h avant le départ car il y a des réservations.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        });
      }
    } else {
      _seats = 3;
    }

    if (widget.rideToEdit != null) {
      final ride = widget.rideToEdit!;
      _fromController.text = ride.origin.label;
      _toController.text = ride.destination.label;
      _priceController.text = ride.pricePerSeat.toString();
      _seatsController.text = ride.availableSeats.toString();
      _dateTime = ride.departureTime;
      _distanceController.text = ride.distanceKm.toStringAsFixed(1);
      _durationController.text = rideController.formatDurationFromMinutes(
        ride.durationMin,
      );
    } else {
      if (app.origin != null) _fromController.text = app.origin!.label;
      if (app.destination != null) _toController.text = app.destination!.label;
      _priceController.text = '10';
      _seatsController.text = '3';
      _distanceController.text = app.distanceKm?.toStringAsFixed(1) ?? '';
      _durationController.text = app.formattedDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isEdit = widget.rideToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9), // Light grey background
      body: Column(
        children: [
          // ----------------- Header & Floating Card Section -----------------
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Blue Background Header
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                isEdit
                                    ? 'Modifier le trajet'
                                    : 'Publier votre trajet',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48), // Balance back button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Floating Location Card
              Container(
                margin: const EdgeInsets.only(top: 130, left: 20, right: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildLocationField(
                      controller: _fromController,
                      hint: 'Lieu de départ',
                      icon: Icons.my_location,
                      color: Colors.blue,
                      isReadOnly: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            width: 2,
                            height: 20,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.only(left: 11),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade200,
                              thickness: 1,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildLocationField(
                      controller: _toController,
                      hint: 'Destination',
                      icon: Icons.location_on,
                      color: Colors.red,
                      isReadOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20), // Reduced spacing to avoid scrolling
          // ----------------- Scrollable Form -----------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // --- Date Selection ---
                      _buildSectionTitle('Date et Heure'),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _isTooLateToEdit
                            ? null
                            : () async {
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
                                  initialTime: TimeOfDay.fromDateTime(
                                    _dateTime,
                                  ),
                                  builder: (context, child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(
                                        context,
                                      ).copyWith(alwaysUse24HourFormat: true),
                                      child: child!,
                                    );
                                  },
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
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isTooLateToEdit
                                ? Colors.grey.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_dateTime.day.toString().padLeft(2, '0')}/${_dateTime.month.toString().padLeft(2, '0')}/${_dateTime.year}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')} (${_getPeriod(_dateTime.hour).displayName})",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.edit,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Price & Seats ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Prix par place'),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _priceController,
                                  readOnly:
                                      _hasReservations || _isTooLateToEdit,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color:
                                        (_hasReservations || _isTooLateToEdit)
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    suffixText: 'DT',
                                    prefixIcon: const Icon(
                                      Icons.attach_money,
                                      color: Colors.green,
                                    ),
                                    filled: true,
                                    fillColor:
                                        (_hasReservations || _isTooLateToEdit)
                                        ? Colors.grey.shade100
                                        : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Requis';
                                    final val = double.tryParse(v);
                                    if (val == null || val <= 0) {
                                      return "Invalide";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Places'),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildSeatButton(
                                        icon: Icons.remove,
                                        onPressed: _isTooLateToEdit
                                            ? null
                                            : (_seats >
                                                      (widget
                                                              .rideToEdit
                                                              ?.reserverSeats ??
                                                          1)
                                                  ? () =>
                                                        setState(() => _seats--)
                                                  : null),
                                      ),
                                      Text(
                                        _seats.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                      _buildSeatButton(
                                        icon: Icons.add,
                                        onPressed: _isTooLateToEdit
                                            ? null
                                            : (_seats < 4
                                                  ? () =>
                                                        setState(() => _seats++)
                                                  : null),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- Read-only Info ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildInfoChip(
                              Icons.straighten,
                              'Distance',
                              _distanceController.text.isEmpty
                                  ? '-- km'
                                  : '${_distanceController.text} km',
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            _buildInfoChip(
                              Icons.timer_outlined,
                              'Durée',
                              _durationController.text.isEmpty
                                  ? '--'
                                  : _durationController.text,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ----------------- Main Action Button -----------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF1976D2).withOpacity(0.4),
                ),
                onPressed: _isTooLateToEdit
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        // Validation: requires destination (unless editing existing ride)
                        if (app.destination == null && widget.rideToEdit == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Veuillez sélectionner une destination !',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final ride = Ride(
                          id: isEdit
                              ? widget.rideToEdit!.id
                              : DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                          driverId: app.currentUser!.id,
                          origin: widget.rideToEdit?.origin ?? app.origin!,
                          destination:
                              widget.rideToEdit?.destination ??
                              app.destination!,
                          departureTime: _dateTime,
                          availableSeats: _seats,
                          pricePerSeat: double.parse(_priceController.text),
                          reserverSeats: widget.rideToEdit?.reserverSeats ?? 0,
                          distanceKm: app.distanceKm?.roundToDouble() ?? 0,
                          durationMin: app.durationMin?.roundToDouble() ?? 0.0,
                          period: _getPeriod(_dateTime.hour),
                        );
                        try {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );

                          if (isEdit) {
                            await rideController.updateRide(ride);
                          } else {
                            await rideController.addRide(ride);
                          }

                          Navigator.pop(context); // Close loading

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit ? 'Trajet modifié !' : 'Trajet publié !',
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          Navigator.pushNamed(context, '/userRides');
                        } catch (e) {
                          Navigator.pop(context); // Close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur : $e')),
                          );
                        }
                      },
                child: Text(
                  isEdit
                      ? 'Enregistrer les modifications'
                      : 'Publier le trajet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSeatButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed == null ? Colors.grey.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: onPressed == null ? Colors.grey : const Color(0xFF1976D2),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1976D2), size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
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
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller, // Using existing controller
                readOnly: isReadOnly,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  RidePeriod _getPeriod(int hour) {
    if (hour >= 5 && hour < 12) return RidePeriod.matin;
    if (hour >= 12 && hour < 18) return RidePeriod.apresmidi;
    if (hour >= 18 && hour < 22) return RidePeriod.soir;
    return RidePeriod.nuit;
  }
}
