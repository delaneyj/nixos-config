{
  python3Packages,
  writers,
}:

writers.writePython3Bin "cosmic-ac-idle-inhibit" {
  libraries = [ python3Packages.dbus-next ];
} ''
  import asyncio

  from dbus_next import BusType, Message, MessageType
  from dbus_next.aio import MessageBus

  DBUS_DESTINATION = "org.freedesktop.DBus"
  DBUS_PATH = "/org/freedesktop/DBus"
  DBUS_INTERFACE = "org.freedesktop.DBus"
  SCREENSAVER_DESTINATION = "org.freedesktop.ScreenSaver"
  SCREENSAVER_PATH = "/org/freedesktop/ScreenSaver"
  UPOWER_DESTINATION = "org.freedesktop.UPower"
  UPOWER_PATH = "/org/freedesktop/UPower"


  async def call(bus, message):
      reply = await bus.call(message)
      if reply.message_type == MessageType.ERROR:
          raise RuntimeError(reply.error_name or "D-Bus call failed")
      return reply.body


  async def get_name_owner(bus, name):
      try:
          body = await call(
              bus,
              Message(
                  destination=DBUS_DESTINATION,
                  path=DBUS_PATH,
                  interface=DBUS_INTERFACE,
                  member="GetNameOwner",
                  signature="s",
                  body=[name],
              ),
          )
      except RuntimeError:
          return None
      return body[0]


  async def is_on_battery(bus):
      body = await call(
          bus,
          Message(
              destination=UPOWER_DESTINATION,
              path=UPOWER_PATH,
              interface="org.freedesktop.DBus.Properties",
              member="Get",
              signature="ss",
              body=[UPOWER_DESTINATION, "OnBattery"],
          ),
      )
      return body[0].value


  async def inhibit(bus):
      body = await call(
          bus,
          Message(
              destination=SCREENSAVER_DESTINATION,
              path=SCREENSAVER_PATH,
              interface=SCREENSAVER_DESTINATION,
              member="Inhibit",
              signature="ss",
              body=[
                  "cosmic-ac-idle-inhibit",
                  "Keep the system awake while connected to AC power",
              ],
          ),
      )
      return body[0]


  async def uninhibit(bus, cookie):
      await call(
          bus,
          Message(
              destination=SCREENSAVER_DESTINATION,
              path=SCREENSAVER_PATH,
              interface=SCREENSAVER_DESTINATION,
              member="UnInhibit",
              signature="u",
              body=[cookie],
          ),
      )


  async def main():
      session_bus = await MessageBus(bus_type=BusType.SESSION).connect()
      system_bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
      cookie = None
      inhibited_owner = None

      while True:
          try:
              on_battery = await is_on_battery(system_bus)
              owner = await get_name_owner(
                  session_bus,
                  SCREENSAVER_DESTINATION,
              )

              if on_battery:
                  if cookie is not None and owner == inhibited_owner:
                      await uninhibit(session_bus, cookie)
                      print("AC idle inhibition disabled", flush=True)
                  cookie = None
                  inhibited_owner = None
              elif owner is not None and owner != inhibited_owner:
                  cookie = await inhibit(session_bus)
                  inhibited_owner = owner
                  print("AC idle inhibition enabled", flush=True)
          except Exception as error:
              print(f"Waiting for power and idle services: {error}", flush=True)

          await asyncio.sleep(5)


  asyncio.run(main())
''
