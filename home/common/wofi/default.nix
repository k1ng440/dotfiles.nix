_: {
  programs.wofi = {
    enable = true;
    settings = {
      location = "center";
      width = 700;
      height = 420;
      show = "drun";
      allow_markup = true;
      prompt = "";
      normal_window = false;
      allow_images = true;
      term = "kitty";
    };
    style =
      let
        background = "#1d2021";
        foreground = "#d5c4a1";
      in
      ''
        window {
          border-radius: 8px;
          background-color: ${background};
          color: ${foreground};
          /*font-family: "Cantarell";*/
          font-size: 17px;
          margin: 0;
          padding: 0;
        }

        #input {
          margin: 8px;
          padding: 6px;
          border: none;
          border-radius: 10px;
          background-color: rgba(0,0,0,0.1);
          color: #ffffff;
        }

        #entry {
          padding: 8px;
          margin: 4px;
          border-radius: 0;
          border: 0;
          color: #ffffff;
        }

        #entry:selected {
          background-color: #5c7070;
          border: solid 2px;
          color: #000000;
        }

        #outer-box, #inner-box, #scroll {
          margin: 0;
          padding: 0;
        }

        #img {
          margin-right: 8px;
        }

        image, label {
          box-shadow: none;
        }
      '';
  };
}
