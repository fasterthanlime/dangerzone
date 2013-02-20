
// third-party stuff
use deadlogger
import deadlogger/[Log, Logger]

use dye
import dye/[core, input, primitives, sprite, math, loop]

// our stuff
import dangerzone/[logging]

Game: class {

    logger: Logger
    dye: DyeContext
    loop: FixedLoop

    init: func {
        Logging setup()

        logger = Log getLogger("Danger Zone")
        logger info("Starting dangerzone")

        dye = DyeContext new(640, 480, "Danger Zone") 
        initEvents()

        loop = FixedLoop new(dye, 60)

        dye setClearColor(Color white())

        loop run(||
            "FPS = %.2f" printfln(loop fps)
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

