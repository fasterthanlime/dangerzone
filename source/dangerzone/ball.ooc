
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

    init: func (.level) {
        super(level)

        pos = vec2(200, 500)

        sprite = GlSprite new("assets/png/ball-happy.png")
        level group add(sprite)

        initPhysx()
    }

    update: func {
        sprite sync(body)
    }

    initPhysx: func {
        // main body
        (width, height) := (sprite width, sprite height)
        mass := 10.0
        moment := cpMomentForBox(mass, width, height)

        body = CpBody new(mass, moment)
        body setPos(cpv(pos))
        level space addBody(body)

        shape = CpBoxShape new(body, width, height)
        shape setUserData(this)
        level space addShape(shape)
    }

}
