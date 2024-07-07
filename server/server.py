import socket
import threading
import json

from svr_model import *
from pathlib import Path

class Connection:
    def __init__(self, sock : socket.SocketType, is_auth : bool) -> None:
        self.sock = sock
        self.auth = is_auth

def close_conn(sock : socket.SocketType):
    for conn in connections:
        if conn.sock == sock:
            connections.remove(conn)
            break

    sock.shutdown(1)
    sock.close()


def check_authfile(uname : str, pword : str):
    if not Path("../data/.authfile").exists():
        return False, "Cannot authenticate at the moment."

    with open("../data/.authfile", "r") as authfile:
        line = authfile.readline()
        
        while line: # Ignore newline char
            creds = line.replace("\n", "").split(":")
            if len(creds) != 2:
                continue # Malformed credentials

            elif creds[0] == uname and creds[1] == pword:
                return True, "Welcome!"
            
            line = authfile.readline()
        
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
        conn.send(str.encode( json.dumps(status.dict()) ))
        return

    authentic, res_msg = check_authfile(uname= req.get("uname"), pword= req.get("pword"))
    if authentic:
        update_auth_status(conn, True)
        status = AuthStatus(True, res_msg)
        conn.send(str.encode( json.dumps(status.dict()) ))
    else:
        status = AuthStatus(False, res_msg)
        conn.send(str.encode( json.dumps(status.dict()) ))
    

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
        if is_auth_conn(conn.sock) and conn.sock != sender:
            conn.sock.send(msg)
            count += 1
    
    print(f"[+] Sent {len(msg)} bytes to {count}/{len(connections)} hosts.")


def recv_msgs(conn : socket.SocketType):
    remote = conn.getpeername()
    while cont_to_listen:
        try:
            msg = conn.recv(1024)
            if not msg:
                continue

            print(f"[i] New message from {remote}.")
            print(msg.decode("utf-8"))

            jsonObj = json.loads(msg)
            if is_auth_req(jsonObj):
                auth(conn, jsonObj)

            elif is_auth_conn(conn):
                forward(conn, msg)
            else:
                status = AuthStatus(False, "Not authenticated.")
                conn.send(str.encode( json.dumps(status.dict()) ))

        except Exception as e:
            print(f"[!] Receiving from {remote} failed. {e}")
            close_conn(conn)


def listen(host : str, port :int):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # IPv4, TCP
    sock.bind((host, port))
    sock.listen()
    print(f"[i] Listening on {host}:{port}.")

    max_conns = 25
    while cont_to_listen:
        new_conn, conn_info = sock.accept()
        print(f"[i] Connection from {conn_info[0]}:{conn_info[1]}")

        if len(connections) >= max_conns:
            status = AuthStatus(False, "Channel is full. Try again later.")
            new_conn.send(json.dumps(status.dict()))
            close_conn(new_conn)
            continue

        new_receiver = threading.Thread(target=recv_msgs, args=(new_conn,))
        new_receiver.start()

        connections.append(Connection(new_conn, False))



connections = [] # Connection type elements
cont_to_listen = True # Updatable by thread listen for KeyboarInterrupt to end server

if __name__=="__main__":
    host = "0.0.0.0"
    port = 178

    try: 
        listen(host, port)
    except KeyboardInterrupt:
        exit()

# TODO: Messages like <AUTH>.akdald.adkalwd. will fail because of ending dot(.)