import threading
import time

c = threading.Condition()


class ReadThread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    def run(self):
        global arduino
        while True:
            c.acquire()
            print "Here..."
            print arduino
            time.sleep(1)
