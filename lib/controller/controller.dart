import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:floor_billing/SCREENs/FLOORBILL/HOME/homeFloorBilling.dart';
import 'package:floor_billing/SCREENs/FLOORBILL/HOME/mainHome.dart';
import 'package:floor_billing/SCREENs/db_selection.dart';
import 'package:floor_billing/MODEL/registration_model.dart';
import 'package:floor_billing/authentication/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:floor_billing/components/custom_snackbar.dart';
import 'package:floor_billing/components/external_dir.dart';
import 'package:floor_billing/db_helper.dart';
import 'package:floor_billing/MODEL/customer_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_conn/sql_conn.dart';
import '../components/network_connectivity.dart';

class Controller extends ChangeNotifier {
  // int? cartNo;
  String? fromDate;
  String? lastdate;
  String? cname;

  bool isSearch = false;
  bool isDelSearch = false;
  DateTime? sdate;
  DateTime? ldate;
  String? os;
  String? cName;
  String? fp;
  String? cid;
  ExternalDir externalDir = ExternalDir();
  List<CD> c_d = [];
  String? sof;
  bool incorect = false;
  // ignore: prefer_typing_uninitialized_variables
  var jsonEncoded;
  DateTime d = DateTime.now();
  String? todate;

  bool isLoading = false;
  String? appType;
  bool isdbLoading = true;

  // List<Map<String, dynamic>> filteredList = [];

  List<bool> isAdded = [];

  List<Map<String, dynamic>> catlist = [
    {"catid": "C1", "catname": "Category1"},
    {"catid": "C2", "catname": "Category2"},
    {"catid": "C3", "catname": "Category3"},
    {"catid": "C4", "catname": "Category4"},
    {"catid": "C5", "catname": "Category5"},
    {"catid": "C6", "catname": "Category6"},
    {"catid": "C7", "catname": "Category7"},
  ];

  double itemcount = 0.0;

  String? userName;

  List<Map<String, dynamic>> db_list = [];
  bool isYearSelectLoading = false;
  bool isLoginLoading = false;
  bool isDBLoading = false;
  bool isTableLoading = false;
  bool isCategoryLoading = false;
  bool isItemLoading = false;
  List delWidget = [];
  String? catlID = "";
  Timer timer = Timer.periodic(Duration(seconds: 3), (timer) {});

  String u_id = "";
  String card_id = "";
  String disply_name = "";
  String bag_no = "";
  List custDetailsList = [];
  List unsavedList = [];
  List bagDetailsList = [];
  String cus_name = "";
  String cus_contact = "";
  List barcodeList = [];
  List selectedBarcodeList = [];
  String selectedBarcode = "";
  bool findsales = true;
  bool barcodeinvalid = false;
  List<Map<dynamic, dynamic>> salesManlist = [];
  List savedresult = [];
  Map selectedSalesMan = {};
  List<TextEditingController> qty = [];
  List<TextEditingController> persntage = [];
  List<TextEditingController> smantext = [];
  List<TextEditingController> saved = [];
  TextEditingController ccname = TextEditingController();
  TextEditingController ccfon = TextEditingController();
  TextEditingController cardNoctrl = TextEditingController();
  List<Text> netamt = [];
  bool showdata = false;
  int slot_id = 0;
  Text baggerror = Text("");
  Text salesError = Text("ytuytu");
  Text barcodeerror = Text("");
  Text adduserError = Text("");
  int cart_id = 0;
  double srate = 0.0;
  double unsaved_tot = 0.0;
  List usedbagList = [];
  List usedbagITEMList = [];
  Map<int, double> floor_totl = {};
  double all_total = 0.0;
  Map<int, List<Map<String, dynamic>>> itemSortedList = {};
  int allbagallcount = 0;
  List fbList = [];
  List fbResulList = [];
  List delList = [];
  List delResulList = [];
  bool showadduser = false;
  bool typlock = false;
  bool tapped = false;
  List printingList = [];
  List deliveryBillList = [];
  int len = 0;
  Map<int, List<Map<String, dynamic>>> resultList = {};
  Map<int, List<Map<String, dynamic>>> sortedDelvryList = {};
  List slotIds = [];
  bool isvalidsale = false;
  bool isbagloading = false;
  bool igno = false;
  bool itemloading = false;
  bool cartloading = false;
  bool fbListLoading = false;
  bool delListLoading = false;
  // Future<void> sendHeartbeat() async {
  //   try {
  //     if (SqlConn.isConnected) {
  //       print("connected.........OK");
  //     } else {
  //       print("Not  connected.........OK");
  //     }
  //   } catch (error) {
  //     // Handle the error (connection issue)
  //     print("Connection lost: $error");
  //     // You can trigger a reconnection here
  //     // ...
  //   }
  // }

