{ pkgs, ... }:
{
  imports = [
    ./aws
  ];

  home.packages = with pkgs; [
    act
    ansible
    awscli2
    azure-cli
    eksctl
    kind
    kubelogin-oidc
    kubernetes-helm
    kubeseal
    minio-client
    mysql-client
    openstackclient
    swiftclient
    # terraform
    kubectl
    tilt
    kubernetes-polaris
    fzf
    kubeshark
    k3d
    k9s
    (writeShellApplication {
      name = "kctx";
      runtimeInputs = [
        kubectl
        fzf
      ];
      text = ''
        kubectl config get-contexts -o name \
        | fzf --height=10 \
        | xargs kubectl config use-context
      '';
    })
    (writeShellApplication {
      name = "kctn";
      runtimeInputs = [
        kubectl
        fzf
      ];
      text = ''
        kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
          | fzf --height=10 \
          | xargs kubectl config set-context --current --namespace
      '';
    })
  ];
}
