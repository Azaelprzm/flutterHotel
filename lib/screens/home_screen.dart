import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
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
              leading: Icon(Icons.hotel, color: Colors.teal),
              title: Text('Hoteles'),
              onTap: () {
                Navigator.pushNamed(context, '/hoteles');
              },
            ),
            ListTile(
              leading: Icon(Icons.meeting_room, color: Colors.teal),
              title: Text('Habitaciones'),
              onTap: () {
                Navigator.pushNamed(context, '/habitaciones');
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.teal),
              title: Text('Clientes'),
              onTap: () {
                Navigator.pushNamed(context, '/clientes');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.teal),
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
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Explora las opciones disponibles para administrar hoteles, clientes y reservas.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 30.0),

            // Accesos directos
            Text(
              'Accesos Rápidos',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20.0),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildShortcutCard(
                  context,
                  icon: Icons.hotel,
                  label: 'Hoteles',
                  route: '/hoteles',
                ),
                _buildShortcutCard(
                  context,
                  icon: Icons.people,
                  label: 'Clientes',
                  route: '/clientes',
                ),
                _buildShortcutCard(
                  context,
                  icon: Icons.calendar_month,
                  label: 'Reservas',
                  route: '/reservas',
                ),
                _buildShortcutCard(
                  context,
                  icon: Icons.meeting_room,
                  label: 'Habitaciones',
                  route: '/habitaciones',
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.teal),
            SizedBox(height: 12.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
