
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

    mass := 0.01

    enemyHandler: static CpCollisionHandler

    init: func (.level, .pos, vel: Vec2) {
        super(level)

        this pos = pos clone()

        sprite = GlSprite new("assets/png/enemy.png")
        level group add(sprite)

        initPhysx(vel)
    }

    update: func {
        scale := radius * 2.0 / spriteSide
        sprite scale set!(scale, scale)

        sprite sync(body)
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
        /*
        if (!enemyHandler) {
            enemyHandler = EnemyHandler new()
            level space addCollisionHandler(CollisionTypes HEROES,
                CollisionTypes HEROES, enemyHandler)
        }
        */
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
        shape setCollisionType(CollisionTypes HEROES)
        level space addShape(shape)
    }

    getMoment: func -> Float {
        cpMomentForCircle(mass, 0, radius, cpv(radius, radius))
    }

}

EnemyHandler: class extends CpCollisionHandler {

    begin: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        // TODO
        true
    }

    separate: func (arbiter: CpArbiter, space: CpSpace) {
        // TODO
    }

    delta: func (arbiter: CpArbiter, delta: Int) {
        shape1, shape2: CpShape
        arbiter getShapes(shape1&, shape2&) 

        ball1 := shape1 getUserData() as Ball
        ball2 := shape2 getUserData() as Ball

        ball1 selfCount += delta
        ball2 selfCount += delta
    }

}
