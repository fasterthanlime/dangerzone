
// third-party stuff
use dye
import dye/[sprite, math]

use gnaar
import gnaar/[utils]

use chipmunk
import chipmunk

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import math

// our stuff
import dangerzone/[level, leveldef]

Ball: class extends Entity {

    logger := static Log getLogger(This name)

    pos: Vec2

    group: GlGroup
    sprite, spikeSprite: GlSprite

    shape: CpShape
    body: CpBody

    radius := 1.0
    targetRadius := 1.0

    spriteSide := 512.0

    mass := 10.0

    snapped := true
    dead := false

    selfCount := 0
    invulnerableCount := 0
    invulnerableLength := 30
    invulnerable: Bool { get { invulnerableCount > 0 || spiky || spiker } }

    spiky := false

    spiker: This
    spikePoint: Vec2
    spikeConstraint: CpPinJoint

    life := 1.0

    harmed := false

    brightness := 1.0

    selfHandler, ballWallsHandler: static CpCollisionHandler

    init: func (.level, .pos) {
        super(level)

        this pos = pos clone()

        group = GlGroup new()
        level group add(group)

        sprite = GlSprite new("assets/png/ball-happy.png")
        group add(sprite)

        initPhysx()
    }

    area: func -> Float {
        PI * radius * radius
    }

    update: func -> Bool {
        if (dead) {
            return false
        }

        if (life <= 0.0) {
            dead = true
            return false
        }

        // handle spikes
        if (spiker && !spikeConstraint) {
            point := cpv(spikePoint)
            spikeConstraint = CpPinJoint new(spiker body, body, point, point)
            level space addConstraint(spikeConstraint)
            logger info("Added point constraint!")
        }

        if (selfCount < 2 && invulnerableCount > 0) {
            invulnerableCount -= 1
        }

        if (harmed) {
            harmed = false
            if (snapped) {
                dead = true
                level lives -= 1
            } else {
                if (level def fragile && !invulnerable) {
                    life -= 0.1
                    targetRadius *= 0.85
                    updateShape()
                }
            }
        }

        if ((radius - targetRadius) abs() > EPSILON) {
            alpha := 0.95
            radius = radius * alpha + targetRadius * (1 - alpha)
            updateShape()
        }

        targetBrightness := 65.0
        if (invulnerable) {
            targetBrightness = 255.0
        }

        {
            alpha := 0.95
            brightness = brightness * alpha + targetBrightness * (1 - alpha)
        }
        sprite color set!(brightness, brightness, spiky ? 20 : brightness)
        diameter := radius * 2.0

        if (snapped) {
            pos := level dye input getMousePos()
            size := level dye size toVec2()

            if (diameter >= size x || diameter >= size y) {
                // we're as big as we're gonna get
                unsnap()
            }

            if (selfCount > 0) {
                if (level def selfHurt) {
                    // we've hit something! - we're doomed
                    harm()
                } else {
                    // we've hit something! - unsnap
                    unsnap()
                }
            }

            if (pos x < radius) {
                pos x = radius
            }
            if (pos x + radius >= size x) {
                pos x = size x - radius
            }
            if (pos y < radius) {
                pos y = radius
            }
            if (pos y + radius >= size y) {
                pos y = size y - radius
            }

            body setPos(cpv(pos))
            body setVel(cpv(0, 0))
            setRadius(radius + 1.2)
            updateShape()
        }

        // local gravity
        body setForce(cpv(0, -8000))

        scale := diameter * (1.0 / spriteSide as Float)
        sprite scale set!(scale, scale)
        sprite sync(body)

        if (spikeSprite) {
            spikeScale := scale * 1.3
            spikeSprite scale set!(spikeScale, spikeScale)
            spikeSprite sync(body)
        }

        true
    }

    setRadius: func (=radius) {
        targetRadius = radius
        updateShape()
    }

    destroy: func {
        level group remove(group)
        level space removeShape(shape)
        level space removeBody(body)
    }

    initPhysx: func {
        moment := cpMomentForCircle(mass, 0, radius, cpv(radius, radius))

        body = CpBody new(mass, moment)
        body setPos(cpv(pos))
        level space addBody(body)

        updateShape()

        initHandlers()
    }

    initHandlers: func {
        if (!selfHandler) {
            selfHandler = SelfHandler new()
            level space addCollisionHandler(CollisionTypes HEROES,
                CollisionTypes HEROES, selfHandler)
        }

        if (!ballWallsHandler) {
            ballWallsHandler = BallWallsHandler new()
            level space addCollisionHandler(CollisionTypes HEROES,
                CollisionTypes WALLS, ballWallsHandler)
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
        shape setFriction(0.9)
        shape setElasticity(0.2)
        shape setCollisionType(CollisionTypes HEROES)
        level space addShape(shape)
    }

    getMoment: func -> Float {
        cpMomentForCircle(mass, 0, radius, cpv(radius, radius))
    }

    unsnap: func {
        if (!snapped) { return }

        snapped = false
        level balls -= 1
    }

    harm: func {
        if (dead) { return }

        harmed = true
    }

    makeSpiky: func {
        if (invulnerable && !spiky) {
            level balls -= 1
            spiky = true
            updateShape() // so we re-have collisions

            spikeSprite = GlSprite new("assets/png/ball-spiky.png")
            group add(spikeSprite)
        } else {
            // TODO: feedback
        }
    }

}

SelfHandler: class extends CpCollisionHandler {

    begin: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        delta(arbiter, 1)

        true
    }

    preSolve: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        arbiter setElasticity(0.05) 
        arbiter setFriction(0.7)

        true
    }

    separate: func (arbiter: CpArbiter, space: CpSpace) {
        delta(arbiter, -1)
    }

    delta: func (arbiter: CpArbiter, delta: Int) {
        shape1, shape2: CpShape
        arbiter getShapes(shape1&, shape2&) 

        ball1 := shape1 getUserData() as Ball
        ball2 := shape2 getUserData() as Ball

        ball1 selfCount += delta
        if (ball1 selfCount >= 2) {
            ball1 invulnerableCount = ball1 invulnerableLength
        }

        ball2 selfCount += delta
        if (ball2 selfCount >= 2) {
            ball2 invulnerableCount = ball2 invulnerableLength
        }

        if (delta > 0 && (ball1 spiky || ball2 spiky)) {
            if (ball2 spiky) {
                tmp := ball1
                ball1 = ball2
                ball2 = tmp
            }

            if (!ball2 spiker) {
                ball2 spiker = ball1

                set := arbiter getContactPointSet()
                contactPos := vec2(set points[0] point)

                ball2 spikePoint = contactPos
                Ball logger info("spiky collision going on at %s, delta = %d", contactPos _, delta)
            }
        }
    }

}

BallWallsHandler: class extends CpCollisionHandler {

    begin: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        shape1, shape2: CpShape
        arbiter getShapes(shape1&, shape2&) 

        ball := shape1 getUserData() as Ball
        if (ball level def bordersHurt) {
            if (ball snapped) {
                ball harm()
            }
        }

        true
    }

    preSolve: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        arbiter setElasticity(0.05) 
        arbiter setFriction(0.7)

        true
    }

}

