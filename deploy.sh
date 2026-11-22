prompt_var() {
    local var_name="$1" default="$2" prompt="$3" mode="$4"
    local input val

    if [[ "$mode" == "secret" ]]; then
        read -rsp "$prompt: " input
        echo ""
    else
        read -rp "$prompt: " input
    fi

    val="${input:-$default}"

    if [[ "$mode" == "bool" ]]; then
        case "${val,,}" in
            t|true) val="true" ;;
            *)      val="false" ;;
        esac
    fi

    export "$var_name"="$val"
    echo ""
}

prompt_var SPACEAGE        "false"                    "Enable the Space Age expansion? (true/[false])" bool
prompt_var SERVER_NAME     "My Server"                "Enter Server name (Default: 'My Server')"
prompt_var PORT            "34197"                    "Enter Server Port (Default: 34197)"
prompt_var COUNT           "8"                        $'Enter max player count (Default: 8)'
prompt_var MOTD            "Welcome to $SERVER_NAME"  $'Enter Server description\n(Default: Welcome to '"$SERVER_NAME"')'
prompt_var ADMIN_USER      ""                         $'Enter your factorio.com username for server admin\n(Default: None)'
prompt_var AUTH_TOKEN      ""                         $'Enter your factorio.com Auth Token to make server publicly visible\n(Default: None)' secret
prompt_var SERVER_PASSWORD ""                         $'Enter server password (Default: none)' secret

if [ -f "namespace.yml" ]; then
    echo "Applying namespace.yml..."
    kubectl apply -f namespace.yml
fi
for file in *.yml; do
    [ -e "$file" ] || continue
    echo "Applying $file..."
    envsubst < "$file" | sed 's/_DOLLAR_/\$/g' | kubectl apply -f -
done