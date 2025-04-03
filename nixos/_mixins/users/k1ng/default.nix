{ username, ... }: {
  users.users.${username} = {
    description = "Asaduzzaman Pavel";
    # mkpasswd -m sha-512
    hashedPassword = "$6$GmGSaCgKe/tG.Wcy$fuhpDvDyhRkvyIOswz5zVawcXrq5GUmCoWnlXZvyu1OLtN3RlMnCQGZZ4BtffH1tLeWV3cgiGcgIH8qVWAg7v.";
  };
  # systemd.tmpfiles.rules = [ "d /mnt/snapshot/${username} 0755 ${username} users" ];
}
