import 'package:clout/defs/chat.dart';
import 'package:clout/models/chatlistview.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/models/userlistview.dart';
import 'package:clout/screens/authscreens/chatroomscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
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
  applogic logic = applogic();

  Future<void> getchatlist() async {
    List<Chat> chats = [];
    try {
      List<Chat> chats = await db.getChatsfromUserUID(widget.curruser.uid);
      setState(() {
        chatlist = chats.reversed.toList();
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not retrieve chats", context);
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
      logic.displayErrorSnackBar("Could not refresh", context);
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

    Future<void> userchatinteract(AppUser user) async {
      bool userchatexists =
          await db.checkuserchatexists(widget.curruser.uid, user.uid);

      if (!userchatexists) {
        await db.createuserchat(widget.curruser, user.uid);
      }
      Chat userchat =
          await db.getUserChatFromParticipants(widget.curruser.uid, user.uid);

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
            chatlistsearchbar(screenwidth, context),
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
                    showsendbutton: false,
                    showfriendbutton: false,
                  )
          ]),
        ));
  }

  Center chatlistsearchbar(double screenwidth, BuildContext context) {
    return Center(
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
                List<AppUser> res =
                    await db.searchUsers(searchquery.trim(), widget.curruser);
                setState(() {
                  searchedusers = res;
                });
              } catch (e) {
                logic.displayErrorSnackBar("Could not search users", context);
              }
            },
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                )),
          ),
        ),
      ),
    );
  }
}
