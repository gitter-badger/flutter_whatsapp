import 'package:async/async.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp/src/config/application.dart';
import 'package:flutter_whatsapp/src/config/routes.dart';
import 'package:flutter_whatsapp/src/screens/camera_screen.dart';
import 'package:flutter_whatsapp/src/tabs/calls_tab.dart';
import 'package:flutter_whatsapp/src/tabs/chats_tab.dart';
import 'package:flutter_whatsapp/src/tabs/status_tab.dart';
import 'package:flutter_whatsapp/src/values/colors.dart';

enum HomeOptions {
  settings,
  // Chats Tab
  newGroup,
  newBroadcast,
  whatsappWeb,
  starredMessages,
  // Status Tab
  statusPrivacy,
  // Calls Tab
  clearCallLog,
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  List<Widget> _actionButtons;
  List<List<PopupMenuItem<HomeOptions>>> _popupMenus;

  int _tabIndex;
  TabController _tabController;
  List<Widget> _tabBars;

  bool _isSearching;
  TextField _searchBar;
  TextEditingController _searchBarController;

  List<Widget> _fabs;

  static final TextStyle _textBold = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  String _searchKeyword = '';

  AsyncMemoizer _memoizerChats = AsyncMemoizer();
  AsyncMemoizer _memoizerStatus = AsyncMemoizer();
  AsyncMemoizer _memoizerCalls = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
    _tabIndex = 1; // Start at second tab.
    _isSearching = false;

    _searchBarController = new TextEditingController();
    _searchBarController.addListener(() {
      setState(() {
        _searchKeyword = _searchBarController.text;
      });
    });

