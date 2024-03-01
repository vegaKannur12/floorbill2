import 'package:floor_billing/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ITEMSearch extends StatefulWidget {
  const ITEMSearch({super.key});

  @override
  State<ITEMSearch> createState() => _ITEMSearchState();
}

class _ITEMSearchState extends State<ITEMSearch> {
  TextEditingController itembarcodctrl = TextEditingController();
  // TextEditingController smanContrlr = TextEditingController();
  String sman = "";
  FocusNode smanfocus = FocusNode();
  FocusNode barfocus = FocusNode();
  String _scanBarcode = 'Unknown';
  String _topModalData = "";
  bool? ss = false;
  String date = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController bagno = TextEditingController();
  FocusNode bagFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.teal,
        title: Consumer<Controller>(
          builder: (BuildContext context, Controller value, Widget? child) =>
              Row(
            children: [
              Text(
                "ITEM DETAILS",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<Controller>(
          builder: (context, value, child) => Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 45,
                          width: 230,
                          child: GestureDetector(
                            child: TextFormField(
                                focusNode: barfocus,
                                controller: itembarcodctrl,
                                autofocus: true,
                                onChanged: (val) {
                                  // _debouncer.run(() {
                                  //   Provider.of<Controller>(context,
                                  //           listen: false)
                                  //       .getItemDetails(context,
                                  //           itembarcodctrl.text.toString());
                                  // });
                                },
                                decoration: InputDecoration(
                                    errorBorder: UnderlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),
                                    hintText: "Barcode",
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          Provider.of<Controller>(context,
                                                  listen: false)
                                              .clearSelectedBarcode(context);
                                          itembarcodctrl.clear();
                                        },
                                        icon: Icon(Icons.close))),
                                onFieldSubmitted: (_) async {
                                  print(
                                      "baaaaaaaaaaaaaaaaaarrrrrrrrrrr${itembarcodctrl.text.toString()}");
                                  await Provider.of<Controller>(context,
                                          listen: false)
                                      .getItemDetails(context,
                                          itembarcodctrl.text.toString());
                                  setState(() {});
                                  if (value.selectedBarcodeList.isEmpty ||
                                      value.selectedBarcodeList.length == 0 ||
                                      value.selectedBarcodeList == []) {
                                    ShowBottomSeet(context);
                                  } else {
                                    setState(() {
                                      Provider.of<Controller>(context,
                                              listen: false)
                                          .setshowdata(true);
                                    });

                                    print(
                                        "Not empty........................................");
                                  }
                                }),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        IconButton(
                          icon: Image.asset(
                            "assets/barscan.png",
                            height: 40,
                            width: 30,
                          ),
                          onPressed: () {
                            scanBarcode("", 0);
                          },
                        ),
                      ],
                    ),
                    value.itemloading
                        ? Expanded(
                            child: SpinKitCircle(
                            size: 50,
                            color: Colors.blue,
                          ))
                        :
                        // value.showdata &&
                        //         value.selectedBarcodeList.isNotEmpty ||
                        value.barcodeinvalid == false &&
                                    value.selectedBarcodeList.isEmpty ||
                                value.barcodeList.isEmpty
                            ? Expanded(
                                child: Container(
                                    height: size.height * 0.8,
                                    child: Center(
                                        child: LottieBuilder.asset(
                                      "assets/noData.json",
                                      height: size.height * 0.24,
                                    ))))
                            : value.showdata
                                ? Expanded(
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            value.selectedBarcodeList.length,
                                        itemBuilder: (context, index) {
                                          if (value.selectedBarcodeList[index]
                                                      ["Barcode"]
                                                  .toString()
                                                  .trim() ==
                                              value.selectedBarcode
                                                  .toString()) {
                                            print('haiiiiiii');
                                            return Container(
                                                height: 440,
                                                decoration: BoxDecoration(
                                                  color: Colors.green[50],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                    "BARCODE"),
                                                              ),Text(": "),
                                                              SizedBox(
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["Barcode"].toString().trimLeft()}",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text("EAN"),
                                                              ),
                                                              Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value
                                                                      .selectedBarcodeList[
                                                                          index]
                                                                          [
                                                                          "EAN"]
                                                                      .toString()
                                                                      .trimLeft()}",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  "Item Name",
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ),Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["Item_Name"].toString().trimLeft()}",
                                                                  style: TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "SRate          : ${value.selectedBarcodeList[index]["SRate"].toStringAsFixed(2)} \u{20B9}",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Text(
                                                                " TAX   : ${value.selectedBarcodeList[index]["TaxPer"].toString()} %",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                          
                                                            children: [
                                                              SizedBox(width: 90,
                                                                child: Text(
                                                                  "MRP",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                              Text(": "),
                                                              Text(
                                                                "${value.selectedBarcodeList[index]["MRP"].toStringAsFixed(2)} \u{20B9}",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  "Brand",
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ), Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["Brand"].toString().trimLeft()}",
                                                                  style: TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  "Model",
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ), Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["Model"].toString().trimLeft()}",
                                                                  style: TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  "Size",
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ), Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["Size"].toString().trimLeft()}",
                                                                  style: TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  "BillNo",
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ), Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["BillNo"].toString().trimLeft()}",
                                                                  style: TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  "Supplier",
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ), Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["Supplier"].toString().trimLeft()}",
                                                                  style: TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        child: ListTile(
                                                          title: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  "EntryDate",
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ), Text(": "),
                                                              SizedBox(
                                                                width:
                                                                    size.width /
                                                                        1.8,
                                                                child: Text(
                                                                  "${value.selectedBarcodeList[index]["EntryDate"].toString().trimLeft()}",
                                                                  style: TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ));
                                          } else {
                                            return Container(
                                              child: Text(""),
                                            );
                                          }
                                        }),
                                  )
                                : Container()
                    // : Container(
                    //     child: Text(""), ////nodar
                    //   )
                  ],
                ),
              )),
    );
  }

  Future<void> ShowBottomSeet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<Controller>(
          builder: (BuildContext context, Controller value, Widget? child) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: value.barcodeList.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 238, 231, 212)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: ListTile(
                                title: Text(
                                    "BARCODE : ${value.barcodeList[index]["Barcode"].toString().trimLeft()}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text("EAN")),
                                      Text(": "),
                                      Text(
                                        "${value.barcodeList[index]["EAN"].toString().trimLeft()}",overflow: TextOverflow.ellipsis,),
                                    ],),
                                     Row(children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text("Item Name")),
                                      Text(": "),
                                      Text(
                                        "${value.barcodeList[index]["Item_Name"].toString().trimLeft()}",overflow: TextOverflow.ellipsis,),
                                    ],),
                                    Row(children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text("SRate")),
                                      Text(": "),
                                      Text(
                                        "${value.barcodeList[index]["SRate"].toStringAsFixed(2)} \u{20B9}",overflow: TextOverflow.ellipsis,),
                                    ],),
                                    
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);

                                Provider.of<Controller>(context, listen: false)
                                    .setSelectedBarcode(
                                        context,
                                        value.barcodeList[index]["Barcode"]
                                            .toString()
                                            .trim());
                              },
                            ),
                          )));
                });
          },
        );
      },
    );
  }

  Future<void> scanBarcode(String field, int index) async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (!mounted) return;
      setState(() async {
        _scanBarcode = barcode;

        itembarcodctrl.text = _scanBarcode.toString().trim();
        _scanBarcode = "";
        await Provider.of<Controller>(context, listen: false)
            .getItemDetails(context, itembarcodctrl.text.toString());
        // setState(() {});on 1mar
        if (Provider.of<Controller>(context, listen: false)
                    .selectedBarcode
                    .toString() ==
                "" ||
            Provider.of<Controller>(context, listen: false)
                    .selectedBarcode
                    .toString() ==
                " " ||
            Provider.of<Controller>(context, listen: false)
                .selectedBarcode
                .toString()
                .isEmpty ||
            Provider.of<Controller>(context, listen: false)
                    .selectedBarcode
                    .toString() ==
                "null") {
          ShowBottomSeet(context);
        } else {
          setState(() {
            Provider.of<Controller>(context, listen: false).setshowdata(true);
          });

          print("Not empty........................................");
        }
      });
    } catch (e) {
      print("error");
      _scanBarcode = "hugugu";
    }
    //  on PlatformException {
    //   _scanBarcode = "hugugu";
    // }  on 1mar
  }
}
