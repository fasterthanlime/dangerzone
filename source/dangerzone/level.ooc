
// third-party stuff
use chipmunk
import chipmunk

use dye
import dye/[core, math, input]

use gnaar
import gnaar/[utils]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/[List, ArrayList, HashMap]
import math/Random

// our stuff
import dangerzone/[game, ball, walls, enemy, leveldef]

Level: class {

    logger := static Log getLogger(This name)

    game: Game

    space: CpSpace
    physicSteps := 10
    entities := ArrayList<Entity> new()

    group: GlGroup

    dye: DyeContext { get { game dye } }
    input: Input { get { game dye input } }

    lastBall: Ball

    lives := 2
    balls := 20
    filled := 0.0

    // current level stuff
    currentLevel := 0
    def: LevelDef
    defs: List<LevelDef>

    init: func (=game) {
        group = GlGroup new()

        initPhysx()
        initEvents()

        Walls new(this)

        defs = LevelDef getList()
        loadLevel(0)
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

        input onKeyPress(KeyCode RIGHT, |kp|
            loadLevel(currentLevel + 1)
        )

        input onKeyPress(KeyCode LEFT, |kp|
            loadLevel(currentLevel - 1)
        )

        input onKeyPress(KeyCode SPACE, |kp|
            lives += 10
        )
    }

    spawnBall: func {
        pos := game dye input getMousePos()

        touched := false
        for (e in entities) {
            match e {
                case ball: Ball =>
                    ballPos := vec2(ball body getPos())
                    dist := pos dist(ballPos)
                    if (dist < ball radius) {
                        if (def spiky) {
                            ball makeSpiky()
                        }
                        touched = true
                        break
                    }
            }
        }

        if (!touched) {
            // all clear, spawn a new one
            ball := Ball new(this, pos)
            add(ball)
            lastBall = ball
        }
    }

    releaseBall: func {
        if (!lastBall) { return }

        lastBall unsnap()
    }

    add: func (e: Entity) {
        entities add(e)
    }

    update: func {
        updatePhysics()

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

        canwin := true

        for (e in entities) {
            match e {
                case b: Ball =>
                    if (b snapped) {
                        canwin = false
                    }
                    ballArea += b area()             
            }
        }

        filled = ballArea * 100.0 / terrainArea

        if (canwin) {
            winloss()
        }
    }

    updatePhysics: func {
        timeStep: CpFloat = 1.0 / game loop fpsGoal
        realStep := timeStep / physicSteps as Float
        for (i in 0..physicSteps) {
            space step(realStep)
        }
    }

    winloss: func {
        if (lost?()) {
            lives = 2
            loadLevel(0)
        }

        if (won?()) {
            lives += 1
            loadLevel(currentLevel + 1)
        }
    }

    lost?: func -> Bool {
        lives < 0 || balls < 0
    }

    won?: func -> Bool {
        filled >= 66.0
    }

    loadLevel: func (=currentLevel) {
        reset()

        if (currentLevel >= defs size) {
            // won the game!
            loadLevel(0)
            return
        }

        if (currentLevel < 0) {
            // wrapping around - cheater!
            loadLevel(defs size - 1)
            return
        }

        def = defs get(currentLevel)
        spawnEnemies(def numEnemies)
        balls = def numBalls
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
    WALLS
}

