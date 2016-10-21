#!/usr/bin/python
'''
2013/3/18
mengjun
get wave longth
'''
import os
import sys
import wave

#-------------------------------------------------------------
def main():
    totallongth = 0
    fpw = open(sys.argv[2],"w")
    
    #name_db = {}

    cmd = "find %s/ -iname '*.wav' &> wav_raw.lst" % sys.argv[1]
    os.system(cmd)
    
    with open ('wav_raw.lst',"r") as wavlists:
	for wavlist in wavlists:
           
            f=wave.open(wavlist.strip(),'r')
            fn=f.getnframes()
            rate=f.getframerate()
            wavlength = float(fn) * (1/float(rate))

            totallongth = totallongth + wavlength
            fpw.write(wavlist.strip())
            fpw.write('    ')
            fpw.write('%ss\n' % wavlength)
    fpw.write('The total longth is %sh\n' % (float(totallongth)/3600))
    fpw.close()
            
#------------------------------------------------------------------            
if __name__ == '__main__':

    if (len(sys.argv)!=3):
        print "%s wavlistdir  wavelongthfile" % sys.argv[0]
        sys.exit()
    if os.path.exists(sys.argv[2]):
        os.remove(sys.argv[2])    

    main()
