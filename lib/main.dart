import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as L;
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';
import 'dart:math';
import 'TextBox.dart';
import 'Settings.dart';
import 'models/pin_pill_info.dart';
import 'components/map_pin_pill.dart';
import 'package:string_validator/string_validator.dart';

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
  double _pathDistance = 0;


  static LatLng myLocation =  LatLng(39.8283,-98.5795);
  PinInformation currentlySelectedPin = PinInformation(pinPath: '', avatarPath: '', location: LatLng(0, 0), locationName: '', labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(apiKey: "AIzaSyDFphgQHYwYhst9ZGNfkct-5ZAxF6GWQdI");
  List<bool> _selectionStartPoint;
  List<bool> _selectionKlMi;
  double pinPillPosition = -100;


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




  double distanceRoute(start,finish){
    double latDis = finish.latitude - start.latitude;
    double lonDis = finish.longitude - start.longitude;

    double R = 3960.0;
    double a = pow(sin( (   ( ( latDis*pi)/180 ) )/2),2)+ cos(start.latitude) * cos(finish.latitude) * pow(sin(  ( ( lonDis*pi)/180 ) /2),2);
    double c = 2 * atan2( sqrt(a), sqrt(1-a) );
    double d = R * c ;
    return d;


  }
  
  Future getSomePoints(range,origen, destination) async{
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
//        print("the coordiates");
        routeCoords= onValue;
//        print(routeCoords);
        for( var i = 0 ; i < routeCoords.length-1; i++ ) {
          _pathDistance=_pathDistance+distanceRoute(routeCoords[i],routeCoords[i+1]);
        }
        return _pathDistance;


      });

    }
//    for( var i = 0 ; i < routeCoords.length-1; i++ ) {
//      _pathDistance=_pathDistance+distanceRoute(routeCoords[i],routeCoords[i+1]);
//    }
//    print("number of " + _pathDistance.toString());

    /// change this to add the distance
//    currentlySelectedPin = sourcePinInfo;
//    pinPillPosition = 0;

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

  void setPolyLines(totalMiles) async{
    if (_selectionKlMi[0] == true){
      totalMiles = totalMiles*00.621371;
    }
    _getLocation();

    sourcePinInfo = PinInformation(
        locationName: "Start Location",
        location: myLocation,
        pinPath: "assets/driving_pin.png",
        avatarPath: "assets/friend1.jpg",
        labelColor: Colors.blueAccent
    );

    setState(() {


//      markers[MarkerId(markersID.toString())] = marker;
    });
    double segment = totalMiles/4;
    double change_long =change_in_longitude(segment);
    double change_lat = change_in_latitude(segment);

    if(_selectionStartPoint[1] == true ){
      change_lat= change_lat*-1;
    }else if (_selectionStartPoint[2] == true){
      change_lat= change_lat*-1;

      change_long=change_long * -1;
    }else if (_selectionStartPoint[3] == true){
      change_long=change_long * -1;

    }

    var futures = List<Future>();
    _pathDistance = 0;
    for( var i = 0 ; i <= 4; i++ ) {
      if(i == 0){
        futures.add(getSomePoints(i, myLocation, LatLng(myLocation.latitude,myLocation.longitude+change_long )) );
      }if(i == 1){
        futures.add(getSomePoints(i,  LatLng(myLocation.latitude,myLocation.longitude+change_long ), LatLng(myLocation.latitude+change_lat,myLocation.longitude+change_long )));
      }if(i == 3){
        futures.add(getSomePoints(i, LatLng(myLocation.latitude+change_lat,myLocation.longitude+change_long ), LatLng(myLocation.latitude+change_lat,myLocation.longitude )));
      }if(i == 4){
        futures.add(getSomePoints(i, LatLng(myLocation.latitude+change_lat,myLocation.longitude ), myLocation));
      }
    }
    await Future.wait(futures);


//   use _pathDistance to  implemen use set state into the notification.
    var typeMetric  = " Mi";
    if (_selectionKlMi[0] == true){
      typeMetric = "Km";
    }
    setState(() {
      currentlySelectedPin = PinInformation(pinPath: '', avatarPath: '', location: LatLng(0, 0), locationName: _pathDistance.toStringAsFixed(1)+typeMetric, labelColor: Colors.grey);

    });
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

    return



      MaterialApp(
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

//                      currentlySelectedPin= PinInformation(pinPath: '', avatarPath: '', location: LatLng(0, 0), locationName: '', labelColor: Colors.grey);


                      markers.clear();
                      polyline.clear();
                      typing = !typing;
                    });
                    if(typing == false){
                        if (_distance.text !=  ""  && isNumeric(_distance.text)  ){

                          setPolyLines( double.parse( _distance.text));
                          pinPillPosition = 0;
                        }else if ( _distance.text ==  "" || !isNumeric(_distance.text) ){
                            pinPillPosition = -100;

                        }
                    }
                  setState(() {

                    });
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


              Stack(
                  children: <Widget>[
                      GoogleMap(
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          polylines: polyline,
                          markers:  Set<Marker>.of(markers.values),
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: myLocation,
                            zoom: 2.0,
                          )
                      ),



                    MapPinPillComponent(
                        pinPillPosition: pinPillPosition,
                        currentlySelectedPin: currentlySelectedPin
                    ),

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





