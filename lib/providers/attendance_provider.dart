import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

import '../core/db/attendance_db_helper.dart';
import '../models/attendance_model.dart';

/// Provider for attendance punch in/out functionality.
/// Handles camera capture, GPS location, file storage, and database operations.
class AttendanceProvider extends ChangeNotifier {
  // State
  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _allAttendance = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  AttendanceModel? get todayAttendance => _todayAttendance;
  List<AttendanceModel> get allAttendance => _allAttendance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasPunchedIn => _todayAttendance?.hasPunchedIn ?? false;
  bool get hasPunchedOut => _todayAttendance?.hasPunchedOut ?? false;

  /// Get today's date in YYYY-MM-DD format.
  String get _todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Load today's attendance for an employee.
  Future<void> loadTodayAttendance(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayAttendance = await AttendanceDbHelper.getTodayAttendance(
        employeeId,
        _todayDate,
      );
    } catch (e) {
      _error = 'Failed to load attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Punch In: Capture selfie + location, save to database.
  /// Returns true on success, false on failure.
  Future<bool> punchIn(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Check if already punched in today
      final existing = await AttendanceDbHelper.getTodayAttendance(
        employeeId,
        _todayDate,
      );
      if (existing != null) {
        _error = 'Already punched in today';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Capture selfie photo
      final photoPath = await _captureSelfiePhoto();
      if (photoPath == null) {
        _error = 'Camera capture cancelled or failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. Get current location
      final location = await _getCurrentLocation();
      if (location == null) {
        _error = 'Location access denied or unavailable';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 4. Get current time
      final punchInTime = DateFormat('HH:mm:ss').format(DateTime.now());

      // 5. Create attendance record
      final attendance = AttendanceModel(
        employeeId: employeeId,
        date: _todayDate,
        punchInTime: punchInTime,
        punchInPhotoPath: photoPath,
        punchInLocation: location,
      );

      // 6. Insert into database
      await AttendanceDbHelper.insertAttendance(attendance);

      // 7. Refresh today's attendance
      await loadTodayAttendance(employeeId);

      return true;
    } catch (e) {
      _error = 'Punch in failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Punch Out: Capture selfie + location, update existing record.
  /// Returns true on success, false on failure.
  Future<bool> punchOut(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Verify punch-in exists for today
      final existing = await AttendanceDbHelper.getTodayAttendance(
        employeeId,
        _todayDate,
      );
      if (existing == null || !existing.hasPunchedIn) {
        _error = 'Must punch in before punching out';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (existing.hasPunchedOut) {
        _error = 'Already punched out today';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Capture selfie photo
      final photoPath = await _captureSelfiePhoto();
      if (photoPath == null) {
        _error = 'Camera capture cancelled or failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. Get current location
      final location = await _getCurrentLocation();
      if (location == null) {
        _error = 'Location access denied or unavailable';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 4. Get current time
      final punchOutTime = DateFormat('HH:mm:ss').format(DateTime.now());

      // 5. Update attendance record
      await AttendanceDbHelper.updatePunchOut(
        employeeId: employeeId,
        date: _todayDate,
        punchOutTime: punchOutTime,
        punchOutPhotoPath: photoPath,
        punchOutLocation: location,
      );

      // 6. Refresh today's attendance
      await loadTodayAttendance(employeeId);

      return true;
    } catch (e) {
      _error = 'Punch out failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load all attendance records (for admin).
  Future<void> loadAllAttendance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAttendance = await AttendanceDbHelper.getAllAttendance();
    } catch (e) {
      _error = 'Failed to load attendance records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load attendance records for today (for admin).
  Future<void> loadTodayAllAttendance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allAttendance = await AttendanceDbHelper.getAttendanceByDate(_todayDate);
    } catch (e) {
      _error = 'Failed to load today\'s attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Capture selfie photo using front camera.
  /// Returns the saved file path, or null if cancelled/failed.
  Future<String?> _captureSelfiePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo == null) return null;

      // Save photo to app's local storage
      return await _savePhotoToStorage(photo);
    } catch (e) {
      debugPrint('Camera capture error: $e');
      return null;
    }
  }

  /// Save captured photo to app's documents directory.
  /// Returns the saved file path.
  Future<String> _savePhotoToStorage(XFile photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final attendanceDir = Directory('${directory.path}/attendance_photos');

    // Create directory if it doesn't exist
    if (!await attendanceDir.exists()) {
      await attendanceDir.create(recursive: true);
    }

    // Generate unique filename
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'selfie_$timestamp.jpg';
    final savedPath = '${attendanceDir.path}/$filename';

    // Copy photo to storage
    await File(photo.path).copy(savedPath);

    return savedPath;
  }

  /// Get current GPS location and convert to readable address.
  /// Returns location string, or null if access denied.
  Future<String?> _getCurrentLocation() async {
    try {
      // First, check and request location permission using permission_handler
      PermissionStatus permissionStatus = await Permission.location.status;
      
      if (permissionStatus.isDenied) {
        // Request permission
        permissionStatus = await Permission.location.request();
      }
      
      if (permissionStatus.isPermanentlyDenied) {
        debugPrint('Location permission permanently denied - user should enable in settings');
        _error = 'Location permission denied. Please enable in app settings.';
        // Optionally open app settings
        await openAppSettings();
        return null;
      }
      
      if (!permissionStatus.isGranted) {
        debugPrint('Location permission not granted');
        _error = 'Location permission required for attendance';
        return null;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        _error = 'Please enable location services (GPS)';
        return null;
      }

      // Get current position with lower accuracy for faster results
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 30),
        ),
      );

      // Try to convert to readable address
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[];
          if (place.subLocality?.isNotEmpty ?? false) {
            parts.add(place.subLocality!);
          }
          if (place.locality?.isNotEmpty ?? false) {
            parts.add(place.locality!);
          }
          if (place.administrativeArea?.isNotEmpty ?? false) {
            parts.add(place.administrativeArea!);
          }
          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
      } catch (e) {
        debugPrint('Geocoding failed: $e');
      }

      // Fallback to coordinates
      return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint('Location error: $e');
      _error = 'Failed to get location: ${e.toString()}';
      return null;
    }
  }

  /// Get formatted punch in time for display.
  String? getFormattedPunchInTime() {
    if (_todayAttendance?.punchInTime == null) return null;
    try {
      final time = DateFormat('HH:mm:ss').parse(_todayAttendance!.punchInTime!);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return _todayAttendance!.punchInTime;
    }
  }

  /// Get formatted punch out time for display.
  String? getFormattedPunchOutTime() {
    if (_todayAttendance?.punchOutTime == null) return null;
    try {
      final time = DateFormat('HH:mm:ss').parse(_todayAttendance!.punchOutTime!);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return _todayAttendance!.punchOutTime;
    }
  }

  /// Calculate working hours between punch in and punch out.
  String? getWorkingHours() {
    if (_todayAttendance?.punchInTime == null ||
        _todayAttendance?.punchOutTime == null) {
      return null;
    }

    try {
      final inTime = DateFormat('HH:mm:ss').parse(_todayAttendance!.punchInTime!);
      final outTime = DateFormat('HH:mm:ss').parse(_todayAttendance!.punchOutTime!);
      final duration = outTime.difference(inTime);

      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    } catch (e) {
      return null;
    }
  }

  /// Clear error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
