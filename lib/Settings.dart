import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  List<bool> selectionStartPoint;
  List<bool> selectionKmMi;

  Settings(List<bool> selectionKmMi1,List<bool> selectionStartPoint1){
    selectionStartPoint = selectionStartPoint1;
    selectionKmMi = selectionKmMi1;
  }

  @override
  SettingState createState() => SettingState( selectionKmMi, selectionStartPoint);
}



class SettingState extends State<Settings> {
  List<bool> selectionStartPoint;
  List<bool> selectionKmMi;

  SettingState(List<bool> selectionKmMi1,List<bool> selectionStartPoint1){
    selectionStartPoint = selectionStartPoint1;
    selectionKmMi = selectionKmMi1;
    Settings createState() => Settings(selectionKmMi,selectionStartPoint1);

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settigs"),
      ),
      body:


      Center(
        child: Column(
          children: <Widget>[
            ToggleButtons(
              borderColor: Colors.black,
              fillColor: Colors.lightBlue[200],
              borderWidth: 2,
              selectedBorderColor: Colors.white,
              selectedColor: Colors.blueAccent,
              borderRadius: BorderRadius.circular(0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Kilometers',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Miles',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
              isSelected: selectionKmMi,
              onPressed: (int index) {

                print(selectionKmMi);
                setState(() {
                  for (int i = 0; i < selectionKmMi.length; i++) {
                    selectionKmMi[i] = i == index;
                  }
                });
              },
            ),
              Text("Enter the direction you would like to create a route\n"),
            ToggleButtons(
              borderColor: Colors.black,
              fillColor: Colors.grey,
              borderWidth: 2,
              selectedBorderColor: Colors.black,
              selectedColor: Colors.white,
              borderRadius: BorderRadius.circular(0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'Nothern West',
                    style: TextStyle(fontSize: 8),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'Nothern East',
                    style: TextStyle(fontSize: 8),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'South East',
                    style: TextStyle(fontSize: 8),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'South West',
                    style: TextStyle(fontSize: 8),
                  ),
                ),
              ],
              isSelected: selectionStartPoint,
              onPressed: (int index) {
                print(selectionStartPoint);
                setState(() {
                  for (int i = 0; i < selectionStartPoint.length; i++) {
                    selectionStartPoint[i] = i == index;
                  }
                });
              },
            ),


          ],
        ),
      ),


    );
  }
}





