enum AssetType {
  logo("logo.png"),
  signature("signature.png"),
  header("header.png"),
  footer("footer.png");

  final String fileName;

  const AssetType(this.fileName);
}