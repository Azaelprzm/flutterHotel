import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reserva_service.dart';
import '../services/cliente_service.dart';
import '../services/hotel_service.dart';
import '../services/habitacion_service.dart';
import '../providers/auth_provider.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  late ReservaService _reservaService;
  late ClienteService _clienteService;
  late HotelService _hotelService;
  late HabitacionService _habitacionService;

  List<dynamic> reservas = [];
  List<dynamic> clientes = [];
  List<dynamic> hoteles = [];
  List<dynamic> habitaciones = [];
  bool isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    _reservaService = ReservaService(token);
    _clienteService = ClienteService(token);
    _hotelService = HotelService(token);
    _habitacionService = HabitacionService(token);
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final results = await Future.wait([
        _reservaService.fetchReservas(),
        _clienteService.fetchClientes(),
        _hotelService.fetchHoteles(),
        _habitacionService.fetchHabitaciones(),
      ]);
      if (!mounted) return;

      setState(() {
        reservas = results[0];
        clientes = results[1];
        hoteles = results[2];
        habitaciones = results[3];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showSnackbar('Error al obtener datos: $e', Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Mostrar snackbar
  void showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Mostrar formulario de creación o edición
  Future<void> showReservaForm({Map<String, dynamic>? reserva}) async {
    DateTime? fechaInicio =
        reserva != null ? DateTime.parse(reserva['fechaInicio']) : null;
    DateTime? fechaFin =
        reserva != null ? DateTime.parse(reserva['fechaFin']) : null;

    int? clienteSeleccionado = reserva?['clienteId'];
    int? hotelSeleccionado = reserva?['hotelId'];
    int? habitacionSeleccionada = reserva?['habitacionId'];
    String metodoPago = reserva?['metodoPago'] ?? "efectivo";
    double? pagoInicial = (reserva?['pagoInicial'] as num?)?.toDouble();
    final pagoController = TextEditingController(text: pagoInicial?.toString());

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              final habitacionesDelHotel = hotelSeleccionado == null
                  ? <dynamic>[]
                  : habitaciones
                      .where((habitacion) =>
                          habitacion['hotelId'] == hotelSeleccionado)
                      .toList();
              return AlertDialog(
                title:
                    Text(reserva == null ? 'Crear Reserva' : 'Editar Reserva'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: fechaInicio ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              fechaInicio = selectedDate;
                            });
                          }
                        },
                        child: Text(fechaInicio == null
                            ? 'Seleccionar Fecha de Inicio'
                            : 'Inicio: ${fechaInicio!.toLocal()}'
                                .split(' ')[0]),
                      ),
                      TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                fechaFin ?? fechaInicio ?? DateTime.now(),
                            firstDate: fechaInicio ?? DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              fechaFin = selectedDate;
                            });
                          }
                        },
                        child: Text(fechaFin == null
                            ? 'Seleccionar Fecha de Fin'
                            : 'Fin: ${fechaFin!.toLocal()}'.split(' ')[0]),
                      ),
                      DropdownButton<int>(
                        value: clienteSeleccionado,
                        hint: const Text('Seleccionar Cliente'),
                        isExpanded: true,
                        items: clientes.map<DropdownMenuItem<int>>((cliente) {
                          return DropdownMenuItem<int>(
                            value: cliente['id'],
                            child: Text(cliente['nombre']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            clienteSeleccionado = value;
                          });
                        },
                      ),
                      DropdownButton<int>(
                        value: hotelSeleccionado,
                        hint: const Text('Seleccionar Hotel'),
                        isExpanded: true,
                        items: hoteles.map<DropdownMenuItem<int>>((hotel) {
                          return DropdownMenuItem<int>(
                            value: hotel['id'],
                            child: Text(hotel['nombre']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            hotelSeleccionado = value;
                            final habitacionValida = habitaciones.any(
                              (habitacion) =>
                                  habitacion['id'] == habitacionSeleccionada &&
                                  habitacion['hotelId'] == value,
                            );
                            if (!habitacionValida) {
                              habitacionSeleccionada = null;
                            }
                          });
                        },
                      ),
                      DropdownButton<int>(
                        value: habitacionSeleccionada,
                        hint: const Text('Seleccionar Habitación'),
                        isExpanded: true,
                        items: habitacionesDelHotel.isNotEmpty
                            ? habitacionesDelHotel
                                .map<DropdownMenuItem<int>>((habitacion) {
                                return DropdownMenuItem<int>(
                                  value: habitacion['id'],
                                  child: Text(
                                      'Habitación ${habitacion['numero']} (${habitacion['tipo']})'),
                                );
                              }).toList()
                            : null,
                        onChanged: habitacionesDelHotel.isNotEmpty
                            ? (value) {
                                setState(() {
                                  habitacionSeleccionada = value;
                                });
                              }
                            : null,
                      ),
                      TextField(
                        controller: pagoController,
                        decoration:
                            const InputDecoration(labelText: 'Pago Inicial'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            pagoInicial = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      DropdownButton<String>(
                        value: metodoPago,
                        hint: const Text('Seleccionar Método de Pago'),
                        isExpanded: true,
                        items: ['efectivo', 'tarjeta'].map((metodo) {
                          return DropdownMenuItem<String>(
                            value: metodo,
                            child: Text(metodo.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            metodoPago = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (fechaInicio == null ||
                          fechaFin == null ||
                          clienteSeleccionado == null ||
                          hotelSeleccionado == null ||
                          habitacionSeleccionada == null) {
                        showSnackbar(
                            'Por favor, complete todos los campos', Colors.red);
                        return;
                      }

                      if (!fechaFin!.isAfter(fechaInicio!)) {
                        showSnackbar(
                          'La fecha de fin debe ser posterior a la fecha de inicio',
                          Colors.red,
                        );
                        return;
                      }

                      if (pagoInicial != null && pagoInicial! < 0) {
                        showSnackbar('El pago inicial no puede ser negativo',
                            Colors.red);
                        return;
                      }

                      final newReserva = {
                        'fechaInicio': fechaInicio!.toIso8601String(),
                        'fechaFin': fechaFin!.toIso8601String(),
                        'clienteId': clienteSeleccionado,
                        'hotelId': hotelSeleccionado,
                        'habitacionId': habitacionSeleccionada,
                        'pagoInicial': pagoInicial,
                        'metodoPago': metodoPago,
                      };

                      Navigator.of(dialogContext).pop();
                      try {
                        if (reserva == null) {
                          await _reservaService.createReserva(newReserva);
                          if (mounted) {
                            showSnackbar(
                                'Reserva creada con éxito', Colors.green);
                          }
                        } else {
                          await _reservaService.updateReserva(
                              reserva['id'], newReserva);
                          if (mounted) {
                            showSnackbar(
                                'Reserva actualizada con éxito', Colors.green);
                          }
                        }
                        if (mounted) await fetchData();
                      } catch (e) {
                        if (mounted) showSnackbar('Error: $e', Colors.red);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      pagoController.dispose();
    }
  }

  // Mostrar alerta de confirmación antes de eliminar
  Future<void> confirmDeleteReserva(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Reserva'),
          content:
              const Text('¿Estás seguro de que deseas eliminar esta reserva?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _reservaService.deleteReserva(id);
        if (!mounted) return;
        showSnackbar('Reserva eliminada con éxito', Colors.green);
        await fetchData();
      } catch (e) {
        if (!mounted) return;
        showSnackbar('Error al eliminar: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservas.isEmpty
              ? const _EmptyReservas()
              : RefreshIndicator(
                  onRefresh: fetchData,
                  child: ListView.builder(
                    itemCount: reservas.length,
                    itemBuilder: (context, index) {
                      final reserva = reservas[index];
                      final cliente = clientes.firstWhere(
                          (c) => c['id'] == reserva['clienteId'],
                          orElse: () => null);
                      final hotel = hoteles.firstWhere(
                          (h) => h['id'] == reserva['hotelId'],
                          orElse: () => null);
                      final habitacion = habitaciones.firstWhere(
                          (h) => h['id'] == reserva['habitacionId'],
                          orElse: () => null);

                      return Card(
                        child: ListTile(
                          title: Text(
                              'Reserva: ${reserva['fechaInicio']} - ${reserva['fechaFin']}'),
                          subtitle: Text(
                              'Cliente: ${cliente?['nombre'] ?? 'N/A'}, Hotel: ${hotel?['nombre'] ?? 'N/A'}, Habitación: ${habitacion?['numero'] ?? 'N/A'}, Total: ${reserva['total']}, Adeudo: ${reserva['adeudo']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    showReservaForm(reserva: reserva),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    confirmDeleteReserva(reserva['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showReservaForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyReservas extends StatelessWidget {
  const _EmptyReservas();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Aún no hay reservas registradas.'),
      ),
    );
  }
}
