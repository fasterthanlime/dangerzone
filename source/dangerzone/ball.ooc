
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
import structs/[ArrayList, List, HashMap]

// our stuff
import dangerzone/[level, leveldef]

SpikeRel: class {
    point: Vec2
    other: Ball
    constraint, constraint2: CpPinJoint

    init: func (=other, =point) {
    }
}

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
    invulnerable: Bool { get { invulnerableCount > 0 || green } }
    green: Bool { get { spiky || (selfCount >= 0 && !spikers empty?()) } }

    spiky := false
    spikers := HashMap<This, SpikeRel> new()
    newSpikers := false

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
        if (newSpikers) {
            newSpikers = false

            for (rel in spikers) if (!rel constraint) {
                pinJoint := CpPinJoint new(body, rel other body,
                    body getPos(), rel other body getPos())
                dist := radius + rel other radius
                //pinJoint setDist(dist)

                logger warn("first pin dist = %.2f", pinJoint getDist())
                
                rel constraint = pinJoint
                level space addConstraint(rel constraint)
            
                pos1 := vec2(body getPos())
                pos2 := vec2(rel other body getPos())

                diff := pos2 sub(pos1) normalized()

                point1 := pos1 add(diff mul(radius))
                point2 := pos2 sub(diff mul(rel other radius))

                logger warn("point1 = %s, point2 = %s, dist = %.2f", point1 _, point2 _, point2 dist(point1))
                pinJoint2 := CpPinJoint new(body, rel other body, cpv(point1), cpv(point2))
                //pinJoint2 setDist(0.0)

                rel constraint2 = pinJoint2
                level space addConstraint(pinJoint2)

                // fiddling
                //errorBias := 0.2
                //rel constraint setErrorBias(errorBias)
                //rel constraint2 setErrorBias(errorBias)
            }
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
            if (green) {
                targetRadius = radius
            } else {
                alpha := 0.95
                radius = radius * alpha + targetRadius * (1 - alpha)
                updateShape()
            }
        }

        targetBrightness := 255.0
        if (level def fragile && !invulnerable) {
            targetBrightness = 65.0
        }

        {
            alpha := 0.95
            brightness = brightness * alpha + targetBrightness * (1 - alpha)
        }
        sprite color set!(brightness, brightness, green ? 20 : brightness)
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
        if (!spiky) {
            if (green) {
                body setForce(cpv(0, -2000))
            } else {
                body setForce(cpv(0, -8000))
            }
        }

        scale := diameter * (1.0 / spriteSide as Float)
        sprite scale set!(scale, scale)
        sprite sync(body)

        if (spikeSprite) {
            spikeScale := scale * 1.2
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
        for (rel in spikers) {
            level space removeConstraint(rel constraint)
            level space removeConstraint(rel constraint2)
        }
        level space removeShape(shape)
        level space removeBody(body)
    }

    initPhysx: func {
        moment := getMoment()

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
    
    updateShape: func (force := false) {
        if ((!spikers empty?() || spiky) && !force) {
            return
        }

        moment := getMoment()
        body setMoment(moment)

        if (shape) {
            level space removeShape(shape)
            shape free()
            shape = null
        }

        shape = CpCircleShape new(body, radius, cpv(0, 0))
        shape setUserData(this)
        shape setFriction(0.8)
        shape setElasticity(0.0)
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
        if (green) {
            // TODO: feedback
            return
        }

        if (invulnerable && !spiky) {
            level balls -= 1
            spiky = true
            updateShape(true) // so we re-have collisions

            spikeSprite = GlSprite new("assets/png/ball-spiky.png")
            group add(spikeSprite)
        } else {
            // TODO: feedback
        }
    }

    spikedBy?: func (other: This) -> Bool {
        spikers contains?(other)
    }

}

SelfHandler: class extends CpCollisionHandler {

    begin: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        delta(arbiter, 1)

        true
    }

    preSolve: func (arbiter: CpArbiter, space: CpSpace) -> Bool {
        //arbiter setElasticity(0.0) 
        //arbiter setFriction(0.4)

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

            if (!ball2 spikedBy?(ball1)) {
                set := arbiter getContactPointSet()
                contactPos := vec2(set points[0] point)

                rel := SpikeRel new(ball1, contactPos)
                ball2 spikers put(rel other, rel)
                ball2 newSpikers = true

                Ball logger info("spiky hug going on at %s, dist %.2f", contactPos _, set points[0] dist)
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
        //arbiter setElasticity(0.0) 
        //arbiter setFriction(0.4)

        true
    }

}

