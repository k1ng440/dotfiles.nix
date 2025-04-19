{ hostSpec, ... }:
{
  programs.git = {
    # userName = hostSpec.userFullName;
    # userEmail = hostSpec.email.work;
    enable = true;
  };
}
