import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as L;
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';
import 'dart:math';

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
  var location = new L.Location();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS
  var markersID = 0;
  LatLng myLocation =  LatLng(37.4219983,-122.084);
  TextEditingController _distance = new TextEditingController();
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
  void getSomePoints(range,origen, destination) async{
    var permissions = await Permission.getPermissionsStatus([PermissionName.Location]);
    if(permissions[0].permissionStatus == PermissionStatus.notAgain){
      var askpermissions = await Permission.requestPermissions([PermissionName.Location]);
    }else{
      List<LatLng> route;
       await googleMapPolyline.getCoordinatesWithLocation(
          origin: origen,
          destination: destination,
          mode: RouteMode.driving
       ).then((onValue) {
            print("the coordiates");
            routeCoords= onValue;
            print(routeCoords);
      });

    }

    setState(() {
      polyline.add(Polyline(
          polylineId: PolylineId('route'+ range.toString()),
          visible: true,
          points: routeCoords,
          width: 4,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });

  }

  void setPolyLines(totalMiles){

    double segment = totalMiles/4;
    double change_long =change_in_longitude(segment);
    double change_lat = change_in_latitude(segment);
    for( var i = 0 ; i <= 4; i++ ) {
      if(i == 0){
        getSomePoints(i, myLocation, LatLng(myLocation.latitude,myLocation.longitude+change_long ));
      }if(i == 1){
        getSomePoints(i,  LatLng(myLocation.latitude,myLocation.longitude+change_long ), LatLng(myLocation.latitude+change_lat,myLocation.longitude+change_long ));
      }if(i == 3){
        getSomePoints(i, LatLng(myLocation.latitude+change_lat,myLocation.longitude+change_long ), LatLng(myLocation.latitude+change_lat,myLocation.longitude ));
      }if(i == 4){
        getSomePoints(i, LatLng(myLocation.latitude+change_lat,myLocation.longitude ), myLocation);
      }


      
    }

  }
//  return going up north
  double change_in_latitude(miles){
    double earth_radius = 3960.0;
    double radians_to_degrees = 180.0/pi;
//    "Given a distance north, return the change in latitude."
    return  (miles/earth_radius)*radians_to_degrees;
  }
//returns going west
  double change_in_longitude(miles){
    double earth_radius = 3960.0;
    double degrees_to_radians = pi/180.0;
    double radians_to_degrees = 180.0/pi;
    double r = earth_radius*cos(myLocation.longitude*degrees_to_radians);
    return (miles/r)*radians_to_degrees;
  }

  void _getLocation() async {
    try {
      await location.getLocation().then((onValue) {
        myLocation = LatLng(onValue.latitude, onValue.longitude);
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(onValue.latitude, onValue.longitude),
            zoom: 17.0,
          ),
        ));
        print(onValue.latitude.toString() + "," + onValue.longitude.toString());
        final MarkerId markerIdT = MarkerId(markersID.toString());
        final Marker marker = Marker(
          markerId: markerIdT,
          position: LatLng(
            onValue.latitude,
            onValue.longitude,
          ),
          infoWindow: InfoWindow(title: "My Location", snippet: '*'),
        );
        setState(() {
          markers[markerIdT] = marker;
        });

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
                    target: myLocation,
                    zoom: 11.0,
                  ),
                    markers: Set<Marker>.of(markers.values),
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
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: TextField(
                          controller: _distance ,
                          obscureText: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Distance',
                            ),
                          ),
                      ),
                  ),


//                  Flexible(
//                    flex: 2,
//                    child: Container(
//                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
//                      child: TextField(
//                        controller: _endPoint ,
//                        obscureText: false,
//                        decoration: InputDecoration(
//                          border: OutlineInputBorder(),
//                          labelText: 'End Point',
//                        ),
//                      ),
//                    ),
//                  ),
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
                        setPolyLines( double.parse( _distance.text));
                        var change =change_in_latitude(10.0);
                        print(change+myLocation.latitude);
                        var change_long = change_in_longitude(10.0);
                        print(change_long+myLocation.longitude);
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