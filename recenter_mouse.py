import pyautogui
from pynput import keyboard
from ctypes import windll, create_string_buffer, byref, Structure, c_ulong, c_long, c_ushort, c_short, c_char
import os
import logging

# Set up logging
logging.basicConfig(filename='recenter_mouse.log', level=logging.INFO, format='%(asctime)s - %(message)s')


class DEVMODE(Structure):
    _fields_ = [
        ("dmDeviceName", c_char * 32),
        ("dmSpecVersion", c_ushort),
        ("dmDriverVersion", c_ushort),
        ("dmSize", c_ushort),
        ("dmDriverExtra", c_ushort),
        ("dmFields", c_ulong),
        ("dmPositionX", c_long),
        ("dmPositionY", c_long),
        ("dmDisplayOrientation", c_ulong),
        ("dmDisplayFixedOutput", c_ulong),
        ("dmColor", c_short),
        ("dmDuplex", c_short),
        ("dmYResolution", c_short),
        ("dmTTOption", c_short),
        ("dmCollate", c_short),
        ("dmFormName", c_char * 32),
        ("dmLogPixels", c_ushort),
        ("dmBitsPerPel", c_ulong),
        ("dmPelsWidth", c_ulong),
        ("dmPelsHeight", c_ulong),
        ("dmDisplayFlags", c_ulong),
        ("dmDisplayFrequency", c_ulong),
        ("dmICMMethod", c_ulong),
        ("dmICMIntent", c_ulong),
        ("dmMediaType", c_ulong),
        ("dmDitherType", c_ulong),
        ("dmReserved1", c_ulong),
        ("dmReserved2", c_ulong),
        ("dmPanningWidth", c_ulong),
        ("dmPanningHeight", c_ulong)
    ]

class DISPLAY_DEVICE(Structure):
    _fields_ = [
        ("cb", c_ulong),
        ("DeviceName", c_char * 32),
        ("DeviceString", c_char * 128),
        ("StateFlags", c_ulong),
        ("DeviceID", c_char * 128),
        ("DeviceKey", c_char * 128)
    ]

def get_main_display():
    user32 = windll.user32
    devmode = DEVMODE()
    display_device = DISPLAY_DEVICE()
    display_device.cb = c_ulong(424)

    i = 0
    while user32.EnumDisplayDevicesA(None, i, byref(display_device), 0):
        if display_device.StateFlags & 0x4:  # DISPLAY_DEVICE_PRIMARY_DEVICE
            user32.EnumDisplaySettingsA(display_device.DeviceName, -1, byref(devmode))
            return devmode.dmPositionX, devmode.dmPositionY, devmode.dmPelsWidth, devmode.dmPelsHeight
        i += 1

def center_mouse():
    main_display = get_main_display()
    if main_display:
        x, y, width, height = main_display
        # Calculate the center position of the main display
        center_x = x + width // 2
        center_y = y + height // 2
        # Move the mouse to the center of the main display
        pyautogui.moveTo(center_x, center_y)

def on_activate():
    center_mouse()

def for_canonical(f):
    return lambda k: f(l.canonical(k))

if __name__ == "__main__":
    # Define the hotkey
    hotkey = keyboard.HotKey(
        keyboard.HotKey.parse('<ctrl>+<alt>+c'),
        on_activate
    )

    # Set up the listener
    with keyboard.Listener(
            on_press=for_canonical(hotkey.press),
            on_release=for_canonical(hotkey.release)) as l:
        
        logging.info("Keyboard listener is now running")
        l.join()
        logging.info("Keyboard listener is now running 2")