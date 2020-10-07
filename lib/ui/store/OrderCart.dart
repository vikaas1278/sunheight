

import '../base/libraryExport.dart';
import 'OrderSummery.dart';
import 'ProductSearch.dart';

class OrderCartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OrderCartScreenState();
}

class _OrderCartScreenState extends State<OrderCartScreen> {
  List<CartSummery> cartSummery = List<CartSummery>();

  @override
  void initState() {
    super.initState();
    initCart();
  }

  void initCart() {
    AppPreferences.getString(AppConstants.USER_CART_DATA).then((value) => {
      if (value != null)
        {
          setState(() {
            cartSummery = List<CartSummery>();
            for (Map json in jsonDecode(value)) {
              cartSummery.add(CartSummery.fromJson(json));
            }
          })
        }
    });
  }

  void goAllProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ProductSearchScreen(
          isBack: true,
        ),
      ),
    ).then((value) => initCart());
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
        title: Text('Cart'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_shopping_cart,
              color: Colors.white,
            ),
            onPressed: () {
              goAllProduct();
            },
          )
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: cartSummery.length == 0
              ? Center(
            child: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                goAllProduct();
              },
            ),
          )
              : ListView.builder(
            itemCount: cartSummery.length,
            itemBuilder: (BuildContext context, int index) {
              CartSummery item = cartSummery[index];
              return Card(
                elevation: 8.0,
                child: ListTile(
                  leading: FadeInImage.assetNetwork(
                    image: item.image,
                    placeholder: 'images/iv_empty.png',
                    height: 80,
                    width: 60,
                  ),
                  title: Row(children: <Widget>[
                    Expanded(
                      child: Text(
                        item.product,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_shopping_cart,
                          color: Colors.deepOrange),
                      onPressed: () {
                        AwesomeDialog(
                            title: 'Remove',
                            context: context,
                            dialogType: DialogType.ERROR,
                            animType: AnimType.BOTTOMSLIDE,
                            desc: 'Are you sure, you want to remove',
                            btnCancelOnPress: () {
                              print('Cancel On Pressed');
                            },
                            btnOkOnPress: () {
                              setState(() {
                                cartSummery.removeWhere((itemToCheck) =>
                                itemToCheck.id == item.id);
                                String key = AppConstants.USER_CART_DATA;
                                AppPreferences.setString(
                                    key, jsonEncode(cartSummery));
                                print(jsonEncode(cartSummery));
                                print('Item Removed');
                              });
                            }).show();
                      },
                    ),
                  ]),
                  subtitle: Row(children: <Widget>[
                    Text(
                      '₹ ${cartSummery[index].amount}/-',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        String value = item.controller.text;
                        if (int.parse(value) > 1) {
                          item.controller.text =
                              (int.parse(value) - 1).toString();
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        controller: item.controller,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        int value = int.tryParse(item.controller.text);
                        int stock = int.tryParse(item.stock);
                        value = value + 1;

                        if (item.checkStock == '0') {
                          item.controller.text = value.toString();
                        }
                        //
                        else if (stock >= value) {
                          item.controller.text = value.toString();
                        }
                        //
                        else {
                          AwesomeDialog(
                              title: 'Overflow',
                              context: context,
                              desc: 'Only $stock items in stock',
                              headerAnimationLoop: false,
                              animType: AnimType.TOPSLIDE,
                              dialogType: DialogType.WARNING,
                              btnOkOnPress: () {})
                              .show();
                        }
                      },
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
          height: 55,
          onPressed: () {
            if (cartSummery.length > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        OrderSummeryScreen(summery: cartSummery)),
              );
            } else {
              AwesomeDialog(
                  title: 'Empty',
                  context: context,
                  desc: 'your cart is empty',
                  headerAnimationLoop: false,
                  animType: AnimType.TOPSLIDE,
                  dialogType: DialogType.WARNING,
                  btnOkOnPress: () {})
                  .show();
            }
          },
          color: Colors.lightBlueAccent,
          child: Text(
            'ORDER SUMMARY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}
