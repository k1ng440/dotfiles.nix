let
  inherit (builtins) readFile;
in
{
  name.long = "Asaduzzaman Pavel";
  name.short = "Pavel";
  username = "k1ng";
  email = "contact@iampavel.dev";
  openpgp.id = "XXXXXXXXXX";
  openpgp.asc = ./k1ng.asc;
  phone = "+880-175-565-5440";
  ssh = readFile ./k1ng.pub;
  image = ./k1ng.jpg;
}
