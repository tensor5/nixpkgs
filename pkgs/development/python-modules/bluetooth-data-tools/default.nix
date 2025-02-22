{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cryptography,
  cython,
  poetry-core,
  pytest-benchmark,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bluetooth-data-tools";
  version = "1.20.0";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "bluetooth-data-tools";
    tag = "v${version}";
    hash = "sha256-qg2QZc95DD2uTO0fTwoNaPfL+QSrcqDwJvx41lIZDRs=";
  };

  # The project can build both an optimized cython version and an unoptimized
  # python version. This ensures we fail if we build the wrong one.
  env.REQUIRE_CYTHON = 1;

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  dependencies = [ cryptography ];

  nativeCheckInputs = [
    pytest-benchmark
    pytest-cov-stub
    pytestCheckHook
  ];

  pytestFlagsArray = [ "--benchmark-disable" ];

  pythonImportsCheck = [ "bluetooth_data_tools" ];

  meta = with lib; {
    description = "Library for converting bluetooth data and packets";
    homepage = "https://github.com/Bluetooth-Devices/bluetooth-data-tools";
    changelog = "https://github.com/Bluetooth-Devices/bluetooth-data-tools/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
