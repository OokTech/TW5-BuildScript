#!/bin/bash
subfolder=OokTech
pluginsubfolder=OokTech
pluginprefix=TW5-
alreadybuilt=false

#this isn't used yet, but we will eventually make/update twcards as needed using this same script
#$1 is the $plugin name and $2 is the $pluginfolder
maketwcard () {
    plugintiddler="$(cat $2/plugin.info | jq '.title')"
    version="$(cat $2/plugin.info | jq '.title')"
    maintainer="$(cat $2/plugin.info | jq '.author')"
    description="$(cat $2/plugin.info | jq '.description')"
    repo="$(cat $2/plugin.info | jq '.source')"
    CardName="$1 ($(sed -e 's/^"//' -e 's/"$//' <<<"$maintainer"))"
    echo title: $(sed -e 's/^"//' -e 's/"$//' <<<"$CardName") > "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo caption: $1 >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo plugin_tidder: $(sed -e 's/^"//' -e 's/"$//' <<<"$plugintiddler") >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo caption: $(sed -e 's/^"//' -e 's/"$//' <<<"$1") >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo revision: $(sed -e 's/^"//' -e 's/"$//' <<<"$version") >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo description: $(sed -e 's/^"//' -e 's/"$//' <<<"$description") >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo repo: $(sed -e 's/^"//' -e 's/"$//' <<<"$repo") >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo url: http://ooktech.com/TiddlyWiki/$1/ >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo name_plate_type: TiddlyWiki >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
    echo "tags: [[<Name Plate>]] Website OokTech" >> "./editions/$subfolder/ZZZDirectory/tiddlers/$CardName.tid"
}

#This is the function that dues the actual building part, $1 in the $plugin name
#and $2 is the $pluginfolder $3 is true if the plugin version needs to be incremented, false otherwise
buildwiki () {
    echo build $1 edition
    #if the plugin needs to be updated, increment the version number
    if [ "$3" = true ]; then
        #Update the version number in plugin.info (awk is magic)
        plugininfo="$(awk -F'["]' -v OFS='"'  '/"version":/{split($4,a,".");$4=a[1]"."a[2]"."a[3]+1};1' $2/plugin.info)"
        echo "$plugininfo" > $2/plugin.info
        #update or create the twCard for the plugin
        maketwcard $1 $2
    fi
    #build the wiki, the directory is special
    if [ $1 = "Directory" ]; then
        node ./tiddlywiki.js editions/OokTech/ZZZ$1 --build index
    else
        node ./tiddlywiki.js editions/OokTech/$1 --build index
    fi
}

#List all editions in the ./editions/$subfolder/ folder
for f in ./editions/$subfolder/*; do
    alreadybuilt=false
    #get the output file name
    file="$f/output/index.html"
    #get the edition name by removing the ./editions/$subfolder/ prefix
    #The directory is special because it has to come last in order to work
    if [ $f = "./editions/OokTech/ZZZDirectory" ]; then
        plugin=${f#*./editions/$subfolder/ZZZ}
    else
        plugin=${f#*./editions/$subfolder/}
    fi
    #get the tiddlers folder
    tiddlersfolder=$f/tiddlers
    #get the plugin folder by combining the parts of the folder name
    pluginfolder=./plugins/$pluginsubfolder/$pluginprefix$plugin
    maketwcard $plugin $pluginfolder
    #check to see if the output file exists
    if [ -e $file ]; then
        #if the output file exists, check if we should rebuld it
        for pluginfile in $pluginfolder/*; do
            #check each file in the plugin folder
            if [ "$file" -ot "$pluginfile" ]; then
                #if any of the plugin files are newer than the output, rebuild
                #and increment the plugin version number
                buildwiki $plugin $pluginfolder true
                alreadybuilt=true
                #if we build than we don't need to keep testing this plugin,
                #so break
                break
            fi
        done
        if [ alreadybuilt==false ]; then
            for tiddlerfile in $tiddlersfolder/*; do
                #check each file in the tiddlers folder
                if [ "$file" -ot "$tiddlerfile" ]; then
                        #if any of the tiddlers are older than the output, rebuild
                        #without incrementing the plugin version number
                        buildwiki $plugin $pluginfolder false
                        #once we build we don't need to continue checking
                        break
                fi
            done
        fi
    else
        #if the output file doesn't exist, build it
        buildwiki $plugin $pluginfolder false
    fi
done

#After all the editions are built and any plugins that need it are rebuilt
#rebuild the plugin library
node ./tiddlywiki.js editions/pluginlibrary --build
