
// third-party stuff
use deadlogger
import deadlogger/[Log, Logger]

use dye
import dye/[core, input, primitives, sprite, math, loop, text]

// our stuff
import dangerzone/[logging, level, ball]

Game: class {

    logger: Logger
    dye: DyeContext

    loop: FixedLoop

    level: Level

    // UI stuff
    uiGroup: GlGroup
    ballsText, livesText, fillText: GlText

    init: func {
        Logging setup()

        logger = Log getLogger("Danger Zone")
        logger info("Starting dangerzone")

        dye = DyeContext new(640, 480, "Danger Zone") 
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
            }
        )

        dye quit()
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

        ballsText = GlText new("assets/ttf/slant.ttf", "20 balls", 40)
        ballsText pos set!(30, yTextPos)
        uiGroup add(ballsText)

        livesText = GlText new("assets/ttf/slant.ttf", "2 lives", 40)
        livesText pos set!(230, yTextPos)
        uiGroup add(livesText)

        fillText = GlText new("assets/ttf/slant.ttf", "0% fill", 40)
        fillText pos set!(430, yTextPos)
        uiGroup add(fillText)
    }

}

