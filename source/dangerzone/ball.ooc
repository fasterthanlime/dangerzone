
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

    radius := 64.0
    spriteSide := 512.0

    init: func (.level) {
        super(level)

        pos = vec2(200, 500)

        sprite = GlSprite new("assets/png/ball-happy.png")
        level group add(sprite)

        initPhysx()
    }

    update: func {
        scale := radius / spriteSide
        sprite scale set!(scale, scale)

        sprite sync(body)
    }

    initPhysx: func {
        // main body
        mass := 10.0
        moment := cpMomentForCircle(mass, 0, radius, cpv(0, 0))

        body = CpBody new(mass, moment)
        body setPos(cpv(pos))
        level space addBody(body)

        shape = CpCircleShape new(body, radius, cpv(0, 0))
        shape setUserData(this)
        level space addShape(shape)
    }

}
