
import '../base/libraryExport.dart';

class LinkUserPartyMasterScreen extends StatefulWidget {
  final  int id;

  const LinkUserPartyMasterScreen({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LinkUserPartyMasterState();
}

class _LinkUserPartyMasterState extends State<LinkUserPartyMasterScreen> {
  List<Map> _list;

  @override
  void initState() {
    super.initState();

    ApiAdmin().getLinkUserPartyMaster(widget.id).then((value) => {
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
        title: Text("Party Master"),
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
                                  PartyMasterViewScreen(id: item['master_id']),
                            ),
                          );
                        },
                        title: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            item['Name'] ?? 'Name Error',
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                }).toList()),
    );
  }
}
