import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'firstScreen.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'ConvertImage.dart';
import 'package:image/image.dart' as imglib;
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'dart:async' as asy;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:file_picker/file_picker.dart';

late List<CameraDescription> cameras;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => firstScreen(),
        '/player': (context) => Player(),
      },
      initialRoute: '/',
    );
  }
}

class Player extends StatefulWidget {
  static String path = "";
  static bool isURL = false;
  static void setPath(String p, bool URL) {
    path = p;
    isURL = URL;
  }

  @override
  _MyAppState createState() => _MyAppState(path, isURL);
}

class _MyAppState extends State<Player> {
  String path = "";
  bool isURL = false;
  asy.Timer? timer;
  String gesture="";

  late CameraController cameraController;
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  int videoInSeconds = 0;

  _MyAppState(String p, bool URL) {
    path = p;
    isURL = URL;
  }

  void initializeCamera() async {
    cameraController = CameraController(cameras[1], ResolutionPreset.low);
    cameraController.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      setState(() {});
      /*
      cameraController.startImageStream((CameraImage img) async {
        // img is the current frame
        imglib.Image converted = convertImagetoPng(img);
        uploadImageToServer( await File('image.png').writeAsBytes(imglib.encodePng(converted)) );
      });
      */


    });

  }

  void takePhoto() async
  {
    XFile xf = await cameraController.takePicture();
    print(xf.path);
    File f = File(xf.path);
    File? f2 = await FlutterImageCompress.compressAndGetFile(f.path,f.path+'123.jpg');
    if (f2 != null)
      uploadImageToServer(f2);

  }

  void PickImage() async{
    FilePickerResult? res=await FilePicker.platform.pickFiles(type: FileType.image);
    if (res!=null){
      uploadImageToServer(File(res.files.first.path!));
    }
  }

  uploadImageToServer(File imageFile) async
  {
    print('attempting to connect to server……');
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    print(length);
    var uri = Uri.parse('http://192.168.191.181:5000/');
    print('connection established.');
    var request = new http.MultipartRequest('POST', uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
    filename: basename(imageFile.path));
    request.files.add(multipartFile);
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    print('response=' + respStr);
    takeAction(respStr);
  }

  void takeAction(String action){
    setState(() {
      if (!mounted) return;
      gesture = action;
    });
    if (action == 'None')
      return;
    if (action == 'Palm')
      StartPause();
    if (action == 'Rock')
      seekForward();
    if (action == 'Fist')
      seekBackward();
    if (action == 'Four')
      volumeUP();
    if (action == 'Startrek')
      volumeDown();

  }

  void volumeUP() async{
    double x = _controller.value.volume;
    x += 0.3;
    double newx = x <= 1.0 ? x : 1.0;
    await _controller.setVolume(newx);
  }

  void volumeDown() async{
    double x = _controller.value.volume;
    x -= 0.3;
    double newx = x >= 0.0 ? x : 0.0;
    await _controller.setVolume(newx);
  }

  void initializePlayer() async {
    if (isURL) {
      _controller = VideoPlayerController.network(
        path,
      );
    } else {
      _controller = VideoPlayerController.file(
        new File(path),
      );
    }

    await Future.wait([
      _controller.initialize(),
    ]);

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
    );
    setState(() {});
    calcVideoInSeconds();
  }


  void calcVideoInSeconds() {
    Duration video = _controller.value.duration;
    videoInSeconds = video.inSeconds;
  }

  void StartPause() async {
    if (_controller.value.isPlaying) {
      _controller.pause();
    }
    else
      _controller.play();
  }

  void seekForward() async {
    Duration x = _controller.value.position;
    int sc = x.inSeconds;
    sc += 5;
    int newsc = sc <= videoInSeconds ? sc : videoInSeconds;
    Duration y = Duration(seconds: newsc);
    await _controller.seekTo(y);
  }

  void seekBackward() async {
    Duration x = _controller.value.position;
    int sc = x.inSeconds;
    sc -= 5;
    int newsc = sc >= 0 ? sc : 0;
    Duration y = Duration(seconds: newsc);
    await _controller.seekTo(y);
  }

  @override
  void initState() {
    initializeCamera();
    initializePlayer();
    timer = asy.Timer.periodic(Duration(seconds: 2), (asy.Timer t) => takePhoto());
    super.initState();
  }

  @override
  void dispose() async {
    timer!.cancel();
    cameraController.dispose();
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: /*Center(
          child: FlatButton(
            color: Colors.red,
            child: Text('press'),
            onPressed: PickImage,
          ),
        )*/
      SafeArea(
        child: _chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Stack(
                    children :[
                      Chewie(
                      controller: _chewieController!,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 3.5,
                            child: Column(
                              children: [
                                Expanded(child: CameraPreview(cameraController),flex: 8,),
                                Expanded(child: Text(gesture,style: TextStyle(color: Colors.green,fontSize: 26),),flex: 1,),
                              ],
                            )
                        ),
                      )
                    ]
                  )



                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
        )
    );
  }
}
