

import '../base/libraryExport.dart';
import 'WebViewFlutter.dart';

class OrderSummeryScreen extends StatefulWidget {
  final List<CartSummery> summery;

  const OrderSummeryScreen({Key key, this.summery}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderSummeryState();
}

class _OrderSummeryState extends State<OrderSummeryScreen> {
  TextEditingController _orderRemark = TextEditingController();
  TextEditingController _billAddress = TextEditingController();
  TextEditingController _gstNumber = TextEditingController();
  TextEditingController _emailId = TextEditingController();
  TextEditingController _pinCode = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _name = TextEditingController();

  UserProfile profile;
  String paymentCode;
  var orderNumber;

  _bookOrderNow() {
    AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.RIGHSLIDE,
            headerAnimationLoop: false,
            title: 'Required',
            desc: 'Required',
            body: Text('Confirmation place order'),
            btnOkText: 'Place Order',
            btnOkOnPress: () {
              List<String> unit = List<String>();
              List<String> amount = List<String>();
              List<String> product = List<String>();
              List<String> quantity = List<String>();
              List<String> productId = List<String>();
              List<String> extraParams = List<String>();
              widget.summery.forEach((element) {
                productId.add(element.id.toString());
                quantity.add(element.controller.text);
                amount.add(element.amount);
                unit.add(element.unit);
                product.add(element.product);
                extraParams.add(element.extraParams);
              });

              Map<String, dynamic> params = Map<String, dynamic>();

              params['user_id'] = '';
              params['address1'] = '';
              params['address2'] = '';

              params['email'] = _emailId.text;
              params['firm_name'] = _name.text;
              params['pincode'] = _pinCode.text;
              params['remark'] = _orderRemark.text;
              params['address'] = _billAddress.text;
              params['gstNumber'] = _gstNumber.text;
              params['contact_number'] = _mobile.text;

              var id = profile == null ? '' : profile.id;
              params['btob_id'] = id;
              params['account_name_id'] = id;

              params['unit'] = unit;
              params['amount'] = amount;
              params['product'] = product;
              params['quantity'] = quantity;
              params['product_id'] = productId;

              params['parms'] = extraParams;
              params['orderFormData'] = List<String>();

              print(params.toString());
              ProgressDialog dialog =
                  ProgressDialog(context, isDismissible: false);
              dialog.style(
                  message: 'Please Wait...',
                  progressWidget: CircularProgressIndicator());
              dialog.show();
              ApiClient().addBooking(params).then((value) => {
                    orderNumber = value.data['result'],

                    print(value),
                    dialog.hide(),

                    AwesomeDialog(
                        title: 'Success',
                        context: context,
                        animType: AnimType.SCALE,
                        dismissOnTouchOutside: false,
                        btnOkIcon: Icons.check_circle,
                        dialogType: DialogType.SUCCES,
                        desc:
                            'Thank you, your order #$orderNumber has been successfully completed!',
                        btnOkOnPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => SplashScreen(),
                            ),
                          );
                        }).show(),

                    //{"status":"200","message":"success","result":3585}
                    AppPreferences.setString(AppConstants.USER_CART_DATA,
                        jsonEncode(List<String>())),
                  });
            },
            btnOkIcon: Icons.cancel,
            btnOkColor: Colors.red)
        .show();
  }

  @override
  void initState() {
    super.initState();

    ApiClient().getPaymentButton().then((value) => {
          setState(() {
            print(value.data);
            Map response = value.data;
            if (response['status'] == '200') {
              paymentCode = response['result']['payment_code'];
              print('Payment Code $paymentCode');
            }
          }),
        });

    String key = AppConstants.USER_LOGIN_CREDENTIAL;
    AppPreferences.getString(key).then((credential) => {
          setState(() {
            UserLogin login = UserLogin.formJson(credential);
            if (login.isMaster && login.isLogin) {
              String key = AppConstants.USER_LOGIN_DATA;
              AppPreferences.getString(key).then((value) => {
                    setState(() {
                      Map response = jsonDecode(value);
                      profile = UserProfile.fromJson(response);
                      _billAddress.text = profile.address.trim();
                      _gstNumber.text = profile.gstIn.trim();
                      _emailId.text = profile.email.trim();
                      _mobile.text = profile.phone.trim();
                      _name.text = profile.name.trim();
                    }),
                  });
            }
          }),
        });
  }

  Widget getItemList() {
    var grandTotalAmount = 0.00;
    var variantWidgets = List<Widget>();
    variantWidgets.add(Row(children: <Widget>[
      Expanded(
        flex: 1,
        child: Text(
          'Item',
          style: TextStyle(
            fontSize: 15,
            color: Colors.blue.shade300,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Center(
          child: Text(
            'Rate',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blue.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Center(
          child: Text(
            'Amt',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blue.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ]));
    variantWidgets.add(Divider());
    variantWidgets.addAll(widget.summery.map((cart) {
      double counter = double.tryParse(cart.controller.text) ?? 1;
      double amount = double.tryParse(cart.amount) ?? 0.00;
      int gst = int.tryParse(cart.gstRate) ?? 0;

      double subAmount = double.parse((counter * amount).toStringAsFixed(2));
      double gstAmount =
          double.parse(((counter * amount * gst) / 100).toStringAsFixed(2));
      double totalAmount =
          double.parse(((counter * amount) + gstAmount).toStringAsFixed(2));
      grandTotalAmount =
          double.parse((grandTotalAmount += totalAmount).toStringAsFixed(2));
      return Column(
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    cart.product + ' - ' + cart.extraParams,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Qty - ' + cart.controller.text,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '₹ $subAmount + ₹ $gstAmount',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '(GST $gst%)',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '₹ ${(totalAmount).toStringAsFixed(2)}',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ]),
          Divider()
        ],
      );
    }).toList());

    variantWidgets.add(Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: 1,
            ),
          ),
          Text(
            'Total Amt : ₹ ${(grandTotalAmount).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 15, color: Colors.blue.shade300),
          )
        ],
      ),
    ));
    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12),
      width: MediaQuery.of(context).size.width,
      child: Column(children: variantWidgets),
    );
  }

  Widget getShippingForm() {
    var variantWidgets = List<Widget>();

    variantWidgets.add(SizedBox(height: 20.0));
    variantWidgets.add(
      Center(
        child: Text(
          'BILLING SHIPPING INFO',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    variantWidgets.add(SizedBox(height: 20.0));
    variantWidgets.add(TextFormField(
      autofocus: false,
      controller: _name,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Firm Name',
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.business),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ));
    variantWidgets.add(SizedBox(height: 6.0));
    variantWidgets.add(TextFormField(
      autofocus: false,
      controller: _mobile,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Phone Number',
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.phone),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ));
    variantWidgets.add(SizedBox(height: 6.0));
    variantWidgets.add(TextFormField(
      autofocus: false,
      controller: _emailId,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Email Id',
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.email),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ));
    variantWidgets.add(SizedBox(height: 6.0));
    variantWidgets.add(TextFormField(
      autofocus: false,
      controller: _gstNumber,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        hintText: 'GST-IN',
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.insert_comment),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ));
    variantWidgets.add(SizedBox(height: 6.0));
    variantWidgets.add(TextFormField(
      maxLines: null,
      autofocus: false,
      controller: _billAddress,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Address',
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.map),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ));
    variantWidgets.add(SizedBox(height: 6.0));
    variantWidgets.add(TextFormField(
      autofocus: false,
      controller: _pinCode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Pin Code',
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.fiber_pin),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ));
    variantWidgets.add(SizedBox(height: 6.0));
    variantWidgets.add(TextFormField(
      maxLines: null,
      autofocus: false,
      controller: _orderRemark,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        filled: true,
        hintText: 'Remark',
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.mode_comment),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ));
    variantWidgets.add(SizedBox(height: 30.0));

    return Container(
      padding: EdgeInsets.all(12),
      decoration: new BoxDecoration(
          color: Colors.blue.shade300,
          border: new Border.all(color: Colors.grey.shade50, width: 1),
          borderRadius: new BorderRadius.circular(12.0)),
      width: MediaQuery.of(context).size.width,
      child: Column(children: variantWidgets),
    );
  }

  Widget getSubmitButton() {
    return Row(
      children: <Widget>[
        SizedBox(width: 16),
        getPaymentButton(),
        SizedBox(width: 6),
        Expanded(
          child: GFButton(
              size: 45,
              text: 'PAY LATER',
              color: Colors.blue.shade300,
              fullWidthButton: true,
              onPressed: () {
                if (_name.text.length > 4 &&
                    _mobile.text.length > 9 &&
                    _billAddress.text.length > 4) {
                  _bookOrderNow();
                }
                // Error
                else {
                  AwesomeDialog(
                          context: context,
                          dialogType: DialogType.ERROR,
                          animType: AnimType.RIGHSLIDE,
                          headerAnimationLoop: false,
                          title: 'Required',
                          desc: 'Name, Phone or Address is required',
                          btnOkOnPress: () {},
                          btnOkIcon: Icons.cancel,
                          btnOkColor: Colors.red)
                      .show();
                }
              }),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget getPaymentButton() {
    return paymentCode == null
        ? SizedBox(width: 0)
        : Expanded(
            child: GFButton(
                size: 45,
                text: 'PAY NOW',
                fullWidthButton: true,
                type: GFButtonType.outline,
                onPressed: () {
                  if (_name.text.length > 4 &&
                      _mobile.text.length > 9 &&
                      _billAddress.text.length > 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            WebViewFlutter(paymentCode: paymentCode),
                      ),
                    ).then(
                      (value) => _bookOrderNow(),
                    );
                  }
                  // Error
                  else {
                    AwesomeDialog(
                            context: context,
                            dialogType: DialogType.ERROR,
                            animType: AnimType.RIGHSLIDE,
                            headerAnimationLoop: false,
                            title: 'Required',
                            desc: 'Name, Phone and Address is required',
                            btnOkOnPress: () {},
                            btnOkIcon: Icons.cancel,
                            btnOkColor: Colors.red)
                        .show();
                  }
                }),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Order summary'),
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(12),
            children: <Widget>[
              getItemList(),
              getShippingForm(),
            ],
          ),
        ),
        getSubmitButton(),
        SizedBox(height: 16),
      ]),
    );
  }

//prefixIcon: Image(image: AssetImage('assets/search_field.png')),
}
