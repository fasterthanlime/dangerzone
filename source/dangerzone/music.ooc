
// third-party stuff
use bleep
import bleep

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/[HashMap, ArrayList, List]
import math/Random

// our stuff
import dangerzone/[game]

Music: class {

    logger := static Log getLogger(This name)

    bleep: Bleep { get { game bleep } }
    game: Game

    sets := HashMap<String, SongSet> new()
    currentTheme: String

    musicStopped := false

    init: func (=game) {
        setupSets()
        bleep onMusicStop(|| musicStopped = true)
    }

    update: func {
        if (musicStopped) {
            musicStopped = false
            pickNewMusic()
        }
    }

    setupSets: func {
        {
            ingame := SongSet new("ingame")
            ingame add("dangerzone-01"). \
                   add("dangerzone-02"). \
                   add("dangerzone-03"). \
                   add("dangerzone-04")
            sets put(ingame name, ingame)
        }
    }

    setTheme: func (.currentTheme) {
        if (currentTheme != this currentTheme) {
            this currentTheme = currentTheme
            logger info("Changing music theme to: %s", currentTheme)

            if (this currentTheme) {
                if (bleep musicPlaying?()) {
                    logger info("Fading out...")
                    bleep fadeMusic(3000)
                } else {
                    pickNewMusic()
                }
            }
        }
    }

    pickNewMusic: func {
        if (!currentTheme) {
            logger warn("Current theme is null, not picking music!")
            return
        }

        myset := sets get(currentTheme)
        if (!myset) {
            logger warn("Unknown them '%s', not playing", currentTheme)
            return
        }

        music := Random choice(myset songs)
        logger warn("Playing music %s", music)
        bleep playMusic(music, 0)
    }

}

SongSet: class {

    name: String
    songs := ArrayList<String> new()

    init: func (=name) {
    }

    add: func (musicName: String) {
        songs add("assets/ogg/%s.ogg" format(musicName))
    }

}

