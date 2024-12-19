import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habitacion_service.dart';
import '../services/hotel_service.dart';
import '../providers/auth_provider.dart';

class HabitacionesScreen extends StatefulWidget {
  @override
  _HabitacionesScreenState createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  late HabitacionService _habitacionService;
  late HotelService _hotelService;

  List<dynamic> habitaciones = [];
  List<dynamic> hoteles = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _habitacionService = HabitacionService(authProvider.token);
    _hotelService = HotelService(authProvider.token);
    fetchData();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final habitacionesData = await _habitacionService.fetchHabitaciones();
      final hotelesData = await _hotelService.fetchHoteles();
      setState(() {
        habitaciones = habitacionesData;
        hoteles = hotelesData;
        isLoading = false;
      });
    } catch (e) {
      showSnackbar('Error al obtener datos: $e', Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Mostrar snackbar
  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Mostrar formulario de creación o edición
  void showHabitacionForm({Map<String, dynamic>? habitacion}) async {
    String? numero = habitacion?['numero'];
    String? tipo = habitacion?['tipo'];
    double? costoPorNoche = habitacion?['costoPorNoche'];
    int? hotelSeleccionado = habitacion?['hotelId'];

    await showDialog(
      context: context,
      builder: (context) {
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
                      decoration: InputDecoration(labelText: 'Número'),
                      controller: TextEditingController(text: numero),
                      onChanged: (value) {
                        numero = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Tipo'),
                      controller: TextEditingController(text: tipo),
                      onChanged: (value) {
                        tipo = value;
                      },
                    ),
                    TextField(
                      decoration:
                          InputDecoration(labelText: 'Costo por Noche'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                          text: costoPorNoche?.toString()),
                      onChanged: (value) {
                        costoPorNoche = double.tryParse(value);
                      },
                    ),
                    DropdownButton<int>(
                      value: hotelSeleccionado,
                      hint: Text('Seleccionar Hotel'),
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
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (numero == null ||
                        tipo == null ||
                        costoPorNoche == null ||
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

                    Navigator.of(context).pop();
                    try {
                      if (habitacion == null) {
                        await _habitacionService.createHabitacion(
                            newHabitacion);
                        showSnackbar(
                            'Habitación creada con éxito', Colors.green);
                      } else {
                        await _habitacionService.updateHabitacion(
                            habitacion['id'], newHabitacion);
                        showSnackbar(
                            'Habitación actualizada con éxito', Colors.green);
                      }
                      fetchData();
                    } catch (e) {
                      showSnackbar('Error: $e', Colors.red);
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Confirmar eliminación de una habitación
  void confirmDeleteHabitacion(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Habitación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar esta habitación?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _habitacionService.deleteHabitacion(id);
        showSnackbar('Habitación eliminada con éxito', Colors.green);
        fetchData();
      } catch (e) {
        showSnackbar('Error al eliminar: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habitaciones'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              showHabitacionForm(habitacion: habitacion),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              confirmDeleteHabitacion(habitacion['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showHabitacionForm(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
