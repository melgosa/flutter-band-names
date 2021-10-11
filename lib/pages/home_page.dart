import 'dart:io';

import 'package:bands_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metalica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 3),
    Band(id: '3', name: 'Otro', votes: 2),
    Band(id: '4', name: 'Melgosa band', votes: 7),
    Band(id: '5', name: 'Caifanes', votes: 8)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTile(bands[i])),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      onDismissed: (direction){

      },
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete band', style: TextStyle(color: Colors.white),),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  _addNewBand(){
    final textController = TextEditingController();

    if(Platform.isAndroid){
      return showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              actions: [
                MaterialButton(
                    child: Text('Add'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => _addBandToList(textController.text)
                )
              ],
              title: Text('New band name:'),
              content: TextField(
                controller: textController,
              ),
            );
          });
    }

    showCupertinoDialog(
        context: context,
        builder: (_){
          return CupertinoAlertDialog(
            title: Text('New band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'),
                onPressed: () => _addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
    );

  }

  _addBandToList(String name){
    if(name.length > 1){
      this.bands.add(
          Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
