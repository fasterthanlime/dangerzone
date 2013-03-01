
// third-party stuff
use deadlogger
import deadlogger/[Log, Logger]

use dye
import dye/[core, input, primitives, sprite, math, loop, text]

use bleep
import bleep

// our stuff
import dangerzone/[logging, level, leveldef, ball, music]

Game: class {

    logger: Logger
    dye: DyeContext

    bleep: Bleep
    music: Music

    loop: FixedLoop

    level: Level

    FONT := static "assets/ttf/slant.ttf"

    // UI stuff
    uiGroup: GlGroup
    ballsText, livesText, fillText, numText, messageText: GlText

    init: func {
        Logging setup()

        logger = Log getLogger("Danger Zone")
        logger info("Starting dangerzone")

        dye = DyeContext new(640, 480, "Danger Zone") 

        initMusic()
        initEvents()

        level = Level new(this)
        dye add(level group)

        uiGroup = GlGroup new()
        dye add(uiGroup)

        initUI()

        level add(Ball new(level))

        dye setClearColor(Color black())

        counter := 0

        loop = FixedLoop new(dye, 60)
        loop run(||
            level update()
            music update()

            counter += 1
            if (counter >= 5) {
                counter = 0

                /*
                "FPS = %.2f | lives = %d | balls = %d | filled = %.2f" \
                    printfln(loop fps, level lives, level balls, level filled)
                */

                ballsText value = "%d balls" format(level balls)
                livesText value = "%d lives" format(level lives)
                fillText value = "%.0f% fill" format(level filled)
                messageText value = level def message
                numText value = "level %d" format(level currentLevel + 1)
            }
        )

        dye quit()
    }

    initMusic: func {
        bleep = Bleep new()
        music = Music new(this)
        music setTheme("ingame")
    }

    initEvents: func {

        dye input onWindowMinimized(||
            loop paused = true
        )

        dye input onWindowRestored(||
            loop paused = false
        )

        // on Android, the back key quits
        dye input onKeyPress(|kev|
            match (kev scancode) {
                case KeyCode AC_BACK || KeyCode ESC =>
                    loop running = false
            }
        )

        dye input onExit(||
            loop running = false
        )

    }

    initUI: func {
        yTextPos := dye height - 80

        ballsText = GlText new(FONT, "20 balls", 32)
        ballsText pos set!(20, yTextPos)
        uiGroup add(ballsText)

        livesText = GlText new(FONT, "2 lives", 32)
        livesText pos set!(200, yTextPos)
        uiGroup add(livesText)

        fillText = GlText new(FONT, "0% fill", 32)
        fillText pos set!(350, yTextPos)
        uiGroup add(fillText)

        numText = GlText new(FONT, "level 1", 32)
        numText pos set!(500, yTextPos)
        uiGroup add(numText)

        messageText = GlText new(FONT, "DANGER!", 32)
        messageText pos set!(20, yTextPos - 40)
        uiGroup add(messageText)
    }

}

