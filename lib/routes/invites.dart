import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sigil/data/auth.dart';
import 'package:sigil/data/friends.dart';
import 'package:sigil/widgets.dart';

/// A simple screen to check the current users invites
class InviteScreen extends StatelessWidget {
  InviteScreen({super.key});

  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Invites")),
        body: _buildInvitesList(context));
  }

  Widget _buildInvitesList(BuildContext context) {
    return StreamBuilder(
        stream: _friendService.getInviteStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No invites... yet!"));
          }

          return ListView(
            padding: const EdgeInsets.only(top: 15),
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildInvitesListItem(context, doc))
                .toList(),
          );
        });
  }

  Widget _buildInvitesListItem(
      BuildContext context, DocumentSnapshot userData) {
    final inviteID = userData.id;
    final subjectEmail = userData['email'];
    final subjectID = userData['uid'];

    if (subjectEmail == _authService.getCurrentUser()!.email) {
      return const SizedBox.shrink();
    }

    return Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        clipBehavior: Clip.antiAlias,
        child: Container(
            // decoration:
            //     BoxDecoration(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 10),
                Text(subjectEmail),
                const Spacer(),
                SigilEntryButton(
                    text: "Accept",
                    onPress: () {
                      _friendService.acceptInvite(
                          inviteID, subjectID, subjectEmail);
                    }),
                const SizedBox(width: 10),
                SigilEntryButton(
                    text: "Dismiss",
                    onPress: () {
                      _friendService.dismissInvite(inviteID);
                    },
                    color: Colors.blueGrey)
              ],
            )));
  }
}