  /////////////////////////////////////////////
  Future<RegistrationData?> postRegistration(
      String companyCode,
      String? fingerprints,
      String phoneno,
      String deviceinfo,
      BuildContext context) async {
    NetConnection.networkConnection(context).then((value) async {
      print("Text fp...$fingerprints---$companyCode---$phoneno---$deviceinfo");
      // ignore: prefer_is_empty
      if (companyCode.length >= 0) {
        appType = companyCode.substring(10, 12);
      }
      if (value == true) {
        try {
          Uri url =
              Uri.parse("https://trafiqerp.in/order/fj/get_registration.php");
          Map body = {
            'company_code': companyCode,
            'fcode': fingerprints,
            'deviceinfo': deviceinfo,
            'phoneno': phoneno
          };
          // ignore: avoid_print
          print("register body----$body");
          isLoading = true;
          notifyListeners();
          http.Response response = await http.post(
            url,
            body: body,
          );
          // print("body $body");
          var map = jsonDecode(response.body);
          // ignore: avoid_print
          print("regsiter map----$map");
          RegistrationData regModel = RegistrationData.fromJson(map);

          sof = regModel.sof;
          fp = regModel.fp;
          String? msg = regModel.msg;

          if (sof == "1") {
            if (appType == 'UY') {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              /////////////// insert into local db /////////////////////
              String? fp1 = regModel.fp;
              // ignore: avoid_print
              print("fingerprint......$fp1");
              prefs.setString("fp", fp!);
              cid = regModel.cid;
              os = regModel.os;
              prefs.setString("cid", cid!);
              for (var item in regModel.c_d!) {
                print("cinm......${item.cnme.toString()}");
                c_d.add(item);
              }
              cname = regModel.c_d![0].cnme;
              notifyListeners();
              print("regModel.c_d![0].cnme-----${regModel.c_d![0].cnme}");
              prefs.setString("cname", cname!);
              prefs.setString("os", os!);
              print("cid----cname-----$cid---$cname....$os");
              notifyListeners();

              await externalDir.fileWrite(fp1!);

              // ignore: duplicate_ignore
              // for (var item in regModel.c_d!) {
              //   print("ciddddddddd......$item");
              //   c_d.add(item);
              // }noteee
              // verifyRegistration(context, "");

              isLoading = false;
              notifyListeners();
              prefs.setString("user_type", appType!);
              prefs.setString("db_name", map["mssql_arr"][0]["db_name"]);
              prefs.setString("old_db_name", map["mssql_arr"][0]["db_name"]);
              prefs.setString("ip", map["mssql_arr"][0]["ip"]);
              prefs.setString("port", map["mssql_arr"][0]["port"]);
              prefs.setString("usern", map["mssql_arr"][0]["username"]);
              prefs.setString("pass_w", map["mssql_arr"][0]["password"]);
              prefs.setString("multi_db", map["mssql_arr"][0]["multi_db"]);

              String? user = prefs.getString("userType");
              await BILLING.instance
                  .deleteFromTableCommonQuery("companyRegistrationTable", "");
              // ignore: use_build_context_synchronously
              String? m_db = prefs.getString("multi_db");
              if (m_db == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } 
              else 
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DBSelection()),
                );
              }
            } else {
              CustomSnackbar snackbar = CustomSnackbar();
              // ignore: use_build_context_synchronously
              snackbar.showSnackbar(context, "Invalid Apk Key", "");
            }
          }
          /////////////////////////////////////////////////////
          if (sof == "0") {
            CustomSnackbar snackbar = CustomSnackbar();
            // ignore: use_build_context_synchronously
            snackbar.showSnackbar(context, msg.toString(), "");
          }
          notifyListeners();
        } catch (e) {
          // ignore: avoid_print
          print(e);
          return null;
        }
      }
    });
    return null;
  }

  //////////////////////////////////////////////////////////
  getLogin(String userName, String password, BuildContext context) async {
    incorect = false;
    notifyListeners();
    try {
      isLoginLoading = true;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? os = prefs.getString("os");
      String? cn = prefs.getString("cname");
      print("cnameeeeee$cn");
      print("unaaaaaaaaaaammmeeeeeeeee$userName");
      String oo = "Flt_Sp_Verify_User '$os','$userName','$password'";
      print("loginnnnnnnnnnnnnnn$oo");
      //  print("{Flt_Sp_Verify_User '$os','$userName','$password'}");
      // initDb(context, "from login");
      // initYearsDb(context, "");
      // await initYearsDb(context, ""); noteeeeee
      var res = await SqlConn.readData(
          "Flt_Sp_Verify_User '$os','$userName','$password'");
      var valueMap = json.decode(res);
      print("item list----------$res");
      if (valueMap.isNotEmpty && valueMap != null) {
        print("user dataa----------$res");
        print(
            "UserID >>>>>> ${valueMap[0]["UserID"]}----Displynam>>>>> ${valueMap[0]["Flt_Display_Name"]}");
        prefs.setString("UserID", valueMap[0]["UserID"].toString());
        prefs.setString("Flt_Display_Name",
            valueMap[0]["Flt_Display_Name"].toString().trimLeft());
        prefs.setString("st_uname", userName);
        prefs.setString("st_pwd", password);

        await getSalesman();
        await setUID();
        // SqlConn.disconnect();
        incorect = false;
        notifyListeners();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainHome()),
        // );
      } else {
        incorect = true;
        notifyListeners();
        // CustomSnackbar snackbar = CustomSnackbar();
        // snackbar.showSnackbar(context, "Incorrect Username or Password", "");
        // isLoginLoading = false;
        // notifyListeners();
      }

      isLoginLoading = false;
      notifyListeners();
    }
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   print(e);
    //   return null;
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected == false) {
        print("hi");
        //   // SharedPreferences prefs = await SharedPreferences.getInstance();
        //   // String? os = prefs.getString("os");
        //   // String? cn = prefs.getString("cname");
        //   // if (incorect) {
        //   //   CustomSnackbar snackbar = CustomSnackbar();
        //   //   snackbar.showSnackbar(context, "Incorrect Username or Password", "");
        //   //   //  Navigator.pop(context);
        //   //   exit(0);
        //   // } else {
        //   //   Navigator.push(
        //   //     context,
        //   //     MaterialPageRoute(builder: (context) => MainHome()),
        //   //   );
        //   // }
        //   // If connected, do not pop context as it may dismiss the error dialog

        //   // Navigator.push(
        //   //   context,
        //   //   MaterialPageRoute(builder: (context) => MainHome()),
        //   // );

        //   debugPrint("Database connected, not popping context.");
        // }
        //  else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initYearsDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

  getCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? os = prefs.getString("os");
    try {
      var res = await SqlConn.readData("Flt_Sp_Get_Fb_CartID '$os'");
      var map = jsonDecode(res);
      print("caaaaaaaaaaaaaarrrrrrrttttttttt$map");
      cart_id = map[0]["CartId"];
      notifyListeners();
      print("cart iddddddddd ====== $cart_id");//note chane
      
      // SqlConn.disconnect();
    } on PlatformException catch (e) {
      print("PlatformException occurredcttr: $e");
      SqlConn.disconnect();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Connection Lost...! ",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Reconnect'),
                onPressed: () async {
                  await initYearsDb(context, "");
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      // Handle the PlatformException here
      // You can log the exception, display an error message, or take other appropriate actions
    } catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
  }

  setUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    u_id = prefs.getString("UserID")!;
    disply_name = prefs.getString("Flt_Display_Name")!;
    notifyListeners();
  }

  setshowdata(bool bbb) {
    showdata = bbb;
    notifyListeners();
  }

  setBagNo(String data, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("BagNo", data);
      bag_no = data;
      notifyListeners();
    }
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   print(e);
    //   return null;
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
  }

  getBagDetails(String bagNo, BuildContext context, String from) async {
    setbagerror("");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? os = prefs.getString("os");
    String? cardNo = prefs.getString("cardNo");
    print('os ----- $os, cardNo ------->$card_id,bagnum----$bagNo');
    setBagNo(bagNo, context);
    // await initYearsDb(context, "");
    try {
      print("${'Flt_Sp_Get_Bag $os, $card_id, $bagNo'}");
      var res =
          await SqlConn.readData("Flt_Sp_Get_Bag '$os',$card_id,'$bagNo'");
      var map = jsonDecode(res);
      // SqlConn.disconnect();
      if (map.isEmpty && bagNo.isNotEmpty) {
        if (from == "home") {
          setbagerror("Not Available");
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bag already taken",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('OK'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          setBagNo("0", context);
          slot_id = 0;
          tapped = true;
          notifyListeners();
        }
      }
      tapped = false;
      notifyListeners();
      print("bag dataaa------------>>$res");

      bagDetailsList.clear();
      for (var item in map) {
        bagDetailsList.add(item);
      }
      slot_id = bagDetailsList[0]["Slot"];
      print("Bag List ==$bagDetailsList");
      print("SLot ==$slot_id");

      notifyListeners();
    }
    //  on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   // Handle the PlatformException here
    //   // You can log the exception, display an error message, or take other appropriate actions
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected) {
        // If connected, do not pop context as it may dismiss the error dialog
        // Navigator.pop(context);

        debugPrint("Database connected, not popping context.");
      } else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initYearsDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

  setbagerror(String err) {
    baggerror = Text(
      err,
      style: TextStyle(color: Colors.red),
    );
    notifyListeners();
  }

  setSalesrror(String err) {
    salesError = Text(
      err,
      style: TextStyle(color: Colors.red),
    );
    notifyListeners();
  }

  setBarerror(String err) {
    barcodeerror = Text(
      err,
      style: TextStyle(color: Colors.red),
    );
    notifyListeners();
  }

  changeSalesman(Map val) {
    selectedSalesMan = val;
    notifyListeners();
  }

  searchSalesMan(String smcode) async {
    isvalidsale = false;
    setSalesrror("");
    notifyListeners();
    print("7777777777777777$smcode");
    for (var sm in salesManlist) {
      if (sm['Sm_Code'].toString().trimLeft() == smcode) {
        isvalidsale = true;
        notifyListeners();
        break;
      }
    }
    print("isvalid===$isvalidsale");
    if (!isvalidsale) {
      setSalesrror("Invalid");
      notifyListeners();
    }
    // for (var item in salesManlist) {
    //   if (item['Sm_Code'].toString().trim() == smcode) {
    //     print("0000000000000000000000000000000$smcode");
    //     findsales = true;

    //     notifyListeners();
    //   }
    //   if (findsales == false) {
    //     setSalesrror("Invalid");
    //     notifyListeners();
    //   }
    // }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool("smbool", findsales);
    notifyListeners();
  }

  setSelectedBarcode(BuildContext context, String data) async {
    print("barcode select----------->>> $data");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("SelBar", data.toString());
    selectedBarcode = data.toString();
    getItemDetails(context, selectedBarcode);
    notifyListeners();
  }

  clearSelectedBarcode(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("SelBar", "");
    selectedBarcode = "";
    setshowdata(false);
    notifyListeners();
  }

  getSalesman() async {
    var res = await SqlConn.readData("Flt_Sp_Get_Sm_List '$os'");
    var map = jsonDecode(res);
    salesManlist.clear();
    for (var item in map) {
      salesManlist.add(item);
    }
    selectedSalesMan = salesManlist[0];
    notifyListeners();
    print("Salesman List--$salesManlist");
  }

  getItemDetails(BuildContext context, String barcodedata) async {
    // await initYearsDb(context, "");nvbnb
    // setBarerror("");

    barcodeinvalid = false;
    setBarerror("");
    barcodeinvalid = false;
    selectedBarcodeList.clear();
    selectedBarcode = "";
    barcodeList.clear();
    clearSelectedBarcode(context);

    notifyListeners();
    try {
      itemloading = true;
      notifyListeners();
      var res = await SqlConn.readData(
          "Flt_Sp_Get_Barcode_Item '$os','$barcodedata'");
      var map = jsonDecode(res);

      print("Item details Map--$map");
      // selectedBarcode = "";

      barcodeList.clear();
      if (map != null) {
        barcodeinvalid = false;
        setBarerror("");
        notifyListeners();
        for (var item in map) {
          barcodeList.add(item);
        }

        if (barcodeList.length == 1) {
          // selectedBarcode = barcodedata;
          selectedBarcode = barcodeList[0]["Barcode"].toString().trim();
          notifyListeners();

          for (var item in barcodeList) {
            var barcode = item['Barcode'].toString().trim();
            bool barcodeExists = selectedBarcodeList
                .any((element) => element['Barcode'] == barcode);
            if (!barcodeExists) {
              selectedBarcodeList.add(item);
            }
          }

          setshowdata(true);
          // notifyListeners();
          notifyListeners();
        } else {
          barcodeinvalid = true;
          setBarerror("Invalid code");
          setshowdata(false);
          notifyListeners();
        }
        qty = List.generate(
            selectedBarcodeList.length, (index) => TextEditingController());
        persntage = List.generate(
            selectedBarcodeList.length, (index) => TextEditingController());
        smantext = List.generate(
            selectedBarcodeList.length, (index) => TextEditingController());
        netamt =
            List.generate(selectedBarcodeList.length, (index) => Text("0.0"));
        isAdded = List.generate(selectedBarcodeList.length, (index) => false);
        // response = List.generate(selectedBarcodeList.length, (index) => 0);
        for (int i = 0; i < selectedBarcodeList.length; i++) {
          if (selectedBarcodeList[i]["Barcode"].toString().trim() ==
              selectedBarcode.toString()) {
            qty[i].text = "1.0";
            persntage[i].text = selectedBarcodeList[i]["DiscPer"].toString();
            srate = selectedBarcodeList[i]["SRate"];
            smantext[i].text = "0";
            notifyListeners();
            print("sratte ==== $srate");
            discount_calc(i, "from add");
          }
          // response[i] = 0;
        }
        isLoading = false;
        notifyListeners();
        print("Selected Barcode----^^^___$selectedBarcode");
        print("Selected BarcodeList----^^^___$selectedBarcodeList");
        notifyListeners();
      }
      itemloading = false;
      notifyListeners();
      // throw PlatformException(
      //   code: 'ERROR',
      //   message: 'Network error IOException: failed to connect...',
      // );
    }
    //  on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   // await SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Not Connected.! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //             SpinKitCircle(
    //               color: Colors.green,
    //             )
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Connect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   print(e);
    //   return null;
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected) {
        // If connected, do not pop context as it may dismiss the error dialog
        // Navigator.pop(context);
        debugPrint("Database connected, not popping context.");
      } else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initYearsDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

  savefloorbill(String dt, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? os = prefs.getString("os");
    try {
      printingList.clear();
      savedresult.clear();
      notifyListeners();
      int itemcount = unsavedList.length;
      print(
          "save floor ${'Flt_Sp_Save_FloorBill $cart_id,$dt,$card_id,$slot_id,$os,$u_id,$unsaved_tot,$itemcount'}");
      var res = await SqlConn.readData(
          "Flt_Sp_Save_FloorBill $cart_id,'$dt',$card_id,0,'$os',$u_id,$unsaved_tot,$itemcount"); //slot=0
      var map = jsonDecode(res);
      savedresult.clear();
      for (var item in map) {
        savedresult.add(item);
      }
      unsavedList.clear();
      notifyListeners();
      print("Saved result--$savedresult");
      await getprintingFBdetails(dt, os!, int.parse(card_id),
          int.parse(savedresult[0]['FB_no'].toString()));
    } on PlatformException catch (e) {
      print("PlatformException occurredcttr: $e");
      SqlConn.disconnect();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Connection Lost...! ",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Reconnect'),
                onPressed: () async {
                  await initYearsDb(context, "");
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print(e);
      return null;
    } catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
  }

  getprintingFBdetails(String dt, String os, int cardId, int fb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? os = prefs.getString("os");
    printingList.clear();
    notifyListeners();
    int itemcount = unsavedList.length;
    print("printGet ${'Flt_Sp_Get_Fb_Details_Full $fb,$cardId,$os'}");
    var res =
        await SqlConn.readData("Flt_Sp_Get_Fb_Details_Full $fb,$cardId,'$os'");
    var map = jsonDecode(res);
    printingList.clear();
    for (var item in map) {
      printingList.add(item);
    }

    notifyListeners();
    print("printing data result--$printingList");
  }

  clearprintList() {}

  discount_calc(int index, String type) {
    if (type == "from add") {
      double srate =
          double.parse(selectedBarcodeList[index]["SRate"].toString().trim());
      double qua = double.parse(qty[index].text.toString());
      double disco = double.parse(persntage[index].text.toString());
      print("srate: $srate-------qty: $qua--------- discou: $disco");
      double total = (srate * qua) - ((srate * qua) * disco / 100);

      netamt[index] = Text(
        "${total.toStringAsFixed(2)}  \u20B9",
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
      );
      print("neTTTTT-------------->$total");
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////
  getDatabasename(BuildContext context, String type) async {
    isdbLoading = true;
    db_list.clear();
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? db = prefs.getString("db_name");
    String? cid = await prefs.getString("cid");
    print("cid dbname---------$cid---$db");
    var res = await SqlConn.readData("Flt_LoadYears '$db','$cid'");
    var map = jsonDecode(res);

    if (map != null) {
      for (var item in map) {
        db_list.add(item);
      }
    }
    notifyListeners();
    print("years res-$res");
    print("tyyyyyyyyyp--------$type");
    isdbLoading = false;
    notifyListeners();

    if (db_list.length > 1) {
      if (type == "from login") {
        await SqlConn.disconnect();
        print("disconnected--------$db");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DBSelection()),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

/////////////////////////////////////////////////////////////////////////////
  initYearsDb(
    BuildContext context,
    String type,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? port = prefs.getString("port");
    String? un = prefs.getString("usern");
    String? pw = prefs.getString("pass_w");
    String? db = prefs.getString("db_name");
    String? multi_db = prefs.getString("multi_db");

    debugPrint("Connecting selected DB...$db----");
    try {
      isYearSelectLoading = true;
      notifyListeners();
      // await SqlConn.disconnect();
      showDialog(
        context: context,
        builder: (context) {
          // Navigator.push(
          //   context,
          //   new MaterialPageRoute(builder: (context) => HomePage()),
          // );
          // Future.delayed(Duration(seconds: 5), () {
          //   Navigator.of(mycontxt).pop(true);
          // });
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Please wait",
                  style: TextStyle(fontSize: 13),
                ),
                SpinKitCircle(
                  color: Colors.green,
                )
              ],
            ),
          );
        },
      );
      if (multi_db == "1") {
        await SqlConn.connect(
          ip: ip!,
          port: port!,
          databaseName: db!,
          username: un!,
          password: pw!,
          timeout: 10,
        );
        //  Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoginPage()),
        // );
      }
      debugPrint("Connected selected DB!----$ip------$db");
      // getDatabasename(context, type);
      CustomSnackbar snackbar = CustomSnackbar();
      snackbar.showSnackbar(context, "Connected successfully..", "");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // yr = prefs.getString("yr_name");
      // dbn = prefs.getString("db_name");
      cname = prefs.getString("cname");
      isYearSelectLoading = false;
      notifyListeners();
      // prefs.setString("db_name", dbn.toString());
      // prefs.setString("yr_name", yrnam.toString());
      // getDbName();
      // getBranches(context);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

//////////////////////////////////////////////////////////time out
  Future<void> initDb(BuildContext context, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? db = prefs.getString("old_db_name");
    String? ip = prefs.getString("ip");
    String? port = prefs.getString("port");
    String? un = prefs.getString("usern");
    String? pw = prefs.getString("pass_w");
    print("db: $db \n ip : $ip \n port : $port \n uname: $un \n pawd: $pw");
    debugPrint("Connecting..initdb.");
    try {
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //       title: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Text(
      //             "Please wait",
      //             style: TextStyle(fontSize: 13),
      //           ),
      //           SpinKitCircle(
      //             color: Colors.green,
      //           )
      //         ],
      //       ),
      //     );
      //   },
      // );
      await SqlConn.connect(
        ip: ip!, port: port!, databaseName: db!, username: un!, password: pw!,
        // ip:"192.168.18.37",
        // port: "1433",
        // databaseName: "TL169715",
        // username: "sa",
        // password: "1"
        timeout: 8,
      );

      debugPrint("Connected!");
      getDatabasename(context, type);
      notifyListeners();
      // throw TimeoutException(message);
      // throw PlatformException(
      //   code: 'ERROR',
      //   message: 'Network error IOException: failed to connect...',
      // );
    }
    // on TimeoutException catch (_) {
    //   // Handle timeout exception
    //   await SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Timeout",
    //               style: TextStyle(fontSize: 13),
    //             ),
    //             SpinKitCircle(
    //               color: Colors.green,
    //             )
    //           ],
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () async {
    //               await initDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //             child: Text('Try again'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // } on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   // await SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Not Connected.! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //             SpinKitCircle(
    //               color: Colors.green,
    //             )
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Connect'),
    //             onPressed: () async {
    //               await initDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   print(e);
    //   return null;
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected) {
        // If connected, do not pop context as it may dismiss the error dialog
        // Navigator.pop(context);
        debugPrint("Database connected, not popping context.");
      } else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

///////////////////////.................////////////////////////////////
  disconnectDB(BuildContext context) async {
    debugPrint("Disconnecting...!!!");
    try {
      await SqlConn.disconnect();
      debugPrint("DisConnected----------!!!!!!!!!!!!!!");
    } catch (e) {
      debugPrint("Disconnection error--->>>${e.toString()}");
    } finally {
      Navigator.pop(context);
    }
  }

/////////////////////////////////////////////////////////////////
  ///
  updateCart(BuildContext context, String dd, String sm, int? cartrow,
      String bch, double qt, double dic, int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    os = await prefs.getString("os");
    try {
      if (status == 0) {
        print(
            "update data====== ${'Flt_Update_FB_Cart $cart_id, $dd, $card_id, $cus_name, $cus_contact, $slot_id, $cartrow, $sm, $os, $bch ,$qt , $srate, $dic, $status'}");
        var res = await SqlConn.readData(
            "Flt_Update_FB_Cart '$cart_id','$dd','$card_id','$cus_name','$cus_contact',0,$cartrow,'$sm','$os','$bch','$qt','$srate','$dic',$status");
        var map = jsonDecode(res);
        if (map.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Added to cart",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ok'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          print("update Map------------>>$map");
          clearSelectedBarcode(context);
          notifyListeners();
        }
      } else {
        print(
            "delete data====== ${'Flt_Update_FB_Cart $cart_id, $dd, $card_id, $cus_name, $cus_contact, $slot_id, $cartrow, $sm, $os, $bch ,$qt , $srate, $dic, $status'}");
        var res = await SqlConn.readData(
            "Flt_Update_FB_Cart '$cart_id','$dd','$card_id','$cus_name','$cus_contact','$slot_id',$cartrow,'$sm','$os','$bch','$qt','$srate','$dic',$status");
        var map = jsonDecode(res);
        if (map.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Item deleted",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ok'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          print("update Map------------>>$map");
        }
      }

      // SqlConn.disconnect();
    }
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   // Handle the PlatformException here
    //   // You can log the exception, display an error message, or take other appropriate actions
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected) {
        // If connected, do not pop context as it may dismiss the error dialog
        Navigator.pop(context);

        debugPrint("Database connected, not popping context.");
      } else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initYearsDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

//////////////////////................/////////////////////////
  getCustData(String date, String cardNo, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cardNo", cardNo);
    os = await prefs.getString("os");
    print('os ----- $os, cardNo ------->$cardNo');
    // await initYearsDb(context, "");
    // setcusnameAndPhone(" ", " ", context);
    igno = false;
    notifyListeners();

    try {
      var res = await SqlConn.readData("Flt_Sp_GetFloor_Cards '$os','$cardNo'");
      var map = jsonDecode(res);
      // SqlConn.disconnect();
      print("custdata------------>>$res");

      custDetailsList.clear();
      for (var item in map) 
      {
        custDetailsList.add(item);
      }
      print("customer Data List ==$custDetailsList");

      if (custDetailsList.length == 0) {
        clearCardID("0");
        setcusnameAndPhone("", "", context);
        igno = true;
        cardNoctrl.clear();
        userAddButtonDisable(true);
        notifyListeners();
      } else {
        //  prefs.setInt("CardID", custDetailsList[0]['CardID']);
        igno = false;
        card_id = custDetailsList[0]['CardID'].toString();notifyListeners();
        setcusnameAndPhone(custDetailsList[0]['Cust_Name'].toString().trim(),
            custDetailsList[0]['Cust_Phone'].toString().trim(), context);
        getUsedBags(context, date, card_id);
        notifyListeners();
      }

      notifyListeners();
      print("card ID--Name---Contact------->$card_id--$cus_name--$cus_contact");
    }
    
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   print(e);
    //   return null;
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected) {
        // If connected, do not pop context as it may dismiss the error dialog
        // Navigator.pop(context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainHome()),
        // );
        debugPrint("Database connected, not popping context.");
      } else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initYearsDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

  userAddButtonDisable(bool bb) {
    showadduser = bb;
    notifyListeners();
  }

  setaDDUserError(String er) {
    adduserError = Text(er);
    notifyListeners();
  }

/////////////////////////////////////////////////
  createFloorCardsNew(
      String date, String cn, String ph, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    os = await prefs.getString("os");
    print("Flt_Sp_Create_Floor_Cards_As_Customer '$os','$ph','$cn'");
    try {
      var res = await SqlConn.readData(
          "Flt_Sp_Create_Floor_Cards_As_Customer '$os','$ph','$cn'");
      var map = jsonDecode(res);
      // SqlConn.disconnect();
      if (map.isNotEmpty) {
        print("Creating MAP----$map");
        print("newcustomer------------>>$res");

        prefs.setInt("CardID", map[0]['Card_ID']);
        card_id = map[0]['Card_ID'].toString();
        notifyListeners();
        cardNoctrl.text = map[0]['Card_Name'].toString().trimLeft();
        setcusnameAndPhone(cn, ph, context);
        userAddButtonDisable(false);
        setaDDUserError(" ");
        typlock = true;
        igno = false;
        // getUsedBags(context, date, card_id);
        notifyListeners();
        print(
            "card ID--Name---Contact------->$card_id--$cus_name--$cus_contact");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Customer Added ",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('OK'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      else{
print("Not Created");
      }

      
    }
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   // Handle the PlatformException here
    //   // You can log the exception, display an error message, or take other appropriate actions
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected) {
        // If connected, do not pop context as it may dismiss the error dialog
        // Navigator.pop(context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainHome()),
        // );
        debugPrint("Database connected, not popping context.");
      } else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initYearsDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

///////////////////////////////////////////////
  getUsedBags(BuildContext context, String date, String cardid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    os = await prefs.getString("os");
    try {
      var res = await SqlConn.readData(
          "Flt_Sp_Used_Bags_For_Card '$date',$card_id,'$os'");
      var map = jsonDecode(res);
      // SqlConn.disconnect();
      usedbagList.clear();
      allbagallcount = 0;
      notifyListeners();
      for (var item in map) {
        usedbagList.add(item);
      }
      print("used bag list------------>>$res");
      for (int i = 0; i < usedbagList.length; i++) {
        allbagallcount =
            allbagallcount + int.parse(usedbagList[i]["Cnt"].toString());
        print("alll count======$allbagallcount");
        notifyListeners();
      }

      notifyListeners();
    } on PlatformException catch (e) {
      print("PlatformException occurredcttr: $e");
      SqlConn.disconnect();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Connection Lost...! ",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Reconnect'),
                onPressed: () async {
                  await initYearsDb(context, "");
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      // Handle the PlatformException here
      // You can log the exception, display an error message, or take other appropriate actions
    } catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
  }

/////////////////////////////////////////////////////
  getUsedBagsItems(BuildContext context, String date, int slot_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    os = await prefs.getString("os");
    isbagloading = true;
    notifyListeners();
    try {
      var res = await SqlConn.readData(
          "Flt_Sp_GetSaved_Fb_Items '$date',$card_id,$slot_id,'$os'");
      var map = jsonDecode(res);
      usedbagITEMList.clear();
      itemSortedList.clear();
      floor_totl.clear();
      all_total = 0.0;
      notifyListeners();
      for (var item in map) {
        usedbagITEMList.add(item);
        int fbNo = item['FB_No'];
        if (!itemSortedList.containsKey(fbNo)) {
          itemSortedList[fbNo] = [];
        }
        itemSortedList[fbNo]!.add(item);
      }

      itemSortedList.forEach((key, value) {
        double sum = 0;
        for (var element in value) {
          sum += element['Amount'];
        }
        floor_totl[key] = sum;
        notifyListeners();
        print("fffffffffffffffffffffffffoooooooooooooooooo${floor_totl[key]}");
      });
      all_total = floor_totl.values.fold(0, (prev, value) => prev + value);
      notifyListeners();

      print("used bag ITEMS------------>>$usedbagITEMList");
      print("SorteD ITEMS------------>>$itemSortedList");
      isbagloading = false;
      notifyListeners();

      // throw PlatformException(
      //   code: 'ERROR',
      //   message: 'Network error IOException: failed to connect...',
      // );
    }
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   print(e);
    //   return null;
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
  }

  clearunsaved() {
    unsavedList.clear();
    notifyListeners();
  }

  ////////////////////////////////////////
  getUnsavedCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("cardNo", cardNo);
    os = await prefs.getString("os");
    print(
      'os ----- $os, cardId ------->$card_id, cart No----------$cart_id',
    );
    // await initYearsDb(context, "");

    unsavedList.clear();
    notifyListeners();
    try {
      cartloading = true;
      notifyListeners();
      var res = await SqlConn.readData(
          "Flt_Sp_Get_Unsaved_FBCart '$cart_id','$card_id','$os'");
      var map = jsonDecode(res);
      // SqlConn.disconnect();
      print("unsaved cart------------>>$res");

      for (var item in map) {
        unsavedList.add(item);
      }

      notifyListeners();
      qty =
          List.generate(unsavedList.length, (index) => TextEditingController());
      persntage =
          List.generate(unsavedList.length, (index) => TextEditingController());
      print("Unsaved List ==$unsavedList");
      unsaved_tot = 0.0;
      notifyListeners();
      for (int i = 0; i < unsavedList.length; i++) {
        qty[i].text = unsavedList[i]["Cart_Qty"].toString();
        persntage[i].text = unsavedList[i]["Cart_Disc_Per"].toString();
        unsaved_tot = unsaved_tot +
            double.parse(unsavedList[i]["Total"].toStringAsFixed(2));
        print('unsaved total :$unsaved_tot');
        notifyListeners();
      }
      cartloading = false;

      notifyListeners();
    }
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   // Handle the PlatformException here
    //   // You can log the exception, display an error message, or take other appropriate actions
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    } finally {
      if (SqlConn.isConnected) {
        // If connected, do not pop context as it may dismiss the error dialog
        // Navigator.pop(context);

        debugPrint("Database connected, not popping context.");
      } else {
        // If not connected, pop context to dismiss the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Not Connected.!",
                    style: TextStyle(fontSize: 13),
                  ),
                  SpinKitCircle(
                    color: Colors.green,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await initYearsDb(context, "");
                    Navigator.of(context).pop();
                  },
                  child: Text('Connect'),
                ),
              ],
            );
          },
        );
        debugPrint("Database not connected, popping context.");
      }
    }
  }

