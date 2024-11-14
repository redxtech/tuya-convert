{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          packages = let
            sslpsk = pkgs.python3.pkgs.buildPythonPackage {
              pname = "sslpsk";
              version = "1.0.0";
              src = pkgs.fetchFromGitHub {
                owner = "drbild";
                repo = "sslpsk";
                rev = "d88123a75786953f82f5e25d6c43d9d9259acb62";
                hash = "sha256-RqaZLtRMzYJPKXBBsw1alujGyqWAQRSQLPyAR8Zi6t4=";
              };
              buildInputs = with pkgs; [ openssl.dev ];
            };

            pythonWithPackages = pkgs.python3.withPackages (ps:
              with ps; [
                pip
                setuptools
                wheel
                pycryptodomex
                paho-mqtt
                tornado
                sslpsk
              ]);
          in with pkgs; [
            git
            iw
            dnsmasq
            util-linux
            hostapd
            screen
            curl
            pythonWithPackages
            mosquitto
            haveged
            nettools
            openssl
            openssl.dev
            iproute2
            iputils

            # build-essential
            dpkg
            gcc
            libgcc
            libcxx
            gnumake
          ];
        };
      };
      flake = { };
    };
}
