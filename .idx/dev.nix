# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages.
  # This setup provides a complete environment for Flutter development.
  packages = [
    # The Flutter SDK. Essential for building Flutter apps.
    pkgs.flutter
    
    # The Dart language SDK.
    pkgs.dart
    
    # Java Development Kit. Required for the Android toolchain and Gradle.
    pkgs.jdk
    
    # Android Debug Bridge (ADB) and other platform tools. Needed to communicate with devices.
    pkgs.android-tools
    
    # Provides SSL certificates for network access, useful for package downloads.
    pkgs.cacert
  ];

  # Sets environment variables in the workspace.
  env = {}; # Cleaned up for the new environment.

  idx = {
    # Search for extensions on https://open-vsx.org/ and use "publisher.id".
    extensions = [
      "dart-code.flutter"
      "dart-code.dart-code"
    ];

    # Workspace lifecycle hooks.
    workspace = {
      # Runs when a workspace is first created.
      onCreate = {
        # Open key files on workspace creation.
        default.openFiles = [ ".idx/dev.nix" "pubspec.yaml" "lib/main.dart" ];
      };
    };
  };
}
