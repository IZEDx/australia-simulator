import 'package:start/start.dart';

main() {
  print("Hosting Web Server on port 3000");
  start(host: '0.0.0.0', port: 3000).then((Server app) {
    app.static('./build/web');
  });
}