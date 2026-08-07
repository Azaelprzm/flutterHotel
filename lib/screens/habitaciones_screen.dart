import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habitacion_service.dart';
import '../services/hotel_service.dart';
import '../providers/auth_provider.dart';

class HabitacionesScreen extends StatefulWidget {
  const HabitacionesScreen({super.key});

  @override
  State<HabitacionesScreen> createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  late HabitacionService _habitacionService;
  late HotelService _hotelService;

  List<dynamic> habitaciones = [];
  List<dynamic> hoteles = [];
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
    _habitacionService = HabitacionService(token);
    _hotelService = HotelService(token);
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final results = await Future.wait([
        _habitacionService.fetchHabitaciones(),
        _hotelService.fetchHoteles(),
      ]);
      if (!mounted) return;
      setState(() {
        habitaciones = results[0];
        hoteles = results[1];
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
  Future<void> showHabitacionForm({Map<String, dynamic>? habitacion}) async {
    String? numero = habitacion?['numero'];
    String? tipo = habitacion?['tipo'];
    double? costoPorNoche = (habitacion?['costoPorNoche'] as num?)?.toDouble();
    int? hotelSeleccionado = habitacion?['hotelId'];
    final numeroController = TextEditingController(text: numero);
    final tipoController = TextEditingController(text: tipo);
    final costoController =
        TextEditingController(text: costoPorNoche?.toString());

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(habitacion == null
                    ? 'Crear Habitación'
                    : 'Editar Habitación'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Número'),
                        controller: numeroController,
                        onChanged: (value) {
                          numero = value;
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        controller: tipoController,
                        onChanged: (value) {
                          tipo = value;
                        },
                      ),
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Costo por Noche'),
                        keyboardType: TextInputType.number,
                        controller: costoController,
                        onChanged: (value) {
                          costoPorNoche = double.tryParse(value);
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
                      if (numero == null ||
                          numero!.trim().isEmpty ||
                          tipo == null ||
                          tipo!.trim().isEmpty ||
                          costoPorNoche == null ||
                          costoPorNoche! <= 0 ||
                          hotelSeleccionado == null) {
                        showSnackbar(
                            'Por favor, complete todos los campos', Colors.red);
                        return;
                      }

                      final newHabitacion = {
                        'numero': numero,
                        'tipo': tipo,
                        'costoPorNoche': costoPorNoche,
                        'hotelId': hotelSeleccionado,
                      };

                      Navigator.of(dialogContext).pop();
                      try {
                        if (habitacion == null) {
                          await _habitacionService
                              .createHabitacion(newHabitacion);
                          if (mounted) {
                            showSnackbar(
                                'Habitación creada con éxito', Colors.green);
                          }
                        } else {
                          await _habitacionService.updateHabitacion(
                              habitacion['id'], newHabitacion);
                          if (mounted) {
                            showSnackbar('Habitación actualizada con éxito',
                                Colors.green);
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
      numeroController.dispose();
      tipoController.dispose();
      costoController.dispose();
    }
  }

  // Confirmar eliminación de una habitación
  Future<void> confirmDeleteHabitacion(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Habitación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta habitación?'),
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
        await _habitacionService.deleteHabitacion(id);
        if (!mounted) return;
        showSnackbar('Habitación eliminada con éxito', Colors.green);
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
        title: const Text('Habitaciones'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : habitaciones.isEmpty
              ? const _EmptyHabitaciones()
              : RefreshIndicator(
                  onRefresh: fetchData,
                  child: ListView.builder(
                    itemCount: habitaciones.length,
                    itemBuilder: (context, index) {
                      final habitacion = habitaciones[index];
                      final hotel = hoteles.firstWhere(
                          (h) => h['id'] == habitacion['hotelId'],
                          orElse: () => null);

                      return Card(
                        child: ListTile(
                          title: Text('Habitación: ${habitacion['numero']}'),
                          subtitle: Text(
                              'Tipo: ${habitacion['tipo']}, Costo: \$${habitacion['costoPorNoche']}, Hotel: ${hotel?['nombre'] ?? 'N/A'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    showHabitacionForm(habitacion: habitacion),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    confirmDeleteHabitacion(habitacion['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showHabitacionForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyHabitaciones extends StatelessWidget {
  const _EmptyHabitaciones();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Aún no hay habitaciones registradas.'),
      ),
    );
  }
}
