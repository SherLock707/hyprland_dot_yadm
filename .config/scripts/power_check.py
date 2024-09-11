import subprocess
import os
import time

def ping_host(host):
    """
    Ping a host and return True if successful, False otherwise.
    """
    ping_cmd = ["ping","-W", "1.0", "-c", "1", host]
    try:
        subprocess.check_output(ping_cmd)
        return True
    except subprocess.CalledProcessError:
        return False

def main():
    host_to_ping = "192.168.1.88"
    router_to_ping = "192.168.1.1"
    failed = 5
    count_down = 3
    suspended = False

    while True:
        if os.path.exists("/tmp/POWER_OUTAGE_KILLSWITCH"):
            if ping_host(host_to_ping):
                # print('Successful ping')
                failed = 5
                suspended = False
            else:
                print('Failed ping')
                failed -= 1
            
            if failed < 5 and not suspended:
                os.system(f"notify-send -e -a 'Power failure' -h string:x-canonical-private-synchronous:power_notif -u low -i '/home/itachi/.config/dunst/images/bell.png' 'Suspending in {failed}' &")
                count_down -= 1

            if failed <= 1 and not suspended:
                if not ping_host(router_to_ping):
                    time.sleep(5)
                    continue
                failed = 5
                os.system(f"notify-send -t 3000 -e -a 'Power failure' -h string:x-canonical-private-synchronous:power_notif -u low -i '/home/itachi/.config/dunst/images/bell.png' 'Suspending' &")
                suspended = True
                os.system("systemctl suspend & disown")
                # os.system(f"notify-send -e -a 'Power failure' -h string:x-canonical-private-synchronous:power_notif -u low -i '/home/itachi/.config/dunst/images/bell.png' 'Good bye' &")
                # os.system("sudo systemctl suspend & disown")

                count_down = 3

                # break
        # else:
        #     print("POWER_OUTAGE_KILLSWITCH file not found. Ignoring the operation.")

        time.sleep(0.1)

if __name__ == "__main__":
    main()
