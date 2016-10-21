# -*- coding: utf-8 -*-

import sys
import os

extension_name = ['.wav','.WAV'];

def wav_all_path(in_dir):

    if os.path.isfile(in_dir):
        return 0
    v_dir = os.listdir(in_dir);
    #print v_dir;
    for file in v_dir:
        file_path=os.path.join(in_dir,file);
        if os.path.isfile(file_path) and (file_path[-4:] in extension_name):
            print file_path
        elif os.path.isfile(file_path):
            continue;
        else:
            wav_all_path(file_path);



if len(sys.argv)<2:
    print "usage : $0 in_dir "
    print "usage : 遍历目录中的每个wav语音 制作成list"
    sys.exit(0)

in_dir = sys.argv[1];

if os.path.isdir(in_dir):
    wav_all_path(in_dir);


