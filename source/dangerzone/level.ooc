
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

    lives := 2
    balls := 20
    filled := 0.0

    currentLevel := 0

    init: func (=game) {
        group = GlGroup new()

        initPhysx()
        initEvents()

        Walls new(this)
        loadLevel(1)
    }

    spawnEnemies: func (count: Int) {
        for (i in 0..count) {
            padding := 10
            x := Random randRange(padding, dye width  - padding)
            y := Random randRange(padding, dye height - padding)

            velX := Random randRange(-100, 100)
            velY := Random randRange(-100, 100)
            vel := vec2(velX, velY)

            pos := vec2(x, y)
            add(Enemy new(this, pos, vel, 256.0))
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

        iter := entities iterator()
        while (iter hasNext?()) {
            e := iter next()
            if (!e update()) {
                iter remove()
                e destroy()
            }
        }

        // update filledness
        terrainArea := (dye width * dye height) as Float
        ballArea := 0.0

        for (e in entities) {
            match e {
                case b: Ball =>
                    ballArea += b area()             
            }
        }

        filled = ballArea * 100.0 / terrainArea

        winloss()
    }

    winloss: func {
        if (lost?()) {
            lives = 2
            loadLevel(1)
        }

        if (won?()) {
            lives += 1
            loadLevel(currentLevel + 1)
        }
    }

    lost?: func -> Bool {
        lives <= 0 || balls <= 0
    }

    won?: func -> Bool {
        filled >= 66.0
    }

    loadLevel: func (=currentLevel) {
        reset()
        spawnEnemies(currentLevel + 1)
    }

    reset: func {
        balls = 20
        while (!entities empty?()) {
            entities removeAt(0) destroy()
        }
    }

}

Entity: class {

    level: Level

    init: func (=level) {
    }

    update: func -> Bool {
        true
    }

    destroy: func {
    }

}

CollisionTypes: enum from Int {
    HEROES
    ENEMIES
}

