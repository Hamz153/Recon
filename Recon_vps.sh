#!/bin/bash -x

wordlist="/root/Tools/SecLists/Discovery/DNS/all.txt"
resolvers="/root/resolvers.txt"
#Directory making and replacing output files are coming soon

#mkdir -p /root/Document/recon/$ip /root/Document/recon/$ip/subdomain /root/Document/recon/$ip/shuffeldns /root/Document/recon/$ip/httpx /root/Document/recon/$ip/wayback /root/Document/recon/$ip/ffuf /root/Document/recon/$ip/gf /root/Document/recon/$ip/unfurl /root/Document/recon/$ip/massdns_ip /root/Document/recon/$ip/nuclei /root/Document/recon/$ip/Directory_BruteForcing /root/Document/recon/$ip/Naabu /root/Document/recon/$ip/Katana

# Get IP address or file name containing IPs
read -p "Enter IP address or file name containing IPs: " input

# Run subfinder, assetfinder, and amass on each IP and store results
if [[ -f "$input" ]]; then
  for ip in $(cat $input); do
    
    mkdir -p /root/Document/recon /root/Document/recon/$ip /root/Document/recon/$ip/subdomain /root/Document/recon/$ip/shuffeldns /root/Document/recon/$ip/httpx /root/Document/recon/$ip/wayback /root/Document/recon/$ip/ffuf /root/Document/recon/$ip/gf /root/Document/recon/$ip/unfurl / root/Document/recon/massdns_ip /root/Document/recon/$ip/nuclei /root/Document/recon/$ip/Directory_BruteForcing /root/Document/recon/$ip/Naabu /root/Document/recon/$ip/Katana
    subfinder -d $ip >> /root/Document/recon/$ip/subdomain/$ip/subfinder_$ip.txt
    assetfinder $ip >> /root/Document/recon/$ip/subdomain/$ip/assetfinder_$ip.txt
    amass enum -passive -d $ip >> /root/Document/recon/$ip/subdomain/$ip/amass_$ip.txt
    shuffledns -d $domain -w $wordlist -r $resolvers >> /root/Document/recon/$ip/subdomain/$ip/shuffledns_$ip.txt
  done
else
  ip=$input
  mkdir -p /root/Document/recon /root/Document/recon/$ip /root/Document/recon/$ip/subdomain /root/Document/recon/$ip/shuffeldns /root/Document/recon/$ip/httpx /root/Document/recon/$ip/wayback /root/Document/recon/$ip/ffuf /root/Document/recon/$ip/gf /root/Document/recon/$ip/unfurl / root/Document/recon/massdns_ip /root/Document/recon/$ip/nuclei /root/Document/recon/$ip/Directory_BruteForcing /root/Document/recon/$ip/Naabu /root/Document/recon/$ip/Katana
  subfinder -d $ip >> /root/Document/recon/$ip/subdomain/subfinder_$ip.txt
  assetfinder $ip >> /root/Document/recon/$ip/subdomain/assetfinder_$ip.txt
  amass enum -passive -d $ip >> /root/Document/recon/$ip/subdomain/amass_$ip.txt
  shuffledns -d $ip -w $wordlist -r $resolvers >> /root/Document/recon/$ip/subdomain/shuffledns_$ip.txt
fi

# Concatenate all IPs and sort them
cat *.txt | sort -u >> /root/Document/recon/$ip/subdomain/All.txt

# Shuffle DNS to resolve IPs and URLs
sudo shuffledns -d $ip -list /root/Document/recon/$ip/subdomain/All.txt -r $resolvers -o /root/Document/recon/$ip/shuffeldns/resolved.txt

# Find response codes using httpx and store results in files with response code names
for code in 200 400 401 403 500 505 301 300 302; do
 sudo httpx -list /root/Document/recon/$ip/shuffeldns/resolved.txt -silent -status-code -threads 200 -follow-redirects  -mc $code -o /root/Document/recon/$ip/httpx/$code.txt
done
#httpx simple file with all the urls and status code
cat /root/Document/recon/$ip/shuffeldns/resolved.txt | httpx  -threads 200 -o /root/Document/recon/$ip/httpx/All_httpx.txt
# doing tls probing for ssl data
cat /root/Document/recon/$ip/shuffeldns/resolved.txt | httpx -tls-probe  -threads 200 -sr /root/Document/recon/$ip/httpx/httpx_tls.txt
#doing wayback url data fetching
cat /root/Document/recon/$ip/shuffeldns/resolved.txt | waybackurls |tee /root/Document/recon/$ip/waybacktemp.txt
#removing junk files from wayback data
cat /root/Document/recon/$ip/wayback/temp.txt | egrep -v "\.woff|\.woff2|\.tiff|\.tif|\.pdf|\.txt|\.ttf|\.svg|\.png|\.jpeg|\.jpg|\.eot|\.ioc|\.css|\.ico" | sed 's/:80//g' | sort -u >> /root/Document/recon/$ip/wayback/valid_wayback_url.txt

