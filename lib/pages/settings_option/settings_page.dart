import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:novelcity/pages/user_admin_communication/book_recommendation_page.dart';
import 'package:novelcity/widget/snack_bar_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_write_constants.dart';
import '../../style/colors.dart';
import '../user_admin_communication/FAQs.dart';
import '../user_admin_communication/question_list.dart';
import '../user_admin_communication/users_questions.dart'; // Assuming you have your color styles imported

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userName = '';
  String userEmail = '';
  bool isLoading = true;
  String userId = '';

  final Client client = Client();
  late Databases databases;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '123456789';
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String userId = auth.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      // User is not logged in, add a delay before navigating to the login page
      await Future.delayed(Duration(seconds: 2));
      context.push('/login');
    } else {
      // User is logged in, fetch user details
      await _fetchUserDetails();
    }
  }

  Future<void> _fetchUserDetails() async {
    print("Fetching user details...");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if user details are already stored in SharedPreferences
    String? cachedUserName = prefs.getString('$userId+userName');
    String? cachedUserEmail = prefs.getString('$userId+userEmail');

    if (cachedUserName != null && cachedUserEmail != null) {
      // Load data from SharedPreferences if available
      setState(() {
        userName = cachedUserName;
        userEmail = cachedUserEmail;

        isLoading = false;
      });
    } else {
      // If no cached data, fetch from the database
      final FirebaseAuth auth = FirebaseAuth.instance;
      final String userId = auth.currentUser?.uid ?? '';

      if (userId.isNotEmpty) {
        final userDetails = await fetchUserDetails(userId);
        if (userDetails != null) {
          // Save the fetched details in SharedPreferences for future use
          await prefs.setString('$userId+userName', userDetails['userName'] ?? '');
          await prefs.setString('$userId+userEmail', userDetails['email'] ?? '');

          setState(() {
            userName = userDetails['userName'] ?? '';
            userEmail = userDetails['email'] ?? '';
            isLoading = false;
          });
        } else {
          print("User details not found.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("No user is logged in.");
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    try {
      // Initialize the Appwrite client
      client
        ..setEndpoint(Constants.endpoint) // Your Appwrite Endpoint
        ..setProject(Constants.projectId); // Your Project ID

      databases = Databases(client);
      print("Fetching user details from Appwrite...");
      final response = await databases.listDocuments(
        databaseId: Constants.databaseId, // Replace with your actual database ID
        collectionId: Constants.usersCollectionId, // Replace with your actual collection ID
        queries: [
          Query.equal('userId', userId), // Assuming 'userId' is the attribute name in Appwrite
        ],
      );

      print("Response from Appwrite: ${response.documents.length} documents found.");

      if (response.documents.isNotEmpty) {
        // Assuming the first document is the correct one
        return response.documents[0].data;
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 25,
            color: AppColors.textHighlight,
          ),
        ),
        backgroundColor: AppColors.backgroundSecondary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.buttonPrimary,))
          : SingleChildScrollView(
            child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32),
              Divider(),
              ListTile(
                title: Text(
                  'Recommend us a book',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                ),
                onTap: () {
                  // Navigate to the book recommendation page
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BookRecommendationPage())
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Tell us anything',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                ),
                onTap: () {
                  _launchEmail(receiverEmail: 'needlinkcustomerservice@gmail.com'); // Call the function to launch email
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Have a question?',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                ),
                onTap: () {
                  // Navigate to feedback page
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => QuestionSubmissionPage())
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Answer users question',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                ),
                onTap: () {
                  // Navigate to feedback page
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => QuestionsListPage())
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'FAQs',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                ),
                onTap: () {
                  // Navigate to FAQs page
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FAQsPage())
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Log Out',
                  style: TextStyle(color: AppColors.textHighlight, fontSize: 18),
                ),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
                    ),
                  ),
          ),
    );
  }





  void _launchEmail({required String receiverEmail}) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: receiverEmail,
      query: encodeQueryParameters({
        'subject': 'Novel City User',
        'body': 'Please enter your message here.',
      }),
    );

    try {
      // Launch the email client
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        showCustomSnackbar(context, 'Email Linking', 'Email client not found on this device', AppColors.warning);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSecondary,
            title: Text(
              'Email Client Not Found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Row(
              children: [
                Expanded(
                  child: Text(
                    'You can reach us on \n $receiverEmail',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: AppColors.textHighlight),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: receiverEmail));
                        showCustomSnackbar(context, 'Copy', 'Email copied to clipboard', AppColors.success);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(color: AppColors.textHighlight, fontSize: 18),
                ),
              ),
            ],
          ),
        );

        throw 'Email client not found on this device';
      }
    } catch (e) {
      // Handle exception by showing a message to the user
      print('Could not launch email client: $e');
      showCustomSnackbar(context, 'Linking Email', '$e', AppColors.error);
    }
  }




  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }



}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
              color: AppColors.textPrimary
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
              color: AppColors.textSecondary
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              'No',
              style: TextStyle(
                  color: AppColors.textHighlight
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pop(); // Close the dialog
              context.pushReplacement('/login'); // Navigate to the login page
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                  color: AppColors.textHighlight
              ),
            ),
          ),
        ],
      );
    },
  );
}