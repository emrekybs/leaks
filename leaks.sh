#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color


read -p "Enter the target URL: " target_url


data_leakage_paths=(
    "/.git" "/.env" "/.htaccess" "/.htpasswd" "/.DS_Store" "/.svn" "/.well-known"
    "/robots.txt" "/sitemap.xml" "/backup" "/log" "/tmp"
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
