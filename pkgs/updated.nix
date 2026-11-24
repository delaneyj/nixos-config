{
  system ? builtins.currentSystem,
}:

import
  (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/f4a03c008967841f2a0b3cb7c436fc6fc31671f6.tar.gz";
    sha256 = "0x9zk8y0n31hll1alqppw83lz6n0azf4ssja214lw962zgc6f9nf";
  })
  {
    inherit system;
    config.allowUnfree = true;
  }
