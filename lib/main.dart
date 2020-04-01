import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as L;
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}



class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MyMapState();
}

class MyMapState extends State<MapSample> {
  GoogleMapController mapController;

  LatLng _center =  LatLng(37.4219983,-122.084);
  TextEditingController _startPoint = new TextEditingController();
  TextEditingController _endPoint = new TextEditingController();

  Set<Polyline> polyline = {};
  List<LatLng> routeCoords;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {

    setState(() {
      mapController = controller;
//      polyline.add(Polyline(
//          polylineId: PolylineId('route1'),
//          visible: true,
//          points: routeCoords,
//          width: 4,
//          color: Colors.blue,
//          startCap: Cap.roundCap,
//          endCap: Cap.buttCap));
    }
    );
    

  }
  void getSomePoints() async{
    var permissions = await Permission.getPermissionsStatus([PermissionName.Location]);
    if(permissions[0].permissionStatus == PermissionStatus.notAgain){
      var askpermissions = await Permission.requestPermissions([PermissionName.Location]);
    }else{

//      getCoordinatesWithLocation
      routeCoords= await googleMapPolyline.getPolylineCoordinatesWithAddress(
          origin: '1600 Amphitheatre Pkwy, Mountain View, CA 94043',
          destination: '1401 N Shoreline Blvd, Mountain View, CA 94043',
          mode: RouteMode.driving);
      print(routeCoords.length);
      print(routeCoords);
      print("\t  the size of the lines");


    }

    setState(() {
      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: routeCoords,
          width: 4,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });

  }



  void _getLocation() async {
    var location = new L.Location();
    try {
      await location.getLocation().then((onValue) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(onValue.latitude, onValue.longitude),
            zoom: 17.0,
          ),
        ));
        print(onValue.latitude.toString() + "," + onValue.longitude.toString());
      });
    } catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        var askpermissions = await Permission.requestPermissions([PermissionName.Location]);
      }
    }
  }





  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home:

      Scaffold(
          appBar: AppBar(
            title: Text('Runout'),
            backgroundColor: Colors.green[700],
          ),
          body:
          Column(
            children: <Widget>[
              Text('Deliver features faster'),
              Text('Craft beautiful UIs'),
              Flexible(
                flex: 2,
                child:
                GoogleMap(
                  polylines: polyline,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                  ),
                ),

              ),

              Flexible(
                flex: 1,
                child:
                Row(children: <Widget>[
                  Flexible(
                      flex: 1,
                      child: Container(
                        child: Text('Enter range'),
                      ),
                  ),
                  Flexible(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: TextField(
                          controller: _startPoint ,
                          obscureText: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Start Point',
                            ),
                          ),
                      ),
                  ),


                  Flexible(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextField(
                        controller: _endPoint ,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'End Point',
                        ),
                      ),
                    ),
                  ),
                ]),
          ),

              Flexible(
                child:
                    Row(children: <Widget>[

                  Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),

                      child:
                    FlatButton(

                      color: Colors.blue,
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.blueAccent,
                      onPressed: () {
                        getSomePoints();

                      },
                      child: Text(
                        "Find me a route",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    )
                  ),

                      Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 20.0),

                          child:
                          FlatButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.black,
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.blueAccent,
                            onPressed: () {
                              _getLocation();
                            },
                            child: Text(
                              "Find Me",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          )
                      )
              ])
              )
            ],
          )
      ),
    );
  }
}




//
//import 'package:flutter/material.dart';
//import 'package:google_map_polyline/google_map_polyline.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:permission/permission.dart';
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      home: MyHomePage(),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  final Set<Polyline> polyline = {};
//
//  GoogleMapController _controller;
//  List<LatLng> routeCoords;
//  GoogleMapPolyline googleMapPolyline =
//  new GoogleMapPolyline(apiKey: "AIzaSyDFphgQHYwYhst9ZGNfkct-5ZAxF6GWQdI");
//
//  getsomePoints() async {
//    var permissions =
//    await Permission.getPermissionsStatus([PermissionName.Location]);
//    if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
//      var askpermissions = await Permission.requestPermissions([PermissionName.Location]);
//    } else {
//      routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
//          origin: LatLng(40.6782, -73.9442),
//          destination: LatLng(40.6944, -73.9212),
//          mode: RouteMode.driving);
//    }
//  }
//
//  getaddressPoints() async {
//    routeCoords = await googleMapPolyline.getPolylineCoordinatesWithAddress(
//        origin: '55 Kingston Ave, Brooklyn, NY 11213, USA',
//        destination: '178 Broadway, Brooklyn, NY 11211, USA',
//        mode: RouteMode.driving);
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    getaddressPoints();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        body:
//
//
//         GoogleMap(
//          onMapCreated: onMapCreated,
//          polylines: polyline,
//          initialCameraPosition:
//          CameraPosition(target: LatLng(40.6782, -73.9442), zoom: 14.0),
//          mapType: MapType.normal,
//        ));
//  }
//
//  void onMapCreated(GoogleMapController controller) {
//    setState(() {
//      _controller = controller;
//      print(routeCoords);
//      polyline.add(Polyline(
//          polylineId: PolylineId('route1'),
//          visible: true,
//          points: routeCoords,
//          width: 4,
//          color: Colors.blue,
//          startCap: Cap.roundCap,
//          endCap: Cap.buttCap));
//    });
//  }
//}