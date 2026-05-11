import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseService {
  static final String? BASE_URL = dotenv.env['URL_BASE_API']; 
}