//////////////////////////////////////////////
  clearCardID(String c) {
    card_id = c;

    cardNoctrl.clear();
    ccfon.clear();
    ccname.clear();
    usedbagITEMList.clear();
    len = 0;
    unsavedList.clear();
    itemSortedList.clear;
    setbagerror("");

    notifyListeners();
  }

  getFBList(String date, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? os = await prefs.getString("os");
    int car;
    card_id == 0 ? car = 0 : car = int.parse(card_id);

    print("Flt_Sp_Get_Fb_List------$date----$os----$car");
    try {
      fbListLoading = true;
      notifyListeners();
      var res = await SqlConn.readData("Flt_Sp_Get_Fb_List '$date',$car,'$os'");
      var map = jsonDecode(res);
      fbList.clear();
      if (map != null) {
        for (var item in map) {
          fbList.add(item);
        }
        fbResulList = fbList;
        isSearch = false;
      }
      print("fbList-----$res");
      fbListLoading = false;

      notifyListeners();
    } catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
    if (SqlConn.isConnected == false) {
      print("hi");
      //   // SharedPreferences prefs = await SharedPreferences.getInstance();
      //   // String? os = prefs.getString("os");
      //   // String? cn = prefs.getString("cname");
      //   // if (incorect) {
      //   //   CustomSnackbar snackbar = CustomSnackbar();
      //   //   snackbar.showSnackbar(context, "Incorrect Username or Password", "");
      //   //   //  Navigator.pop(context);
      //   //   exit(0);
      //   // } else {
      //   //   Navigator.push(
      //   //     context,
      //   //     MaterialPageRoute(builder: (context) => MainHome()),
      //   //   );
      //   // }
      //   // If connected, do not pop context as it may dismiss the error dialog

      //   // Navigator.push(
      //   //   context,
      //   //   MaterialPageRoute(builder: (context) => MainHome()),
      //   // );

      //   debugPrint("Database connected, not popping context.");
      // }
      //  else {
      // If not connected, pop context to dismiss the dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Not Connected.!",
                  style: TextStyle(fontSize: 13),
                ),
                SpinKitCircle(
                  color: Colors.green,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await initYearsDb(context, "");
                  Navigator.of(context).pop();
                },
                child: Text('Connect'),
              ),
            ],
          );
        },
      );
      debugPrint("Database not connected, popping context.");
    }
  }

  getDELList(String b_no, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? os = await prefs.getString("os");
    int car;
    card_id == "" ? car = 0 : car = int.parse(card_id);
    delListLoading = true;
    deliveryBillList.clear();
    sortedDelvryList.clear();
    delList.clear();
    notifyListeners();
    print("tabl para---------$os----$b_no");
    try {
      var res = await SqlConn.readData(
          "Flt_Sp_BillList_For_Delivery_SearchAll '$os','$b_no'");
      var map = jsonDecode(res);

      if (map != null) {
        for (var item in map) {
          delList.add(item);
        }
        deliveryBillList = delList.where((map) => map['Paid'] == 1).toList();
        for (var item in deliveryBillList) {
          int fbNo = item['Bill_No'];

          if (sortedDelvryList.containsKey(fbNo)) {
            sortedDelvryList[fbNo]!.add(item);
          } else {
            sortedDelvryList[fbNo] = [item];
          }
        }
        notifyListeners();

        // delResulList = delList;
        // isDelSearch = false;
      }
      print("delList-----$res");
      print("deliveryBillList-----$deliveryBillList");
      print("sorted====>$sortedDelvryList");
      // Map so = {
      //   1237: [
      //     {
      //       'Bill_No': 1237,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 13886.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 21,
      //       'Slot_ID': 19,
      //       'Slot_Name': 'D1',
      //       'Paid': 1,
      //     },
      //     {
      //       'Bill_No': 1237,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 13886.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 20,
      //       'Slot_ID': 20,
      //       'Slot_Name': 'D2',
      //       'Paid': 1,
      //     },
      //   ],
      //   123757: [
      //     {
      //       'Bill_No': 123757,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 12886.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 21,
      //       'Slot_ID': 19,
      //       'Slot_Name': 'D1',
      //       'Paid': 1,
      //     },
      //     {
      //       'Bill_No': 123757,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 12886.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 20,
      //       'Slot_ID': 20,
      //       'Slot_Name': 'D2',
      //       'Paid': 1,
      //     },
      //   ],
      //   34566: [
      //     {
      //       'Bill_No': 34566,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 1280.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 21,
      //       'Slot_ID': 19,
      //       'Slot_Name': 'D1',
      //       'Paid': 1,
      //     },
      //     {
      //       'Bill_No': 34566,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 1280.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 20,
      //       'Slot_ID': 20,
      //       'Slot_Name': 'D2',
      //       'Paid': 1,
      //     },
      //   ],
      //   99999: [
      //     {
      //       'Bill_No': 99999,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 12886.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 21,
      //       'Slot_ID': 19,
      //       'Slot_Name': 'D1',
      //       'Paid': 1,
      //     },
      //     {
      //       'Bill_No': 99999,
      //       'Bill_Date': '2024-02-23 00:00:00.0',
      //       'Amount': 12886.0,
      //       'CardID': 5007,
      //       'CardNo': 'HJ004',
      //       'Cust_Name': 'dhanush',
      //       'Cust_Phone': 9544533972,
      //       'Fb_No': 20,
      //       'Slot_ID': 20,
      //       'Slot_Name': 'D2',
      //       'Paid': 1,
      //     },
      //   ],
      // };
      Map so = {
        123761: [
          {
            'Bill_No': 123761,
            'Bill_Date': '2024-02-27 00:00:00.0',
            'Amount': 3297.0,
            'CardID': 4998,
            'CardNo': 1002,
            'Cust_Name': 'test',
            'Cust_Phone': 1234567890,
            'Slots': 'A1',
            'Fb': '30, 47, 48',
            'Paid': 1
          },
          {
            'Bill_No': 123761,
            'Bill_Date': '2024-02-27 00:00:00.0',
            'Amount': 3297.0,
            'CardID': 4998,
            'CardNo': 1006,
            'Cust_Name': 'test',
            'Cust_Phone': 1234567890,
            'Slots': 'A1',
            'Fb': '30, 47, 48',
            'Paid': 1
          }
        ],
        12376: [
          {
            'Bill_No': 12376,
            'Bill_Date': '2024-02-27 00:00:00.0',
            'Amount': 3297.0,
            'CardID': 4998,
            'CardNo': 1002,
            'Cust_Name': 'test',
            'Cust_Phone': 1234567890,
            'Slots': 'A1',
            'Fb': '30, 47, 48',
            'Paid': 1
          }
        ]
      };
      // getDelwidget(so, context);
      getDelwidget(sortedDelvryList, context);
      // getDelwidget(so, context);
      delListLoading = false;

      notifyListeners();
    }
    // on PlatformException catch (e) {
    //   print("PlatformException occurredcttr: $e");
    //   SqlConn.disconnect();
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "Connection Lost...! ",
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           ],
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             style: TextButton.styleFrom(
    //               textStyle: Theme.of(context).textTheme.labelLarge,
    //             ),
    //             child: const Text('Reconnect'),
    //             onPressed: () async {
    //               await initYearsDb(context, "");
    //               // Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   print(e);
    //   return null;
    // }
    catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
    if (SqlConn.isConnected == false) {
      print("hi");
      //   // SharedPreferences prefs = await SharedPreferences.getInstance();
      //   // String? os = prefs.getString("os");
      //   // String? cn = prefs.getString("cname");
      //   // if (incorect) {
      //   //   CustomSnackbar snackbar = CustomSnackbar();
      //   //   snackbar.showSnackbar(context, "Incorrect Username or Password", "");
      //   //   //  Navigator.pop(context);
      //   //   exit(0);
      //   // } else {
      //   //   Navigator.push(
      //   //     context,
      //   //     MaterialPageRoute(builder: (context) => MainHome()),
      //   //   );
      //   // }
      //   // If connected, do not pop context as it may dismiss the error dialog

      //   // Navigator.push(
      //   //   context,
      //   //   MaterialPageRoute(builder: (context) => MainHome()),
      //   // );

      //   debugPrint("Database connected, not popping context.");
      // }
      //  else {
      // If not connected, pop context to dismiss the dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Not Connected.!",
                  style: TextStyle(fontSize: 13),
                ),
                SpinKitCircle(
                  color: Colors.green,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await initYearsDb(context, "");
                  Navigator.of(context).pop();
                },
                child: Text('Connect'),
              ),
            ],
          );
        },
      );
      debugPrint("Database not connected, popping context.");
    }
  }

  getDelwidget(Map sorted, BuildContext context) {
    print("====fhhhhhhhh");
    List<Map<String, dynamic>> billDetails = [];
    int billNo = 0;
    delWidget.clear();
    notifyListeners();
    delWidget.add(ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        //             scrollDirection: Axis.vertical,
        // shrinkWrap: true, physics: ScrollPhysics(),scrollDirection: Axis.vertical,
        itemCount: sorted.keys.length,
        itemBuilder: (context, index) {
          billNo = sorted.keys.elementAt(index);
          print("bill==$billNo");
          billDetails = sorted[billNo]!;
          print("billdata==${sorted[billNo]}");
          double amt = billDetails[0]['Amount'];
          String fb = billDetails[0]['Fb'].toString().trimLeft();
          String slt = billDetails[0]['Slots'].toString().trimLeft();

          return Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black45)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Color.fromARGB(255, 174, 198, 238),
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ' Bill No# $billNo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "${amt.toStringAsFixed(2)} \u20B9 ",
                            // widget.slotname,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: billDetails.length,
                      itemBuilder: (context, index) {
                        Map details = billDetails[index];
                        return Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          height: 40,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/card.png",
                                    height: 27,
                                    width: 27,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    details['CardNo'].toString().trimLeft(),
                                    // widget.slotname,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(" - "),
                                  Row(
                                    children: [
                                     
                                      Text("${details['Cust_Phone']
                                          .toString()
                                          .trimLeft()} / "),
                                           Text(
                                          "${details['Cust_Name'].toString().trimLeft()}",),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          // Add more details to display if needed
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/bagimg.png",
                                color: Color.fromARGB(255, 61, 131, 63),
                                height: 27,
                                width: 27,
                              ),
                              Text(
                                 " ${slt.toString()}",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/floor.png",
                                height: 27,
                                width: 27,
                              ),
                              Text(
                                 " ${fb.toString()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,overflow: TextOverflow.ellipsis
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 35,
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                getDelivery(billNo, context);
                                Provider.of<Controller>(context, listen: false)
                                    .getDELList("0", context);
                                CustomSnackbar snackbar = CustomSnackbar();
                                snackbar.showSnackbar(
                                    context, "Item Delevered...", "");
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 189, 104, 104)),
                              child: Text(
                                "DELIVER",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          );
        }));

    notifyListeners();
  }

