import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hotel_service.dart';
import '../providers/auth_provider.dart';

class HotelesScreen extends StatefulWidget {
  @override
  _HotelesScreenState createState() => _HotelesScreenState();
}

class _HotelesScreenState extends State<HotelesScreen> {
  late HotelService _hotelService;
  List<dynamic> hoteles = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _hotelService = HotelService(authProvider.token);
    fetchHoteles();
  }

  void fetchHoteles() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _hotelService.fetchHoteles();
      setState(() {
        hoteles = data;
        isLoading = false;
      });
    } catch (e) {
      showSnackbar('Error al obtener los hoteles: $e', Colors.red);
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
  void showHotelForm({Map<String, dynamic>? hotel}) async {
    final TextEditingController nombreController = TextEditingController(
        text: hotel != null ? hotel['nombre'] : '');
    final TextEditingController direccionController = TextEditingController(
        text: hotel != null ? hotel['direccion'] : '');
    final TextEditingController telefonoController = TextEditingController(
        text: hotel != null ? hotel['telefono'] : '');
    final TextEditingController estrellasController = TextEditingController(
        text: hotel != null ? hotel['estrellas'].toString() : '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(hotel == null ? 'Crear Hotel' : 'Editar Hotel'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: direccionController,
                  decoration: InputDecoration(labelText: 'Dirección'),
                ),
                TextField(
                  controller: telefonoController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                ),
                TextField(
                  controller: estrellasController,
                  decoration: InputDecoration(labelText: 'Estrellas (1-5)'),
                  keyboardType: TextInputType.number,
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
                // Validar campos vacíos
                if (nombreController.text.isEmpty ||
                    direccionController.text.isEmpty ||
                    telefonoController.text.isEmpty ||
                    estrellasController.text.isEmpty) {
                  showSnackbar('Por favor, complete todos los campos', Colors.red);
                  return;
                }

                final newHotel = {
                  'nombre': nombreController.text,
                  'direccion': direccionController.text,
                  'telefono': telefonoController.text,
                  'estrellas': int.tryParse(estrellasController.text) ?? 1,
                };

                Navigator.of(context).pop();
                try {
                  if (hotel == null) {
                    // Crear un nuevo hotel
                    await _hotelService.createHotel(newHotel);
                    showSnackbar('Hotel creado con éxito', Colors.green);
                  } else {
                    // Editar el hotel existente
                    await _hotelService.updateHotel(hotel['id'], newHotel);
                    showSnackbar('Hotel editado con éxito', Colors.green);
                  }
                  fetchHoteles();
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
  }

  // Mostrar alerta de confirmación antes de eliminar
  void confirmDeleteHotel(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Hotel'),
          content: Text('¿Estás seguro de que deseas eliminar este hotel?'),
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
        await _hotelService.deleteHotel(id);
        showSnackbar('Hotel eliminado con éxito', Colors.green);
        fetchHoteles();
      } catch (e) {
        showSnackbar('Error al eliminar: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoteles'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: hoteles.length,
              itemBuilder: (context, index) {
                final hotel = hoteles[index];
                return Card(
                  child: ListTile(
                    title: Text(hotel['nombre']),
                    subtitle: Text('${hotel['direccion']} - Tel: ${hotel['telefono']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showHotelForm(hotel: hotel),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDeleteHotel(hotel['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showHotelForm(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
