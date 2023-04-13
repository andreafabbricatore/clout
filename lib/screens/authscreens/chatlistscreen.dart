import 'package:clout/components/chat.dart';
import 'package:clout/components/chatlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/authscreens/chatroomscreen.dart';
import 'package:clout/services/db.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  ChatListScreen(
      {super.key,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics,
      required this.returnHome});
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  final Function() returnHome;
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Chat> chatlist = [];
  db_conn db = db_conn();
  TextEditingController searchcontroller = TextEditingController();
  bool searching = false;
  Color suffixiconcolor = Colors.white;
  List<AppUser> searchedusers = [];

  void displayErrorSnackBar(
    String error,
  ) {
    final snackBar = SnackBar(
      content: Text(
        error,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 48, 117),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
      closeIconColor: Colors.white,
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getchatlist() async {
    List<Chat> chats = [];
    try {
      List<Chat> chats = await db.getChatsfromUserUID(widget.curruser.uid);
      setState(() {
        chatlist = chats.reversed.toList();
      });
    } catch (e) {
      displayErrorSnackBar("Could not retrieve chats");
    }
  }

  Future<void> refresh() async {
    try {
      AppUser curruser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = curruser;
      });
      db.resetchatnotificationcounter(widget.curruser.uid);
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
    await getchatlist();
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> chatnavigate(Chat chat, int index) async {
      await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ChatRoomScreen(
                    chatinfo: chat,
                    curruser: widget.curruser,
                    curruserlocation: widget.curruserlocation,
                    analytics: widget.analytics,
                  ),
              settings: RouteSettings(name: "ChatRoomScreen")));
      refresh();
    }

    Future<void> userchatinteract(AppUser user, int index) async {
      bool userchatexists =
          await db.checkuserchatexists(widget.curruser, user.uid);
      print(userchatexists);
      if (!userchatexists) {
        await db.createuserchat(widget.curruser, user.uid);
      }
      Chat userchat =
          await db.getUserChatFromParticipants(widget.curruser, user.uid);

      await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ChatRoomScreen(
                    chatinfo: userchat,
                    curruser: widget.curruser,
                    curruserlocation: widget.curruserlocation,
                    analytics: widget.analytics,
                  ),
              settings: RouteSettings(name: "ChatRoomScreen")));
      setState(() {
        searching = false;
        suffixiconcolor = Colors.white;
        searchedusers = [];
      });
      //error?
      await db.setuserchatvisibility(
          widget.curruser, user.uid, userchat.chatid);
      searchcontroller.clear();
      FocusScope.of(context).unfocus();
      refresh();
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            title: Text(
              widget.curruser.username,
              textScaleFactor: 1.0,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            elevation: 0.0,
            leading: GestureDetector(
              onTap: () {
                widget.returnHome.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )),
        body: CustomRefreshIndicator(
          onRefresh: refresh,
          builder: (context, child, controller) {
            return Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: controller.value * screenheight * 0.1,
                  width: screenwidth,
                ),
                child
              ],
            );
          },
          child: Column(children: [
            Center(
              child: Focus(
                onFocusChange: (hasfocus) {
                  if (hasfocus) {
                    setState(() {
                      searching = hasfocus;
                      suffixiconcolor = Colors.grey;
                    });
                  }
                },
                child: SizedBox(
                  width: screenwidth * 0.9,
                  child: TextField(
                    controller: searchcontroller,
                    onChanged: (String searchquery) async {
                      try {
                        List<AppUser> res = await db.searchUsers(
                            searchquery.trim(), widget.curruser);
                        setState(() {
                          searchedusers = res;
                        });
                      } catch (e) {
                        displayErrorSnackBar("Could not search users");
                      }
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: GestureDetector(
                            onTap: searching
                                ? () {
                                    if (searchcontroller.text.isNotEmpty) {
                                      searchcontroller.clear();
                                    } else {
                                      setState(() {
                                        searching = false;
                                        suffixiconcolor = Colors.white;
                                        searchedusers = [];
                                      });
                                      FocusScope.of(context).unfocus();
                                    }
                                  }
                                : null,
                            child: Icon(Icons.close, color: suffixiconcolor)),
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        )),
                  ),
                ),
              ),
            ),
            !searching
                ? chatlist.isNotEmpty
                    ? ChatListView(
                        chatlist: chatlist,
                        screenwidth: screenwidth,
                        onTap: chatnavigate,
                        curruser: widget.curruser,
                      )
                    : Container()
                : UserListView(
                    userres: searchedusers,
                    onTap: userchatinteract,
                    curruser: widget.curruser,
                    screenwidth: screenwidth,
                    showcloutscore: false,
                    showrembutton: false,
                  )
          ]),
        ));
  }
}
