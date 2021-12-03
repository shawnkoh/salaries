{
  description = "Developer Salaries";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    devShell.x86_64-darwin = with nixpkgs.legacyPackages.x86_64-darwin; mkShell
      {
        name = "my-shell";
        buildInputs = [
          nodejs
          elmPackages.elm
          elmPackages.elm-format
          elmPackages.elm-live
        ];
      };
  };
}
