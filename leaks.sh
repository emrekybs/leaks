
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi


domain=$1

data_leakage_paths=(
    "/.git" "/.env" "/.htaccess" "/.htpasswd" "/.DS_Store" "/.svn" "/.gitignore"
    "/robots.txt" "/sitemap.xml" "/backup" "/dump" "/config" "/config.php"
    "/wp-config.php" "/.backup" "/.mysql_history" "/.bash_history" "/.ssh"
    "/phpinfo.php" "/info.php" "/readme.html" "/README.md" "/LICENSE"
    "/admin" "/cgi-bin" "/server-status" "/server-info" "/.dockerenv"
    "/docker-compose.yml" "/api" "/.gitlab-ci.yml" "/debug" "/cache"
    "/.user.ini" "/secret" "/.idea" "/.vscode" "/error_log" "/access_log"
    "/.mailrc" "/.forward" "/.rnd" "/.gemrc" "/.bashrc" "/.profile"
    "/.viminfo" "/.vimrc" "/.netrc" "/.ssh/authorized_keys" "/.ssh/id_rsa"
    
)

function check_path {
    local url=$1
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    if [ "$response" -eq 200 ]; then
        echo -e "${RED}Warning: Potential data leakage at $url${NC}"
    else
        echo -e "${GREEN}Normal: No data leakage at $url (status code: $response)${NC}"
    fi
}

function try_both_protocols {
    local path=$1
    local https_url="https://$domain$path"
    local http_url="http://$domain$path"

    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$https_url")
    if [ "$response" -eq 200 ]; then
        check_path "$https_url"
    else
       
        check_path "$http_url"
    fi
}

for path in "${data_leakage_paths[@]}"; do
    try_both_protocols "$path"
done

