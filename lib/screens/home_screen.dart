import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gestión Hotelera',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.hotel),
              title: Text('Hoteles'),
              onTap: () {
                Navigator.pushNamed(context, '/hoteles');
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Clientes'),
              onTap: () {
                Navigator.pushNamed(context, '/clientes');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text('Reservas'),
              onTap: () {
                Navigator.pushNamed(context, '/reservas');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje de bienvenida
            Text(
              'Bienvenido al sistema de gestión hotelera',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Explora las opciones disponibles para administrar hoteles, clientes y reservas.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 20.0),


            // Accesos directos
            Text(
              'Accesos Rápidos',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tarjeta Hoteles
                _buildShortcutCard(
                  context,
                  icon: Icons.hotel,
                  label: 'Hoteles',
                  route: '/hoteles',
                ),
                // Tarjeta Clientes
                _buildShortcutCard(
                  context,
                  icon: Icons.people,
                  label: 'Clientes',
                  route: '/clientes',
                ),
                // Tarjeta Reservas
                _buildShortcutCard(
                  context,
                  icon: Icons.calendar_month,
                  label: 'Reservas',
                  route: '/reservas',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCard(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.blueAccent, width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.blueAccent),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(fontSize: 14.0, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
