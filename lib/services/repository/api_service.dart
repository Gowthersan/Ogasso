class APIService {
  static const String URL = "ogasso.pivot40.tech";

  static uri(final String path){
    return Uri.https(URL, path);
  }
}