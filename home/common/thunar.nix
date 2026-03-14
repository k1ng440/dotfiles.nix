{ pkgs, ... }:
let
  zenity = "${pkgs.zenity}/bin/zenity";
  fileRoller = "${pkgs.file-roller}/bin/file-roller";
  zip = "${pkgs.zip}/bin/zip";
  tar = "${pkgs.gnutar}/bin/tar";
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
  convert = "${pkgs.imagemagick}/bin/convert";
  mediainfo = "${pkgs.mediainfo}/bin/mediainfo";
  pkexec = "${pkgs.polkit}/bin/pkexec";
  shred = "${pkgs.coreutils}/bin/shred";
  sha256sum = "${pkgs.coreutils}/bin/sha256sum";
  chmod = "${pkgs.coreutils}/bin/chmod";
  ln = "${pkgs.coreutils}/bin/ln";
  mount = "/run/wrappers/bin/mount";
  thunar = "${pkgs.thunar}/bin/thunar";
  terminal = "${pkgs.kitty}/bin/kitty";
  catfish = "${pkgs.catfish}/bin/catfish";
  code = "${pkgs.vscode}/bin/code";
  nvim = "${pkgs.neovim}/bin/nvim";
  git = "${pkgs.git}/bin/git";
in
{
  xdg.configFile."Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
      <!-- ───────────────── SEARCH / NAVIGATION ───────────────── -->

      <action>
        <icon>org.xfce.catfish</icon>
        <name>Search with Catfish</name>
        <unique-id>catfish-search-1710430000</unique-id>
        <command>${catfish} --path=%f</command>
        <description>Search for files in this folder</description>
        <patterns>*</patterns>
        <directories/>
      </action>

      <!-- ───────────────── FILE OPERATIONS ───────────────── -->

      <action>
        <icon>link</icon>
        <name>Create Symlink</name>
        <unique-id>symlink-1710430001</unique-id>
        <command>${ln} -s %f "%f (link)"</command>
        <description>Create a symbolic link</description>
        <patterns>*</patterns>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <action>
        <icon>edit-copy</icon>
        <name>Copy Path to Clipboard</name>
        <unique-id>copy-path-1710430010</unique-id>
        <command>sh -c "echo -n %f | ${wlCopy}"</command>
        <description>Copy the full file path to the clipboard (Wayland)</description>
        <patterns>*</patterns>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <unique-id>terminal-here-1710430011</unique-id>
        <command>${terminal} --working-directory=%d</command>
        <description>Open a terminal in this folder</description>
        <patterns>*</patterns>
        <directories/>
      </action>

      <action>
        <icon>edit-delete</icon>
        <name>Shred (Secure Delete)</name>
        <unique-id>shred-1710430012</unique-id>
        <command>sh -c "${shred} -u %F &amp;&amp; ${zenity} --info --text='File(s) securely deleted.'"</command>
        <description>Securely overwrite and delete file(s)</description>
        <patterns>*</patterns>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <action>
        <icon>system-run</icon>
        <name>Make Executable</name>
        <unique-id>chmod-exec-1710430040</unique-id>
        <command>sh -c "${chmod} +x %F &amp;&amp; ${zenity} --info --text='chmod +x applied.'"</command>
        <description>Mark file(s) as executable</description>
        <patterns>*</patterns>
        <other-files/>
        <text-files/>
      </action>

      <!-- ───────────────── EDITORS ───────────────── -->

      <action>
        <icon>vscode</icon>
        <name>Open in Code</name>
        <unique-id>vscode-1710430002</unique-id>
        <command>${code} %f</command>
        <description>Open folder or file in VS Code</description>
        <patterns>*</patterns>
        <directories/>
        <text-files/>
      </action>

      <action>
        <icon>text-editor</icon>
        <name>Open in Neovim</name>
        <unique-id>neovim-1710430041</unique-id>
        <command>${terminal} -e "${nvim} '%f'"</command>
        <description>Open file in Neovim</description>
        <patterns>*</patterns>
        <text-files/>
        <other-files/>
      </action>

      <!-- ───────────────── ADMIN ───────────────── -->

      <action>
        <icon>dialog-password</icon>
        <name>Open as Root</name>
        <unique-id>root-thunar-1710430003</unique-id>
        <command>${pkexec} ${thunar} %f</command>
        <description>Open current folder with administrative privileges</description>
        <patterns>*</patterns>
        <directories/>
      </action>

      <!-- ───────────────── ARCHIVES ───────────────── -->

      <action>
        <icon>ark</icon>
        <name>Extract Here</name>
        <unique-id>extract-1710430004</unique-id>
        <command>${fileRoller} --extract-to=%d %F</command>
        <description>Extract archive to current folder</description>
        <patterns>*.tar;*.tar.gz;*.zip;*.rar;*.7z;*.tar.xz</patterns>
        <other-files/>
      </action>

      <action>
        <icon>package-x-generic</icon>
        <name>Compress to zip</name>
        <unique-id>compress-zip-1710430020</unique-id>
        <command>sh -c "${zip} -r '%f.zip' %F"</command>
        <description>Compress selected file(s) into a zip archive</description>
        <patterns>*</patterns>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <action>
        <icon>package-x-generic</icon>
        <name>Compress to tar.gz</name>
        <unique-id>compress-targz-1710430021</unique-id>
        <command>sh -c "${tar} czf '%f.tar.gz' %F"</command>
        <description>Compress selected file(s) into a tar.gz archive</description>
        <patterns>*</patterns>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <!-- ───────────────── MEDIA ───────────────── -->

      <action>
        <icon>image-x-generic</icon>
        <name>Convert Image to PNG</name>
        <unique-id>convert-png-1710430031</unique-id>
        <command>sh -c "${convert} '%f' '%f.png' &amp;&amp; ${zenity} --info --text='Converted to %f.png'"</command>
        <description>Convert image to PNG using ImageMagick</description>
        <patterns>*.jpg;*.jpeg;*.webp;*.bmp;*.gif;*.tiff</patterns>
        <image-files/>
      </action>

      <action>
        <icon>dialog-information</icon>
        <name>Media Info</name>
        <unique-id>mediainfo-1710430032</unique-id>
        <command>sh -c "${mediainfo} '%f' | ${zenity} --text-info --title='Media Info: %n' --width=700 --height=500"</command>
        <description>Show media information for this file</description>
        <patterns>*.mp4;*.mkv;*.avi;*.mov;*.mp3;*.flac;*.ogg;*.wav;*.webm</patterns>
        <audio-files/>
        <video-files/>
      </action>

      <!-- ───────────────── DEVELOPMENT ───────────────── -->

      <action>
        <icon>git</icon>
        <name>Git Log Here</name>
        <unique-id>git-log-1710430042</unique-id>
        <command>${terminal} --working-directory=%d -e "${git} log --oneline --graph --decorate"</command>
        <description>Show git log for this directory</description>
        <patterns>*</patterns>
        <directories/>
      </action>

      <!-- ───────────────── SYSTEM / MISC ───────────────── -->

      <action>
        <icon>org.xfce.thunar-bulkrename</icon>
        <name>Bulk Rename</name>
        <unique-id>bulk-1710430005</unique-id>
        <command>${thunar} --bulk-rename %F</command>
        <description>Open Thunar Bulk Rename</description>
        <patterns>*</patterns>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <action>
        <icon>document-properties</icon>
        <name>SHA256 Checksum</name>
        <unique-id>sha256-1710430050</unique-id>
        <command>sh -c "${sha256sum} %F | ${zenity} --text-info --title='SHA256 Checksum' --width=600 --height=200"</command>
        <description>Show SHA256 checksum of selected file(s)</description>
        <patterns>*</patterns>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <action>
        <icon>drive-optical</icon>
        <name>Mount ISO as Loop</name>
        <unique-id>mount-iso-1710430051</unique-id>
        <command>sh -c "${pkexec} ${mount} -o loop '%f' /mnt/loop &amp;&amp; ${zenity} --info --text='Mounted at /mnt/loop'"</command>
        <description>Mount ISO image at /mnt/loop (requires /mnt/loop to exist)</description>
        <patterns>*.iso;*.img</patterns>
        <other-files/>
      </action>

    </actions>
  '';
}
