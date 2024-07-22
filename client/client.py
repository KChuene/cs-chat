import threading
import socket
import json
import sys
import fileinput

from hashlib import sha256
from cli_model import *
from datetime import datetime

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

    except Exception:
        print(f"[!] Error connecting to server at {host}:{port}")
        exit()

    new_msg_receiver = threading.Thread(target=recv_messages, args=(sock,))
    new_msg_receiver.start()

    send_messages(sock)

def recv_messages(sock : socket.SocketType):
    global cont_exec
    try: 
        while cont_exec:
            in_msg = sock.recv(1024)
            
            jsonObj = json.loads(in_msg)
            if is_auth_stat(jsonObj) or is_txt_msg(jsonObj):
                print(f"\r{' '*len(prompt_txt)}\n{jsonObj['sender']} ~ {jsonObj['text']}\n")
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
                    sock.send(str.encode( json.dumps(auth_req.dict()) ))

            elif out_msg:
                text_msg = TextMessage(uname, out_msg, str(datetime.now()))
                sock.send(str.encode( json.dumps(text_msg.dict()) ))

            print(prompt_txt, end="")

    except KeyboardInterrupt:
        cont_exec = False
        print("\n[i] Bye bye.")
        sys.exit()

cont_exec = True
prompt_txt = "(message)~$ "
uname = ""

if __name__=="__main__":
    host = "127.0.0.1"
    port = 178

    connect(host, port)


# print(f"\r{' '*len(prompt_text)}\n{msg}\n") # overwrite current prompt before output new message
# print(prompt_text, end="", flush=True)