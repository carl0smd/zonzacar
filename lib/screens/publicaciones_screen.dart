import 'package:flutter/material.dart';
import 'package:zonzacar/screens/screens.dart';
import '../providers/google_places_provider.dart';
import 'package:uuid/uuid.dart';

class PublicacionesScreen extends StatefulWidget {
   
  const PublicacionesScreen({Key? key}) : super(key: key);

  @override
  State<PublicacionesScreen> createState() => _PublicacionesScreenState();
}

class _PublicacionesScreenState extends State<PublicacionesScreen> {

  final _goToZonzamasSearchController = TextEditingController();
  final _goFromZonzamasSearchController = TextEditingController();

  final googlePlaceProvider = GooglePlacesProvider();

  List<dynamic> goToPlaceList = [];
  List<dynamic> goFromPlaceList = [];

  var _sessionToken;

  @override
  void initState() {
    super.initState();
    _goToZonzamasSearchController.addListener(() {
      _onChangedGoToController();
    });
    _goFromZonzamasSearchController.addListener(() {
      _onChangedGoFromController();
    });
  }

  _onChangedGoToController() async {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = const Uuid().v4();
      });
    }
    goToPlaceList = await googlePlaceProvider.placeAutocomplete(_goToZonzamasSearchController.text, _sessionToken);
    setState(() {});
  }

  _onChangedGoFromController() async {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = const Uuid().v4();
      });
    }
    goFromPlaceList = await googlePlaceProvider.placeAutocomplete(_goFromZonzamasSearchController.text, _sessionToken);
    setState(() {});
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
                        goToZonzamasSearchController: _goToZonzamasSearchController, 
                        placeList: goToPlaceList,
                        hintText: '¿Desde dónde sales?',
                        imagePath: 'assets/publicaciones1.png',
                        isGoingToZonzamas: true,
                      ),
                      SearchBar(
                        size: size, 
                        goToZonzamasSearchController: _goFromZonzamasSearchController, 
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

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.size,
    required TextEditingController goToZonzamasSearchController,
    required this.placeList, required this.hintText, required this.imagePath, required this.isGoingToZonzamas,
  }) : _goToZonzamasSearchController = goToZonzamasSearchController;

  final Size size;
  final TextEditingController _goToZonzamasSearchController;
  final List placeList;
  final String hintText;
  final String imagePath;
  final bool isGoingToZonzamas;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(                 
          height: size.height * 0.38,
          width:  double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: _goToZonzamasSearchController,
            autofocus: false,
            showCursor: false,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _goToZonzamasSearchController.clear();
                }, 
                icon: const Icon(Icons.clear)
              ),
              hintText: hintText,
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
            itemCount: placeList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(placeList[index].description),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PublicarTrayectoScreen(isGoingToZonzamas: isGoingToZonzamas,)));
                  print('Voy a air desde ${placeList[index].description} hasta el CIFP Zonzamas');
                },
              );
            }
          ),
        )
      ],
    );
  }
}