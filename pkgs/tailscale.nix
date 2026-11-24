{ tailscale, fetchFromGitHub }:

tailscale.overrideAttrs (_: rec {
  version = "1.104.6";
  vendorHash = "sha256-IJ0m56UP0RyMBE5eQeQ082EMJZfvrgE37lfPHE2ujCA=";
  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    tag = "v${version}";
    hash = "sha256-oF3izFlknJRuEYp3rw1urN4XKZPvjtda6lsIw9arRvs=";
  };
})
