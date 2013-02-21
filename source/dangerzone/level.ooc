
// third-party stuff
use chipmunk
import chipmunk

use dye
import dye/[core, math, input]

// sdk stuff
import structs/[ArrayList, HashMap]
import math/Random

// our stuff
import dangerzone/[game, ball, walls, enemy]

Level: class {

    game: Game

    space: CpSpace
    entities := ArrayList<Entity> new()

    group: GlGroup

    dye: DyeContext { get { game dye } }
    input: Input { get { game dye input } }

    lastBall: Ball

    init: func (=game) {
        group = GlGroup new()

        initPhysx()
        initEvents()

        add(Walls new(this))
        spawnEnemies(3)
    }

    spawnEnemies: func (count: Int) {
        for (i in 0..count) {
            padding := 10
            x := Random randRange(padding, dye width  - padding)
            y := Random randRange(padding, dye height - padding)

            velX := Random randRange(-100, 100)
            velY := Random randRange(-100, 100)
            vel := vec2(velX, velY) normalized() mul(256.0)

            pos := vec2(x, y)
            add(Enemy new(this, pos, vel))
        }
    }

    initPhysx: func {
        space = CpSpace new()
    }

    initEvents: func {
        input onMousePress(MouseButton LEFT, |mp|
            spawnBall()
        )

        input onMouseRelease(MouseButton LEFT, |mr|
            releaseBall()
        )
    }

    spawnBall: func {
        pos := game dye input getMousePos()
        ball := Ball new(this, pos)
        add(ball)
        lastBall = ball
    }

    releaseBall: func {
        if (!lastBall) { return }

        lastBall unsnap()
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

CollisionTypes: enum from Int {
    HEROES
    ENEMIES
}

