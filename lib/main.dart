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

// Hints mapping for English and Telugu
Map<String, List<String>> categoryHintsEn = {
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

Map<String, List<String>> categoryHintsTe = {
  "Farmers": [
    "ఉదా: రమేష్",
    "ఉదా: 9876543210",
    "ఉదా: టమోటా",
    "ఉదా: 100 కేజీలు",
    "ఉదా: ₹20 ప్రతి కేజీ",
    "ఉదా: రాయచోటి",
    "ఉదా: తాజా కూరగాయలు అందుబాటులో ఉన్నాయి"
  ],
  "Shops": [
    "ఉదా: శ్రీ లక్ష్మి స్టోర్స్",
    "ఉదా: 9876543210",
    "ఉదా: వెంకటేష్",
    "ఉదా: కిరాణా",
    "ఉదా: ఉదయం 9 - రాత్రి 9",
    "ఉదా: రాయచోటి",
    "ఉదా: అన్ని నిత్యావసరాలు లభిస్తాయి"
  ],
  "Services": [
    "ఉదా: ఎలక్ట్రీషియన్",
    "ఉదా: 9876543210",
    "ఉదా: రాజు",
    "ఉదా: 5 ఏళ్లు",
    "ఉదా: ₹500 ఫీజు",
    "ఉదా: రాయచోటి",
    "ఉదా: ఇంటి వద్దకే సర్వీస్"
  ],
  "Jobs": [
    "ఉదా: సేల్స్ ఎగ్జిక్యూటివ్",
    "ఉదా: 9876543210",
    "ఉదా: ABC కంపెనీ",
    "ఉదా: నెలకు ₹15000",
    "ఉదా: డిగ్రీ",
    "ఉదా: రాయచోటి",
    "ఉదా: వెంటనే చేరాలి"
  ],
  "Hospitals": [
    "ఉదా: సిటీ హాస్పిటల్",
    "ఉదా: 9876543210",
    "ఉదా: డాక్టర్ కుమార్",
    "ఉదా: కార్డియాలజీ",
    "ఉదా: ఉదయం 9 - సాయంత్రం 6",
    "ఉదా: రాయచోటి",
    "ఉదా: 24/7 అత్యవసర సేవలు"
  ],
  "Emergency": [
    "ఉదా: అంబులెన్స్ సేవ",
    "ఉదా: 9876543210",
    "ఉదా: రవి",
    "ఉదా: 24/7",
    "ఉదా: మెడికల్",
    "ఉదా: రాయచోటి",
    "ఉదా: వేగవంతమైన స్పందన"
  ],
  "Schools": [
    "ఉదా: అర్చన స్కూల్",
    "ఉదా: 9876543210",
    "ఉదా: మిస్టర్ రెడ్డి",
    "ఉదా: 1-10 తరగతులు",
    "ఉదా: ₹5000 ఫీజు",
    "ఉదా: రాయచోటి",
    "ఉదా: ఇంగ్లీష్ మీడియం పాఠశాల"
  ],
  "Hotels": [
    "ఉదా: శ్రీ బాలాజీ హోటల్",
    "ఉదా: 9876543210",
    "ఉదా: వెజ్ / నాన్-వెజ్",
    "ఉదా: నెలకు ₹150",
    "ఉదా: హోమ్ డెలివరీ కలదు",
    "ఉదా: రాయచోటి",
    "ఉదా: ఫ్యామిలీ రెస్టారెంట్"
  ],
  "Old Goods": [
    "ఉదా: పాత బైక్",
    "ఉదా: 9876543210",
    "ఉదా: వంశీ",
    "ఉదా: మంచి స్థితి",
    "ఉదా: ₹25000",
    "ఉదా: రాయచోటి",
    "ఉదా: బాగా నిర్వహించబడిన వాహనం"
  ],
  "House Rent": [
    "ఉదా: రాజు",
    "ఉదా: 9876543210",
    "ఉదా: 2BHK",
    "ఉదా: ₹8000 అద్దె",
    "ఉదా: ₹20000 అడ్వాన్స్",
    "ఉదా: రాయచోటి",
    "ఉదా: బస్టాండ్ దగ్గర"
  ],
  "Vehicle Rentals": [
    "ఉదా: స్విఫ్ట్ కారు",
    "ఉదా: 9876543210",
    "ఉదా: శ్రీనివాస్",
    "ఉదా: 2022 మోడల్",
    "ఉదా: రోజుకు ₹2000",
    "ఉదా: రాయచోటి",
    "ఉదా: డ్రైవర్ అందుబాటులో ఉన్నారు"
  ]
};

// Emoji Auto Detection Function - Fully Fixed with Farmers and House Rent corrections
String getEmojiForTitle(String title, String category) {
  String t = title.toLowerCase();

  // Category Specific Matches
  if (category == "Farmers") {
    if (t.contains("brinjal") || t.contains("వంకాయ")) return "🍆";
    if (t.contains("cauliflower") || t.contains("కాలిఫ్లవర్")) return "🥦";
    if (t.contains("cabbage") || t.contains("క్యాబేజీ")) return "🥬";
    if (t.contains("potato") || t.contains("బంగాళదుంప")) return "🥔";
    if (t.contains("groundnut") ||
        t.contains("verusenaga") ||
        t.contains("వేరుసెనగ")) return "🥜";
    if (t.contains("tomato") || t.contains("టమోటా")) return "🍅";
    if (t.contains("chilli") || t.contains("మిర్చి")) return "🌶️";
    if (t.contains("onion") || t.contains("ఉల్లిపాయ")) return "🧅";
    if (t.contains("carrot") || t.contains("క్యారెట్")) return "🥕";
    if (t.contains("apple") || t.contains("ఆపిల్")) return "🍎";
    if (t.contains("banana") || t.contains("అరటి")) return "🍌";
    if (t.contains("vegetable") || t.contains("కూరగాయ")) return "🥦";
    if (t.contains("fruit") || t.contains("పండు")) return "🍎";
    if (t.contains("rice") || t.contains("బియ్యం")) return "🍚";
    return "🌾";
  }

  if (category == "House Rent") {
    if (t.contains("2bhk") || t.contains("3bhk") || t.contains("1bhk"))
      return "🏠";
    if (t.contains("apartment") || t.contains("అపార్ట్‌మెంట్")) return "🏢";
    if (t.contains("ground floor") || t.contains("గ్రౌండ్ ఫ్లోర్"))
      return "🏘️";
    if (t.contains("independent") || t.contains("ఇండిపెండెంట్")) return "🏡";
    return "🏠";
  }

  if (category == "Old Goods") {
    if (t.contains("fridge") || t.contains("ఫ్రిజ్")) return "🧊";
    if (t.contains("tv") || t.contains("టీవీ")) return "📺";
    if (t.contains("bike") || t.contains("బైక్")) return "🏍️";
    if (t.contains("car") || t.contains("కారు")) return "🚗";
    if (t.contains("sofa") || t.contains("సోఫా")) return "🛋️";
    if (t.contains("bed") || t.contains("మంచం")) return "🛏️";
    if (t.contains("laptop") || t.contains("ల్యాప్టాప్")) return "💻";
    if (t.contains("mobile") || t.contains("ఫోన్")) return "📱";
    if (t.contains("washing machine")) return "🧺";
    return "♻️";
  }

  if (category == "Vehicle Rentals") {
    if (t.contains("car") || t.contains("కారు")) return "🚗";
    if (t.contains("bike") || t.contains("బైక్")) return "🏍️";
    if (t.contains("auto") || t.contains("ఆటో")) return "🛺";
    if (t.contains("bus") || t.contains("బస్")) return "🚌";
    if (t.contains("tractor") || t.contains("ట్రాక్టర్")) return "🚜";
    return "🚘";
  }

  if (category == "Services") {
    if (t.contains("plumber") || t.contains("ప్లంబర్")) return "🔧";
    if (t.contains("electrician") || t.contains("ఎలక్ట్రిషియన్")) return "⚡";
    if (t.contains("mechanic") || t.contains("మెకానిక్")) return "🛠️";
    if (t.contains("driver") || t.contains("డ్రైవర్")) return "🚗";
    if (t.contains("cleaning") || t.contains("క్లీనింగ్")) return "🧹";
    if (t.contains("painter") || t.contains("పెయింటర్")) return "🎨";
    if (t.contains("tailor") || t.contains("దర్జీ")) return "🧵";
    return "🛠️";
  }

  if (category == "Shops") {
    if (t.contains("grocery") || t.contains("కిరాణా")) return "🛒";
    if (t.contains("medical") || t.contains("మెడికల్")) return "💊";
    if (t.contains("bakery") || t.contains("బేకరీ")) return "🥖";
    if (t.contains("electronics")) return "🔌";
    if (t.contains("clothes")) return "👕";
    if (t.contains("vegetable shop")) return "🥦";
    return "🏬";
  }

  if (category == "Hospitals") return "🏥";
  if (category == "Schools") return "🏫";

  if (category == "Emergency") {
    if (t.contains("ambulance") || t.contains("అంబులెన్స్")) return "🚑";
    if (t.contains("police") || t.contains("పోలీస్")) return "🚓";
    if (t.contains("fire") || t.contains("ఫైర్")) return "🚒";
    return "🚨";
  }

  if (category == "Hotels") {
    if (t.contains("hotel") || t.contains("హోటల్")) return "🏨";
    if (t.contains("veg") && !t.contains("non")) return "🥗";
    if (t.contains("non veg") || t.contains("nonveg")) return "🍗";
    return "🍽️";
  }

  if (category == "Jobs") {
    if (t.contains("software")) return "💻";
    if (t.contains("sales")) return "🛍️";
    if (t.contains("teacher")) return "👩‍🏫";
    return "💼";
  }

  return "";
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  currentLanguage = prefs.getString('selected_language') ?? "Telugu";

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
  // Reordered categories per instructions
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
      "title": "Services",
      "telugu": "సేవలు",
      "icon": Icons.build,
      "color": Color(0xFFE3F2FD),
      "iconColor": Colors.blue
    },
    {
      "title": "Vehicle Rentals",
      "telugu": "వాహనాలు",
      "icon": Icons.directions_car,
      "color": Color(0xFFE8EAF6),
      "iconColor": Colors.indigo
    },
    {
      "title": "Shops",
      "telugu": "దుకాణాలు",
      "icon": Icons.store,
      "color": Color(0xFFFFF3E0),
      "iconColor": Colors.orange
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
            Text(isEng ? "Mana" : "మన",
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400)),
            Text(isEng ? "Rayachoty Sevalu" : "రాయచోటి సేవలు",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22)),
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
          if (!isAdminLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          side: isEng
                              ? const BorderSide(
                                  color: Color(0xFF673AB7), width: 2)
                              : BorderSide.none,
                          label: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("English",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isEng
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ),
                          selected: isEng,
                          onSelected: (v) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString(
                                'selected_language', "English");
                            setState(() => currentLanguage = "English");
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: isEng
                            ? "My Services (View & Delete your posted services)"
                            : "నా సేవలు (మీరు పోస్ట్ చేసిన సేవలు చూడండి / తొలగించండి)",
                        child: IconButton(
                          icon: const Icon(Icons.person,
                              color: Color(0xFF03A9F4)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyListingsPage()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          side: !isEng
                              ? const BorderSide(
                                  color: Color(0xFF673AB7), width: 2)
                              : BorderSide.none,
                          label: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("తెలుగు",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: !isEng
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ),
                          selected: !isEng,
                          onSelected: (v) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString(
                                'selected_language', "Telugu");
                            setState(() => currentLanguage = "Telugu");
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEng
                        ? "Press above button to change language"
                        : "భాష మార్చడానికి పై బటన్ నొక్కండి",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          // Increased Add Service Button
          if (!isAdminLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 85,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const AddListingPage())),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            isEng ? "Add Your Service" : "మీ సేవను జోడించండి",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ],
                      ),
                      Text(
                        isEng ? "Click Here" : "ఇక్కడ క్లిక్ చేయండి",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12, // Reduced vertical spacing
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
                                style: const TextStyle(
                                    fontSize: 36)) // Reduced icon size by ~20%
                            : Icon(cat["icon"],
                                size: 36,
                                color: cat[
                                    "iconColor"]), // Reduced icon size by ~20%
                        Text(
                            isAdminLoggedIn
                                ? cat["title"]
                                : (isEng ? cat["title"] : cat["telugu"]),
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
  bool isSubmitting = false;

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

    // Emergency Phone Validation Fix
    if (label.toLowerCase().contains("phone")) {
      if (selectedCat == "Emergency") {
        if (value.length < 3) return "Enter valid number";
      } else {
        if (value.length != 10) return "Enter valid 10 digit mobile number";
      }
    }
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _submit() async {
    if (isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);
    bool isEng = currentLanguage == "English";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String devId = prefs.getString('user_device_id') ??
          DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('user_device_id', devId);

      Map<String, String> fieldsToTranslate = {
        'f1': _capitalize(controllers['f1']!.text.trim()),
        'f2': controllers['f2']!.text.trim(),
        'f3': _capitalize(controllers['f3']!.text.trim()),
        'f4': _capitalize(controllers['f4']!.text.trim()),
        'f5': controllers['f5']!.text.trim(),
        'f6': _capitalize(controllers['f6']!.text.trim()),
        'desc': _capitalize(controllers['desc']!.text.trim()),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEng
              ? "Successful! Waiting for admin approval."
              : "విజయవంతమైంది! అడ్మిన్ ఆమోదం కోసం వేచి ఉంది."),
          backgroundColor: Colors.green,
        ),
      );

      // Automatic navigate to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    List<String> labels = _getLabels(selectedCat, isEng);
    // Logic to select hints based on language
    List<String> dynamicHints = isEng
        ? (categoryHintsEn[selectedCat] ?? [])
        : (categoryHintsTe[selectedCat] ?? []);

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
                onPressed: isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF673AB7)),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEng ? "SUBMIT" : "సమర్పించండి",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
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
            child: TextField(
              onChanged: (v) => setState(() => search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: isEng ? "Search..." : "వెతకండి...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
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

                listings.sort((a, b) {
                  if (a.isPinned && !b.isPinned) return -1;
                  if (!a.isPinned && b.isPinned) return 1;

                  final aTime = a.timestamp as Timestamp?;
                  final bTime = b.timestamp as Timestamp?;

                  if (aTime == null || bTime == null) return 0;

                  return bTime.compareTo(aTime);
                });

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

                    String titleText = l.getHighlightedTitle(currentLanguage);

                    // HOUSE RENT UI FIX
                    if (l.category == "House Rent") {
                      titleText =
                          isEng ? l.f3En : l.f3Te; // House Type as title
                    }

                    String emoji = getEmojiForTitle(titleText, l.category);

                    Widget cardSubtitle;

                    if (l.category == "Farmers") {
                      String price = isEng ? l.f5En : l.f5Te;
                      if (!price.toLowerCase().contains("per kg") &&
                          !price.toLowerCase().contains("ప్రతి కేజీ")) {
                        price += isEng ? " per kg" : " ప్రతి కేజీ";
                      }
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f1En : l.f1Te),
                          Text(isEng ? l.f6En : l.f6Te),
                          Text(price,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      );
                    } else if (l.category == "Old Goods") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f3En : l.f3Te),
                          Text(isEng ? l.f6En : l.f6Te),
                          Text(isEng ? l.f5En : l.f5Te,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      );
                    } else if (l.category == "House Rent") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f1En : l.f1Te), // Owner name below
                          Text(isEng ? l.f6En : l.f6Te),
                          Text(isEng ? l.f4En : l.f4Te,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      );
                    } else if (l.category == "Vehicle Rentals") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f6En : l.f6Te),
                          Text(isEng ? l.f5En : l.f5Te,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      );
                    } else if (l.category == "Services") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f3En : l.f3Te),
                          Text(isEng ? l.f6En : l.f6Te),
                          if ((isEng ? l.f5En : l.f5Te).isNotEmpty)
                            Text(isEng ? l.f5En : l.f5Te,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                        ],
                      );
                    } else if (l.category == "Jobs") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f3En : l.f3Te),
                          Text(isEng ? l.f6En : l.f6Te),
                          if ((isEng ? l.f4En : l.f4Te).isNotEmpty)
                            Text(isEng ? l.f4En : l.f4Te,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                        ],
                      );
                    } else if (l.category == "Hotels") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f3En : l.f3Te,
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                          Text(isEng ? l.f6En : l.f6Te),
                        ],
                      );
                    } else if (l.category == "Hospitals") {
                      // HOSPITAL DUPLICATE FIX
                      bool showDoctor = (l.f3En.trim().toLowerCase() !=
                              l.f1En.trim().toLowerCase()) &&
                          (l.f3Te.trim() != l.f1Te.trim());
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDoctor) Text(isEng ? l.f3En : l.f3Te),
                          Text(isEng ? l.f4En : l.f4Te,
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                          Text(isEng ? l.f6En : l.f6Te),
                        ],
                      );
                    } else if (l.category == "Schools") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f4En : l.f4Te,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(isEng ? l.f6En : l.f6Te),
                        ],
                      );
                    } else if (l.category == "Emergency") {
                      cardSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEng ? l.f3En : l.f3Te),
                          Text(isEng ? l.f6En : l.f6Te),
                          if ((isEng ? l.f4En : l.f4Te).isNotEmpty &&
                              !(isEng ? l.f4En : l.f4Te).contains("24/7"))
                            Text(isEng ? l.f4En : l.f4Te),
                        ],
                      );
                    } else {
                      cardSubtitle = Text(isEng ? l.f6En : l.f6Te);
                    }

                    // EMERGENCY 24/7 LOGIC
                    bool isEmergency247 = l.category == "Emergency" &&
                        (isEng ? l.f4En : l.f4Te).contains("24/7");

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: l.isPinned ? Colors.yellow.shade50 : Colors.white,
                      child: Stack(
                        children: [
                          ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DetailPage(listing: l))),
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              children: [
                                if (emoji.isNotEmpty)
                                  Text("$emoji ",
                                      style: const TextStyle(fontSize: 18)),
                                Expanded(
                                  child: Text(titleText,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                          color: Color(0xFF673AB7))),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: cardSubtitle,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (canDelete)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      bool? confirm = await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Delete?"),
                                          content: const Text("Are you sure?"),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text("No")),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text("Yes")),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await firebaseService
                                            .deleteListing(l.id);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                if (l.isPinned)
                                  const Icon(Icons.push_pin,
                                      size: 18, color: Colors.orange)
                                else
                                  const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                          if (isEmergency247)
                            Positioned(
                              top: 8,
                              right: 40,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Text("24/7",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
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

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});
  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    return Scaffold(
      appBar: AppBar(title: Text(isEng ? "My Services" : "నా సేవలు")),
      body: FutureBuilder<String>(
        future: SharedPreferences.getInstance()
            .then((p) => p.getString('user_device_id') ?? ""),
        builder: (context, idSnap) {
          if (!idSnap.hasData)
            return const Center(child: CircularProgressIndicator());
          return StreamBuilder<List<Listing>>(
            stream: firebaseService.getMyListings(idSnap.data!),
            builder: (context, snap) {
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              if (snap.data!.isEmpty)
                return Center(
                    child: Text(isEng
                        ? "You haven't posted any services."
                        : "మీరు ఎటువంటి సేవలను పోస్ట్ చేయలేదు."));
              return ListView.builder(
                itemCount: snap.data!.length,
                itemBuilder: (context, i) {
                  Listing l = snap.data![i];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      title: Text(isEng ? l.f1En : l.f1Te),
                      subtitle: Text(getCategory(l.category)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete?"),
                              content: const Text("Are you sure?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("No")),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Yes")),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await firebaseService.deleteListing(l.id);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Listing listing;
  const DetailPage({super.key, required this.listing});
  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    List<String> labels = categoryLabels[listing.category] ?? [];
    String f1 = isEng ? listing.f1En : listing.f1Te;
    String f2 = isEng ? listing.f2En : listing.f2Te;
    String f3 = isEng ? listing.f3En : listing.f3Te;
    String f4 = isEng ? listing.f4En : listing.f4Te;
    String f5 = isEng ? listing.f5En : listing.f5Te;
    String f6 = isEng ? listing.f6En : listing.f6Te;
    String desc = isEng ? listing.descEn : listing.descTe;
    List<String> values = [f1, f2, f3, f4, f5, f6];
    return Scaffold(
      appBar: AppBar(title: Text(isEng ? "Details" : "వివరాలు")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f1,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF673AB7))),
            const Divider(height: 30),
            for (int i = 1; i < labels.length; i++)
              if (i < values.length && values[i].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${labels[i]}: ",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(values[i])),
                      ]),
                ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text("Description:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(desc, style: const TextStyle(fontSize: 15))
            ],
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse("tel:$f2")),
              icon: const Icon(Icons.call),
              label: Text(isEng ? "CALL NOW" : "కాల్ చేయండి"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55)),
            ),
          ],
        ),
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
      'descTe': TextEditingController(text: l.descTe)
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
            _adminField(editCtrls['descTe']!, "Desc (TE)", lines: 2)
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
                  'desc_te': editCtrls['descTe']!.text
                });
                if (!mounted) return;
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text("SAVE"))
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
            decoration: InputDecoration(
                labelText: label, border: const OutlineInputBorder())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Approvals")),
      body: FutureBuilder<List<Listing>>(
        future: firebaseService.getPendingListings(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty)
            return const Center(child: Text("No pending approvals."));
          return ListView.builder(
            itemCount: snap.data!.length,
            itemBuilder: (context, i) {
              Listing l = snap.data![i];
              String f1 = l.f1En;
              String f2 = l.f2En;
              String f6 = l.f6En;
              String cat = l.category;
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CATEGORY: $cat",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const SizedBox(height: 5),
                        Text("Name: $f1"),
                        Text("Phone: $f2"),
                        Text("Location: $f6"),
                        const Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.push_pin,
                                      color: Colors.orange),
                                  onPressed: () async {
                                    await firebaseService.togglePinned(
                                        l.id, !l.isPinned);
                                    setState(() {});
                                  }),
                              IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
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
                            ]),
                      ]),
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
                minimumSize: const Size(double.infinity, 50)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect PIN")));
              }
            },
            child: const Text("LOGIN"),
          ),
        ]),
      ),
    );
  }
}
