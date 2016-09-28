import serial
import time
import threading

c = threading.Condition()

arduino = None


class ReadThread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    def run(self):
        global arduino
        while True:
            c.acquire()
            if not arduino:
                continue
            try:
                data = arduino.readline()
            except serial.serialutil.SerialException:
                try:
                    arduino.close()
                except:
                    pass
                continue
            if data:
                print data.strip()  # strip out the new lines for now
                # (better to do .read() in the long run for this reason


def get_arduino_serial():
    global arduino
    try:
        arduino = serial.Serial("/dev/cu.usbmodem1411", 9600, timeout=.1)
        time.sleep(1)  # Need to wait until the connection is finished
    except:
        arduino = None
    return arduino


def main():
    global arduino

    arduino = get_arduino_serial()

    read_thread = ReadThread()
    read_thread.start()

    while True:
        if not arduino or not arduino.isOpen():
            print "Arduino not connected! Attempting reconnect..."
            arduino = get_arduino_serial()
            if arduino:
                print "Arduino has been reconnected!"
        time.sleep(5)


if __name__ == "__main__":
    main()
