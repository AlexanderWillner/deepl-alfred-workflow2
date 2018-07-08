# Alfred DeepL Translation Workflow

[DeepL.com](https://www.deepl.com/) is a great, new translation service. It provides better translations compared to other popular translation engines. This workflow is a quick hack to enable support for Alfred.

## Importing a Workflow

Simply install the DeepL workflow by double-clicking the workflow file. You can add the workflow to a category, then click "Import" to finish importing. You'll now see the workflow listed in the left sidebar of your Workflows preferences pane.

Once imported, take a quick look at the workflow settings and setup what keyword you want to use.

## Usage

To activate this workflow use the default keyword _"dl"_, enter the passage you wanna get translated. Source and destination language will be inferred automatically.

## Requirements

This workflow requires the ```jq commandline JSON processor``` installed at ```/usr/local/bin/jq```. Install it via ```brew install jq```.

## Disclaimer

This workflow currently interacts with DeepL's JSON-RPC API. The API of DeepL.com is free but this might change in the future.

DeepL is a product from DeepL GmbH. More info: [deepl.com/publisher.html](https://www.deepl.com/publisher.html)

This package has been heavily inspired by [m9dfukc's DeepL Alfred Workflow](https://github.com/m9dfukc/deepl-alfred-workflow).