    _searchBar  = new TextField(
      controller: _searchBarController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
      ),
    );
    _tabController = new TabController(
      length: 4,
      initialIndex: _tabIndex,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
        _isSearching = false;
        _searchBarController?.text = "";
      });
    });

    _actionButtons = <Widget>[
      IconButton(
        tooltip: "Search",
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            _isSearching = true;
            _searchBarController?.text = "";
          });
        },
      ),
      PopupMenuButton<HomeOptions>(
        tooltip: "More options",
        onSelected: _selectOption,
        itemBuilder: (BuildContext context) {
          return _popupMenus[_tabIndex];
        },
      ),
    ];

    _tabBars = <Widget>[
      Tab(
        icon: Icon(Icons.camera_alt),
      ),
      Tab(
        child: Text(
          "CHATS",
          style: _textBold,
        ),
      ),
      Tab(
        child: Text(
          "STATUS",
          style: _textBold,
        ),
      ),
      Tab(
        child: Text(
          "CALLS",
          style: _textBold,
        ),
      ),
    ];

    _popupMenus  = [
      null,
      [
        PopupMenuItem<HomeOptions>(
          child: Text("New group"),
          value: HomeOptions.newGroup,
        ),
        PopupMenuItem<HomeOptions>(
          child: Text("New broadcast"),
          value: HomeOptions.newBroadcast,
        ),
        PopupMenuItem<HomeOptions>(
          child: Text("WhatsApp Web"),
          value: HomeOptions.whatsappWeb,
        ),
        PopupMenuItem<HomeOptions>(
          child: Text("Starred messages"),
          value: HomeOptions.starredMessages,
        ),
        PopupMenuItem<HomeOptions>(
          child: Text("Settings"),
          value: HomeOptions.settings,
        ),
      ],
      [
        PopupMenuItem<HomeOptions>(
          child: Text("Status privacy"),
          value: HomeOptions.statusPrivacy,
        ),
        PopupMenuItem<HomeOptions>(
          child: Text("Settings"),
          value: HomeOptions.settings,
        ),
      ],
      [
        PopupMenuItem<HomeOptions>(
          child: Text("Clear call log"),
          value: HomeOptions.clearCallLog,
        ),
        PopupMenuItem<HomeOptions>(
          child: Text("Settings"),
          value: HomeOptions.settings,
        ),
      ],
    ];

    _fabs  = [
      null,
      new FloatingActionButton(
          child: Icon(Icons.message),
          backgroundColor: fabBgColor,
          foregroundColor: Colors.white,
          onPressed: () {
            Application.router.navigateTo(
              context,
              "/chat/new",
              transition: TransitionType.inFromRight,
            );
          }),
      Container(
        height: 150.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new FloatingActionButton(
                heroTag: 'newTextStatus',
                mini: true,
                child: Icon(Icons.edit),
                backgroundColor: Colors.white,
                foregroundColor: fabBgSecondaryColor,
                onPressed: () {
                  Application.router.navigateTo(
                    context,
                    Routes.newTextStatus,
                    transition: TransitionType.inFromRight,
                  );
                }),
            new SizedBox(
              height: 16.0,
            ),
            new FloatingActionButton(
                heroTag: 'newStatus',
                child: Icon(Icons.camera_alt),
                backgroundColor: fabBgColor,
                foregroundColor: Colors.white,
                onPressed: () {
                  Application.router.navigateTo(
                    context,
                    Routes.newStatus,
                    transition: TransitionType.inFromRight,
                  );
                }),
          ],
        ),
      ),
      new FloatingActionButton(
          child: Icon(Icons.add_call),
          backgroundColor: fabBgColor,
          foregroundColor: Colors.white,
          onPressed: () {
            Application.router.navigateTo(
              context,
              Routes.newCall,
              transition: TransitionType.inFromRight,
            );
          }),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _tabIndex == 0
          ? null
        : AppBar(
        backgroundColor: _isSearching
          ? Colors.white
          : null,
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                color: const Color(0xff075e54),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchBarController?.text = "";
                  });
                },
              )
            : null,
        title: _isSearching
            ? _searchBar
            : Text(
                'WhatsApp',
                style: _textBold,
              ),
        actions: _isSearching
            ? null
            : _actionButtons,
        bottom: _isSearching
          ? null
          : TabBar(
            controller: _tabController,
            tabs: _tabBars,
          ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          CameraScreen(),
          ChatsTab(
            searchKeyword: _searchKeyword,
            memoizer: _memoizerChats,
            refresh: () {setState((){_memoizerChats = new AsyncMemoizer();});}
          ),
          StatusTab(
            searchKeyword: _searchKeyword,
            memoizer: _memoizerStatus,
              refresh: () {setState((){_memoizerStatus = new AsyncMemoizer();});}
          ),
          CallsTab(
            searchKeyword: _searchKeyword,
            memoizer: _memoizerCalls,
              refresh: () {setState((){_memoizerCalls = new AsyncMemoizer();});}
          ),
        ],
      ),
      floatingActionButton: _fabs[_tabIndex],
    );
  }

  void _selectOption(HomeOptions option) {
    switch(option) {
      case HomeOptions.newGroup:
        Application.router.navigateTo(
          context,
          Routes.newChatGroup,
          transition: TransitionType.inFromRight,
        );
        break;
      case HomeOptions.newBroadcast:
        Application.router.navigateTo(
          context,
          Routes.newChatBroadcast,
          transition: TransitionType.inFromRight,
        );
        break;
      case HomeOptions.whatsappWeb:
        Application.router.navigateTo(
          context,
          Routes.whatsappWeb,
          transition: TransitionType.inFromRight,
        );
        break;
      case HomeOptions.starredMessages:
        Application.router.navigateTo(
          context,
          Routes.starredMessages,
          transition: TransitionType.inFromRight,
        );
        break;
      case HomeOptions.settings:
        Application.router.navigateTo(
          context,
          Routes.settings,
          transition: TransitionType.inFromRight,
        );
        break;
      case HomeOptions.statusPrivacy:
        Application.router.navigateTo(
          context,
          Routes.statusPrivacy,
          transition: TransitionType.inFromRight,
        );
        break;
      case HomeOptions.clearCallLog:
        Application.router.navigateTo(
          context,
          Routes.clearCallLog,
          transition: TransitionType.inFromRight,
        );
        break;
    }
  }
}
