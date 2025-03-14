{
  lib,
  buildPgrxExtension,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  postgresql,

  # buildInputs
  openblas,
  openssl,

  # nativeBuildInputs
  cmake,
  llvmPackages,
  python3,
  rustfmt,
}:

buildPgrxExtension rec {
  inherit postgresql;

  pname = "pgml";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "postgresml";
    repo = "postgresml";
    rev = "v${version}";
    hash = "sha256-FfhGPitkpuiUQtczjR06Y4IVQbOw/VFXWfHmURLgKmo=";
  };

  sourceRoot = "${src.name}/pgml-extension";

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "lightgbm-0.2.3" = "sha256-9BJjlL7shDajPGv6o3EFSXQ32CiZHfWwMnzvM7iL3CY=";
      "linfa-0.7.0" = "sha256-qGwu0mk/opc+b72kO9KVgLY9hdc2BPkSMNU58SAKx10=";
      "xgboost-0.2.0" = "sha256-8m8GSi8n9ZfS6RmyF5HO0gyv4vr35aK3qmQ6AtbbTEk=";
    };
  };

  buildInputs = [
    openblas
    openssl
  ];

  nativeBuildInputs = [
    cmake
    llvmPackages.bintools
    python3
    # Using buildPgrxExtension fake rustfmt makes lightgbm-sys output empty
    # bindings.
    rustfmt
  ];

  # See comment above.
  useFakeRustfmt = false;


doCheck = false;
  # Check phase fails without this.
  checkFeatures = [ "python" ];

  passthru = {
    tests = nixosTests.postgresql.pgml.passthru.override postgresql;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Postgres with GPUs for ML/AI apps";
    homepage = "https://postgresml.org/";
    downloadPage = "https://github.com/postgresml/postgresml";
    changelog = "https://github.com/postgresml/postgresml/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [
      lib.maintainers.tensor5
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
