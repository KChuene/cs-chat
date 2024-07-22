from enum import Enum

class MsgType(Enum):
    auth = 1,
    normal = 2

class AuthStatus:
    def __init__(self, did_succeed, text) -> None:
        self.type = MsgType.auth
        self.success = did_succeed
        self.text = text

    def dict(self) -> dict:
        return {
            "type": self.type.name,
            "isSuccess": self.success,
            "text": self.text
        }
    

class TextMessage:
    def __init__(self, uname, text, date) -> None:
        self.type = MsgType.normal
        self.sender = uname
        self.text = text
        self.date = date

    def dict(self):
        return {
            "type": self.type.name,
            "sender": self.sender,
            "text": self.text,
            "date": self.date
        }
