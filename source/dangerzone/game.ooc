
// third-party stuff
use deadlogger
import deadlogger/[Log, Logger]

use dye
import dye/[core, input, primitives, sprite, math, loop]

// our stuff
import dangerzone/[logging, level, ball]

Game: class {

    logger: Logger
    dye: DyeContext

    loop: FixedLoop

    level: Level

    init: func {
        Logging setup()

        logger = Log getLogger("Danger Zone")
        logger info("Starting dangerzone")

        dye = DyeContext new(640, 480, "Danger Zone") 
        initEvents()

        loop = FixedLoop new(dye, 60)

        level = Level new(this)
        dye add(level group)

        level add(Ball new(level))

        dye setClearColor(Color white())

        counter := 0

        loop run(||
            level update()

            counter += 1
            if (counter >= 30) {
                counter = 0
                "FPS = %.2f | lives = %d | balls = %d | filled = %.2f" \
                    printfln(loop fps, level lives, level balls, level filled)
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

}

