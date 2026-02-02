# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use for package versions.
  channel = "stable-24.05"; # Using a stable channel for reproducibility.

  # This setup provides a complete environment for Flutter and Dart development,
  # specifically for building Android applications.
  packages = [
    # The Flutter SDK. Essential for building Flutter apps.
    pkgs.flutter

    # The Dart language SDK. Useful for Dart-specific tools.
    pkgs.dart

    # Java Development Kit. Required for the Android toolchain and running Gradle.
    pkgs.jdk

    # The full Android SDK, including platform-tools, build-tools, and command-line tools.
    # We are overriding it to automatically accept the licenses, which is necessary
    # for the tools to run without manual intervention.
    (pkgs.android-sdk.override { acceptAndroidSdkLicenses = true; })
  ];

  # Sets environment variables in the workspace.
  env = {
    # Set the ANDROID_HOME to the path provided by the Nix android-sdk package.
    # This allows Flutter and Gradle to find the Android SDK.
    ANDROID_HOME = "${pkgs.android-sdk}/share/android-sdk";
  };

  idx = {
    # Recommended VS Code extensions for Flutter and Dart development.
    extensions = [
      "dart-code.flutter" # The main Flutter extension.
      "dart-code.dart-code" # The main Dart extension.
    ];

    # Workspace lifecycle hooks.
    workspace = {
      # Runs when a workspace is first created to finalize the setup.
      onCreate = {
        # Run `flutter doctor` to verify the environment and download any remaining
        # Android build dependencies. This is a crucial step for a healthy environment.
        flutter-doctor = "flutter doctor";
      };

      # Runs when the workspace is (re)started.
      onStart = {
        # Inform the user that the environment is ready.
        echo-ready = "echo 'Complete Flutter environment is ready. Run `flutter doctor` to verify.'";
      };
    };
  };
}