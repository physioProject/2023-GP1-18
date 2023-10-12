import 'package:cloud_firestore/cloud_firestore.dart';

class AppConstants {
  static CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');

  static String typeIsTherapist = 'therapist';
  static String typeIsPatient = 'patient';
  static String typeIsAdmin = 'admin';

  static List<String> conditionMenu = [
    'Thoracic outlet syndrome',
    'Cervical disc bulge',
    'Frozen shoulder',
    'Tennis elbow',
    'Golfer’s elbow',
    'Carpel tunnel',
    'Shoulder impingement syndrome',
    'Shoulder recurrent dislocation'
  ];
  static List<String> typeMenu = ['admin', 'patient', 'therapist'];

}