{ pkgs, ... }: {
  # =================================================================================
  #
  #  AMBIENTE DE DESENVOLVIMENTO NIX PARA PROJETO FLUTTER
  #
  #  Este arquivo define o ambiente de desenvolvimento para um projeto Flutter
  #  usando o Nix. Ele garante uma configuração consistente e reproduzível
  #  para todos os desenvolvedores.
  #
  # =================================================================================

  # ---------------------------------------------------------------------------------
  #  Canal Nixpkgs
  #  Define a versão do conjunto de pacotes Nix a ser utilizado.
  #  'stable-24.05' garante reprodutibilidade e estabilidade.
  # ---------------------------------------------------------------------------------
  channel = "stable-24.05";

  # ---------------------------------------------------------------------------------
  #  Pacotes do Sistema
  #  Lista de ferramentas e SDKs necessários para o desenvolvimento.
  # ---------------------------------------------------------------------------------
  packages = [
    # SDK do Flutter. Essencial para compilar e rodar o app.
    # Inclui o SDK do Dart automaticamente.
    pkgs.flutter

    # JDK (Java Development Kit). Necessário para a toolchain do Android (Gradle).
    pkgs.jdk

    # SDK completo do Android.
    # A configuração 'override' aceita as licenças automaticamente,
    # o que é crucial para a automação em ambientes como o IDX.
    (pkgs.android-sdk.override { acceptAndroidSdkLicenses = true; })

    # Utilitário para criar arquivos ZIP.
    pkgs.zip
  ];

  # ---------------------------------------------------------------------------------
  #  Variáveis de Ambiente
  #  Configura variáveis de ambiente para o workspace.
  # ---------------------------------------------------------------------------------
  env = {
    # Aponta para o local do SDK do Android instalado pelo Nix.
    # Permite que o Flutter e o Gradle encontrem o SDK.
    ANDROID_HOME = "${pkgs.android-sdk}/share/android-sdk";
  };

  # ---------------------------------------------------------------------------------
  #  Configurações Específicas do IDX
  #  Customizações para o ambiente do Google IDX.
  # ---------------------------------------------------------------------------------
  idx = {
    # Extensões recomendadas do VS Code para desenvolvimento Flutter e Dart.
    extensions = [
      "dart-code.flutter"   # Extensão principal para Flutter.
      "dart-code.dart-code" # Extensão principal para Dart.
    ];

    # Hooks do ciclo de vida do Workspace.
    workspace = {
      # Comandos executados na criação inicial do workspace.
      onCreate = {
        # Garante que o ambiente Flutter está saudável e baixa dependências
        # adicionais do Android. Etapa crucial para a primeira execução.
        flutter-doctor = "flutter doctor";
      };

      # Comandos executados toda vez que o workspace é (re)iniciado.
      onStart = {
        # Mensagem informativa para o usuário.
        echo-ready = "echo 'Ambiente Flutter pronto. Rode `flutter doctor` para verificar.'";
      };
    };
  };
}