#Performing ffuf for validating the 200 ok sites from wayback data
ffuf -c -t 100 -u "FUZZ" -w /root/Document/recon/$ip/wayback/valid_wayback_url.txt -mc 200 -of csv -o /root/Document/recon/$ip/ffuf/temp.txt 
cat /root/Document/recon/$ip/ffuf/temp.txt |grep http | awk -F "," '{print $1}' >> /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt
#rm /home/Documents/$domain/Recon/Ffuf/After.ffuf.temp_url.txt 

#Performing gf-pattern for vulnerable parameters

gf xss /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/xss_url.txt

gf debug_logic /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/debug_logic_url.txt

gf img-traversal /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/img-traversal_url.txt

gf interestingparams /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/interestingparams_url.txt

gf jsvar /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/jsvar_url.txt

gf rce /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/rce_url.txt

gf sqli /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/sqli_url.txt

gf ssti /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/ssti_url.txt

gf idor /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/idor_url.txt

gf interestingEXT /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/interestingEXT_url.txt

gf interestingsubs /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/interestingsubs_url.txt

gf lfi /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/lfi_url.txt

gf redirect /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/redirect_url.txt

gf ssrf /root/Document/recon/$ip/ffuf/Valid_Ffuf.txt | tee /root/Document/recon/$ip/gf/ssrf_url.txt

# performing unfurl for all the pathes and parameters website using or was using

cat /root/Document/recon/$ip/wayback/valid_wayback_url.txt | unfurl path -u >>/root/Document/recon/$ip/unfurl/paths.txt

cat /root/Document/recon/$ip/wayback/valid_wayback_url.txt | unfurl keys -u >>/root/Document/recon/$ip/unfurl/params.txt

cat /root/Document/recon/$ip/wayback/valid_wayback_url.txt | unfurl keypairs -u >>/root/Document/recon/$ip/unfurl/pairs.txt

# performing Directory Bruteforcing

for line in $(cat /root/Document/recon/$ip/httpx/200.txt);do ffuf -u "$lin/FUZZ" -mc 200 -fs 0 -w /root/Document/recon/$ip/unfurl/paths.txt >> /root/Document/recon/$ip/Directory_BruteForcing/Directory_200.txt;done

for line in $(cat /root/Document/recon/$ip/httpx/200.txt);do ffuf -u "$lin/FUZZ" -mc 403 -fs 0 -w /root/Document/recon/$ip/unfurl/paths.txt >> /root/Document/recon/$ip/Directory_BruteForcing/Directory_403.txt;done

# performing massdns for converting urls to ip for nmap or naabu to use
massdns  -r $resolvers -t A -o S -w /root/Document/recon/$ip/massdns_ip/temp-ips.txt /root/Document/recon/$ip/shuffeldns/resolved.txt

gf ip /root/Document/recon/$ip/massdns_ip/temp-ips.txt |awk -F ":" '{print $3}'|sort -u >> /root/Document/recon/$ip/massdns_ip/valid_Ips.txt



#Performing Port Scannig with Naabu

naabu -list /root/Document/recon/$ip/massdns_ip/valid_Ips.txt -r $resolvers -tp 1000 -o /root/Document/recon/$ip/Naabu/initia_portscan.txt
naabu -list /root/Document/recon/$ip/massdns_ip/valid_Ips.txt -r $resolvers -p- -o /root/Document/recon/$ip/Naabu/Full_portscan.txt 

#Performing crawling with Katana 

katana -list /root/Document/recon/$ip/httpx/All_httpx.txt -d 5 -o /root/Document/recon/$ip/Katana/katana.txt

httpx -l /root/Document/recon/$ip/Katana/katana.txt -mc 200 -threads 200 -follow-redirects -o /root/Document/recon/$ip/Katana/200_katana.txt

httpx -l /root/Document/recon/$ip/Katana/katana.txt -mc 403 -threads 200 -follow-redirects -o /root/Document/recon/$ip/Katana/403_katana.txt




#Performing nuclei for vulnerabilities

nuclei -l /root/Document/recon/$ip/shuffeldns/resolved.txt -o /root/Document/recon/$ip/nuclei/200.txt -t /home/abdullah/.local/nuclei-templates/http/  
