#!/bin/bash

# setup #######################################################################
#set -o errexit -o pipefail -o noclobber -o nounset
LANGUAGE="${DEEPL_TARGET:-EN}"
LANGUAGE_SOURCE="${DEEPL_SOURCE:-auto}"
LANGUAGE_PREFERRED="${DEEPL_PREFERRED:-[\"DE\",\"EN\"]}"
KEY="${DEEPL_KEY:-}"
PRO="${DEEPL_PRO:-}"
# see https://developers.deepl.com/docs/api-reference/translate/openapi-spec-for-text-translation
FORMALITY="${DEEPL_FORMALITY:-prefer_less}"
POSTFIX="${DEEPL_POSTFIX:-.}"
VERSION="2.1.0"
PATH="$PATH:/usr/local/bin/"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
###############################################################################

# helper functions ############################################################
function printJson() {
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
  echo "Home made DeepL CLI (${VERSION}; https://github.com/AlexanderWillner/deepl-alfred-workflow2)"
  echo ""
  echo "SYNTAX : $0 [-l language] <query>" >&2
  echo "Example: $0 -l DE \"This is just an example.\""
  echo ""
  exit 1
fi
###############################################################################

# process query ###############################################################
query="$1"
# shellcheck disable=SC2001
query="$(echo "$query" | sed 's/\"/\\\"/g')"
# shellcheck disable=SC2001
query="$(echo "$query" | sed "s/'/\\\'/g")"
query="$(echo "$query" | iconv -f utf-8-mac -t utf-8 | xargs)"

if [[ $KEY = "" ]] && [[ $query != *"$POSTFIX"   ]]; then
  printJson "End query with $POSTFIX"
  exit 2
fi
###############################################################################

# prepare query ###############################################################
# shellcheck disable=SC2001
query="$(echo "$query" | sed "s/\\$POSTFIX$//")"
if [ "$KEY" = "" ]; then
  FORM_PARAM=''
else
  FORM_PARAM='"formality": "'"$FORMALITY"'", '
fi
data='{"jsonrpc":"2.0","method": "LMT_handle_jobs","params":{"commonJobParams": {'$FORM_PARAM'"browserType": 1, "mode": "translate", "textType": "plaintext"}, "jobs":[{"kind":"default","raw_en_sentence":"'"$query"'","preferred_num_beams":4,"raw_en_context_before":[],"raw_en_context_after":[],"quality":"fast"}],"lang":{"user_preferred_langs":'"${LANGUAGE_PREFERRED}"',"source_lang_user_selected":"'"${LANGUAGE_SOURCE}"'","target_lang":"'"${LANGUAGE:-EN}"'"},"priority":1,"timestamp":1557063997314},"id":79120002}'
HEADER=(
  --compressed
  -H 'authority: www2.deepl.com'
  -H 'Origin: https://www.deepl.com'
  -H 'Referer: https://www.deepl.com/translator'
  -H 'Accept: */*'
  -H 'Content-Type: application/json'
  -H 'Accept-Language: en-us'
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Safari/605.1.15'
)
###############################################################################

# query #######################################################################
if [ -n "$KEY" ]; then
  if [ "$PRO" = "1" ]; then
    url="https://api.deepl.com/v2/translate"
  else
    url="https://api-free.deepl.com/v2/translate"
  fi
  if [ ! -z "$DEEPL_HOST" ]; then
    url="$DEEPL_HOST/v2/translate"
  fi

  echo >&2 "curl -s -X POST '$url' -H 'Authorization: DeepL-Auth-Key $KEY' --data-urlencode 'text=$query' -d 'formality=$FORMALITY' -d 'target_lang=${LANGUAGE:-EN}'"
  result=$(curl -s -X POST "$url" -H "Authorization: DeepL-Auth-Key $KEY" --data-urlencode "text=$query" -d "formality=$FORMALITY" -d "target_lang=${LANGUAGE:-EN}")
  ret=$?
  if [[ "x$ret" != "x0" ]] || [[ "$result" == "" ]]; then
    echo >&2 "$ret: $result"
    http_code=$(curl -s -X POST "$url" -H "Authorization: DeepL-Auth-Key $KEY" --data-urlencode "text=$query" -d "target_lang=${LANGUAGE:-EN}" -d "formality=$FORMALITY" -w %{http_code} -o /dev/null)
    if [[ $http_code -eq 403 ]]; then
      printJson "Error: Invalid API key"
      exit 3
    fi
    if [[ $ret -eq 6 ]]; then
      printJson "Error: DNS resolution failed - no Internet connection?"
      exit 4
    fi
    printJson "Error Code $ret - HTTP Code $http_code"
    exit 5
  fi
  osascript -l JavaScript -e 'function run(argv) {
    const translations = JSON.parse(argv[0])["translations"].map(item => ({
      title: item["text"],
      arg: item["text"]
    }))

    return JSON.stringify({ items: translations }, null, 2)
  }' "$result" || echo >&2 "ERROR w/ key: result '$result', query '$query'"
else
  echo >&2 "curl -s 'https://www2.deepl.com/jsonrpc' '${HEADER[@]}' --data-binary $'$data'"
  result=$(curl -s 'https://www2.deepl.com/jsonrpc' "${HEADER[@]}" --data-binary $"$data")
  ret=$?
  if [[ "x$ret" != "x0" ]] || [[ "$result" == "" ]]; then
    echo >&2 "$ret: $result"
    http_code=$(curl -s 'https://www2.deepl.com/jsonrpc' "${HEADER[@]}" --data-binary $"$data" -w %{http_code} -o /dev/null)
    if [[ $ret -eq 6 ]]; then
      printJson "Error: DNS resolution failed - no Internet connection?"
      exit 6
    fi
    printJson "Error Code $ret - HTTP Code $http_code"
    exit 7
  fi
  if [[ $result == *'"error":{"code":'* ]]; then
    message="$(osascript -l JavaScript -e 'function run(argv) { return JSON.parse(argv[0])["error"]["message"] }')"
    printJson "Error: $message"
    exit 8
  else
    osascript -l JavaScript -e 'function run(argv) {
      const translations = JSON.parse(argv[0])["result"]["translations"][0]["beams"].map(item => ({
        title: item["postprocessed_sentence"],
        arg: item["postprocessed_sentence"]
      }))

      return JSON.stringify({ items: translations }, null, 2)
    }' "$result" || echo >&2 "ERROR w/o key: result '$result', query '$query'"
  fi
fi
###############################################################################
