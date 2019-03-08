# TODO: Add an appropriate license to your skill before publishing.  See
# the LICENSE file for more information.

# Below is the list of outside modules you'll be using in your skill.
# They might be built-in to Python, from mycroft-core or from external
# libraries.  If you use an external library, be sure to include it
# in the requirements.txt file so the library is installed properly
# when the skill gets installed later by a user.

import vlc
import requests
import json

from .vlc import Instance
from adapt.intent import IntentBuilder
from mycroft.skills.core import MycroftSkill, intent_file_handler
from mycroft.util.log import LOG

# Static values for tunein search requests
search_url = "http://api.iheart.com/api/v3/search/all"
station_url = "https://api.iheart.com/api/v2/content/liveStations/"
headers = {}

class IHeartRadioSkill(MycroftSkill):

    # The constructor of the skill, which calls MycroftSkill's constructor
    def __init__(self):
        super().__init__(name="IHeartRadioSkill")
        self.vlc_instance = Instance()
        self.vlc_player = self.vlc_instance.media_player_new()
        self.station_name = None
        self.station_id = None
        self.stream_url = None

    @intent_file_handler('StreamRequest.intent')
    def handle_stream_intent(self, message):
        self.find_station(message.data["station"])
        LOG.debug("Station data: " + message.data["station"])

    def find_station(self, search_term):
        payload = { "keywords" : search_term, "maxRows" : 1, "bundle" : "false", "station" : "true", "artist" : "false", "track" : "false", "playlist" : "false", "podcast" : "false" }
        # get the response from the IHeartRadio API
        search_res = requests.get(search_url, params=payload, headers=headers)
        search_obj = json.loads(search_res.text)

        self.station_name = search_obj["results"]["stations"][0]["name"]
        self.station_id = search_obj["results"]["stations"][0]["id"]
        LOG.debug("Station name: " + self.station_name + " ID: " + str(self.station_id))

        # query the station URL using the ID
        station_res = requests.get(station_url+str(self.station_id))
        station_obj = json.loads(station_res.text)
        # Use the first stream URL
        for x in list(station_obj["hits"][0]["streams"])[0:1]:
            self.stream_url = station_obj["hits"][0]["streams"][x]
            break
        LOG.debug("Station URL: " + self.stream_url)

        # start playing the stream
        Media = self.vlc_instance.media_new(self.stream_url)
        Media.get_mrl()
        self.vlc_player.set_media(Media)
        self.vlc_player.play()

    def stop(self):
        self.vlc_player.stop();
        return True

# The "create_skill()" method is used to create an instance of the skill.
# Note that it's outside the class itself.
def create_skill():
    return IHeartRadioSkill()
