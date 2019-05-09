#!/bin/bash

# setup #######################################################################
#set -o errexit -o pipefail -o noclobber -o nounset
PATH="$PATH:/usr/local/bin/"
PARSER="jq"
if ! type "${PARSER}" >/dev/null 2>&1; then
  PARSER="./jq-dist"
fi
###############################################################################

# helper functions ############################################################
function printJson {
  echo '{"items": [{"uid": null,"arg": "'"$1"'","valid": "yes","autocomplete": "autocomplete","title": "'"$1"'"}]}'
}
###############################################################################

# parameters ##################################################################
POSITIONAL=()
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
data='{"jsonrpc":"2.0","method": "LMT_handle_jobs","params":{"jobs":[{"kind":"default","raw_en_sentence":"'"$query"'","raw_en_context_before":[],"raw_en_context_after":[]}],"lang":{"user_preferred_langs":["EN","DE"],"source_lang_user_selected":"auto","target_lang":"'"${LANGUAGE:-EN}"'"},"priority":1,"timestamp":1557063997314},"id":69120002}'
contentlen="$(($(echo $data | wc -c) - 1))"
HEADER=(\
  -H 'Accept-Language: en-us' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Safari/605.1.15' \
  -H 'Connection: keep-alive' )
###############################################################################

# pre query ###################################################################
curl -s 'https://www.deepl.com/PHP/backend/clientState.php?request_type=jsonrpc&il=EN' \
-XPOST \
"${HEADER[@]}" \
-H 'Content-Type: text/plain' \
-H 'Accept: */*' \
-H 'Accept-Encoding: br, gzip, deflate' \
-H 'Host: www.deepl.com' \
-H 'Origin: https://www.deepl.com' \
-H 'Referer: https://www.deepl.com/translator' \
-H 'Content-Length: 83' \
-H 'X-Requested-With: XMLHttpRequest' \
--data-binary '{"jsonrpc":"2.0","method":"getClientState","params":{"v":"20180814"},"id":69120001}' >| /dev/null
###############################################################################

# query #######################################################################
result=$(curl -s 'https://www2.deepl.com/jsonrpc' \
-XPOST \
"${HEADER[@]}" \
-H 'Accept: */*' \
-H 'Accept-Encoding: br, deflate' \
-H 'Content-Type: text/plain' \
-H 'Origin: https://www.deepl.com' \
-H 'Content-Length: '$contentlen \
-H 'Host: www2.deepl.com' \
-H 'Referer: https://www.deepl.com/translator' \
--data-binary "$data")

if [[ "$result" == *'"error":{"code":'* ]] ; then
  message=$(echo "$result"|"${PARSER}" -r '.["error"]|.message')
  printJson "Error: $message"
else
  echo $result|"${PARSER}" -r '{items: [.result.translations[0].beams[] | {uid: null, arg:.postprocessed_sentence, valid: "yes", autocomplete: "autocomplete",title: .postprocessed_sentence}]}'
fi
###############################################################################
