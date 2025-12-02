import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  client,
  gerant,
  coordinateur,
  livreur,
  cuisinier,
  chef,
}

enum UserType {
  client,
  collaborateur,
}

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Sign in for Client (using phone and password from Client table)
  Future<Map<String, dynamic>> signInClient({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client
          .from('Client')
          .select()
          .eq('phone', phone.trim())
          .eq('password', password.trim())
          .maybeSingle();

      if (response == null) {
        throw Exception('Numéro de téléphone ou mot de passe incorrect');
      }

      return {
        'success': true,
        'userType': UserType.client,
        'userData': response,
        'userId': response['idClient'],
      };
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Sign in for Collaborateurs (using email and password from Collaborateurs table)
  Future<Map<String, dynamic>> signInCollaborateur({
    required String email,
    required String password,
  }) async {
    try {
      // First try Supabase Auth
      try {
        await _client.auth.signInWithPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } catch (e) {
        // If Supabase auth fails, try direct database lookup
      }

      // Get collaborateur from database
      final response = await _client
          .from('Collaborateurs')
          .select()
          .eq('email', email.trim())
          .eq('password', password.trim())
          .maybeSingle();

      if (response == null) {
        throw Exception('Email ou mot de passe incorrect');
      }

      final role = response['role'] as String? ?? '';
      UserRole userRole;

      switch (role.toLowerCase()) {
        case 'gerant':
          userRole = UserRole.gerant;
          break;
        case 'coordinateur':
          userRole = UserRole.coordinateur;
          break;
        case 'livreur':
          userRole = UserRole.livreur;
          break;
        case 'cuisinier':
          userRole = UserRole.cuisinier;
          break;
        case 'chef':
          userRole = UserRole.chef;
          break;
        default:
          userRole = UserRole.livreur;
      }

      return {
        'success': true,
        'userType': UserType.collaborateur,
        'userRole': userRole,
        'userData': response,
        'userId': response['idCollab'],
      };
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Sign up for Client
  Future<Map<String, dynamic>> signUpClient({
    required String nom,
    required String phone,
    required String password,
    String? prenom,
    String? adresse,
    String? email,
  }) async {
    try {
      // Check if phone already exists
      final existing = await _client
          .from('Client')
          .select()
          .eq('phone', phone.trim())
          .maybeSingle();

      if (existing != null) {
        throw Exception('Un client avec ce numéro existe déjà');
      }

      final idClient = DateTime.now().millisecondsSinceEpoch.toString();

      final response = await _client.from('Client').insert({
        'idClient': idClient,
        'nom': nom.trim(),
        if (prenom != null && prenom.isNotEmpty) 'prenom': prenom.trim(),
        'phone': phone.trim(),
        'password': password.trim(), // Note: Should be hashed in production
        if (adresse != null && adresse.isNotEmpty) 'adresse': adresse.trim(),
        if (email != null && email.isNotEmpty) 'email': email.trim(),
      }).select().single();

      return {
        'success': true,
        'userType': UserType.client,
        'userData': response,
        'userId': response['idClient'],
      };
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  /// Sign up for Collaborateur (using Supabase Auth)
  Future<Map<String, dynamic>> signUpCollaborateur({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String role,
    String? telephone,
  }) async {
    try {
      // Sign up with Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': '$prenom $nom',
          'role': role,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Échec de la création du compte');
      }

      // Create collaborateur record
      final idCollab = authResponse.user!.id;

      final response = await _client.from('Collaborateurs').insert({
        'idCollab': idCollab,
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'email': email.trim(),
        'password': password.trim(), // Note: Should be hashed in production
        'role': role.toLowerCase(),
        'disponible': true,
        if (telephone != null && telephone.isNotEmpty) 'telephone': telephone.trim(),
      }).select().single();

      UserRole userRole;
      switch (role.toLowerCase()) {
        case 'gerant':
          userRole = UserRole.gerant;
          break;
        case 'coordinateur':
          userRole = UserRole.coordinateur;
          break;
        case 'livreur':
          userRole = UserRole.livreur;
          break;
        case 'cuisinier':
          userRole = UserRole.cuisinier;
          break;
        case 'chef':
          userRole = UserRole.chef;
          break;
        default:
          userRole = UserRole.livreur;
      }

      return {
        'success': true,
        'userType': UserType.collaborateur,
        'userRole': userRole,
        'userData': response,
        'userId': response['idCollab'],
      };
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Check if user is logged in
  bool get isLoggedIn => _client.auth.currentSession != null;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current user role from database
  Future<UserRole?> getCurrentUserRole() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('Collaborateurs')
          .select('role')
          .eq('idCollab', user.id)
          .maybeSingle();

      if (response == null) return null;

      final role = response['role'] as String? ?? '';
      switch (role.toLowerCase()) {
        case 'gerant':
          return UserRole.gerant;
        case 'coordinateur':
          return UserRole.coordinateur;
          break;
        case 'livreur':
          return UserRole.livreur;
          break;
        case 'cuisinier':
          return UserRole.cuisinier;
          break;
        case 'chef':
          return UserRole.chef;
          break;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get client by ID
  Future<Map<String, dynamic>?> getClientById(String clientId) async {
    try {
      final response = await _client
          .from('Client')
          .select()
          .eq('idClient', clientId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Save current user data to SharedPreferences
  Future<void> saveCurrentUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', userData['userId']);
    await prefs.setString('currentUserType', userData['userType'].toString());
    if (userData['userRole'] != null) {
      await prefs.setString('currentUserRole', userData['userRole'].toString());
    }
    await prefs.setString('currentUserData', userData['userData'].toString());
  }

  /// Get current user data from SharedPreferences
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    final userType = prefs.getString('currentUserType');
    final userRole = prefs.getString('currentUserRole');

    if (userId == null || userType == null) return null;

    return {
      'userId': userId,
      'userType': userType,
      'userRole': userRole,
    };
  }

  /// Clear current user data (logout)
  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    await prefs.remove('currentUserType');
    await prefs.remove('currentUserRole');
    await prefs.remove('currentUserData');
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    final userData = await getCurrentUserData();
    return userData?['userId'];
  }
}
