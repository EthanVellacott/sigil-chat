import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This manages the basic functions for listing Friends and handling Invites
class FriendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  /// Get a stream of the current users friends.
  Stream<QuerySnapshot> getFriendStream() {
    final currentID = _auth.currentUser!.uid;
    return _store
        .collection("Connections")
        .doc(currentID)
        .collection("friends")
        .orderBy("email", descending: false)
        .snapshots();
  }

  /// Get a stream of the current users invites.
  Stream<QuerySnapshot> getInviteStream() {
    final currentID = _auth.currentUser!.uid;
    return _store
        .collection("Connections")
        .doc(currentID)
        .collection("invites")
        .orderBy("email", descending: false)
        .snapshots();
  }

  /// Send an invite from current user to user with target email.
  /// Returns success.
  Future<InviteErrors> sendInvite(String targetEmail) async {
    // current creds
    final currentID = _auth.currentUser!.uid;
    final currentEmail = _auth.currentUser!.email;

    // get target user id
    final targetID = await getUserIDByEmail(targetEmail);
    if (targetID == null) {
      return InviteErrors.noneExist;
    }

    // prevent double ups
    if (await hasFriend(currentID, targetID)) {
      return InviteErrors.alreadyFriends;
    }
    final existingInvites = await _store
        .collection("Connections")
        .doc(targetID)
        .collection("invites")
        .where('uid', isEqualTo: currentID)
        .get();
    if (existingInvites.docs.isNotEmpty) {
      return InviteErrors.alreadyInvited;
    }

    // add invite
    _store
        .collection("Connections")
        .doc(targetID)
        .collection("invites")
        .add({'uid': currentID, 'email': currentEmail});
    return InviteErrors.success;
  }

  /// Accept an invite, adding the respective users as friends.
  Future<void> acceptInvite(
      String inviteID, String targetID, String targetEmail) async {
    // current creds
    final currentID = _auth.currentUser!.uid;
    final currentEmail = _auth.currentUser!.email;

    // TODO batch the transaction below
    // remove invite
    _store
        .collection("Connections")
        .doc(currentID)
        .collection("invites")
        .doc(inviteID)
        .delete();

    // add to respective friend ledgers
    if (!await hasFriend(targetID, currentID)) {
      _store
          .collection("Connections")
          .doc(targetID)
          .collection("friends")
          .add({'uid': currentID, 'email': currentEmail});
    }
    if (!await hasFriend(currentID, targetID)) {
      _store
          .collection("Connections")
          .doc(currentID)
          .collection("friends")
          .add({'uid': targetID, 'email': targetEmail});
    }
  }

  /// Dismiss an invite.
  Future<void> dismissInvite(String inviteID) async {
    // current creds
    final currentID = _auth.currentUser!.uid;

    // remove invite
    _store
        .collection("Connections")
        .doc(currentID)
        .collection("invites")
        .doc(inviteID)
        .delete();
  }

  /// Check if userA has friend userB by ID/uid
  Future<bool> hasFriend(String userA, String userB) async {
    final result = await _store
        .collection("Connections")
        .doc(userA)
        .collection("friends")
        .where('uid', isEqualTo: userB)
        .get();
    if (result.docs.isEmpty) {
      return false;
    }
    return true;
  }

  /// Check if user exists, and return their ID if possible.
  Future<String?> getUserIDByEmail(String userEmail) async {
    final query =
        _store.collection("Users").where('email', isEqualTo: userEmail);
    final result = await query.get();

    if (result.docs.isEmpty) {
      return null;
    }

    // assumed target
    final target = result.docs.first;
    return target['uid'];
  }
}

enum InviteErrors {
  success, // no issues
  noneExist, // email not connected to account
  alreadyFriends, // email already connected to a friend account
  alreadyInvited // user has already been sent an invite
}
