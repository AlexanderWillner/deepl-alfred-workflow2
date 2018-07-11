# Alfred DeepL Translation Workflow

[DeepL.com](https://www.deepl.com/) is a great, new translation service. It provides better translations compared to other popular translation engines. 

## Caveats

This workflow is a quick hack to enable support for Alfred (wrote it in a few minutes). It might break at any time. As such, a lot is hard coded. You might need to adapt the ```user_preferred_langs``` or ```source_lang_user_selected``` in the file ```info.plist```. Further, this workflow requires the ```jq commandline JSON processor``` installed at ```/usr/local/bin/jq```. Install it e.g. via [brew](https://brew.sh) using ```brew install jq```.

## Installing the Workflow

Simply install the DeepL workflow by double-clicking the workflow file. You can add the workflow to a category, then click "Import" to finish importing. You'll now see the workflow listed in the left sidebar of your Workflows preferences pane.

Once imported, take a quick look at the workflow settings and setup what keyword you want to use.

## Usage

To activate this workflow use the default keyword ```dl```, enter the passage you wanna get translated. Source and destination language will be inferred automatically.

## Details

In its core, the following command is being used. This workflow currently interacts with DeepL's JSON-RPC API. The API of DeepL.com is free but this might change in the future.

```
curl -s 'https://www2.deepl.com/jsonrpc' \
  -XPOST -H 'Content-Type: text/plain' \
  -H 'Origin: https://www.deepl.com' \
  -H 'Host: www2.deepl.com' \
  -H 'Accept: */*' \
  -H 'Connection: keep-alive' \
  -H 'Accept-Encoding: br, gzip, deflate' \
  -H 'DNT: 1' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15' \
  -H 'Referer: https://www.deepl.com/translator' \
  -H 'Accept-Language: en-us' \
  --data-binary '{"jsonrpc":"2.0","method":"LMT_handle_jobs","params":{"jobs":[{"kind":"default","raw_en_sentence":"'"$1"'"}],"lang":{"user_preferred_langs":["FR","ES","EN","DE"],"source_lang_user_selected":"auto","target_lang":"auto"},"priority":1},"id":1}'\
  |gunzip|/usr/local/bin/jq -r ".result.translations[0].beams[0].postprocessed_sentence"
```

## Disclaimer

DeepL is a product from DeepL GmbH. More info: [deepl.com/publisher.html](https://www.deepl.com/publisher.html)

This package has been heavily inspired by [m9dfukc's DeepL Alfred Workflow](https://github.com/m9dfukc/deepl-alfred-workflow).


