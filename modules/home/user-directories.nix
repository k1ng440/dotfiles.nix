{ config, ... }: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
  };

  home.file = {
    # Documents
    "Documents/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Documents
      Icon=folder-documents
    '';

    # Downloads
    "Downloads/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Downloads
      Icon=folder-download
    '';

    # Pictures
    "Pictures/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Pictures
      Icon=folder-pictures
    '';

    # Music
    "Music/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Music
      Icon=folder-music
    '';

    # Videos
    "Videos/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Videos
      Icon=folder-videos
    '';

    # Desktop
    "Desktop/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Desktop
      Icon=user-desktop
    '';

    # Public
    "Public/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Public
      Icon=folder-publicshare
    '';

    # Templates
    "Templates/.directory".text = ''
      [Desktop Entry]
      LocalizedResourceName=Templates
      Icon=folder-templates
    '';
  };

  gtk = {
    gtk3.bookmarks = [
      "file://${config.xdg.userDirs.desktop} Desktop"
      "file://${config.xdg.userDirs.documents} Documents"
      "file://${config.xdg.userDirs.download} Downloads"
      "file://${config.xdg.userDirs.music} Music"
      "file://${config.xdg.userDirs.pictures} Pictures"
      "file://${config.xdg.userDirs.publicShare} Public"
      "file://${config.xdg.userDirs.templates} Templates"
      "file://${config.xdg.userDirs.videos} Videos"
    ];
  };
}
