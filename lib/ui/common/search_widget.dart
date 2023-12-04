import 'package:bunyan/models/real_estate_filter.dart';
import 'package:bunyan/models/services_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchWidget extends StatefulWidget {
  final bool showDropDown;
  final Function(dynamic filter) onSearch;
  final dynamic filter;

  SearchWidget({Key key, this.showDropDown = true, this.onSearch, this.filter}) : super(key: key);

  createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {

  final _queryController = TextEditingController();
  final _livingRoomsController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minLandController = TextEditingController();
  final _maxLandController = TextEditingController();
  final _bathRoomsController = TextEditingController();
  bool _swimmingPoolStatus;
  bool _furnishedStatus;


  @override
  Widget build(BuildContext context) {

    _queryController.text = widget.filter.query;
    _minPriceController.text = widget.filter.minPrice?.toString();
    _maxPriceController.text = widget.filter.maxPrice?.toString();
    if (widget.filter is RealEstateFilterModel) {
      _livingRoomsController.text = widget.filter.livingRooms?.toString();
      _minLandController.text = widget.filter.minLand?.toString();
      _maxLandController.text = widget.filter.maxLand?.toString();
      _bathRoomsController.text = widget.filter.bathRooms?.toString();
      _swimmingPoolStatus = widget.filter.swimmingPool ?? false;
      _furnishedStatus = widget.filter.furnished ?? false;
    }

    return Container(
      width: 1.sw,
      //height: .25.sh,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/search_bg.jpg'),
              fit: BoxFit.cover,
              repeat: ImageRepeat.noRepeat)),
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withOpacity(.5)),
        child: Padding(
          padding: EdgeInsets.only(top: 30.h, right: 20.w, left: 20.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (widget.onSearch != null) {
                        widget.filter.maxPrice = double.tryParse(_maxPriceController.text);
                        widget.filter.minPrice = double.tryParse(_minPriceController.text);
                        widget.filter.query = _queryController.text;
                        if (widget.filter is RealEstateFilterModel) {
                          widget.filter.maxLand =
                              double.tryParse(_maxLandController.text);
                          widget.filter.minLand =
                              double.tryParse(_minLandController.text);
                          widget.filter.livingRooms =
                              int.tryParse(_livingRoomsController.text);
                        }

                        widget.onSearch(widget.filter);
                      }
                    },
                    child: Container(
                      child: Center(
                          child: Row(
                            children: [
                              Text(
                                'بحث',
                                style: GoogleFonts.cairo(
                                    color: Colors.white, fontSize: 18.sp),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Transform(
                                  transform: Matrix4.rotationY(3.14159),
                                  alignment: FractionalOffset.center,
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 20.sp,
                                  )),
                            ],
                          )),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2.50)),
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                    ),
                  ),
                  if (widget.showDropDown) SizedBox(width: 20.w),
                  if (widget.showDropDown)
                    DropdownButtonHideUnderline(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(2.50)),
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: DropdownButton(
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('عقارات'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('خدمات'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('شركات'),
                              ),
                            ],
                            style: GoogleFonts.cairo(color: Colors.white),
                            value: 1,
                            iconEnabledColor: Colors.white,
                            hint: Text(
                              'الفئة',
                              style: GoogleFonts.cairo(color: Colors.white60),
                            ),
                            isDense: true,
                            dropdownColor: Colors.black87,
                            onChanged: (_) => print('')),
                      ),
                    ),
                  SizedBox(width: 20.w),
                  Expanded(
                    //height: 50.h,
                    child: TextField(
                      controller: _queryController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                          isDense: true,
                          labelStyle: GoogleFonts.cairo(color: Colors.white),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 2.5.h, horizontal: 15.w),
                          hintText: 'كلمة البحث',
                          hintStyle: GoogleFonts.cairo(color: Colors.white60)),
                      cursorHeight: 30.h,
                      cursorColor: Colors.white,
                      style: GoogleFonts.cairo(
                          color: Colors.white, fontSize: 24.sp),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.h, right: 20.w, left: 20.w),
                child: Wrap(
                  runSpacing: 5.h,
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  children: [
                    if (widget.filter is RealEstateFilterModel)
                      Wrap(
                        runSpacing: 5.h,
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        children: [
                          SizedBox(width: .4.sw, child: _txtField(hint: 'عدد غرف المعيشة', controller: _livingRoomsController)),
                          SizedBox(
                            width: .05.sw,
                          ),
                          SizedBox(width: .4.sw, child: _txtField(hint: 'عدد الحمّامات', controller: _bathRoomsController)),
                        ],
                      ),


                    //price
                    SizedBox(
                        width: double.infinity,
                        child: Text(
                          'السعر',
                          style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      width: .4.sw,
                      child: _txtField(hint: 'من', controller: _minPriceController, inputType: TextInputType.numberWithOptions(decimal: true, signed: false)),
                    ),
                    SizedBox(
                      width: .05.sw,
                    ),
                    SizedBox(
                      width: .4.sw,
                      child: _txtField(hint: 'إلى', controller: _maxPriceController, inputType: TextInputType.numberWithOptions(decimal: true, signed: false)),
                    ),

                    if (widget.filter is ServicesFilter)
                      SizedBox(height: 100.0,),


                    if (widget.filter is RealEstateFilterModel)
                      Wrap(
                        runSpacing: 5.h,
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        children: [
                          //space
                          SizedBox(
                              width: double.infinity,
                              child: Text(
                                'المساحة',
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            width: .4.sw,
                            child: _txtField(hint: 'من', controller: _minLandController, inputType: TextInputType.numberWithOptions(decimal: true, signed: false)),
                          ),
                          SizedBox(
                            width: .05.sw,
                          ),
                          SizedBox(
                            width: .4.sw,
                            child: _txtField(hint: 'إلى', controller: _maxLandController, inputType: TextInputType.numberWithOptions(decimal: true, signed: false)),
                          ),

                          SizedBox(
                            width: .4.sw,
                            child: _checkBox(caption: 'حوض سباحة', status: widget.filter.swimmingPool, onChanged: (status) => widget.filter.swimmingPool = status,),
                          ),

                          SizedBox(
                            width: .05.sw,
                          ),

                          SizedBox(
                            width: .4.sw,
                            child: _checkBox(caption: 'مؤثّث', status: widget.filter.furnished, onChanged: (status) => widget.filter.furnished = status,),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _txtField(
      {String hint, TextInputType inputType = TextInputType.number, TextEditingController controller}) {
    return TextField(
      textDirection: TextDirection.ltr,
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0)),
          isDense: true,
          labelStyle: GoogleFonts.cairo(color: Colors.white),
          contentPadding:
          EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 15.w),
          hintText: hint,
          hintStyle: GoogleFonts.cairo(color: Colors.white60)),
      cursorHeight: 30.h,
      cursorColor: Colors.white,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 24.sp),
    );
  }
  
  Widget _checkBox({bool status, Function(bool) onChanged, String caption}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: ThemeData(unselectedWidgetColor: Colors.white),
        child: CheckboxListTile(
          value: status,
          tristate: true,
          onChanged: (status) {
            setState(() {
              status = status;
              onChanged(status);
            });
          },
          contentPadding:
          EdgeInsets.symmetric(horizontal: 20.w),
          title: Text(
            caption,
            style: GoogleFonts.cairo(
                color: Colors.white, fontSize: 20.sp),
          ),
        ),
      ),
    );
  }
}

