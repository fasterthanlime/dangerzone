
// third-party stuff
use dye
import dye/[sprite, math]

use gnaar
import gnaar/[utils]

use chipmunk
import chipmunk

// our stuff
import dangerzone/[level]

Ball: class extends Entity {

    pos: Vec2

    sprite: GlSprite

    shape: CpShape
    body: CpBody

    radius := 1.0
    spriteSide := 512.0

    mass := 10.0

    snapped := true

    init: func (.level, .pos) {
        super(level)

        this pos = pos clone()

        sprite = GlSprite new("assets/png/ball-happy.png")
        level group add(sprite)

        initPhysx()
    }

    update: func {

        if (snapped) {
            pos := level dye input getMousePos()
            size := level dye size toVec2()

            diameter := radius * 2.0
            if (diameter >= size x || diameter >= size y) {
                // we're as big as we're gonna get
                unsnap()
                return
            }

            if (pos x < radius) {
                pos x = radius
            }
            if (pos x + radius >= size y) {
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
            radius += 1.0
            updateShape()
        }

        scale := radius * 2.0 / spriteSide
        sprite scale set!(scale, scale)

        sprite sync(body)
    }

    initPhysx: func {
        // main body
        moment := cpMomentForCircle(mass, 0, radius, cpv(radius, radius))

        body = CpBody new(mass, moment)
        body setPos(cpv(pos))
        level space addBody(body)

        updateShape()
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
        level space addShape(shape)
    }

    getMoment: func -> Float {
        cpMomentForCircle(mass, 0, radius, cpv(radius, radius))
    }

    unsnap: func {
        snapped = false
    }

}

