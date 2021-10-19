import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'main.dart';

class firstScreen extends StatelessWidget {

  Widget _AlertDialogeBuilder(BuildContext context){
    TextEditingController _controller = TextEditingController();
    return AlertDialog(
      title: Text('Enter URL:'),
      content: Container(
          child:
          TextField(
            controller: _controller,
            onSubmitted: (userURL){
              Player.setPath(userURL, true);
              Navigator.pushNamed(context, '/player');
            },
          )
      ),
      actions: [
        FlatButton(
          child :Text('Close'),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        FlatButton(
            onPressed:(){
              String url = _controller.text;
              Player.setPath(url, true);
              Navigator.pushNamed(context, '/player');
            },
            child: Text('Ok')
        ),

      ],
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/videoPlayer.jpg'),
              fit: BoxFit.cover,
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 20.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.play_circle_fill,
                  size: 250.0,
                  color: Colors.yellow,
                ),
                Text(
                  'Video Player',
                  style: TextStyle(
                    fontSize: 50.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Powered By AI Technologies',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding:EdgeInsets.all(20.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: 130,height: 85),
                    child: ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? res=await FilePicker.platform.pickFiles(type: FileType.video);
                        String? path;
                        if (res!=null)
                          path=res.files.first.path;
                        Player.setPath(path??"", false);
                        Navigator.pushNamed(context, '/player');
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(20.0),
                        backgroundColor: MaterialStateProperty.all(Colors.yellow),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wallpaper,size: 50.0,),
                          Text('Storage',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w900),),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:EdgeInsets.all(20.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: 130,height: 85),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(context: context, builder:(BuildContext context) =>_AlertDialogeBuilder(context));
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(20.0),
                        backgroundColor: MaterialStateProperty.all(Colors.yellow),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_rounded,size: 50.0,),
                          Text('URL',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w900),),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

