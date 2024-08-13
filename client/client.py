import threading
import socket
import json
import sys
import rotcipher

from hashlib import sha256
from datetime import datetime
from cli_model import *


def usage(msg : str):
    if msg:
        print(msg)
    
    print("usage: program.py [-h] -addr <IPv4 address> -p <port>")
    sys.exit()

def valid_addr(host : str, port : str):
    return host.replace('.','').isdecimal() and port.isdecimal()

def safe_read(argv : list[str], opt : str):
    valid_opts = ["-svr", "-p"]
    if not (opt in argv):
        usage(f"Option {opt} required.")

    opt_idx = argv.index(opt)
    if opt_idx + 1 > len(argv):
        usage(f"Value expected for {opt}.")
    
    else:
        val = argv[opt_idx + 1]
        if not val or val in valid_opts:
            usage(f"Invalid value '{val}' for {opt}.")
        
        return val
    

def auth_usage():
    print("Enter auth.login to initiate login.")

def is_auth_stat(msg : dict):
    return isinstance(msg, dict) and msg.get("type") == MsgType.auth.name

def is_txt_msg(msg : dict):
    return isinstance(msg, dict) and msg.get("type") == MsgType.normal.name

def login() -> AuthRequest:
    global uname
    uname = input("Username: ").strip()
    pword = input("Password: ").strip()

    if uname and pword:
        return AuthRequest(uname, sha256(str.encode(pword)).hexdigest())

def connect(host : str, port : int):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # IPv4, TCP
        sock.connect((host, port))
        print(f"[+] Connected to {sock.getpeername()}")
    except ConnectionRefusedError:
        print("[!] Connection refused. Check address.")

    except Exception as ex:
        print(f"[!] Error connecting to server at {host}:{port}")
        sys.exit()

    new_msg_receiver = threading.Thread(target=recv_messages, args=(sock,))
    new_msg_receiver.start()

    send_messages(sock)

def recv_messages(sock : socket.SocketType):
    global cont_exec
    try: 
        while cont_exec:
            in_msg = sock.recv(1024)
            
            deo_msg = rotcipher.deobfuscate(in_msg.decode("utf-8"))
            jsonObj = json.loads(deo_msg)
            if is_auth_stat(jsonObj) or is_txt_msg(jsonObj):
                pretext = f"{jsonObj['sender']} ~ " if "sender" in jsonObj else ""
                # timestamp = f"[{datetime(jsonObj['date']).timetz()}]" if "date" in jsonObj else ""
                
                print(f"\r{' '*len(prompt_txt)}\n{pretext}{jsonObj['text']}\n")
                print(f"{prompt_txt}", end="", flush=True)

        return
    except ConnectionResetError:
        print("\n[!] Server disconnected.")
        sock.close()
        cont_exec = False

def send_messages(sock : socket.SocketType):
    global cont_exec
    try:
        auth_usage()
        print(prompt_txt, end="")
        while cont_exec:
            out_msg = input().strip()

            if out_msg == "auth.login":
                auth_req = login()

                if auth_req:
                    obf_auth_req = rotcipher.obfuscate(json.dumps(auth_req.dict()))
                    sock.send(str.encode(obf_auth_req))

            elif out_msg:
                text_msg = TextMessage(uname, out_msg, str(datetime.now()))
                obf_msg = rotcipher.obfuscate(json.dumps(text_msg.dict()))
                sock.send(str.encode( obf_msg ))

            print(prompt_txt, end="")

    except KeyboardInterrupt:
        cont_exec = False
        print("\n[i] Bye bye.")
        sys.exit()

cont_exec = True
prompt_txt = "(message)~$ "
uname = ""

if __name__=="__main__":
    sys.argv.append("-svr")
    sys.argv.append("127.0.0.1")
    sys.argv.append("-p")
    sys.argv.append("178")
    if "-h" in sys.argv:
        usage(None)

    host = safe_read(sys.argv, "-svr")
    port = safe_read(sys.argv, "-p")
    if not valid_addr(host, port):
        usage("Invalid address detected.")
    else:
        port = int(port)

    connect(host, port)


# print(f"\r{' '*len(prompt_text)}\n{msg}\n") # overwrite current prompt before output new message
# print(prompt_text, end="", flush=True)