# Alfred DeepL Translation Workflow

[DeepL.com](https://www.deepl.com/) is a great, new translation service. It provides better translations compared to other popular translation engines. 

## Caveats

This workflow is a quick hack to enable support for Alfred (wrote it in a few minutes). It might break at any time. As such, a lot is hard coded. You might need to adapt the ```user_preferred_langs``` or ```source_lang_user_selected``` in the file ```deepl.sh```. Further, this workflow requires the ```jq commandline JSON processor``` installed at ```/usr/local/bin/jq```. Install it e.g. via [brew](https://brew.sh) using ```brew install jq```.

## Installing the Workflow

Simply download the [```DeepL Workflow```](https://github.com/AlexanderWillner/deepl-alfred-workflow2/blob/master/Deepl-Translate.alfredworkflow?raw=true) and install it by  double-clicking the workflow file. You can add the workflow to a category, then click "Import" to finish importing. You'll now see the workflow listed in the left sidebar of your Workflows preferences pane.

Once imported, take a quick look at the workflow settings and setup what keyword you want to use.

## Usage

To activate this workflow use the default keyword ```dl```, enter the passage you wanna get translated. Source and destination language will be inferred automatically.

## Details

To create a modified version of the workflow, edit the files and run ```make workflow``` to create an updated workflow.

## Disclaimer

DeepL is a product from DeepL GmbH. More info: [deepl.com/publisher.html](https://www.deepl.com/publisher.html)

This package has been heavily inspired by [m9dfukc's DeepL Alfred Workflow](https://github.com/m9dfukc/deepl-alfred-workflow).


