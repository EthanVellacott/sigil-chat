import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sigil/data/auth.dart';
import 'package:sigil/data/friends.dart';
import 'package:sigil/routes/chat.dart';
import 'package:sigil/widgets.dart';

/// Home screen handles guiding the user to other relevant parts of the app including:
/// - Adding users to their friends list
/// - Checking their friend invites
/// - Starting a chat with a friend
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Friends"),
          actions: [
            StreamBuilder(
              stream: _friendService.getInviteStream(),
              builder: (context, snapshot) {
                Widget result = ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/invites'),
                    icon: const Icon(Icons.contacts_outlined),
                    label: const Text('Invites'));
                if (snapshot.hasError) {
                  return result;
                }

                final snapshotData = snapshot.data;
                if (snapshotData == null) {
                  return result;
                }

                if (snapshotData.docs.isNotEmpty) {
                  result = Badge(child: result);
                }
                return result;
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _authService.signOut(),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildUserList(context)),
            Container(
                padding: const EdgeInsets.all(30),
                child: SigilEntryButton(
                    onPress: () => _dialogueInvite(context),
                    text: "Add Friends",
                    leadingIcon: const Icon(Icons.add)))
          ],
        ));
  }

  void _dialogueInvite(BuildContext context) async {
    final inviteController = TextEditingController();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Send Invite'),
                content: SigilEntryField(
                  controller: inviteController,
                  hintText: "Email",
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL')),
                  TextButton(
                      // TODO remedy async gap
                      onPressed: () async {
                        // exit early if text is empty
                        if (inviteController.text.isEmpty) {
                          return;
                        }
                        final result = await _friendService
                            .sendInvite(inviteController.text);
                        switch (result) {
                          case InviteErrors.success:
                            Navigator.pop(context);
                            break;
                          case InviteErrors.noneExist:
                            await showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                    title: Text('User does not exist')));
                            break;
                          case InviteErrors.alreadyFriends:
                            await showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                    title: Text('User is already a friend')));
                            break;
                          case InviteErrors.alreadyInvited:
                            // In this case, just let the user think a new invite is sent.
                            Navigator.pop(context);
                            break;
                          default:
                        }
                      },
                      child: const Text('SUBMIT'))
                ]));
  }

  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
        // stream: _chatService.getUsersStream(),
        stream: _friendService.getFriendStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // return const Text("Loading...");
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No friends... yet!"));
          }

          return ListView(
            padding: const EdgeInsets.only(top: 15),
            children: snapshot.data!.docs
                .map<Widget>(
                    (userData) => _buildUserListItem(context, userData))
                .toList(),
          );
        });
  }

  Widget _buildUserListItem(BuildContext context, DocumentSnapshot userData) {
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
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(
                                subjectEmail: subjectEmail,
                                subjectID: subjectID,
                              )));
                },
                child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 10),
                        Text(subjectEmail)
                      ],
                    )))));
  }
}
