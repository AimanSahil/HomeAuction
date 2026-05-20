import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getAuctions() {
    return _firestore.collection('auctions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'title': data['title'] ?? '',
          'price': data['price'] ?? 0,
          'image': data['image'] ?? '',
          'address': data['address'] ?? '',
          'endTime': data['endTime'],
          'status': data['status'] ?? 'live',
          'users': data['users'] ?? [],
        };
      }).toList();
    });
  }
}