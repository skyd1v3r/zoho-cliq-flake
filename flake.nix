{
  description = "Zoho Cliq flake package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.zoho-cliq = pkgs.callPackage ./default.nix { };
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.zoho-cliq;
  };
}
