import threading
import socket
import sys

def connect(host : str, port : int):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # IPv4, TCP
        sock.connect((host, port))
        print(f"[+] Connected to {sock.getpeername()}")

    except Exception:
        print(f"[!] Error connecting to server at {sock.getpeername()}")
        exit()

    new_msg_receiver = threading.Thread(target=recv_messages, args=(sock,))
    new_msg_receiver.start()

    send_messages(sock)

def recv_messages(sock : socket.SocketType):
    global cont_exec
    try: 
        while cont_exec:
            in_msg = sock.recv(1024)

            if in_msg.strip():
                print(f"\r{' '*len(prompt_txt)}\n{in_msg.decode('utf-8')}\n")
                print(f"{prompt_txt}", end="", flush=True)

        return
    except ConnectionResetError:
        print("\n[!] Server disconnected.")
        sock.close()
        cont_exec = False

def send_messages(sock : socket.SocketType):
    global cont_exec
    try:
        print(prompt_txt, end="")
        while cont_exec:
            out_msg = input().strip()
            out_msg += "\n"

            if out_msg:
                sock.send(str.encode(out_msg))

    except KeyboardInterrupt:
        cont_exec = False
        print("\n[i] Bye bye.")

cont_exec = True
prompt_txt = "(message)~$ "

if __name__=="__main__":
    host = "127.0.0.1"
    port = 178

    connect(host, port)


# print(f"\r{' '*len(prompt_text)}\n{msg}\n") # overwrite current prompt before output new message
# print(prompt_text, end="", flush=True)