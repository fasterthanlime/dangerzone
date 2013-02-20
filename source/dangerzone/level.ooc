
// third-party stuff
use chipmunk
import chipmunk

use dye
import dye/[core, math, input]

// sdk stuff
import structs/[ArrayList, HashMap]

// our stuff
import dangerzone/[game, ball]

Level: class {

    game: Game

    space: CpSpace
    entities := ArrayList<Entity> new()

    group: GlGroup

    dye: DyeContext { get { game dye } }
    input: Input { get { game dye input } }

    init: func (=game) {
        group = GlGroup new()

        initPhysx()
        initEvents()
    }

    initPhysx: func {
        space = CpSpace new()

        gravity := cpv(0, -1800)
        space setGravity(gravity)
    }

    initEvents: func {
        input onMousePress(MouseButton LEFT, |mp|
            spawnBall()
        )
    }

    spawnBall: func {
        pos := game dye input getMousePos()
        ball := Ball new(this, pos)
        add(ball)
    }

    add: func (e: Entity) {
        entities add(e)
    }

    update: func {
        timeStep: CpFloat = 1.0 / game loop fpsGoal
        space step(timeStep)

        for (e in entities) {
            e update()
        }
    }

}

Entity: class {

    level: Level

    init: func (=level) {
    }

    update: func {
    }

}

