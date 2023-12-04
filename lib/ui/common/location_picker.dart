import 'dart:async';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/position.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart' hide MapType;
import 'package:map_pin_picker/map_pin_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationPicker extends StatefulWidget {
  LocationPicker({Key key, this.position}) : super(key: key);

  final PositionModel position;

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _mapPickerController = MapPickerController();
  CameraPosition _cameraPosition;
  Completer<GoogleMapController> _mapController = Completer();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('position ${widget.position}');
    LatLng pos = LatLng(25.3398632, 50.0962972);
    if (widget.position == null)
      _getLocation();
    else
      pos = LatLng(widget.position.lat, widget.position.lng);
    _cameraPosition = CameraPosition(target: pos, zoom: 14.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: MapPicker(
                  // pass icon widget
                  iconWidget: Icon(
                    Icons.location_pin,
                    size: 50,
                    color: Colors.blue,
                  ),
                  //add map picker controller
                  mapPickerController: _mapPickerController,
                  child: GoogleMap(
                    zoomControlsEnabled: false,
                    // hide location button
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    //  camera position
                    initialCameraPosition: _cameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    onCameraMoveStarted: () {
                      // notify map is moving
                      _mapPickerController.mapMoving();
                    },
                    onCameraMove: (cameraPosition) {
                      this._cameraPosition = cameraPosition;
                    },
                    onCameraIdle: () async {
                      // notify map stopped moving
                      _mapPickerController.mapFinishedMoving();
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: .1.sh,
            right: .0,
            left: .0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: .1.sw),
              child: MaterialButton(
                child: Text(
                  widget.position == null ? Languages.of(context).locate : Languages.of(context).openonmap,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                onPressed: _btnPressed,
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5000.0)),
                minWidth: 1.sw,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    final location = Location();
    final permission = await location.requestPermission();
    if (permission != PermissionStatus.GRANTED) Navigator.pop(context);
    final gpsEnabled = await location.requestService();
    if (!gpsEnabled) Navigator.pop(context);
    final position = await location.getLocation();
    print('position $position');
    final mapController = await _mapController.future;
    mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14.0));
  }

  Future<void> _btnPressed() async {
    if (widget.position == null) {
      Navigator.pop(
          context,
          PositionModel(
              lat: _cameraPosition.target.latitude,
              lng: _cameraPosition.target.longitude));
    } else {
      final maps = await MapLauncher.installedMaps;
      if (maps.isEmpty) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext)
            .showSnackBar(SnackBar(content: Text(Languages.of(context).nomapoutside)));
        return;
      }
      maps.first.showMarker(
        coords: Coords(widget.position.lat, widget.position.lng),
        title: '',
      );
    }
  }
}
