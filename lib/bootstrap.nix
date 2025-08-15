let
  findProjectRoot =
    path:
    let
      parent = dirOf path;
      flakeExists = builtins.pathExists "${parent}/flake.nix";
    in
    if flakeExists then
      parent
    else if parent == path then
      throw "Could not find project root with flake.nix"
    else
      findProjectRoot parent;
  thisFile = ./bootstrap.nix;
  projectRoot = findProjectRoot (toString thisFile);

  loadEnvVars =
    let
      currentDir = builtins.getEnv "PWD";
      # Check for .env in both current directory and project root
      envFileInPwd = "${currentDir}/.env";
      envFileInProject = "${projectRoot}/.env";
      pwdExists = builtins.pathExists envFileInPwd;
      projectExists = builtins.pathExists envFileInProject;
      # Only consider it a flake check if we're in / or empty AND no .env file exists in project root
      isFlakeCheck = (currentDir == "/" || currentDir == "") && !projectExists;
      defaultEnv = {
        USERNAME = "flake-check-user";
        NAME = "Flake Check User";
        EMAIL = "user@example.com";
        HOSTNAME = "flake-check-host";
      };
      # Prefer .env in current directory, fall back to project root
      envFile = if pwdExists then envFileInPwd else envFileInProject;
    in
    if isFlakeCheck then
      defaultEnv
    else if pwdExists || projectExists then
      let
        envContent = builtins.readFile envFile;
        parseEnvFile =
          content:
          let
            trim =
              s:
              let
                m = builtins.match "^[[:space:]]*(.*[^[:space:]])?[[:space:]]*$" s;
              in
              if m == null then
                s
              else if (builtins.elemAt m 0) == null then
                ""
              else
                (builtins.elemAt m 0);

            lines = builtins.filter (
              line:
              let
                l = trim line;
              in
              l != "" && !(builtins.substring 0 1 l == "#")
            ) (builtins.filter builtins.isString (builtins.split "\n" content));

            parseLine =
              line:
              let
                parts = builtins.split "=" (trim line);
                key = trim (builtins.head parts);
                value = trim (
                  builtins.concatStringsSep "=" (builtins.filter builtins.isString (builtins.tail parts))
                );
                unquoted =
                  if
                    builtins.stringLength value >= 2
                    && builtins.substring 0 1 value == "\""
                    && builtins.substring (builtins.stringLength value - 1) 1 value == "\""
                  then
                    builtins.substring 1 (builtins.stringLength value - 2) value
                  else
                    value;
              in
              {
                name = key;
                value = unquoted;
              };
          in
          builtins.listToAttrs (map parseLine lines);

      in
      parseEnvFile envContent
    else
      throw "Required .env file not found at ${envFileInPwd} or ${envFileInProject}. Please create it with USERNAME, NAME, EMAIL, HOSTNAME variables.";

  envVars = loadEnvVars;
  validateEnv =
    env:
    let
      required = [
        "USERNAME"
        "NAME"
        "EMAIL"
        "HOSTNAME"
      ];
      missing = builtins.filter (key: !(builtins.hasAttr key env)) required;
    in
    if missing != [ ] then
      throw "Missing required environment variables in .env: ${builtins.concatStringsSep ", " missing}"
    else
      env;

  validatedEnv = validateEnv envVars;

in
{
  inherit projectRoot;
  env = validatedEnv;
  userHomeDir = "/home/${validatedEnv.USERNAME}";
  actualProjectPath = builtins.getEnv "PWD";
}
