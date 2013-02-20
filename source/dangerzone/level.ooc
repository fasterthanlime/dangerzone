
// third-party stuff
use chipmunk
import chipmunk

use dye
import dye/[core, math]

// sdk stuff
import structs/[ArrayList, HashMap]

// our stuff
import dangerzone/[game, ball]

Level: class {

    game: Game

    space: CpSpace
    entities := ArrayList<Entity> new()

    group: GlGroup

    init: func (=game) {
        group = GlGroup new()

        initPhysx()
    }

    initPhysx: func {
        space = CpSpace new()

        gravity := cpv(0, -1800)
        space setGravity(gravity)
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

