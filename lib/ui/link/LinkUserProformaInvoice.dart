
import '../base/libraryExport.dart';

class LinkUserProformaInvoiceScreen extends StatefulWidget {
  final  int id;

  const LinkUserProformaInvoiceScreen({Key key, this.id})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LinkUserProformaInvoiceState();
}

class _LinkUserProformaInvoiceState
    extends State<LinkUserProformaInvoiceScreen> {
  List<Map> _list;

  @override
  void initState() {
    super.initState();

    ApiAdmin().getLinkUserProformaInvoice(widget.id).then((value) => {
          setState(() {
            Map<String, dynamic> response = value.data;

            _list = List<Map>();
            if (response['status'] == '200') {
              response['result'].forEach((value) {
                _list.add(value);
              });
            }
            print(response);
          }),
        });
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
        title: Text('Proforma Invoice'),
      ),
      body: _list == null
          ? Container(
              width: MediaQuery.of(context).size.height,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: GFLoader(loaderColorOne: Colors.white),
              ),
            )
          : _list.isEmpty
              ? Container(
                  width: MediaQuery.of(context).size.height,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Text(
                      'Empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : ListView(
                  children: _list.map((item) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProformaInvoiceViewScreen(
                                id: item['invoice_id'].toString(),
                              ),
                            ),
                          );
                        },
                        title: Text(item['invoice_no']),
                        subtitle: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(item['invoice_name']),
                            ),
                            Text(item['invoice_date'])
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  );
                }).toList()),
    );
  }
}
