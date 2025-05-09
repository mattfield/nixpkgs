{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "jql";
  version = "8.0.5";

  src = fetchFromGitHub {
    owner = "yamafaktory";
    repo = "jql";
    rev = "jql-v${version}";
    hash = "sha256-0sQEC2kUnuuKp73DJsNBFB0VL0rkBkudmr7ZQpS1v04=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-10eM7tczFoQVYagyP1btsCp4PHm+zRoh2oAEVVxsROA=";

  meta = with lib; {
    description = "JSON Query Language CLI tool built with Rust";
    homepage = "https://github.com/yamafaktory/jql";
    changelog = "https://github.com/yamafaktory/jql/releases/tag/${src.rev}";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [
      akshgpt7
      figsoda
    ];
    mainProgram = "jql";
  };
}
