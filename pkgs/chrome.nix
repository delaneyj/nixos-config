{
  google-chrome,
  fetchurl,
  commandLineArgs ? "",
}:

(google-chrome.override { inherit commandLineArgs; }).overrideAttrs (_: {
  version = "157.0.8103.78";
  src = fetchurl {
    url = "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_157.0.8103.78-1_amd64.deb";
    sha256 = "06vvhsj7mrwacfq8vr02vm20y9ssdanmlb30k1vnhvy9nlv0cx2d";
  };
})
