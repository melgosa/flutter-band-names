import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//enum para definir los estados del server

enum ServerStatus { Online, Offline, Connecting }


//ChangeNotifier notifica a los que este usando mi clase (hace que se redibujen)
class SocketService with ChangeNotifier {
  //se define la variable como privada para controlar que nadie mas cambie el valor
  ServerStatus _serverStatus = ServerStatus.Connecting;

  IO.Socket? _socket;

  //retornamos el valor de nuestra variable privada
  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket? get socket => this._socket;
  Function get emit => _socket!.emit;
  Function get on => _socket!.on;
  Function get off => _socket!.off;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    print('_initConfig');
    // Dart client
    createSocketConnection();
  }

  createSocketConnection() {
    print('createSocketConnection - services');
    //String urlSockets='http://192.16.137.1:5020';
    String urlSockets='https://sockets-flutter-underpro.herokuapp.com/';
    this._socket = IO.io(urlSockets, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket?.on("connect", (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket?.on("disconnect", (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

/*     this._socket?.on("nuevo-mensaje", (payload) {
      print('nuevo-mensaje: $payload');
      print('nombre: ' + payload['nombre']);
      print('mensaje: ' + payload['mensaje']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No hay mensaje');

    });*/
  }




}