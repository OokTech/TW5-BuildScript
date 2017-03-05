# TW5-BuildScript

The script:

- Checks if plugins need to be rebuilt, if so it increments the version number and rebuilds the plugin
- Checks if any editions need to be built for reasons other than updated plugins, if so it rebuilds
- Marks newly changed editions as needing testing, the testing flag must be manually unset
    - The tested/ready flag is in the file TestingState.json, replace 'testing' with 'ready' in the editions that are ready to be uploaded
- If an edition has been built and is newer than the most recently uploaded version and it has been marked as tested than upload the edition
- Update the plugin library if any plugins have changed, if no plugins are marked as needing testing upload the plugin library to the stable library
- If any plugins have changed upload the rebuilt plugin library to the unstable library, regardless of needing testing or not

This is a bash script that is used to build plugins and demo wikis. It is setup for use by OokTech but it can be modified as desired.
It works with the Directory to automatically create a listing of plugins. See https://github.com/OokTech/TW5-Directory