/////////////////////////////////////
  getDeliveryBillList(int b_no, BuildContext context) async {
    try {
      deliveryBillList.clear();
      sortedDelvryList.clear();
      resultList.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? os = await prefs.getString("os");

      print("DeliveryBill para----------$os-----$b_no");

      var res =
          await SqlConn.readData("Flt_Sp_BillList_For_Delivery '$os',$b_no");
      var map = jsonDecode(res);
      print("deliveryB-----$map");
      deliveryBillList.clear();
      sortedDelvryList.clear();
      if (map != null) {
        List tempdelvery = [];
        for (var item in map) {
          tempdelvery.add(item);
          notifyListeners();
        }

        deliveryBillList =
            tempdelvery.where((map) => map['Paid'] == 1).toList();
        for (var item in deliveryBillList) {
          int fbNo = item['Bill_No'];

          if (!sortedDelvryList.containsKey(fbNo)) {
            sortedDelvryList[fbNo] = [];
          }
          sortedDelvryList[fbNo]!.add(item);
        }

        resultList = sortedDelvryList;
      }

      print("deliveryBillList-----$deliveryBillList");
      print("sortttttt$sortedDelvryList");
      notifyListeners();
    } on PlatformException catch (e) {
      print("PlatformException occurredcttr: $e");
      SqlConn.disconnect();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Connection Lost...! ",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Reconnect'),
                onPressed: () async {
                  await initYearsDb(context, "");
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print(e);
      return null;
    } catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
  }

  //////////////////////////////////////
  getDelivery(int b_no, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? os = await prefs.getString("os");
    try {
      print("DeliveryBill para----------$os-----$b_no");

      var res =
          await SqlConn.readData("Flt_Sp_UpdateBills_For_Delivery '$os',$b_no");
      var map = jsonDecode(res);
      print("deliveryBilUpdate-----$map");
      deliveryBillList.clear();
      notifyListeners();
    } on PlatformException catch (e) {
      print("PlatformException occurredcttr: $e");
      // await SqlConn.disconnect();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Not Connected.! ",
                  style: TextStyle(fontSize: 18),
                ),
                SpinKitCircle(
                  color: Colors.green,
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Connect'),
                onPressed: () async {
                  await initYearsDb(context, "");
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print(e);
      return null;
    } catch (e) {
      print("An unexpected error occurred: $e");
      // Handle other types of exceptions
    }
  }

  searchItem(String key) {
    // resultList.clear();
    if (key != null) {
      int keyy = int.parse(key);
      sortedDelvryList.containsKey(keyy);
      isSearch = true;
      notifyListeners();
      resultList[keyy] = sortedDelvryList[keyy]!;
    } else {
      isSearch = false;
      resultList = sortedDelvryList;
      notifyListeners();
    }
    notifyListeners();
  }

  searchCard(String key) {
    print(key);

    if (key != null) {
      isSearch = true;
      fbListLoading = true;
      notifyListeners();
      fbResulList = fbList
          .where((e) => e["CardNo"]
              .toString()
              .trimLeft()
              .toLowerCase()
              .contains(key.toLowerCase()))
          .toList();

      print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$fbResulList");
      fbListLoading = false;
      notifyListeners();
    } else {
      isSearch = false;
      fbResulList = fbList;

      notifyListeners();
    }
    notifyListeners();
  }

  searchDelevery(String key) {
    print(key);

    if (key != null) {
      isDelSearch = true;
      notifyListeners();
      delResulList = delList
          .where((e) => e["Bill_No"]
              .toString()
              .trimLeft()
              .toLowerCase()
              .contains(key.toLowerCase()))
          .toList();

      print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$fbResulList");

      notifyListeners();
    } else {
      isDelSearch = false;
      delResulList = delList;
      notifyListeners();
    }
    notifyListeners();
  }

  ////////////////////////////////////
  setDate(String date1, String date2) {
    fromDate = date1;
    todate = date2;
    print("gtyy----$fromDate----$todate");
    notifyListeners();
  }

  ///////////////////////////////////////////////////////
  setQty(int allowdec, int index, String type) {
    if (allowdec == 1) {
      if (type == "inc") {
        double d = double.parse(qty[index].text) + 0.25;
        qty[index].text = d.toString();
        discount_calc(index, "from add");
        notifyListeners();
      } else if (type == "dec") {
        if (double.parse(qty[index].text) > 1) {
          double d = double.parse(qty[index].text) - 0.25;
          qty[index].text = d.toString();
          notifyListeners();
        } else {
          isAdded[index] = false;
          notifyListeners();
        }
        discount_calc(index, "from add");
        notifyListeners();
      }
    } else {
      if (type == "inc") {
        double d = double.parse(qty[index].text) + 1.0;
        qty[index].text = d.toString();
        discount_calc(index, "from add");
        notifyListeners();
      } else if (type == "dec") {
        if (double.parse(qty[index].text) > 1) {
          double d = double.parse(qty[index].text) - 1.0;
          qty[index].text = d.toString();
          notifyListeners();
        } else {
          isAdded[index] = false;
          notifyListeners();
        }
        discount_calc(index, "from add");
        notifyListeners();
      }
    }
  }

  ///////////////////////////////////
  totalItemCount(String val, String type) {
    if (type == "inc") {
      itemcount = itemcount + double.parse(val);
      notifyListeners();
    } else if (type == "dec") {
      if (itemcount > 1) {
        itemcount = itemcount - double.parse(val);
        notifyListeners();
      }
    }
    print("object$itemcount");
  }

  ///////////////........................../////////////////////////////
  setCatID(String id, BuildContext context) {
    catlID = id;

    print("catlID----$catlID");
    notifyListeners();
  }

  setcusnameAndPhone(String na, String ph, BuildContext context) {
    cus_name = na;
    cus_contact = ph;
    ccname.text = cus_name.toString();
    ccfon.text = cus_contact.toString();
    notifyListeners();
    print("getcusnamfon---->$cus_name , $cus_contact");
    print("catlID----$catlID");
  }

///////////////////////////////////////////
  setslotID(List l) {
    slotIds = l;
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////////////
  getComnameAndUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    os = await prefs.getString("os");
    cName = await prefs.getString("cname");
    userName = await prefs.getString("st_uname");
    notifyListeners();
  }
}
