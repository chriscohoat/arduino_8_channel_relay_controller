import serial
import time
import threading
from flask import Flask
from flask import jsonify
from forms import ToggleForm, SwitchForm

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


class WebThread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    @staticmethod
    def handle_form_errors(form):
        validation_errors = []
        for field, errors in form.errors.items():
            for error in errors:
                validation_errors.append(u"Error in the `%s` field - %s" % (
                    getattr(form, field).label.text,
                    error
                ))
        return jsonify({"errors": validation_errors}), 400

    def run(self):
        global arduino
        app = Flask(__name__)

        @app.route('/toggle', methods=['POST'])
        def toggle_relays():
            form = ToggleForm(csrf_enabled=False)
            if form.validate():
                if form.desired_relay.data < 2 or form.desired_relay.data > 9:
                    return jsonify({"errors": ["Field `desired_relay` must be between 2 and 9, inclusive."]}), 400
                elif form.new_value.data.strip() not in ["off", "on"]:
                    return jsonify({"errors": ["Field `new_value` must be `off` or `on`"]}), 400
                try:
                    arduino.write(bytes(b"%s,%s" % (form.desired_relay.data, form.new_value.data)))
                except:
                    return jsonify({"errors": ["Could not write!"]}), 500
            else:
                return WebThread.handle_form_errors(form)
            return jsonify({"success": True})

        @app.route('/switchAll', methods=['POST'])
        def switch_all_relays():
            form = SwitchForm(csrf_enabled=False)
            if form.validate():
                if form.new_value.data.strip() not in ["off", "on"]:
                    return jsonify({"errors": ["Field `new_value` must be `off` or `on`"]}), 400
                for desired_relay in xrange(2, 10):
                    try:
                        arduino.write(bytes(b"%s,%s" % (desired_relay, form.new_value.data)))
                    except:
                        return jsonify({"errors": ["Could not write!"]}), 500
                    time.sleep(.1)
            else:
                return WebThread.handle_form_errors(form)
            return jsonify({"success": True})

        app.run(host='0.0.0.0', port=9999)


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

    webserver_thread = WebThread()
    webserver_thread.start()

    while True:
        if not arduino or not arduino.isOpen():
            print "Arduino not connected! Attempting reconnect..."
            arduino = get_arduino_serial()
            if arduino:
                print "Arduino has been reconnected!"
        time.sleep(5)


if __name__ == "__main__":
    main()
