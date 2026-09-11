import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cliente_service.dart';
import '../providers/auth_provider.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late ClienteService _clienteService;
  List<dynamic> clientes = [];
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
    _clienteService = ClienteService(token);
    fetchClientes();
  }

  Future<void> fetchClientes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _clienteService.fetchClientes();
      if (!mounted) return;
      setState(() {
        clientes = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showSnackbar('Error al obtener los clientes: $e', Colors.red);
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
  Future<void> showClienteForm({Map<String, dynamic>? cliente}) async {
    final TextEditingController nombreController =
        TextEditingController(text: cliente != null ? cliente['nombre'] : '');
    final TextEditingController emailController = TextEditingController(
        text: cliente != null ? cliente['email'] : ''); // Cambiado a 'email'
    final TextEditingController telefonoController =
        TextEditingController(text: cliente != null ? cliente['telefono'] : '');

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(cliente == null ? 'Crear Cliente' : 'Editar Cliente'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: emailController, // Cambiado a emailController
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: telefonoController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
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
                      emailController
                          .text.isEmpty || // Cambiado a emailController
                      telefonoController.text.isEmpty) {
                    showSnackbar(
                        'Por favor, complete todos los campos', Colors.red);
                    return;
                  }

                  final newCliente = {
                    'nombre': nombreController.text,
                    'email': emailController.text, // Cambiado a 'email'
                    'telefono': telefonoController.text,
                  };

                  Navigator.of(dialogContext).pop();
                  try {
                    if (cliente == null) {
                      // Crear un nuevo cliente
                      await _clienteService.createCliente(newCliente);
                      if (mounted) {
                        showSnackbar('Cliente creado con éxito', Colors.green);
                      }
                    } else {
                      // Editar el cliente existente
                      await _clienteService.updateCliente(
                          cliente['id'], newCliente);
                      if (mounted) {
                        showSnackbar('Cliente editado con éxito', Colors.green);
                      }
                    }
                    if (mounted) await fetchClientes();
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
      emailController.dispose();
      telefonoController.dispose();
    }
  }

  // Mostrar alerta de confirmación antes de eliminar
  Future<void> confirmDeleteCliente(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Cliente'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este cliente?'),
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
        await _clienteService.deleteCliente(id);
        if (!mounted) return;
        showSnackbar('Cliente eliminado con éxito', Colors.green);
        await fetchClientes();
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
        title: const Text('Clientes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clientes.isEmpty
              ? const _EmptyClientes()
              : RefreshIndicator(
                  onRefresh: fetchClientes,
                  child: ListView.builder(
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
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    showClienteForm(cliente: cliente),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    confirmDeleteCliente(cliente['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showClienteForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyClientes extends StatelessWidget {
  const _EmptyClientes();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Aún no hay clientes registrados.'),
      ),
    );
  }
}
