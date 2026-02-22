import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// REFACTOR IMPORTS
import 'package:mana_rayachoty_sevalu/models/listing_model.dart';
import 'package:mana_rayachoty_sevalu/services/firebase_service.dart';
import 'package:mana_rayachoty_sevalu/services/translation_service.dart';

// Global Instances
final FirebaseService firebaseService = FirebaseService();
final TranslationService translationService = TranslationService();
bool isAdminLoggedIn = false;
String currentLanguage = "Telugu";

Map<String, List<String>> categoryLabels = {
  "Farmers": [
    "Farmer Name",
    "Phone",
    "Crop Type",
    "Quantity",
    "Price",
    "Location",
    "Description"
  ],
  "Shops": [
    "Shop Name",
    "Phone",
    "Owner",
    "Category",
    "Timings",
    "Location",
    "Description"
  ],
  "Services": [
    "Service Name",
    "Phone",
    "Provider Name",
    "Experience",
    "Charges",
    "Location",
    "Description"
  ],
  "Jobs": [
    "Job Title",
    "Phone",
    "Company Name",
    "Salary",
    "Qualification",
    "Location",
    "Description"
  ],
  "Hospitals": [
    "Hospital Name",
    "Phone",
    "Doctor Name",
    "Speciality",
    "Timings",
    "Location",
    "Description"
  ],
  "Emergency": [
    "Service Name",
    "Phone",
    "Contact Person",
    "Availability",
    "Service Type",
    "Location",
    "Description"
  ],
  "Schools": [
    "School Name",
    "Phone",
    "Principal Name",
    "Classes",
    "Fees",
    "Location",
    "Description"
  ],
  "Hotels": [
    "Hotel Name",
    "Phone",
    "Food Type",
    "Price",
    "Delivery Option",
    "Location",
    "Description"
  ],
  "Old Goods": [
    "Item Name",
    "Phone",
    "Seller Name",
    "Condition",
    "Price",
    "Location",
    "Description"
  ],
  "House Rent": [
    "Owner Name",
    "Phone",
    "House Type",
    "Rent",
    "Advance",
    "Location",
    "Description"
  ],
  "Vehicle Rentals": [
    "Vehicle Name",
    "Phone",
    "Owner Name",
    "Model",
    "Price",
    "Location",
    "Description"
  ]
};

Map<String, List<String>> categoryHints = {
  "Farmers": [
    "Ex: Ramesh",
    "Ex: 9876543210",
    "Ex: Tomato",
    "Ex: 100 kg",
    "Ex: ₹20 per kg",
    "Ex: Rayachoty",
    "Ex: Fresh farm vegetables available"
  ],
  "Shops": [
    "Ex: Sri Lakshmi Stores",
    "Ex: 9876543210",
    "Ex: Venkatesh",
    "Ex: Grocery",
    "Ex: 9AM - 9PM",
    "Ex: Rayachoty",
    "Ex: All daily essentials available"
  ],
  "Services": [
    "Ex: Electrician",
    "Ex: 9876543210",
    "Ex: Raju",
    "Ex: 5 years",
    "Ex: ₹500 per visit",
    "Ex: Rayachoty",
    "Ex: Home electrical repairs"
  ],
  "Jobs": [
    "Ex: Sales Executive",
    "Ex: 9876543210",
    "Ex: ABC Company",
    "Ex: ₹15000 per month",
    "Ex: Degree",
    "Ex: Rayachoty",
    "Ex: Immediate joining required"
  ],
  "Hospitals": [
    "Ex: City Hospital",
    "Ex: 9876543210",
    "Ex: Dr. Kumar",
    "Ex: Cardiology",
    "Ex: 9AM - 6PM",
    "Ex: Rayachoty",
    "Ex: 24/7 emergency available"
  ],
  "Emergency": [
    "Ex: Ambulance Service",
    "Ex: 9876543210",
    "Ex: Ravi",
    "Ex: 24/7",
    "Ex: Medical",
    "Ex: Rayachoty",
    "Ex: Fast response service"
  ],
  "Schools": [
    "Ex: Archana School",
    "Ex: 9876543210",
    "Ex: Mr. Reddy",
    "Ex: 1-10",
    "Ex: ₹5000",
    "Ex: Rayachoty",
    "Ex: English medium school"
  ],
  "Hotels": [
    "Ex: Sri Balaji Hotel",
    "Ex: 9876543210",
    "Ex: Veg / Non-Veg",
    "Ex: ₹150 per meal",
    "Ex: Home Delivery Available",
    "Ex: Rayachoty",
    "Ex: Family restaurant"
  ],
  "Old Goods": [
    "Ex: Used Bike",
    "Ex: 9876543210",
    "Ex: Vamshi",
    "Ex: Good condition",
    "Ex: ₹25000",
    "Ex: Rayachoty",
    "Ex: Well maintained vehicle"
  ],
  "House Rent": [
    "Ex: Raju",
    "Ex: 9876543210",
    "Ex: 2BHK",
    "Ex: ₹8000",
    "Ex: ₹20000",
    "Ex: Rayachoty",
    "Ex: Near bus stand"
  ],
  "Vehicle Rentals": [
    "Ex: Swift Car",
    "Ex: 9876543210",
    "Ex: Srinivas",
    "Ex: 2022 Model",
    "Ex: ₹2000 per day",
    "Ex: Rayachoty",
    "Ex: With driver available"
  ]
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  runApp(const RayachotySevaluApp());
}

