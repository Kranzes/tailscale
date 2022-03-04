{ lib, stdenv, buildGoApplication, self, version, makeWrapper, iptables, iproute2, procps }:

buildGoApplication rec {
  pname = "tailscale";
  inherit version;
  src = self;
  modules = ./gomod2nix.toml;

  nativeBuildInputs = lib.optionals stdenv.isLinux [ makeWrapper ];

  subPackages = [ "cmd/tailscale" "cmd/tailscaled" ];

  buildFlagsArray = [ "-ldflags=-X tailscale.com/version.Long=${version}" "-X tailscale.com/version.Short=${version}" ];

  postInstall = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/tailscale --suffix PATH : ${lib.makeBinPath [ procps ]}
  
    sed -i -e "s#/usr/sbin#$out/bin#" -e "/^EnvironmentFile/d" ./cmd/tailscaled/tailscaled.service
    install -D -m0444 -t $out/lib/systemd/system ./cmd/tailscaled/tailscaled.service
  '';

  # Tests try to access the internet 
  doCheck = false;

  meta = with lib; {
    homepage = "https://tailscale.com";
    description = "The node agent for Tailscale, a mesh VPN built on WireGuard";
    license = licenses.bsd3;
  };
}
