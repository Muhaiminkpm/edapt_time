import 'package:flutter/material.dart';
import '../../core/services/firestore_user_service.dart';
import 'admin_add_employee_view.dart';

enum EmployeeFilter { all, active, inactive }

class AdminEmployeesView extends StatefulWidget {
  const AdminEmployeesView({super.key});

  @override
  State<AdminEmployeesView> createState() => _AdminEmployeesViewState();
}

class _AdminEmployeesViewState extends State<AdminEmployeesView> {
  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color textMain = Color(0xFF1A1F36);
  static const Color textSub = Color(0xFF697386);
  static const Color textMeta = Color(0xFF8792A2);
  static const Color borderColor = Color(0xFFE3E8EE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF10B981);

  List<FirestoreUser> _employees = [];
  bool _isLoading = true;
  EmployeeFilter _selectedFilter = EmployeeFilter.all;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    final employees = await FirestoreUserService.getAllEmployees();
    if (mounted) {
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    }
  }

  /// Get filtered and searched employees
  List<FirestoreUser> get _filteredEmployees {
    List<FirestoreUser> result = _employees;

    // Apply filter
    switch (_selectedFilter) {
      case EmployeeFilter.active:
        result = result.where((e) => e.isActive).toList();
        break;
      case EmployeeFilter.inactive:
        result = result.where((e) => !e.isActive).toList();
        break;
      case EmployeeFilter.all:
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((e) {
        return e.name.toLowerCase().contains(query) ||
            e.email.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  void _onFilterChanged(EmployeeFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      } else {
        // Focus the search field when opening
        Future.delayed(const Duration(milliseconds: 100), () {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  Future<void> _confirmDeleteAll() async {
    if (_employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees to delete')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: errorColor, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delete All Employees?'),
          ],
        ),
        content: Text(
          'This will permanently delete all ${_employees.length} employee(s) from the system. This action cannot be undone.',
          style: const TextStyle(color: textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: textSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      // Delete all employees from Firestore
      int deletedCount = 0;
      for (final employee in _employees) {
        final success = await FirestoreUserService.deleteUser(employee.uid);
        if (success) deletedCount++;
      }
      
      // Reload employees
      await _loadEmployees();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $deletedCount employee(s)'),
            backgroundColor: successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = _filteredEmployees;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                _buildFilterTabs(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredEmployees.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadEmployees,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                                itemCount: filteredEmployees.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final employee = filteredEmployees[index];
                                  return _buildEmployeeCard(employee: employee);
                                },
                              ),
                            ),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 16,
              child: _buildFAB(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    if (_searchQuery.isNotEmpty) {
      title = 'No results found';
      subtitle = 'Try a different search term';
      icon = Icons.search_off;
    } else if (_selectedFilter == EmployeeFilter.active) {
      title = 'No active employees';
      subtitle = 'All employees are currently inactive';
      icon = Icons.person_off_outlined;
    } else if (_selectedFilter == EmployeeFilter.inactive) {
      title = 'No inactive employees';
      subtitle = 'All employees are currently active';
      icon = Icons.check_circle_outline;
    } else {
      title = 'No employees yet';
      subtitle = 'Tap + to add your first employee';
      icon = Icons.people_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: textMeta),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: textSub, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: textMeta, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: backgroundLight,
        border: Border(
          bottom: BorderSide(color: borderColor.withOpacity(0.5), width: 1),
        ),
      ),
      child: _isSearching ? _buildSearchBar() : _buildTitleBar(),
    );
  }

  Widget _buildTitleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Employees',
          style: TextStyle(
            color: textMain,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        Row(
          children: [
            // Delete All Button
            GestureDetector(
              onTap: _confirmDeleteAll,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBg,
                  border: Border.all(color: borderColor),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: errorColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Search Button
            GestureDetector(
              onTap: _toggleSearch,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBg,
                  border: Border.all(color: borderColor),
                ),
                child: const Icon(
                  Icons.search,
                  color: textSub,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleSearch,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg,
              border: Border.all(color: borderColor),
            ),
            child: const Icon(Icons.arrow_back, color: textSub, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: textMain, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: textMeta.withOpacity(0.7)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        child: const Icon(Icons.close, color: textMeta, size: 18),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip('All', EmployeeFilter.all),
            const SizedBox(width: 8),
            _buildFilterChip('Active', EmployeeFilter.active),
            const SizedBox(width: 8),
            _buildFilterChip('Inactive', EmployeeFilter.inactive),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, EmployeeFilter filter) {
    final isSelected = _selectedFilter == filter;
    
    // Get count for badge
    int count;
    switch (filter) {
      case EmployeeFilter.all:
        count = _employees.length;
        break;
      case EmployeeFilter.active:
        count = _employees.where((e) => e.isActive).length;
        break;
      case EmployeeFilter.inactive:
        count = _employees.where((e) => !e.isActive).length;
        break;
    }

    return GestureDetector(
      onTap: () => _onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2) 
                      : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard({required FirestoreUser employee}) {
    final bool isActive = employee.isActive;
    final String initials = _getInitials(employee.name);
    final Color avatarColor = _getAvatarColor(employee.name);

    return Opacity(
      opacity: isActive ? 1.0 : 0.65,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColor,
                    border: Border.all(
                      color: isActive ? Colors.white : borderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? successColor : const Color(0xFF9CA3AF),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          employee.name,
                          style: TextStyle(
                            color: isActive ? textMain : textSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(isActive),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.email,
                    style: TextStyle(
                      color: isActive ? primaryColor : textMeta,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 12,
                        color: textMeta,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        employee.role.toUpperCase(),
                        style: const TextStyle(
                          color: textMeta,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildToggleSwitch(employee),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFD4A574),
      const Color(0xFF8B7355),
      const Color(0xFFC49A6C),
      const Color(0xFF6B8E23),
      const Color(0xFF4682B4),
      const Color(0xFF9370DB),
      const Color(0xFFCD853F),
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? successColor : textMeta,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(FirestoreUser employee) {
    final bool isOn = employee.isActive;
    return GestureDetector(
      onTap: () async {
        // Update in Firestore
        await FirestoreUserService.updateActiveStatus(employee.uid, !isOn);
        // Reload employees
        _loadEmployees();
      },
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: isOn ? primaryColor : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isOn ? 22 : 2,
              top: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AdminAddEmployeeView(),
          ),
        );
        // Refresh list when returning from add employee
        if (mounted) {
          _loadEmployees();
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
