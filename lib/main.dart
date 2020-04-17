import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as L;
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:permission/permission.dart';
import 'dart:math';

void main() => runApp(MyApp());


enum WhyFather { harder, smarter, selfStarter, tradingCenter}

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
  bool typing = false;
  static TextEditingController _distance = new TextEditingController();
  TextBox distance = new TextBox(_distance);


  static LatLng myLocation =  LatLng(39.8283,-98.5795);


  Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  List<bool> isSelected;

  @override
  void initState() {
    // TODO: implement initState
    isSelected = [true, false];
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

  void _pushSave(){
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) {
          return new Scaffold(
              appBar: AppBar(
                title: new Text("Settings"),

              ),
              body:

              Column(
                  children: <Widget>[

                    ToggleButtons(
                      borderColor: Colors.black,
                      fillColor: Colors.grey,
                      borderWidth: 2,
                      selectedBorderColor: Colors.black,
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      children: <Widget>[
                        Text(
                          'Open 24 Hours',
                          style: TextStyle(fontSize: 16),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            'Custom Hours',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < isSelected.length; i++) {
                            isSelected[i] = i == index;
                          }
                        });
                      },
                      isSelected: isSelected,
                    ),



                  ])
          );
        })


    );

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
                new IconButton(icon: Icon(Icons.settings), onPressed: _pushSave),
              ],
            ),

            body:

            Column(
                children: <Widget>[
//
//
//              ToggleButtons(
//                borderColor: Colors.black,
//                fillColor: Colors.grey,
//                borderWidth: 2,
//                selectedBorderColor: Colors.black,
//                selectedColor: Colors.white,
//                borderRadius: BorderRadius.circular(0),
//                children: <Widget>[
//                  Text(
//                    'Open 24 Hours',
//                    style: TextStyle(fontSize: 16),
//                  ),
//
//                  Padding(
//                    padding: const EdgeInsets.all(1.0),
//                    child: Text(
//                      'Custom Hours',
//                      style: TextStyle(fontSize: 16),
//                    ),
//                  ),
//                ],
//                onPressed: (int index) {
//                  setState(() {
//                    for (int i = 0; i < isSelected.length; i++) {
//                      isSelected[i] = i == index;
//                    }
//                  });
//                },
//                isSelected: isSelected,
//              ),


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
        ])
        )
    );
  }
}






class TextBox extends StatelessWidget {
  TextEditingController _text;

  TextBox(TextEditingController distance){
    _text=distance;

  }


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white,
      child: TextField(
        controller: _text,
        decoration:
        InputDecoration(border: InputBorder.none, hintText: 'Distance'),
      ),
    );
  }
}


