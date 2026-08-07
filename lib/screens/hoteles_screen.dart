import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hotel_service.dart';
import '../providers/auth_provider.dart';

class HotelesScreen extends StatefulWidget {
  const HotelesScreen({super.key});

  @override
  State<HotelesScreen> createState() => _HotelesScreenState();
}

class _HotelesScreenState extends State<HotelesScreen> {
  late HotelService _hotelService;
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
    _hotelService = HotelService(token);
    fetchHoteles();
  }

  Future<void> fetchHoteles() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _hotelService.fetchHoteles();
      if (!mounted) return;
      setState(() {
        hoteles = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showSnackbar('Error al obtener los hoteles: $e', Colors.red);
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
  Future<void> showHotelForm({Map<String, dynamic>? hotel}) async {
    final TextEditingController nombreController =
        TextEditingController(text: hotel != null ? hotel['nombre'] : '');
    final TextEditingController direccionController =
        TextEditingController(text: hotel != null ? hotel['direccion'] : '');
    final TextEditingController telefonoController =
        TextEditingController(text: hotel != null ? hotel['telefono'] : '');
    final TextEditingController estrellasController = TextEditingController(
        text: hotel != null ? hotel['estrellas'].toString() : '');

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(hotel == null ? 'Crear Hotel' : 'Editar Hotel'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: direccionController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  TextField(
                    controller: telefonoController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  TextField(
                    controller: estrellasController,
                    decoration:
                        const InputDecoration(labelText: 'Estrellas (1-5)'),
                    keyboardType: TextInputType.number,
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
                  // Validar campos vacíos
                  if (nombreController.text.isEmpty ||
                      direccionController.text.isEmpty ||
                      telefonoController.text.isEmpty ||
                      estrellasController.text.isEmpty) {
                    showSnackbar(
                        'Por favor, complete todos los campos', Colors.red);
                    return;
                  }

                  final newHotel = {
                    'nombre': nombreController.text,
                    'direccion': direccionController.text,
                    'telefono': telefonoController.text,
                    'estrellas': int.tryParse(estrellasController.text) ?? 1,
                  };

                  final estrellas = newHotel['estrellas'] as int;
                  if (estrellas < 1 || estrellas > 5) {
                    showSnackbar(
                        'Las estrellas deben estar entre 1 y 5', Colors.red);
                    return;
                  }

                  Navigator.of(dialogContext).pop();
                  try {
                    if (hotel == null) {
                      // Crear un nuevo hotel
                      await _hotelService.createHotel(newHotel);
                      if (mounted) {
                        showSnackbar('Hotel creado con éxito', Colors.green);
                      }
                    } else {
                      // Editar el hotel existente
                      await _hotelService.updateHotel(hotel['id'], newHotel);
                      if (mounted) {
                        showSnackbar('Hotel editado con éxito', Colors.green);
                      }
                    }
                    if (mounted) await fetchHoteles();
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
    } finally {
      nombreController.dispose();
      direccionController.dispose();
      telefonoController.dispose();
      estrellasController.dispose();
    }
  }

  // Mostrar alerta de confirmación antes de eliminar
  Future<void> confirmDeleteHotel(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Hotel'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este hotel?'),
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
        await _hotelService.deleteHotel(id);
        if (!mounted) return;
        showSnackbar('Hotel eliminado con éxito', Colors.green);
        await fetchHoteles();
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
        title: const Text('Hoteles'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hoteles.isEmpty
              ? const _EmptyHoteles()
              : RefreshIndicator(
                  onRefresh: fetchHoteles,
                  child: ListView.builder(
                    itemCount: hoteles.length,
                    itemBuilder: (context, index) {
                      final hotel = hoteles[index];
                      return Card(
                        child: ListTile(
                          title: Text(hotel['nombre']),
                          subtitle: Text(
                              '${hotel['direccion']} - Tel: ${hotel['telefono']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => showHotelForm(hotel: hotel),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    confirmDeleteHotel(hotel['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showHotelForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyHoteles extends StatelessWidget {
  const _EmptyHoteles();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Aún no hay hoteles registrados.'),
      ),
    );
  }
}
