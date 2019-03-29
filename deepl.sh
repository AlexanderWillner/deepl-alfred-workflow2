#!/bin/bash

# setup #######################################################################
set -o errexit -o pipefail -o noclobber -o nounset
PATH="$PATH:/usr/local/bin/"
POSITIONAL=()
HEADER=(-H 'Accept-Language: en-us' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Safari/605.1.15' \
  -H 'Accept-Encoding: br, deflate' \
  -H 'Connection: keep-alive' \
  -c '$HOME/.deeplcookie')
###############################################################################

# helper functions ############################################################
function printJson {
  echo '{"items": [{"uid": null,"arg": "'"$1"'","valid": "yes","autocomplete": "autocomplete","title": "'"$1"'"}]}'
}
###############################################################################

# parameters ##################################################################
while [[ $# -gt 0 ]]; do
  key="$1"
  case "$key" in
  -l | --lang)
    LANGUAGE="$2"
    shift # past argument
    shift # past value
    ;;
  *) # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift              # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]:-}" # restore positional parameters
###############################################################################

# help ########################################################################
if [ -z "$1" ]; then
  echo "SYNTAX : $0 [-l language] <query>" >&2
  echo "Example: $0 -l DE \"This is just an example.\""
  exit 1
fi

if ! type jq >/dev/null 2>&1; then
  if type brew >/dev/null 2>&1; then
    HOMEBREW_NO_AUTO_UPDATE=1 brew install jq >/dev/null || exit 2
  else
    echo "Install 'jq' first." >&2
    exit 2
  fi
fi
###############################################################################

# process query ###############################################################
query="$(echo "$1" | iconv -f utf-8-mac -t utf-8)"

if [[ $query != *. ]]; then
  printJson "End query with a dot"
  exit 1
fi
###############################################################################

# prepare query ###############################################################
query="$(echo "$query" | sed 's/.$//')"
find ~ -maxdepth 1 -name ".deeplcounter" -mtime +30s -type f -delete
find ~ -maxdepth 1 -name ".deeplcookie" -mtime +30s -type f -delete
if [[ -f "$HOME/.deeplcounter" ]]; then
  id="$(cat $HOME/.deeplcounter)"
else
  id="$(($(jot -r 1 2000 9000) * 10000 + 1))"
  curl -s 'https://www.deepl.com/translator' \
  -X GET "${HEADER[@]}" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: en-us' \
  -H 'Connection: keep-alive' \
  -H 'Accept-Encoding: br, deflate' \
  -H 'Host: www.deepl.com' \
  -c "$HOME/.deeplcookie" \
  >| /dev/null
  sleep .5
  curl -s 'https://www.deepl.com/PHP/backend/clientState.php?request_type=jsonrpc&il=EN' \
  -X POST \
  -H 'Content-Type: text/plain' \
  -H 'Accept: */*' \
  -H 'Host: www.deepl.com' \
  -H 'Origin: https://www.deepl.com' \
  -H 'Referer: https://www.deepl.com/translator' \
  -H 'Content-Length: 83' \
  -H 'X-Requested-With: XMLHttpRequest' \
  --data-binary '{"jsonrpc":"2.0","method":"getClientState","params":{"v":"20180814"},"id":'"$id"'}' \
  >| /dev/null
fi
id="$(($id + 1))"; echo "$id" >| "$HOME/.deeplcounter"
timestamp="$(python -c 'from time import time; print int(round(time() * 1000))')"
data='{"jsonrpc":"2.0","method": "LMT_handle_jobs","params":{"jobs":[{"kind":"default","raw_en_sentence":"'"$query"'","raw_en_context_before":[],"raw_en_context_after":[]}],"lang":{"user_preferred_langs":["FR","DE","EN"],"source_lang_user_selected":"auto","target_lang":"'"${LANGUAGE:-EN}"'"},"priority":1,"timestamp":'"$timestamp"'},"id":'"$id"'}}'
contentlen="$(($(echo $data | wc -c) - 1))"
sleep .5
###############################################################################

# query #######################################################################
result=$(curl -s 'https://www2.deepl.com/jsonrpc' \
  -X POST "${HEADER[@]}" \
  -H 'Content-Type: text/plain' \
  -H 'Accept: */*' \
  -H 'Host: www2.deepl.com' \
  -H 'Origin: https://www.deepl.com' \
  -H 'Referer: https://www.deepl.com/translator' \
  -H 'Content-Length: '"$contentlen" \
  --data-binary "$data")

if [[ "$result" == *'"error":{"code":'* ]] ; then
  message=$(echo "$result"|jq -r '.["error"]|.message')
  printJson "Error: $message"
else
  echo $result|jq -r '{items: [.result.translations[0].beams[] | {uid: null, arg:.postprocessed_sentence, valid: "yes", autocomplete: "autocomplete",title: .postprocessed_sentence}]}'
fi
###############################################################################

# post query ##################################################################
curl -s 'https://dict.deepl.com/german-english/search?ajax=1&query=QUERY&source=german&onlyDictEntries=1&translator=dnsof7h3k2lgh3gda&delay=300&jsStatus=0&kind=full&eventkind=change&forleftside=true' \
  -X GET "${HEADER[@]}" \
  -H 'Accept: text/html, */*; q=0.01' \
  -H 'Origin: https://www.deepl.com' \
  -H 'Accept-Encoding: br, deflate' \
  -H 'Host: dict.deepl.com' \
  -H 'Referer: https://www.deepl.com/translator' \
  >| /dev/null
###############################################################################
