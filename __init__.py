# The MIT License (MIT)
#
# Copyright (c) 2019 John Bartkiw
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import re
import requests
import json

from mycroft.audio.services.vlc import VlcService

from mycroft.skills.common_play_skill import CommonPlaySkill, CPSMatchLevel
from mycroft.skills.core import intent_file_handler
from mycroft.util.log import LOG

from mycroft.audio import wait_while_speaking

# Static values for tunein search requests
headers = {}

class IHeartRadioSkill(CommonPlaySkill):

    def __init__(self):
        super().__init__(name="IHeartRadioSkill")
        self.mediaplayer = VlcService(config={'low_volume': 10, 'duck': True})
        self.audio_state = "stopped"  # 'playing', 'stopped'
        self.station_name = None
        self.station_id = None
        self.stream_url = None
        self.regexes = {}
        self.set_urls()
        self.settings.set_changed_callback(self.set_urls)

    def initialize(self):
        self.gui.register_handler('skill.pause.event', self.handle_pause_event)
        self.gui.register_handler('skill.timer.event', self.setCurrentTrack)

    def handle_pause_event(self, message):
        if self.audio_state == "playing":
            LOG.info("Pause clicked")
            self.gui["playPauseImage"] = "play.svg"
            self.stop()
        else:
            LOG.info("Play clicked")
            self.gui["playPauseImage"] = "pause.svg"
            self.audio_state = "playing"
            self.stream_url = self.gui["streamURL"]
            tracklist = []
            tracklist.append(self.stream_url)
            self.mediaplayer.add_list(tracklist)
            self.mediaplayer.play()

    def set_urls(self):
        country = self.settings.get('country', 'default')
        country_code = self.location['city']['state']['country']['code'].lower() if country == 'default' else country
        if country_code[-1] != '.':
            country_code = country_code + '.'
        if country == 'global' or not self.test_for_local_api(country_code):
            country_code = ''
        self.search_url = "http://{}api.iheart.com/api/v3/search/all".format(country_code)
        self.station_url = "https://{}api.iheart.com/api/v2/content/liveStations/".format(country_code)
        self.currentTrack_url = "https://{}api.iheart.com/api/v3/live-meta/stream/".format(country_code)

    def test_for_local_api(self, country_code):
        try:
            payload = { "keywords" : "test", "maxRows" : 1, "bundle" : "false", "station" : "true", "artist" : "false", "track" : "false", "playlist" : "false", "podcast" : "false" }
            search_url = "http://{}api.iheart.com/api/v3/search/all".format(country_code)
            r = requests.get(search_url, params=payload, headers=headers)
            return r.status_code == 200
        except:
            return False

    def CPS_match_query_phrase(self, phrase):
        # Look for regex matches starting from the most specific to the least
        # Play <data> internet radio on i heart radio
        match = re.search(self.translate_regex('internet_radio_on_iheart'), phrase)
        if match:
            data = re.sub(self.translate_regex('internet_radio_on_iheart'), '', phrase)
            LOG.debug("CPS Match (internet_radio_on_iheart): " + data)
            return phrase, CPSMatchLevel.EXACT, data

        # Play <data> radio on i heart radio
        match = re.search(self.translate_regex('radio_on_iheart'), phrase)
        if match:
            data = re.sub(self.translate_regex('radio_on_iheart'), '', phrase)
            LOG.debug("CPS Match (radio_on_iheart): " + data)
            return phrase, CPSMatchLevel.EXACT, data

        # Play <data> on i heart radio
        match = re.search(self.translate_regex('on_iheart'), phrase)
        if match:
            data = re.sub(self.translate_regex('on_iheart'), '', phrase)
            LOG.debug("CPS Match (on_iheart): " + data)
            return phrase, CPSMatchLevel.EXACT, data

        # Play <data> internet radio
        match = re.search(self.translate_regex('internet_radio'), phrase)
        if match:
            data = re.sub(self.translate_regex('internet_radio'), '', phrase)
            LOG.debug("CPS Match (internet_radio): " + data)
            return phrase, CPSMatchLevel.CATEGORY, data

        # Play <data> radio
        match = re.search(self.translate_regex('radio'), phrase)
        if match:
            data = re.sub(self.translate_regex('radio'), '', phrase)
            LOG.debug("CPS Match (radio): " + data)
            return phrase, CPSMatchLevel.CATEGORY, data

        return phrase, CPSMatchLevel.GENERIC, phrase

    def CPS_start(self, phrase, data):
        LOG.debug("CPS Start: " + data)
        self.find_station(data)

    @intent_file_handler('StreamRequest.intent')
    def handle_stream_intent(self, message):
        self.find_station(message.data["station"])
        LOG.debug("Station data: " + message.data["station"])

    def find_station(self, search_term):
        tracklist = []
        payload = { "keywords" : search_term, "maxRows" : 1, "bundle" : "false", "station" : "true", "artist" : "false", "track" : "false", "playlist" : "false", "podcast" : "false" }
        # get the response from the IHeartRadio API
        search_res = requests.get(self.search_url, params=payload, headers=headers)
        search_obj = json.loads(search_res.text)

        if (len(search_obj["results"]["stations"]) > 0):
            self.station_name = search_obj["results"]["stations"][0]["name"]
            self.station_id = search_obj["results"]["stations"][0]["id"]
            LOG.debug("Station name: " + self.station_name + " ID: " + str(self.station_id))

            # query the station URL using the ID
            station_res = requests.get(self.station_url+str(self.station_id))
            station_obj = json.loads(station_res.text)
            self.audio_state = "playing"
            self.speak_dialog("now.playing", {"station": self.station_name} )
            wait_while_speaking()
            # Use the first stream URL
            for x in list(station_obj["hits"][0]["streams"])[0:1]:
                self.stream_url = station_obj["hits"][0]["streams"][x]
                break
            LOG.debug("Station URL: " + self.stream_url)

            self.gui["streamURL"] = self.stream_url
            self.gui["logoURL"] = station_obj["hits"][0]["logo"]
            self.gui["description"] = station_obj["hits"][0]["description"]
            self.gui["playPauseImage"] = "pause.svg"
            self.setCurrentTrack("")
            self.gui.show_page("controls.qml", override_idle=True)

            tracklist.append(self.stream_url)
            self.mediaplayer.add_list(tracklist)
            self.mediaplayer.play()
        else:
            self.speak_dialog("not.found")
            wait_while_speaking()

    def setCurrentTrack(self,message):
        currentTrack_res = requests.get(self.currentTrack_url+str(self.station_id)+"/currentTrackMeta")
        LOG.info("Response: "+str(currentTrack_res.status_code))
        if currentTrack_res.status_code == 200:
            currentTrack_obj = json.loads(currentTrack_res.text)
            self.gui["artist"] = "Artist: "+currentTrack_obj["artist"]
            self.gui["album"] = "Album: "+currentTrack_obj["album"]
            self.gui["title"] = currentTrack_obj["title"]
            if "imagePath" in currentTrack_obj:
                self.gui["currentTrackImg"] = currentTrack_obj["imagePath"]
            else:
                self.gui["currentTrackImg"] = self.gui["logoURL"]

    def stop(self):
        if self.audio_state == "playing":
            self.mediaplayer.stop()
            self.mediaplayer.clear_list()
            LOG.debug("Stopping stream")
        self.audio_state = "stopped"
        self.station_name = None
        self.station_id = None
        self.stream_url = None
        return True

    def shutdown(self):
        if self.audio_state == 'playing':
            self.mediaplayer.stop()
            self.mediaplayer.clear_list()

    # Get the correct localized regex
    def translate_regex(self, regex):
        if regex not in self.regexes:
            path = self.find_resource(regex + '.regex')
            if path:
                with open(path) as f:
                    string = f.read().strip()
                self.regexes[regex] = string
        return self.regexes[regex]

def create_skill():
    return IHeartRadioSkill()
