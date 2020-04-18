import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as L;
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';
import 'dart:math';
import 'TextBox.dart';
import 'Settings.dart';
import 'models/pin_pill_info.dart';

void main() => runApp(MyApp());

enum WhyFather { harder, smarter, selfStarter, tradingCenter}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RunOut',
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

  bool typing = false;
  static TextEditingController _distance = new TextEditingController();
  TextBox distance = new TextBox(_distance);


  static LatLng myLocation =  LatLng(39.8283,-98.5795);


  Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  List<bool> _selectionStartPoint;
  List<bool> _selectionKlMi;

  @override
  void initState() {
    // TODO: implement initState
    _selectionKlMi = [true, false];
    _selectionStartPoint = [true, false, false, false];

    _getLocation();
    super.initState();


  }

  void setInitialLocation() async {
    try {
      await location.getLocation().then((onValue) {
        myLocation = LatLng(onValue.latitude, onValue.longitude);
        print(onValue.latitude.toString() + "," + onValue.longitude.toString());

      });
    } catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        var askpermissions = await Permission.requestPermissions([PermissionName.Location]);
      }
    }

  }



  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);

    setState(() {
      mapController = controller;
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
          mode: RouteMode.walking
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
    _getLocation();
    final MarkerId markerIdT = MarkerId(markersID.toString());
    final Marker marker = Marker(
      markerId: markerIdT,
      position: LatLng(
        myLocation.latitude,
        myLocation.longitude,
      ),
      infoWindow: InfoWindow(title: "My Location", snippet: '*'),
    );
    setState(() {
      markers[markerIdT] = marker;
    });
    double segment = totalMiles/4;
    double change_long =change_in_longitude(segment);
    double change_lat = change_in_latitude(segment);
    print("change latitude " + change_lat.toString());
    print("change long " + change_long.toString());

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
        print(onValue.latitude.toString() + "," + onValue.longitude.toString());
      });
    } catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        var askpermissions = await Permission.requestPermissions([PermissionName.Location]);
      }
    }
  }



  void createPolyLines(miles){
    print("creating the lines");
    setPolyLines(3);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        home:

        Scaffold(
//          appBar: AppBar(
//            title: Text('Runout'),
//            backgroundColor: Colors.green[700],
//          ),
            appBar: AppBar(
              title: typing ? distance : Text("BikeOut"),
              leading: IconButton(
                icon: Icon(typing ? Icons.done : Icons.search),
                onPressed: () {
                  setState(() {
                    polyline.clear();
                    typing = !typing;
                  });
                  if(typing == false){
                    setPolyLines( double.parse( _distance.text));
                  }
                  },
              ),
              actions: <Widget>[
//                new IconButton(icon: Icon(Icons.settings), onPressed: _pushSave),
                new IconButton(icon: Icon(Icons.settings), onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings(_selectionKlMi,_selectionStartPoint)),
                  );
                }),
              ],
            ),

            body:

            Column(
                children: <Widget>[


                  Flexible(
                    child:
                    GoogleMap(
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        polylines: polyline,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: myLocation,
                          zoom: 2.0,
                        )
                    ),

                  ),

            FlatButton(

                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () {
                  print("kilo meters and miles");
                  print(_selectionKlMi);
                  print("Starting point");
                  print(_selectionStartPoint);
                },
                child: Text(
                  "Find me a route",
                  style: TextStyle(fontSize: 20.0),
                ),
              )

        ])
        )
    );
  }
}



class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}





