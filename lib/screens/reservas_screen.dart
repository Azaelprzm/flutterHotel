import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reserva_service.dart';
import '../services/cliente_service.dart';
import '../services/hotel_service.dart';
import '../providers/auth_provider.dart';

class ReservasScreen extends StatefulWidget {
  @override
  _ReservasScreenState createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  late ReservaService _reservaService;
  late ClienteService _clienteService;
  late HotelService _hotelService;

  List<dynamic> reservas = [];
  List<dynamic> clientes = [];
  List<dynamic> hoteles = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _reservaService = ReservaService(authProvider.token);
    _clienteService = ClienteService(authProvider.token);
    _hotelService = HotelService(authProvider.token);
    fetchData();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final reservasData = await _reservaService.fetchReservas();
      final clientesData = await _clienteService.fetchClientes();
      final hotelesData = await _hotelService.fetchHoteles();
      setState(() {
        reservas = reservasData;
        clientes = clientesData;
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
  void showReservaForm({Map<String, dynamic>? reserva}) async {
    DateTime? fechaInicio =
        reserva != null ? DateTime.parse(reserva['fechaInicio']) : null;
    DateTime? fechaFin =
        reserva != null ? DateTime.parse(reserva['fechaFin']) : null;

    int? clienteSeleccionado = reserva?['clienteId'];
    int? hotelSeleccionado = reserva?['hotelId'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(reserva == null ? 'Crear Reserva' : 'Editar Reserva'),
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
                          : 'Inicio: ${fechaInicio!.toLocal()}'.split(' ')[0]),
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
                      hint: Text('Seleccionar Cliente'),
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
                    if (fechaInicio == null ||
                        fechaFin == null ||
                        clienteSeleccionado == null ||
                        hotelSeleccionado == null) {
                      showSnackbar(
                          'Por favor, complete todos los campos', Colors.red);
                      return;
                    }

                    final newReserva = {
                      'fechaInicio': fechaInicio!.toIso8601String(),
                      'fechaFin': fechaFin!.toIso8601String(),
                      'clienteId': clienteSeleccionado,
                      'hotelId': hotelSeleccionado,
                    };

                    Navigator.of(context).pop();
                    try {
                      if (reserva == null) {
                        await _reservaService.createReserva(newReserva);
                        showSnackbar('Reserva creada con éxito', Colors.green);
                      } else {
                        await _reservaService.updateReserva(
                            reserva['id'], newReserva);
                        showSnackbar(
                            'Reserva actualizada con éxito', Colors.green);
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

  // Mostrar alerta de confirmación antes de eliminar
  void confirmDeleteReserva(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Reserva'),
          content: Text('¿Estás seguro de que deseas eliminar esta reserva?'),
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
        await _reservaService.deleteReserva(id);
        showSnackbar('Reserva eliminada con éxito', Colors.green);
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
        title: Text('Reservas'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                final cliente = clientes.firstWhere(
                    (c) => c['id'] == reserva['clienteId'],
                    orElse: () => null);
                final hotel = hoteles.firstWhere(
                    (h) => h['id'] == reserva['hotelId'],
                    orElse: () => null);

                return Card(
                  child: ListTile(
                    title: Text(
                        'Reserva: ${reserva['fechaInicio']} - ${reserva['fechaFin']}'),
                    subtitle: Text(
                        'Cliente: ${cliente?['nombre'] ?? 'N/A'}, Hotel: ${hotel?['nombre'] ?? 'N/A'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showReservaForm(reserva: reserva),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDeleteReserva(reserva['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showReservaForm(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
