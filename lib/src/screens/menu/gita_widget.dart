import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_frontend/src/providers/gita_provider.dart';
import 'package:vedanta_frontend/src/screens/detail_sloka_screen.dart';
import 'package:vedanta_frontend/src/screens/search_sloka_screen.dart';
import 'package:vedanta_frontend/src/widgets/gita_card_widget.dart';

class GitaWidget extends StatefulWidget {
  const GitaWidget({super.key});

  @override
  State<GitaWidget> createState() => _GitaWidgetState();
}

class _GitaWidgetState extends State<GitaWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<dynamic> _babList = [];
  final List<dynamic> _slokaList = [];
  int? _currentBab = 1;
  late Future<void> _futureBabList = Future.value();
  late Future<void> _futureSlokaList = Future.value();
  // late Future<Map<String, dynamic>> _futureBacaanTerakhir = Future.value({});

  @override
  void initState() {
    super.initState();
    _futureBabList = _getBabList();
    _futureSlokaList = _getSlokaList(_currentBab!);
    // _futureBacaanTerakhir = _getBacaanTerakhir();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getBabList() async {
    final gitaProvider = Provider.of<GitaProvider>(context, listen: false);
    final response = await gitaProvider.getGita();
    setState(() {
      _babList.clear();
      for (var i = 0; i < response['babs'].length; i++) {
        _babList.add(response['babs'][i]);
      }
    });
  }

  Future<void> _getSlokaList(int bab) async {
    final gitaProvider = Provider.of<GitaProvider>(context, listen: false);
    final response = await gitaProvider.getGitaSlokas(bab);
    setState(() {
      _slokaList.clear();
      for (var i = 0; i < response['slokas'].length; i++) {
        _slokaList.add(response['slokas'][i]);
      }
    });
  }

  // Future<Map<String, dynamic>> _getBacaanTerakhir() async {
  //   final gitaProvider = Provider.of<GitaProvider>(context, listen: false);
  //   final response = await gitaProvider.getBacaanTerakhir();
  //   setState(() {
  //     _futureBacaanTerakhir = response['bacaan'];
  //   });
  //   return response;
  // }

  @override
  Widget build(BuildContext context) {
    final gitaProvider = Provider.of<GitaProvider>(context, listen: false);

    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        final response = await gitaProvider
                            .searchSlokas(_controller.text.trim());
                        if (response['error']) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(response['message']),
                            backgroundColor: Colors.red,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Sloka found'),
                            backgroundColor: Colors.green,
                          ));
                          // navigate to detail sloka screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchSlokaScreen(
                                slokas: response['gitas'],
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              FutureBuilder(
                future: gitaProvider.getBacaanTerakhir(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return GitaCardWidget(
                      headerText: 'Bacaan Terakhir',
                      subHeaderText:
                          "BAB ${snapshot.data!['bacaan']['babNumber']} : SLOKA ${snapshot.data!['bacaan']['slokaNumber']}",
                      text: snapshot.data!['bacaan']['babTitle'],
                      buttonText: 'Lanjutkan Membaca',
                    );
                  }
                },
              ),
              // GitaCardWidget(
              //   headerText: 'Bacaan Terakhir',
              //   subHeaderText: "BAB 1 : SLOKA 1",
              //   text: 'Arjuna Visada Yoga',
              //   buttonText: 'Lanjutkan Membaca',
              // ),
              const SizedBox(height: 20),
              // Tab widget
              Expanded(
                child: FutureBuilder<void>(
                  future: _futureBabList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: [
                                // Dropdown menu for bab
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: DropdownButton<int>(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    underline: Container(),
                                    value: _currentBab,
                                    items: _babList.map((e) {
                                      print(e);
                                      return DropdownMenuItem<int>(
                                        value: _babList.indexOf(e) + 1,
                                        child: Text('BAB ${e['number']}'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _currentBab = value;
                                        _futureSlokaList =
                                            _getSlokaList(value!);
                                      });
                                    },
                                  ),
                                ),
                                const Tab(
                                  text: 'Favorit',
                                ),
                              ],
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.purple,
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // List view for sloka
                                  FutureBuilder<void>(
                                    future: _futureSlokaList,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else {
                                        return ListView.builder(
                                          itemCount: _slokaList.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailSlokaScreen(
                                                                bab:
                                                                    _currentBab!,
                                                                sloka: _slokaList[
                                                                        index][
                                                                    'number'])));
                                              },
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  image: const DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                        'lib/assets/images/order_icon.png'),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${index + 1}",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                'Sloka ${index + 1}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  "Bacaan Sloka ${_slokaList[index]['number']}"),
                                              trailing: InkWell(
                                                onTap: () async {
                                                  // Add to favorite
                                                  final gitaProvider =
                                                      Provider.of<GitaProvider>(
                                                          context,
                                                          listen: false);
                                                  final response =
                                                      await gitaProvider
                                                          .likeSloka(
                                                              _currentBab!,
                                                              _slokaList[index]
                                                                  ['number']);
                                                  if (response['error']) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          response['message']),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ));
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Sloka added to favorite'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ));
                                                    setState(() {
                                                      _slokaList[index]
                                                          ['isLiked'] = true;
                                                    });
                                                  }
                                                },
                                                child: _slokaList[index]
                                                        ['isLiked']
                                                    ? const Icon(
                                                        Icons.favorite,
                                                        color:
                                                            Colors.pinkAccent,
                                                      )
                                                    : const Icon(
                                                        Icons.favorite_border,
                                                        color: Colors.grey,
                                                      ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                  // List view for favorit
                                  FutureBuilder<void>(
                                    future: _futureSlokaList,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else {
                                        // only show liked sloka
                                        final likedSlokaList = _slokaList
                                            .where((e) => e['isLiked'] == true)
                                            .toList();
                                        return ListView.builder(
                                          itemCount: likedSlokaList.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailSlokaScreen(
                                                                bab:
                                                                    _currentBab!,
                                                                sloka: _slokaList[
                                                                        index][
                                                                    'number'])));
                                              },
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  image: const DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                        'lib/assets/images/order_icon.png'),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${index + 1}",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                'Sloka ${index + 1}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  "Bacaan Sloka ${_slokaList[index]['number']}"),
                                              trailing: InkWell(
                                                onTap: () async {
                                                  // Add to favorite
                                                  final gitaProvider =
                                                      Provider.of<GitaProvider>(
                                                          context,
                                                          listen: false);
                                                  final response =
                                                      await gitaProvider
                                                          .likeSloka(
                                                              _currentBab!,
                                                              _slokaList[index]
                                                                  ['number']);
                                                  if (response['error']) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          response['message']),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ));
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Sloka added to favorite'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ));
                                                    setState(() {
                                                      _slokaList[index]
                                                          ['isLiked'] = true;
                                                    });
                                                  }
                                                },
                                                child: _slokaList[index]
                                                        ['isLiked']
                                                    ? const Icon(
                                                        Icons.favorite,
                                                        color:
                                                            Colors.pinkAccent,
                                                      )
                                                    : const Icon(
                                                        Icons.favorite_border,
                                                        color: Colors.grey,
                                                      ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
