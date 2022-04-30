#!/usr/bin/python3

import subprocess
import shlex
import os
import plistlib
from shutil import copyfile
from pprint import pprint

provisionProfilesPath = os.path.expanduser('~/Library/MobileDevice/Provisioning Profiles')
process = subprocess.Popen(['ls', provisionProfilesPath],
                     stdout=subprocess.PIPE, 
                     stderr=subprocess.PIPE)
stdout, stderr = process.communicate()

profiles = []
for profile in filter(lambda x: x != "",  stdout.decode('UTF-8').split("\n")):
    process = subprocess.Popen(shlex.split('security cms -D -i') + [f'{provisionProfilesPath}/{profile}'],
                     stdout=subprocess.PIPE, 
                     stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    try:
        plist = plistlib.loads(stdout)
    except:
        pass

    provisionedDevices = True if plist.get('ProvisionedDevices', None) is not None else False
    isDevelopement = plist['Entitlements']['get-task-allow']
    appIdentifier = plist['Entitlements']['application-identifier']
    
    if isDevelopement:
        exportType = "Development"
    else:
        if provisionedDevices: 
            exportType = "Ad-Hoc"
        else:
            exportType = "App-Store"

    profiles.append({
        'name': profile,
        'appIdentifier': appIdentifier,
        'exportType': exportType
    })

for i, profile in enumerate(profiles):
    print(f'{i + 1}) {profile["name"]}   {profile["exportType"]: <15}  {profile["appIdentifier"]}')

print('Files to copy (comma separated, example 1,4,5, or 0 for all):')
selection = input()
if selection.strip() == "0":
    toCopy = range(len(profiles))
else:
    toCopy = [int(x) - 1 for x in selection.split(',')]

for idx in toCopy:
    profile = profiles[idx]
    copyfile(f'{provisionProfilesPath}/{profile["name"]}', f'{profile["appIdentifier"]}__{profile["exportType"]}.mobileprovision')