class RayachotySevaluApp extends StatelessWidget {
  const RayachotySevaluApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF673AB7),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DashboardScreen(),
    );
  }
}

const Map<String, String> categoryMap = {
  "Farmers": "రైతులు",
  "Shops": "దుకాణాలు",
  "Services": "సేవలు",
  "Jobs": "ఉద్యోగాలు",
  "Hospitals": "ఆసుపత్రులు",
  "Emergency": "అత్యవసరం",
  "Schools": "పాఠశాలలు",
  "Hotels": "హోటళ్ళు",
  "Old Goods": "పాాత వస్తువులు",
  "House Rent": "ఇల్లు అద్దె",
  "Vehicle Rentals": "వాహనాలు",
};

String getCategory(String category) {
  if (currentLanguage == "Telugu") {
    return categoryMap[category] ?? category;
  }
  return category;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> categories = const [
    {
      "title": "Farmers",
      "telugu": "రైతులు",
      "isEmoji": true,
      "emoji": "👨‍🌾",
      "color": Color(0xFFE8F5E9),
      "iconColor": Colors.green
    },
    {
      "title": "Shops",
      "telugu": "దుకాణాలు",
      "icon": Icons.store,
      "color": Color(0xFFFFF3E0),
      "iconColor": Colors.orange
    },
    {
      "title": "Services",
      "telugu": "సేవలు",
      "icon": Icons.build,
      "color": Color(0xFFE3F2FD),
      "iconColor": Colors.blue
    },
    {
      "title": "Jobs",
      "telugu": "ఉద్యోగాలు",
      "icon": Icons.work,
      "color": Color(0xFFE0F2F1),
      "iconColor": Colors.teal
    },
    {
      "title": "Hospitals",
      "telugu": "ఆసుపత్రులు",
      "icon": Icons.local_hospital,
      "color": Color(0xFFFFEBEE),
      "iconColor": Colors.red
    },
    {
      "title": "Emergency",
      "telugu": "అత్యవసరం",
      "icon": Icons.warning,
      "color": Color(0xFFF3E5F5),
      "iconColor": Colors.purple
    },
    {
      "title": "Schools",
      "telugu": "పాఠశాలలు",
      "icon": Icons.school,
      "color": Color(0xFFFFF8E1),
      "iconColor": Colors.amber
    },
    {
      "title": "Hotels",
      "telugu": "హోటళ్ళు",
      "icon": Icons.restaurant,
      "color": Color(0xFFFCE4EC),
      "iconColor": Colors.pink
    },
    {
      "title": "Old Goods",
      "telugu": "పాాత వస్తువులు",
      "icon": Icons.recycling,
      "color": Color(0xFFEFEBE9),
      "iconColor": Colors.brown
    },
    {
      "title": "House Rent",
      "telugu": "ఇల్లు అద్దె",
      "icon": Icons.home,
      "color": Color(0xFFF1F8E9),
      "iconColor": Colors.lightGreen
    },
    {
      "title": "Vehicle Rentals",
      "telugu": "వాహనాలు",
      "icon": Icons.directions_car,
      "color": Color(0xFFE8EAF6),
      "iconColor": Colors.indigo
    },
  ];

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
  }

  void _incrementViewCount() {
    FirebaseFirestore.instance.collection('admin').doc('analytics').set({
      'total_views': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  void _showChangePinDialog() {
    final TextEditingController newPinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Admin PIN"),
        content: TextField(
            controller: newPinController,
            keyboardType: TextInputType.number,
            maxLength: 4),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (newPinController.text.length == 4) {
                await FirebaseFirestore.instance
                    .collection('admin')
                    .doc('settings')
                    .update({'pin': newPinController.text});
                Navigator.pop(ctx);
              }
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: const Color(0xFF673AB7),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.email_outlined, color: Colors.white),
          onPressed: () =>
              launchUrl(Uri.parse("mailto:papireddy.vamshidhar@gmail.com")),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isEng ? "Rayachoty Sevalu" : "రాయచోటి సేవలు",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20)),
            const SizedBox(height: 6),
            Text(
                isEng
                    ? "Developed by Vamshi Reddy"
                    : "రూపొందించినవారు: వంశీ రెడ్డి",
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.yellowAccent,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          StreamBuilder<int>(
            stream: firebaseService.getPendingCount(),
            builder: (context, snap) {
              int count = snap.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                        isAdminLoggedIn
                            ? Icons.admin_panel_settings
                            : Icons.lock_outline,
                        color: isAdminLoggedIn
                            ? Colors.yellowAccent
                            : Colors.white),
                    onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const AdminLoginPage()))
                        .then((_) => setState(() {})),
                  ),
                  if (count > 0 && isAdminLoggedIn)
                    Positioned(
                        right: 8,
                        top: 8,
                        child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text("$count",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white)))),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ChoiceChip(
                      label: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text("English"),
                        ),
                      ),
                      selected: isEng,
                      onSelected: (v) =>
                          setState(() => currentLanguage = "English")),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const AddListingPage())),
                    icon: const Icon(Icons.add),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(isEng ? "Register" : "నమోదు"),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                      label: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text("తెలుగు"),
                        ),
                      ),
                      selected: !isEng,
                      onSelected: (v) =>
                          setState(() => currentLanguage = "Telugu")),
                ),
              ],
            ),
          ),
          if (isAdminLoggedIn)
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                      onPressed: _showChangePinDialog,
                      icon: const Icon(Icons.lock),
                      label: const Text("PIN")),
                  TextButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminApprovalPage())),
                      icon: const Icon(Icons.approval),
                      label: const Text("Approvals")),
                  TextButton.icon(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isAdmin', false);
                        setState(() => isAdminLoggedIn = false);
                      },
                      icon: const Icon(Icons.exit_to_app, color: Colors.red),
                      label: const Text("Exit")),
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ListingPage(categoryTitle: cat["title"]))),
                  child: Container(
                    decoration: BoxDecoration(
                        color: cat["color"],
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cat["isEmoji"] == true
                            ? Text(cat["emoji"],
                                style: const TextStyle(fontSize: 45))
                            : Icon(cat["icon"],
                                size: 45, color: cat["iconColor"]),
                        Text(isEng ? cat["title"] : cat["telugu"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});
  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  String selectedCat = "Farmers";

  final Map<String, TextEditingController> controllers = {
    'f1': TextEditingController(),
    'f2': TextEditingController(),
    'f3': TextEditingController(),
    'f4': TextEditingController(),
    'f5': TextEditingController(),
    'f6': TextEditingController(),
    'desc': TextEditingController(),
  };

  TextInputType _getKeyboardType(String label) {
    String l = label.toLowerCase();
    if (l.contains("phone")) return TextInputType.phone;
    if (l.contains("price") ||
        l.contains("rent") ||
        l.contains("salary") ||
        l.contains("fees") ||
        l.contains("deposit")) return TextInputType.number;
    return TextInputType.text;
  }

  String? _validateField(String label, String value) {
    if (value.trim().isEmpty) return "This field is required";
    if (label.toLowerCase().contains("phone") && value.length != 10)
      return "Enter valid 10 digit mobile number";
    return null;
  }

  List<String> _getLabels(String category, bool isEng) {
    switch (category) {
      case "Farmers":
        return isEng
            ? [
                "Farmer Name",
                "Phone",
                "Crop Type",
                "Quantity",
                "Price",
                "Location"
              ]
            : ["రైతు పేరు", "ఫోన్", "పంట", "పరిమాణం", "ధర", "స్థలం"];
      case "Shops":
        return isEng
            ? ["Shop Name", "Phone", "Owner", "Category", "Timings", "Location"]
            : ["దుకాణం పేరు", "ఫోన్", "యజమాని", "వర్గం", "సమయం", "స్థలం"];
      case "Services":
        return isEng
            ? [
                "Service Name",
                "Phone",
                "Provider Name",
                "Experience",
                "Charges",
                "Location"
              ]
            : ["సేవ పేరు", "ఫోన్", "పేరు", "అనుభవం", "ధర", "స్థలం"];
      case "Jobs":
        return isEng
            ? [
                "Job Title",
                "Phone",
                "Company Name",
                "Salary",
                "Qualification",
                "Location"
              ]
            : ["ఉద్యోగం పేరు", "ఫోన్", "కంపెనీ", "జీతం", "అర్హత", "స్థలం"];
      case "Hospitals":
        return isEng
            ? [
                "Hospital Name",
                "Phone",
                "Doctor Name",
                "Speciality",
                "Timings",
                "Location"
              ]
            : [
                "ఆసుపత్రి పేరు",
                "ఫోన్",
                "డాక్టర్",
                "ప్రత్యేకత",
                "సమయం",
                "స్థలం"
              ];
      case "Emergency":
        return isEng
            ? [
                "Service Name",
                "Phone",
                "Contact Person",
                "Availability",
                "Service Type",
                "Location"
              ]
            : ["సేవ పేరు", "ఫోన్", "వ్యక్తి", "అందుబాటు", "రకం", "స్థలం"];
      case "Schools":
        return isEng
            ? [
                "School Name",
                "Phone",
                "Principal Name",
                "Classes",
                "Fees",
                "Location"
              ]
            : [
                "పాఠశాల పేరు",
                "ఫోన్",
                "ప్రిన్సిపాల్",
                "తరగతులు",
                "ఫీజు",
                "స్థలం"
              ];
      case "Hotels":
        return isEng
            ? [
                "Hotel Name",
                "Phone",
                "Food Type",
                "Price",
                "Delivery Option",
                "Location"
              ]
            : ["హోటల్ పేరు", "ఫోన్", "రకం", "ధర", "డెలివరీ", "స్థలం"];
      case "Old Goods":
        return isEng
            ? [
                "Item Name",
                "Phone",
                "Seller Name",
                "Condition",
                "Price",
                "Location"
              ]
            : ["వస్తువు పేరు", "ఫోన్", "పేరు", "స్థితి", "ధర", "స్థలం"];
      case "House Rent":
        return isEng
            ? [
                "Owner Name",
                "Phone",
                "House Type",
                "Rent",
                "Advance",
                "Location"
              ]
            : ["యజమాని పేరు", "ఫోన్", "రకం", "అద్దె", "అడ్వాన్స్", "స్థలం"];
      case "Vehicle Rentals":
        return isEng
            ? [
                "Vehicle Name",
                "Phone",
                "Owner Name",
                "Model",
                "Price",
                "Location"
              ]
            : ["వాహనం పేరు", "ఫోన్", "యజమాని", "మోడల్", "ధర", "స్థలం"];
      default:
        return isEng
            ? ["Field 1", "Field 2", "Field 3", "Field 4", "Field 5", "Field 6"]
            : [
                "ఫీల్డ్ 1",
                "ఫీల్డ్ 2",
                "ఫీల్డ్ 3",
                "ఫీల్డ్ 4",
                "ఫీల్డ్ 5",
                "ఫీల్డ్ 6"
              ];
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    bool isEng = currentLanguage == "English";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String devId = prefs.getString('user_device_id') ??
        DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString('user_device_id', devId);

    Map<String, String> fieldsToTranslate = {
      'f1': controllers['f1']!.text.trim(),
      'f2': controllers['f2']!.text.trim(),
      'f3': controllers['f3']!.text.trim(),
      'f4': controllers['f4']!.text.trim(),
      'f5': controllers['f5']!.text.trim(),
      'f6': controllers['f6']!.text.trim(),
      'desc': controllers['desc']!.text.trim(),
    };

    Map<String, String> translated =
        await translationService.translateAllFields(fieldsToTranslate, isEng);

    Listing newListing = Listing(
      id: '',
      category: selectedCat,
      ownerId: devId,
      f1En: translated['f1_en']!,
      f1Te: translated['f1_te']!,
      f2En: translated['f2_en']!,
      f2Te: translated['f2_te']!,
      f3En: translated['f3_en']!,
      f3Te: translated['f3_te']!,
      f4En: translated['f4_en']!,
      f4Te: translated['f4_te']!,
      f5En: translated['f5_en']!,
      f5Te: translated['f5_te']!,
      f6En: translated['f6_en']!,
      f6Te: translated['f6_te']!,
      descEn: translated['desc_en']!,
      descTe: translated['desc_te']!,
    );

    await firebaseService.addListing(newListing);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: Text(
          isEng
              ? "Registration Successful! Your listing will be visible after admin approval."
              : "నమోదు విజయవంతమైంది! అడ్మిన్ ఆమోదం తర్వాత మీ వివరాలు కనిపిస్తాయి.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    List<String> labels = _getLabels(selectedCat, isEng);
    List<String> dynamicHints = categoryHints[selectedCat] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(isEng ? "Register" : "నమోదు")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: categoryMap.keys
                    .map((k) => DropdownMenuItem(
                        value: k, child: Text(isEng ? k : categoryMap[k]!)))
                    .toList(),
                onChanged: (v) => setState(() {
                  selectedCat = v!;
                  for (var c in controllers.values) {
                    c.clear();
                  }
                }),
                decoration: InputDecoration(
                    labelText: isEng ? "Category" : "వర్గం",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    controller: controllers['f${i + 1}'],
                    keyboardType: _getKeyboardType(labels[i]),
                    validator: (v) => _validateField(labels[i], v ?? ""),
                    decoration: InputDecoration(
                        labelText: labels[i],
                        hintText:
                            i < dynamicHints.length ? dynamicHints[i] : "",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              TextFormField(
                controller: controllers['desc'],
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: isEng ? "Description (Max 50 words)" : "వివరణ",
                    hintText: 6 < dynamicHints.length ? dynamicHints[6] : "",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF673AB7)),
                child: Text(isEng ? "SUBMIT" : "సమర్పించండి",
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListingPage extends StatefulWidget {
  final String categoryTitle;
  const ListingPage({super.key, required this.categoryTitle});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  String search = "";
  String myDeviceId = "";
  String sortBy = "Latest";

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => myDeviceId = prefs.getString('user_device_id') ?? "");
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";

    return Scaffold(
      appBar: AppBar(
        title: Text(getCategory(widget.categoryTitle)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => search = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: isEng ? "Search..." : "వెతకండి...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: sortBy,
                  underline: const SizedBox(),
                  onChanged: (v) => setState(() => sortBy = v!),
                  items: ["Latest", "Oldest", "Pinned", "A-Z"]
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child:
                                Text(s, style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Listing>>(
              stream: firebaseService.getApprovedListings(widget.categoryTitle),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Listing> listings = snap.data!.where((l) {
                  String f1 = isEng ? l.f1En : l.f1Te;
                  String f2 = isEng ? l.f2En : l.f2Te;
                  return f1.toLowerCase().contains(search) ||
                      f2.toLowerCase().contains(search);
                }).toList();

                if (sortBy == "Latest") {
                  listings.sort((a, b) =>
                      (b.timestamp as Timestamp?)?.compareTo(
                          a.timestamp as Timestamp? ?? Timestamp.now()) ??
                      0);
                } else if (sortBy == "Oldest") {
                  listings.sort((a, b) =>
                      (a.timestamp as Timestamp?)?.compareTo(
                          b.timestamp as Timestamp? ?? Timestamp.now()) ??
                      0);
                } else if (sortBy == "Pinned") {
                  listings.sort((a, b) =>
                      (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0));
                } else if (sortBy == "A-Z") {
                  listings.sort((a, b) => (isEng ? a.f1En : a.f1Te)
                      .compareTo(isEng ? b.f1En : b.f1Te));
                }

                if (listings.isEmpty) {
                  return Center(
                      child: Text(
                          isEng ? "No listings found." : "డేటా లభించలేదు."));
                }

                return ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    Listing l = listings[i];
                    bool canDelete =
                        isAdminLoggedIn || (l.ownerId == myDeviceId);

                    String f1 = isEng ? l.f1En : l.f1Te;
                    String f2 = isEng ? l.f2En : l.f2Te;
                    String f3 = isEng ? l.f3En : l.f3Te;
                    String f4 = isEng ? l.f4En : l.f4Te;
                    String f5 = isEng ? l.f5En : l.f5Te;
                    String f6 = isEng ? l.f6En : l.f6Te;
                    String desc = isEng ? l.descEn : l.descTe;

                    List<String> labels = categoryLabels[l.category] ?? [];
                    List<String> values = [f1, f2, f3, f4, f5, f6];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      elevation: 2,
                      color: l.isPinned ? Colors.yellow.shade50 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    f1,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (canDelete)
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            firebaseService.deleteListing(l.id),
                                      ),
                                    if (isAdminLoggedIn)
                                      IconButton(
                                        icon: Icon(l.isPinned
                                            ? Icons.push_pin
                                            : Icons.push_pin_outlined),
                                        onPressed: () => firebaseService
                                            .togglePinned(l.id, !l.isPinned),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.call,
                                          color: Colors.green),
                                      onPressed: () =>
                                          launchUrl(Uri.parse("tel:$f2")),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            for (int j = 1; j < 6; j++)
                              if (j < labels.length && values[j].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    "${labels[j]}: ${values[j]}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                            if (desc.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  desc,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700),
                                ),
                              ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    f6,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                                Text(
                                  l.timestamp != null
                                      ? DateFormat('dd MMM').format(
                                          (l.timestamp as Timestamp).toDate())
                                      : "",
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});
  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  void _showFullEdit(Listing l) {
    final Map<String, TextEditingController> editCtrls = {
      'f1En': TextEditingController(text: l.f1En),
      'f1Te': TextEditingController(text: l.f1Te),
      'f2En': TextEditingController(text: l.f2En),
      'f2Te': TextEditingController(text: l.f2Te),
      'f3En': TextEditingController(text: l.f3En),
      'f3Te': TextEditingController(text: l.f3Te),
      'f4En': TextEditingController(text: l.f4En),
      'f4Te': TextEditingController(text: l.f4Te),
      'f5En': TextEditingController(text: l.f5En),
      'f5Te': TextEditingController(text: l.f5Te),
      'f6En': TextEditingController(text: l.f6En),
      'f6Te': TextEditingController(text: l.f6Te),
      'descEn': TextEditingController(text: l.descEn),
      'descTe': TextEditingController(text: l.descTe),
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Full Listing"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _adminField(editCtrls['f1En']!, "Name (EN)"),
            _adminField(editCtrls['f1Te']!, "Name (TE)"),
            _adminField(editCtrls['f2En']!, "Phone (EN)"),
            _adminField(editCtrls['f2Te']!, "Phone (TE)"),
            _adminField(editCtrls['f3En']!, "Field 3 (EN)"),
            _adminField(editCtrls['f3Te']!, "Field 3 (TE)"),
            _adminField(editCtrls['f4En']!, "Field 4 (EN)"),
            _adminField(editCtrls['f4Te']!, "Field 4 (TE)"),
            _adminField(editCtrls['f5En']!, "Field 5 (EN)"),
            _adminField(editCtrls['f5Te']!, "Field 5 (TE)"),
            _adminField(editCtrls['f6En']!, "Location (EN)"),
            _adminField(editCtrls['f6Te']!, "Location (TE)"),
            _adminField(editCtrls['descEn']!, "Desc (EN)", lines: 2),
            _adminField(editCtrls['descTe']!, "Desc (TE)", lines: 2),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                await firebaseService.updateListing(l.id, {
                  'f1_en': editCtrls['f1En']!.text,
                  'f1_te': editCtrls['f1Te']!.text,
                  'f2_en': editCtrls['f2En']!.text,
                  'f2_te': editCtrls['f2Te']!.text,
                  'f3_en': editCtrls['f3En']!.text,
                  'f3_te': editCtrls['f3Te']!.text,
                  'f4_en': editCtrls['f4En']!.text,
                  'f4_te': editCtrls['f4Te']!.text,
                  'f5_en': editCtrls['f5En']!.text,
                  'f5_te': editCtrls['f5Te']!.text,
                  'f6_en': editCtrls['f6En']!.text,
                  'f6_te': editCtrls['f6Te']!.text,
                  'desc_en': editCtrls['descEn']!.text,
                  'desc_te': editCtrls['descTe']!.text,
                });
                if (!mounted) return;
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text("SAVE")),
        ],
      ),
    );
  }

  Widget _adminField(TextEditingController ctrl, String label,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
          controller: ctrl,
          maxLines: lines,
          decoration:
              InputDecoration(labelText: label, border: OutlineInputBorder())),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Approvals")),
      body: FutureBuilder<List<Listing>>(
        future: firebaseService.getPendingListings(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty)
            return Center(child: Text("No pending approvals."));
          return ListView.builder(
            itemCount: snap.data!.length,
            itemBuilder: (context, i) {
              Listing l = snap.data![i];
              String f1 = isEng ? l.f1En : l.f1Te;
              String f2 = isEng ? l.f2En : l.f2Te;
              String f6 = isEng ? l.f6En : l.f6Te;
              String cat = getCategory(l.category);

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CATEGORY: $cat",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 5),
                      Text("Name: $f1"),
                      Text("Phone: $f2"),
                      Text("Location: $f6"),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFullEdit(l)),
                          IconButton(
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green, size: 30),
                              onPressed: () async {
                                await firebaseService.approveListing(l.id);
                                setState(() {});
                              }),
                          IconButton(
                              icon: const Icon(Icons.cancel,
                                  color: Colors.red, size: 30),
                              onPressed: () async {
                                await firebaseService.deleteListing(l.id);
                                setState(() {});
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final pin = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(
              controller: pin,
              decoration: const InputDecoration(
                  labelText: "Enter PIN", border: OutlineInputBorder()),
              obscureText: true,
              keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50)),
            onPressed: () async {
              var d = await FirebaseFirestore.instance
                  .collection('admin')
                  .doc('settings')
                  .get();
              if (pin.text == d['pin']) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isAdmin', true);
                isAdminLoggedIn = true;
                if (!mounted) return;
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Incorrect PIN")));
              }
            },
            child: const Text("LOGIN"),
          ),
        ]),
      ),
    );
  }
}
