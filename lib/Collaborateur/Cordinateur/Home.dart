import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../collaborateursPage.dart';
import '../manage_commands_page.dart';
import '../coordinator_profile_page.dart';

class CoordinatorHomePage extends StatefulWidget {
  const CoordinatorHomePage({super.key});

  @override
  State<CoordinatorHomePage> createState() => _CoordinatorHomePageState();
}

class _CoordinatorHomePageState extends State<CoordinatorHomePage> {
  final supabase = Supabase.instance.client;
  String? coordinatorId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoordinatorId();
  }

  Future<void> _loadCoordinatorId() async {
    try {
      // Get current user from Supabase auth
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Try to find coordinator by email
        final response = await supabase
            .from('Collaborateurs')
            .select('idCollab')
            .eq('email', user.email ?? '')
            .eq('role', 'coordinateur')
            .maybeSingle();

        if (response != null) {
          setState(() {
            coordinatorId = response['idCollab'] as String?;
            isLoading = false;
          });
        } else {
          // If not found, try to get first coordinator (for testing)
          final allCoords = await supabase
              .from('Collaborateurs')
              .select('idCollab')
              .eq('role', 'coordinateur')
              .limit(1)
              .maybeSingle();

          setState(() {
            coordinatorId = allCoords?['idCollab'] as String? ?? '';
            isLoading = false;
          });
        }
      } else {
        // No user logged in, try to get first coordinator (for testing)
        final allCoords = await supabase
            .from('Collaborateurs')
            .select('idCollab')
            .eq('role', 'coordinateur')
            .limit(1)
            .maybeSingle();

        setState(() {
          coordinatorId = allCoords?['idCollab'] as String? ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading coordinator ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF2B2B2B),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
      );
    }

    if (coordinatorId == null || coordinatorId!.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF2B2B2B),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Coordinateur non trouvé',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez vous assurer qu\'un coordinateur existe dans la base de données',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadCoordinatorId,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return CoordinatorDashboard(coordinatorId: coordinatorId!);
  }
}

