import 'package:cloud_firestore/cloud_firestore.dart';

class AppConstants {
  static CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  static CollectionReference exerciseCollection =
  FirebaseFirestore.instance.collection('exercises');

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
  static List<String> ExerciseList = [
    'ex1 level1',
    'ex1 level2',
    'ex2 level1',
    'ex2 level2',
    'ex3 level1',
    'ex3 level2'
  ];
  static List<String> typeMenu = ['admin', 'patient', 'therapist'];
}
