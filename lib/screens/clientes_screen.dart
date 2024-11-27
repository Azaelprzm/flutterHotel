import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cliente_service.dart';
import '../providers/auth_provider.dart';

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late ClienteService _clienteService;
  List<dynamic> clientes = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _clienteService = ClienteService(authProvider.token);
    fetchClientes();
  }

  void fetchClientes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _clienteService.fetchClientes();
      setState(() {
        clientes = data;
        isLoading = false;
      });
    } catch (e) {
      showSnackbar('Error al obtener los clientes: $e', Colors.red);
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
  void showClienteForm({Map<String, dynamic>? cliente}) async {
    final TextEditingController nombreController = TextEditingController(
        text: cliente != null ? cliente['nombre'] : '');
    final TextEditingController emailController = TextEditingController(
        text: cliente != null ? cliente['email'] : ''); // Cambiado a 'email'
    final TextEditingController telefonoController = TextEditingController(
        text: cliente != null ? cliente['telefono'] : '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cliente == null ? 'Crear Cliente' : 'Editar Cliente'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: emailController, // Cambiado a emailController
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: telefonoController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
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
                    emailController.text.isEmpty || // Cambiado a emailController
                    telefonoController.text.isEmpty) {
                  showSnackbar('Por favor, complete todos los campos', Colors.red);
                  return;
                }

                final newCliente = {
                  'nombre': nombreController.text,
                  'email': emailController.text, // Cambiado a 'email'
                  'telefono': telefonoController.text,
                };

                Navigator.of(context).pop();
                try {
                  if (cliente == null) {
                    // Crear un nuevo cliente
                    await _clienteService.createCliente(newCliente);
                    showSnackbar('Cliente creado con éxito', Colors.green);
                  } else {
                    // Editar el cliente existente
                    await _clienteService.updateCliente(cliente['id'], newCliente);
                    showSnackbar('Cliente editado con éxito', Colors.green);
                  }
                  fetchClientes();
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
  void confirmDeleteCliente(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Cliente'),
          content: Text('¿Estás seguro de que deseas eliminar este cliente?'),
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
        await _clienteService.deleteCliente(id);
        showSnackbar('Cliente eliminado con éxito', Colors.green);
        fetchClientes();
      } catch (e) {
        showSnackbar('Error al eliminar: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];
                return Card(
                  child: ListTile(
                    title: Text(cliente['nombre']),
                    subtitle: Text(
                        '${cliente['email']} - Tel: ${cliente['telefono']}'), // Cambiado a 'email'
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showClienteForm(cliente: cliente),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDeleteCliente(cliente['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showClienteForm(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
