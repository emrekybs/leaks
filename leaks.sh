#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color


read -p "Enter the target URL: " target_url


data_leakage_paths=(
    "/.git" "/.env" "/.htaccess" "/.htpasswd" "/.DS_Store" "/.svn" "/.well-known"
    "/robots.txt" "/sitemap.xml" "/backup" "/log" "/tmp" "/config" "/db"
    "/sql" "/install" "/setup" "/dump" "/config.php" "/wp-config.php"
    "/.backup" "/.mysql_history" "/.bash_history" "/.ssh" "/phpinfo.php"
    "/info.php" "/readme.html" "/README.md" "/LICENSE" "/admin" "/.gitignore"
    "/cgi-bin" "/server-status" "/server-info" "/test" "/tests" "/vendor"
    "/node_modules" "/.npm" "/.dockerenv" "/docker-compose.yml" "/.travis.yml"
    "/api" "/.gitlab-ci.yml" "/debug" "/cache" "/.httr-oauth" "/.user.ini"
    "/secret" "/.idea" "/.vscode" "/.history" "/.babelrc" "/.eslintrc"
    "/.prettierrc" "/yarn.lock" "/package-lock.json" "/package.json"
    "/gulpfile.js" "/webpack.config.js" "/error_log" "/access_log" "/.mailrc"
    "/.forward" "/.fetchmailrc" "/.rnd" "/.gemrc" "/.irb_history"
    "/.python_history" "/.php_history" "/.perl_history" "/.ksh_history"
    "/.bash_logout" "/.logout" "/.bashrc" "/.profile" "/.cshrc" "/.tcshrc"
    "/.zshrc" "/.viminfo" "/.vimrc" "/.exrc" "/.netrc" "/.tigrc" "/.inputrc"
    "/.cvsrc" "/.pypirc" "/.hgrc" "/.bash_aliases" "/.aliases" "/.rhosts"
    "/.shosts" "/.ssh/authorized_keys" "/.ssh/config" "/.ssh/id_dsa"
    "/.ssh/id_ecdsa" "/.ssh/id_ed25519" "/.ssh/id_rsa" "/.ssh/known_hosts"
)


visited_urls=()

function crawl_and_check {
    local url="$1"

    
    if [[ "${visited_urls[@]}" =~ "${url}" ]]; then
        return
    fi

    
    visited_urls+=("$url")

    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")

   
    if [ "$response" -eq 200 ]; then
     
        echo -e "${RED}Warning: Potential data leakage at $url${NC}"

      
        links=$(curl -s "$url" | grep -o '<a [^>]*href="[^"]*"' | grep -o 'href="[^"]*"' | cut -d'"' -f2)

       
        for link in $links; do
           
            if [[ "$link" == /* ]]; then
              
                full_url="${target_url}${link}"
          
                crawl_and_check "$full_url"
            fi
        done
    else
       
        echo -e "${GREEN}Normal: No data leakage at $url (status code: $response)${NC}"
    fi
}


for path in "${data_leakage_paths[@]}"; do
    full_url="${target_url}${path}"
    
    crawl_and_check "$full_url"
done
