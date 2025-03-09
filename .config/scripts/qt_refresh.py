import dbus

bus = dbus.SessionBus()
config = bus.get_object("org.kde.kconfig.notify", "/kdeglobals")
iface = dbus.Interface(config, "org.kde.kconfig.notify")

# Send the exact KDE-configured signal structure
iface.ConfigChanged(
    {"Icons": [dbus.ByteArray("Theme".encode("utf-8"))]}
)
