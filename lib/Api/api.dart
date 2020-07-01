import 'dart:convert';
import 'package:http/http.dart' as http;
class CallApi{
  final String _url='https://trading.koffeekodes.com/Auth/';
  postData(data,apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }
  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.get(
        fullUrl,
        headers: _setHeaders()
    );
  }
  _setHeaders()=>{
    'Authorization' :'4ccda7514adc0f13595a585205fb9761',
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
  };
}