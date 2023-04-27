import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/screens/screens.dart';
import '../models/models.dart';
import '../providers/google_services_provider.dart';
import 'package:uuid/uuid.dart';

class PublicacionesScreen extends StatefulWidget {
   
  const PublicacionesScreen({Key? key}) : super(key: key);

  @override
  State<PublicacionesScreen> createState() => _PublicacionesScreenState();
}

class _PublicacionesScreenState extends State<PublicacionesScreen> {

  final _goToZonzamasSearchController = TextEditingController();
  final _goFromZonzamasSearchController = TextEditingController();

  final googlePlaceProvider = GoogleServicesProvider();

  Timer? _debounce;

  List<dynamic> goToPlaceList = [];
  List<dynamic> goFromPlaceList = [];

  dynamic _sessionToken;

  @override
  void initState() {
    super.initState();
    _goToZonzamasSearchController.addListener(() {
      _onChangedGoZonzamasToController();
    });
    _goFromZonzamasSearchController.addListener(() {
      _onChangedGoFromZonzamasController();
    });
  }

  _onChangedGoZonzamasToController() async {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = const Uuid().v4();
      });
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      goToPlaceList = await googlePlaceProvider.placeAutocomplete(_goToZonzamasSearchController.text, _sessionToken);
      print('Estoy llamando a la API');
      setState(() {});
    });
  }

  _onChangedGoFromZonzamasController() async {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = const Uuid().v4();
      });
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      goFromPlaceList = await googlePlaceProvider.placeAutocomplete(_goFromZonzamasSearchController.text, _sessionToken);
      print('Estoy llamando a la API');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(text: 'Voy a clase'),
                    Tab(text: 'Salgo de clase'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SearchBar(
                        size: size, 
                        zonzamasSearchController: _goToZonzamasSearchController, 
                        placeList: goToPlaceList,
                        hintText: '¿Desde dónde sales?',
                        imagePath: 'assets/publicaciones1.png',
                        isGoingToZonzamas: true,
                      ),
                      SearchBar(
                        size: size, 
                        zonzamasSearchController: _goFromZonzamasSearchController, 
                        placeList: goFromPlaceList, 
                        hintText: '¿Hacia dónde vas?', 
                        imagePath: 'assets/publicaciones2.png',
                        isGoingToZonzamas: false,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    required this.size,
    required TextEditingController zonzamasSearchController,
    required this.placeList, required this.hintText, required this.imagePath, required this.isGoingToZonzamas,
  }) : _zonzamasSearchController = zonzamasSearchController;

  final Size size;
  final TextEditingController _zonzamasSearchController;
  final List placeList;
  final String hintText;
  final String imagePath;
  final bool isGoingToZonzamas;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {

    final GoogleServicesProvider googlePlaceProvider = GoogleServicesProvider();
    Location? coords;

    return Column(
      children: [
        const SizedBox(height: 10.0),
        Container(                 
          height: widget.size.height * 0.38,
          width:  double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: widget._zonzamasSearchController,
            autofocus: false,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  widget._zonzamasSearchController.clear();
                }, 
                icon: const Icon(Icons.clear)
              ),
              
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.grey,),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Flexible(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.placeList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(widget.placeList[index].description),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () async {
                  await googlePlaceProvider.placeCoordinates(widget.placeList[index].placeId).then(((value) => {
                    coords = value
                  }));
                  if (mounted) {
                    PersistentNavBarNavigator.pushNewScreen(
                      withNavBar: false,
                      context, 
                      screen: PublicarTrayectoScreen(
                      isGoingToZonzamas: widget.isGoingToZonzamas, 
                      zona: widget.placeList[index].description,
                      zonaLat: coords!.lat,
                      zonaLng: coords!.lng,
                      )
                    );
                    FocusScope.of(context).unfocus();
                    widget._zonzamasSearchController.clear();
                  }
                },
              );
            }
          ),
        )
      ],
    );
  }
}