{
  flake.templates = {
    rust = {
      path = ./templates/rust;
      description = "Rust Template using fenix, devenv, and flake-parts";
    };
    empty = {
      path = ./templates/empty;
      description = "Empty Template using devenv and flake-parts";
    };
    callPackage = {
      path = ./templates/callPackage;
      description = "Simply create a package via callPackage";
    };
  };
}
