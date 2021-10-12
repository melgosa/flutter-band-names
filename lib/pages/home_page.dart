import 'dart:io';

import 'package:bands_names/models/band.dart';
import 'package:bands_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    //Escuchar cuando el servidor emita el mensaje active-band (Que actualiza el listado de bandas)
    socketService.socket?.on('active-bands', _handleActiveBands);
  }

  _handleActiveBands(dynamic payload){
    this.bands = (payload as List)
        .map((band) => Band.fromMap(band))
        .toList();

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket?.off('active-bands');
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Connecting
                ? Icon(Icons.watch_later, color: Colors.yellow)
                : socketService.serverStatus == ServerStatus.Offline
                  ? Icon(Icons.offline_bolt, color: Colors.red)
                  : Icon(Icons.check_circle, color: Colors.blue[300])
          )
        ],
      ),
      body: Column(
        children: [
          bands.isEmpty
              ? Container(margin: EdgeInsets.only(top: 50), child: Center(child: CircularProgressIndicator()))
              : _showGraph(),
          _showBandTiles(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
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
        onTap: () => socketService.socket?.emit('vote-band', {'id': band.id})
      ),
    );
  }

  _addNewBand(){
    final textController = TextEditingController();

    if(Platform.isAndroid){
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
            )
            );
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
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
          )
    );

  }

  _addBandToList(String name){
    final socketService = Provider.of<SocketService>(context, listen: false);
    if(name.length > 1){
      socketService.emit('add-band', {'name' : name});
    }

    Navigator.pop(context);
  }

  Widget _showBandTiles() {
    return Expanded(
      child: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTile(bands[i])),
    );
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
        width: double.infinity, height: 200, child: PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      centerText: "Bandas",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),
    ));
  }
}
