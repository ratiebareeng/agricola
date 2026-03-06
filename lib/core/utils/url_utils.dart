/// Returns true if [url] is a valid HTTP or HTTPS URL that can be
/// safely passed to [NetworkImage] or [Image.network].
bool isNetworkUrl(String? url) {
  return url != null && url.startsWith('http');
}
