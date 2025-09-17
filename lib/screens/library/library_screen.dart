import 'package:flutter/material.dart';
import 'package:mobile_custom_ui/screens/ball_bouncing/ball_bouncing.dart';
import 'package:mobile_custom_ui/screens/moving_object/moving_object.dart';

class LibraryScreen extends StatelessWidget {
  final List<SubUiProject> projects = [
    SubUiProject(
      name: 'Sliding Text Box',
      description: 'Animated text box UI',
      screenBuilder: (context) => const Placeholder(), // thay bằng screen thật
    ),
    SubUiProject(
      name: 'Custom Button',
      description: 'Unique button styles',
      screenBuilder: (context) => const Placeholder(),
    ),
    SubUiProject(
      name: 'Glassmorphism Card',
      description: 'Frosted glass card UI',
      screenBuilder: (context) => const Placeholder(),
    ),
    SubUiProject(
      name: 'Ball bouncing effects',
      description: 'A lot of balls bouncing',
      screenBuilder: (context) => BouncingBallsDemo(),
    ),
    SubUiProject(
      name: 'Object moving',
      description: 'Moving an object around',
      screenBuilder: (context) => MovingObjectScreen(),
    ),
  ];

  LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(project.name),
              subtitle: Text(project.description),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: project.screenBuilder));
              },
            ),
          );
        },
      ),
    );
  }
}

class SubUiProject {
  final String name;
  final String description;
  final WidgetBuilder screenBuilder;

  const SubUiProject({
    required this.name,
    required this.description,
    required this.screenBuilder,
  });
}
