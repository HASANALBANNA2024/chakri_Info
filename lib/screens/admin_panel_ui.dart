import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  // --- Admin Credentials ---
  final String _adminEmail = "albannamdhasan48@gmail.com";
  final String _adminPass = "940911";
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoggedIn = false;

  late TabController _tabController;

  // --- Data Variables ---
  final Map<String, List<String>> _categories = {
    'Government': ['BCS', 'Railway', 'Ministry', 'Govt Project'],
    'Bank': ['Govt Bank', 'Private Bank', 'Insurance'],
    'NGO': ['International NGO', 'Local NGO'],
    'Defence': ['Army', 'Navy', 'Air Force', 'Police'],
  };

  final List<String> _questionCategories = [
    'BCS',
    'Krishi',
    'Nursing',
    'Medical',
    'Engineering',
    'Primary',
  ];

  String? selectedMain;
  String? selectedSub;
  String? filterMain;
  String? qSelectedCat;
  String? qFilterCat; // ফিল্টারের জন্য
  bool isGovtJob = true;

  final TextEditingController _qSearchCtrl = TextEditingController();
  final TextEditingController _jsonCtrl = TextEditingController();

  // Multiple Positions Controller
  List<Map<String, TextEditingController>> positions = [
    {'name': TextEditingController(), 'post': TextEditingController()},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _addPositionField() {
    setState(() {
      positions.add({
        'name': TextEditingController(),
        'post': TextEditingController(),
      });
    });
  }

  void _removePositionField(int index) {
    if (positions.length > 1) {
      setState(() => positions.removeAt(index));
    }
  }

  void _handleLogin() {
    if (_emailCtrl.text == _adminEmail && _passCtrl.text == _adminPass) {
      setState(() => _isLoggedIn = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ভুল ইমেইল বা পাসওয়ার্ড!",
            style: TextStyle(fontFamily: 'SolaimanLipi'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) return _buildLoginScreen();

    return Scaffold(
      backgroundColor: Color(0xFFF3F5F9),
      appBar: AppBar(
        title: Text(
          "Admin Control Panel",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(icon: Icon(Icons.post_add), text: "Create Circular"),
            Tab(icon: Icon(Icons.storage_rounded), text: "Database Sync"),
            Tab(icon: Icon(Icons.quiz_rounded), text: "Question Bank"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddCircularTab(),
          _buildManageCircularTab(),
          _buildQuestionBankTab(),
        ],
      ),
    );
  }

  // ================= TAB 1: CREATE CIRCULAR =================
  Widget _buildAddCircularTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard("Circular Image", [_buildImagePickerBox()]),
          _buildSectionCard("Category & Sub-Category", [
            _buildDropdown(
              "Main Category",
              selectedMain,
              _categories.keys.toList(),
              (val) {
                setState(() {
                  selectedMain = val;
                  selectedSub = null;
                });
              },
            ),
            if (selectedMain != null)
              _buildDropdown(
                "Sub Category",
                selectedSub,
                _categories[selectedMain]!,
                (val) => setState(() => selectedSub = val),
              ),
          ]),
          _buildSectionCard("Positions & Vacancy", [
            SwitchListTile(
              title: Text("Government Job? (Grade System)"),
              value: isGovtJob,
              onChanged: (v) => setState(() => isGovtJob = v),
            ),
            _buildInputField(
              "Job Title",
              Icons.work_outline,
              "e.g. Combined 5 Banks",
              null,
            ),
            _buildDynamicPositionsList(),
            _buildInputField(
              isGovtJob ? "Grade" : "Salary",
              Icons.payments_outlined,
              "Enter info...",
              null,
            ),
          ]),
          _buildSectionCard("Details & Link", [
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    "Start Date",
                    Icons.calendar_today,
                    "DD-MM-YYYY",
                    null,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    "Deadline",
                    Icons.timer_off_outlined,
                    "DD-MM-YYYY",
                    null,
                  ),
                ),
              ],
            ),
            _buildInputField(
              "Application Link",
              Icons.link,
              "https://...",
              null,
            ),
            SizedBox(height: 10),
            _buildLargeTextField("Detailed Description", null),
          ]),
          SizedBox(height: 15),
          _buildActionButton("Publish Now", Colors.blueAccent, () {}),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= TAB 2: DATABASE SYNC =================
  Widget _buildManageCircularTab() {
    return Column(
      children: [
        _buildFilterHeader(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: 3,
            itemBuilder: (context, index) => _buildDataCard(
              "Senior Officer (Combined)",
              "Deadline: 20-05-2026",
            ),
          ),
        ),
      ],
    );
  }

  // ================= TAB 3: QUESTION BANK (JSON UPLOAD & FILTER) =================
  Widget _buildQuestionBankTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard("Upload New Question Set", [
            _buildDropdown(
              "Question Category",
              qSelectedCat,
              _questionCategories,
              (val) => setState(() => qSelectedCat = val),
            ),
            _buildInputField(
              "Sub-Table Name",
              Icons.account_tree_outlined,
              "e.g. উপসহকারী কৃষি কর্মকর্তা",
              null,
            ),
            _buildInputField("Year", Icons.event_note, "e.g. 2020", null),
            _buildLargeTextField(
              "JSON Data: [ {\"q\":\"...\", \"a\":\"...\"} ]",
              _jsonCtrl,
            ),
            SizedBox(height: 10),
            _buildActionButton(
              "Upload Question Set",
              Colors.orangeAccent,
              () {},
            ),
          ]),

          Divider(height: 40, thickness: 1),

          _buildSectionCard("Search & Manage Questions", [
            _buildDropdown(
              "Filter by Category",
              qFilterCat,
              _questionCategories,
              (val) => setState(() => qFilterCat = val),
            ),
            _buildInputField(
              "Search by Post or Year",
              Icons.search,
              "Type to search...",
              _qSearchCtrl,
            ),
            SizedBox(height: 10),
            _buildQuestionHistoryItem(
              "কৃষি কর্মকর্তা ২০২০",
              "Category: Krishi",
            ),
            _buildQuestionHistoryItem("BCS 45th Preliminary", "Category: BCS"),
            _buildQuestionHistoryItem(
              "Senior Staff Nurse 2023",
              "Category: Nursing",
            ),
          ]),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
              fontSize: 14,
            ),
          ),
          Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    String hint,
    TextEditingController? ctrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLargeTextField(String hint, TextEditingController? ctrl) {
    return TextField(
      controller: ctrl,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildQuestionHistoryItem(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: Color(0xFFF8FAFC),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11)),
        trailing: Wrap(
          children: [
            IconButton(
              icon: Icon(Icons.edit_note, color: Colors.blue, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: Colors.red,
                size: 22,
              ),
              onPressed: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String sub) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.description_outlined, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(sub, style: TextStyle(fontSize: 12)),
        trailing: Wrap(
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.keys
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(c, style: TextStyle(fontSize: 12)),
                    selected: filterMain == c,
                    onSelected: (s) =>
                        setState(() => filterMain = s ? c : null),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() => Container(
    height: 120,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.blue.shade100),
    ),
    child: Icon(Icons.add_a_photo, color: Colors.blueAccent),
  );

  Widget _buildDynamicPositionsList() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: positions.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInlineInput(
                    positions[index]['name']!,
                    "Pos Name",
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildInlineInput(
                    positions[index]['post']!,
                    "Post",
                    isNum: true,
                  ),
                ),
                if (positions.length > 1)
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                    onPressed: () => _removePositionField(index),
                  ),
              ],
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _addPositionField,
          icon: Icon(Icons.add_circle_outline, size: 16),
          label: Text("Add Position"),
        ),
      ],
    );
  }

  Widget _buildInlineInput(
    TextEditingController ctrl,
    String hint, {
    bool isNum = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            children: [
              Icon(Icons.admin_panel_settings, size: 70, color: Colors.indigo),
              SizedBox(height: 20),
              _buildInputField("Admin Email", Icons.email, "", _emailCtrl),
              _buildInputField("Password", Icons.lock, "", _passCtrl),
              SizedBox(height: 10),
              _buildActionButton("Login to Panel", Colors.indigo, _handleLogin),
            ],
          ),
        ),
      ),
    );
  }
}
