{ config, lib, pkgs, ... }:

let
  aws-mfa = pkgs.writeShellApplication {
    name = "aws-mfa";
    runtimeInputs = with pkgs; [
      awscli2
      jq
    ];

    text = ''
      MFA_SERIAL_NUMBER=""
      PROFILE_NAME="''${AWS_PROFILE:-default}"
      TOKEN_DURATION="3600"
      TOKEN_CODE=""
      EXPORT_MODE="false"

      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      NC='\033[0m'

      print_usage() {
          echo "Usage: aws-mfa [OPTIONS]"
          echo "Options:"
          echo "  -t, --token-code CODE    MFA token code (required)"
          echo "  -d, --duration SECONDS   Token duration (default: 3600)"
          echo "  -p, --profile PROFILE    AWS profile name (default: default)"
          echo "  -s, --serial SERIAL      MFA device serial number"
          echo "  -e, --export             Export credentials as environment variables"
          echo "  -h, --help               Show this help message"
          echo ""
          echo "Examples:"
          echo "  aws-mfa -t 123456"
          echo "  aws-mfa -t 123456 -d 7200 -p myprofile"
          echo "  aws-mfa -t 123456 --export"
      }

      # Parse command line arguments
      while [[ $# -gt 0 ]]; do
          case $1 in
              -t|--token-code)
                  TOKEN_CODE="$2"
                  shift 2
                  ;;
              -d|--duration)
                  TOKEN_DURATION="$2"
                  shift 2
                  ;;
              -p|--profile)
                  PROFILE_NAME="$2"
                  shift 2
                  ;;
              -s|--serial)
                  MFA_SERIAL_NUMBER="$2"
                  shift 2
                  ;;
              -e|--export)
                  EXPORT_MODE=true
                  shift
                  ;;
              -h|--help)
                  print_usage
                  exit 0
                  ;;
              *)
                  echo -e "''${RED}Unknown option: $1''${NC}"
                  print_usage
                  exit 1
                  ;;
          esac
      done

      if [[ -z "$TOKEN_CODE" ]]; then
          echo -e "''${RED}Error: MFA token code is required''${NC}"
          print_usage
          exit 1
      fi

      if [[ ! "$TOKEN_CODE" =~ ^[0-9]{6}$ ]]; then
          echo -e "''${RED}Error: Token code must be 6 digits''${NC}"
          exit 1
      fi

      echo -e "''${YELLOW}Getting session token with MFA...''${NC}"
      echo "Serial Number: $MFA_SERIAL_NUMBER"
      echo "Token Code: $TOKEN_CODE"
      echo "Duration: $TOKEN_DURATION seconds"
      echo "Profile: $PROFILE_NAME"

      if ! RESPONSE=$(aws sts get-session-token \
          --serial-number "$MFA_SERIAL_NUMBER" \
          --token-code "$TOKEN_CODE" \
          --duration-seconds "$TOKEN_DURATION" \
          --output json); then
          echo -e"''${RED}Error: Failed to get session token''${NC}"
          exit 1
      fi

      ACCESS_KEY_ID=$(echo "$RESPONSE" | jq -r '.Credentials.AccessKeyId')
      SECRET_ACCESS_KEY=$(echo "$RESPONSE" | jq -r '.Credentials.SecretAccessKey')
      SESSION_TOKEN=$(echo "$RESPONSE" | jq -r '.Credentials.SessionToken')
      EXPIRATION=$(echo "$RESPONSE" | jq -r '.Credentials.Expiration')

      echo -e "''${GREEN}Session token retrieved successfully!''${NC}"
      echo "Expires: $EXPIRATION"

      if [[ "$EXPORT_MODE" == "true" ]]; then
          echo ""
          echo -e "''${YELLOW}Export these environment variables:''${NC}"
          echo "export AWS_ACCESS_KEY_ID=\"$ACCESS_KEY_ID\""
          echo "export AWS_SECRET_ACCESS_KEY=\"$SECRET_ACCESS_KEY\""
          echo "export AWS_SESSION_TOKEN=\"$SESSION_TOKEN\""
          echo ""
          echo -e "''${YELLOW}Or run:''${NC}"
          echo "eval \"\$(aws-mfa -t $TOKEN_CODE --export | tail -n +8 | head -n 3)\""
      else
          TEMP_PROFILE="''${PROFILE_NAME}-mfa"
          echo ""
          echo -e "''${YELLOW}Updating AWS credentials for profile: $TEMP_PROFILE''${NC}"

          aws configure set aws_access_key_id "$ACCESS_KEY_ID" --profile "$TEMP_PROFILE"
          aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY" --profile "$TEMP_PROFILE"
          aws configure set aws_session_token "$SESSION_TOKEN" --profile "$TEMP_PROFILE"

          echo -e "''${GREEN}Credentials saved to profile: $TEMP_PROFILE''${NC}"
          echo "Use with: aws --profile $TEMP_PROFILE <command>"
          echo "Or set: export AWS_PROFILE=$TEMP_PROFILE"
      fi
    '';
  };

in {
  programs.bash.shellAliases = {
    aws-mfa-export = "aws-mfa --export";
  };

  programs.zsh.shellAliases = {
    aws-mfa-export = "aws-mfa --export";
  };

  programs.fish.shellAliases = {
    aws-mfa-export = "aws-mfa --export";
  };

  # Optional: Create a quick session helper
  home.packages = [
    aws-mfa
    (pkgs.writeShellApplication {
      name = "aws-session";
      runtimeInputs = [ aws-mfa ];
      text = ''
        if [ $# -eq 0 ]; then
            echo "Usage: aws-session <mfa-code> [duration]"
            echo "This will export the credentials for your current shell"
            exit 1
        fi

        TOKEN_CODE=$1
        DURATION=''${2:-3600}

        echo "Getting AWS credentials..."
        aws-mfa -t "$TOKEN_CODE" -d "$DURATION" --export
        echo ""
        echo "To apply to current shell, run:"
        echo "eval \"\$(aws-session $TOKEN_CODE)\""
      '';
    })
  ];
}
