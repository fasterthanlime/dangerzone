
// third-party stuff
use dye
import dye/[sprite, math]

use gnaar
import gnaar/[utils]

use chipmunk
import chipmunk

// our stuff
import dangerzone/[level, ball]

Enemy: class extends Entity {

    pos: Vec2

    sprite: GlSprite

    shape: CpShape
    body: CpBody

    radius := 8.0
    spriteSide := 32.0

    mass := 0.008
    speed: Float

    enemyHandler: static CpCollisionHandler

    init: func (.level, .pos, vel: Vec2, =speed) {
        super(level)

        this pos = pos clone()

        sprite = GlSprite new("assets/png/enemy.png")
        level group add(sprite)

        vel = vel normalized() mul(speed)
        initPhysx(vel)
    }

    update: func -> Bool {
        scale := radius * 2.0 / spriteSide
        sprite scale set!(scale, scale)

        // try to attain constant velocity
        vel := vec2(body getVel())
        currentSpeed := vel norm()

        alpha := 0.995
        newNorm := currentSpeed * alpha + speed * (1.0 - alpha)
        if (newNorm > speed) {
            newNorm = speed
        }

        body setVel(cpv(vel normalized() mul(newNorm)))
    
        stayInTerrain()

        sprite sync(body)

        true
    }

    stayInTerrain: func {
        // constrain in the terrain
        padding := 10
        pos := body getPos()

        dye := level dye

        if (pos x > dye width) {
            pos x = dye width - padding
            body setPos(pos)
        }
        if (pos x < 0) {
            pos x = padding
            body setPos(pos)
        }
        if (pos y >= dye height) {
            pos y = dye width - padding
            body setPos(pos)
        }
        if (pos y < 0) {
            pos y = padding
            body setPos(pos)
        }
    }

    initPhysx: func (vel: Vec2) {
        moment := cpMomentForCircle(mass, 0, radius, cpv(radius, radius))

        body = CpBody new(mass, moment)
        body setPos(cpv(pos))
        body setVel(cpv(vel))
        level space addBody(body)

        updateShape()

        initHandlers()
    }

    initHandlers: func {
        if (!enemyHandler) {
            enemyHandler = EnemyHandler new()
            level space addCollisionHandler(CollisionTypes ENEMIES,
                CollisionTypes HEROES, enemyHandler)
        }
    }
    
    updateShape: func {
        moment := getMoment()
        body setMoment(moment)

        if (shape) {
            level space removeShape(shape)
            shape free()
            shape = null
        }

        shape = CpCircleShape new(body, radius, cpv(0, 0))
        shape setUserData(this)
        shape setFriction(0.0)
        shape setElasticity(0.9)
        shape setCollisionType(CollisionTypes ENEMIES)
        level space addShape(shape)
    }

    getMoment: func -> Float {
        cpMomentForCircle(mass, 0, radius, cpv(radius, radius))
    }

    destroy: func {
        level group remove(sprite)
        level space removeShape(shape)
        level space removeBody(body)
    }

}

EnemyHandler: class extends CpCollisionHandler {

    begin: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        shape1, shape2: CpShape
        arbiter getShapes(shape1&, shape2&)

        hero := shape2 getUserData() as Ball
        hero harm()

        // if we killed the ball, don't bother colliding
        !(hero dead)
    }

    separate: func (arbiter: CpArbiter, space: CpSpace) {
        // TODO
    }

    preSolve: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        arbiter setElasticity(0.5)

        true
    }

}
