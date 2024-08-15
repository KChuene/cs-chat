import socket
import threading
import json
import rotcipher
import sys
import traceback

from svr_model import *
from pathlib import Path

class Connection:
    def __init__(self, sock : socket.SocketType, is_auth : bool) -> None:
        self.sock = sock
        self.auth = is_auth

def bye(code: int, msg: str):
    if msg:
        print(msg)

    print("usage: server.py -af \"path/to/.authfile\"")
    sys.exit(code)

def safe_read(argv: list[str], option: str) -> str:
    valid_opts = ["-af"]

    if not len(argv) > 1:
        bye(-1, "Insufficient arguments.")
    
    elif not option in argv:
        bye(-1, f"Option {option} is required.")


    opt_idx = argv.index(option)
    if opt_idx + 1 >= len(argv):
        bye(-1, f"Value expected for {option}.")
    
    value = argv[opt_idx + 1]
    if value in valid_opts:
        bye(-1, f"Invalid value '{value}' for {option}.")
    
    return value

def close_conn(sock : socket.SocketType):
    for conn in connections:
        if not conn.sock or conn.sock == sock:
            connections.remove(conn)

def check_authfile(uname : str, pword : str):
    global authfile
    if not Path(authfile).exists():
        return False, "Cannot authenticate at the moment."

    with open(authfile, "r") as af:
        line = af.readline()
        
        while line: # Ignore newline char
            creds = line.replace("\n", "").split(":")
            if len(creds) != 2:
                continue # Malformed credentials

            elif creds[0] == uname and creds[1] == pword:
                return True, "Welcome!"
            
            line = af.readline()
        
        return False, "Invalid username or password."


def update_auth_status(sock : socket.SocketType, is_auth: bool):
    for conn in connections:
        if conn.sock == sock:
            conn.auth = is_auth
            return
        
    print(f"[!] Failed to update auth status of {conn.sock.getpeername()}")


def auth(conn : socket.SocketType, req : dict):
    if not req.get("uname") or not req.get("pword"):
        status = AuthStatus(False, "Incomplete authentication request.")
        obf_status = rotcipher.obfuscate(json.dumps(status.dict()))
        conn.send(str.encode(obf_status))
        return

    authentic, res_msg = check_authfile(uname= req.get("uname"), pword= req.get("pword"))
    if authentic:
        update_auth_status(conn, True)
        status = AuthStatus(True, res_msg)
        obf_status = rotcipher.obfuscate(json.dumps(status.dict()))
        conn.send(str.encode(obf_status))
    else:
        status = AuthStatus(False, res_msg)
        obf_status = rotcipher.obfuscate( json.dumps(status.dict()) )
        conn.send(str.encode(obf_status))
    

def is_auth_req(msg_obj : dict):
    return isinstance(msg_obj, dict) and msg_obj.get("type") == MsgType.auth.name

def is_auth_conn(sock : socket.SocketType):
    for conn in connections:
        if conn.sock == sock:
            return conn.auth

    return False

def forward(sender : socket.SocketType, msg : bytes):
    count = 0
    for conn in connections:
        if conn.sock and is_auth_conn(conn.sock) and conn.sock != sender:
            conn.sock.send(msg)
            count += 1
    
    print(f"[+] Sent {len(msg)} bytes to {count}/{len(connections)} hosts.")


def recv_msgs(conn : socket.SocketType):
    remote = conn.getpeername()
    cont_to_listen = True
    while cont_to_listen:
        try:
            msg = conn.recv(1024)
            if not msg:
                continue

            print(f"[i] New message from {remote}.")
            print(msg.decode("utf-8"))

            deo_msg = rotcipher.deobfuscate(msg.decode("utf-8"))
            jsonObj = json.loads(deo_msg)
            if is_auth_req(jsonObj):
                auth(conn, jsonObj)

            elif is_auth_conn(conn):
                forward(conn, msg)
            else:
                status = AuthStatus(False, "Not authenticated.")
                obf_status = rotcipher.obfuscate(json.dumps(status.dict()))
                conn.send(str.encode(obf_status))
        
        except ConnectionResetError:
            print(f"[!] {remote} disconnected.")
            cont_to_listen = False
            close_conn(conn)

        except Exception as e:
            traceback.print_exc()
            print(f"[!] Receiving from {remote} failed. {e}")
            cont_to_listen = False
            close_conn(conn)


def listen(host : str, port :int):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # IPv4, TCP
    sock.bind((host, port))
    sock.listen()
    print(f"[i] Listening on {host}:{port}.")

    max_conns = 5
    while True:
        new_conn, conn_info = sock.accept()
        print(f"[i] Connection from {conn_info[0]}:{conn_info[1]}")

        if len(connections) >= max_conns:
            status = AuthStatus(False, "Channel is full. Try again later.")

            obf_status = rotcipher.obfuscate(json.dumps(status.dict()))
            new_conn.send(str.encode(obf_status))

            close_conn(new_conn)
            continue

        new_receiver = threading.Thread(target=recv_msgs, args=(new_conn,))
        new_receiver.start()

        connections.append(Connection(new_conn, False))



connections = [] # Connection type elements
authfile = "./data/.authfile"

if __name__=="__main__":
    host = "0.0.0.0"
    port = 178
    authfile = safe_read(sys.argv, "-af")

    try: 
        listen(host, port)
    except KeyboardInterrupt:
        exit()

# TODO: Messages like <AUTH>.akdald.adkalwd. will fail because of ending dot(.)