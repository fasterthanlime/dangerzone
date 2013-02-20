
// third-party stuff
use dye
import dye/[sprite, math]

use gnaar
import gnaar/[utils]

use chipmunk
import chipmunk

// our stuff
import dangerzone/[level, game]

Walls: class extends Entity {

    init: func (.level) {
        super(level)

        initPhysx()
    }

    initPhysx: func {
        bl := vec2(0, 0)
        ul := vec2(0, level dye height)
        ur := vec2(level dye width, level dye height)
        br := vec2(level dye width, 0)

        createSegment(bl, ul)
        createSegment(ul, ur)
        createSegment(ur, br)
        createSegment(br, bl)
    }

    createSegment: func (p1, p2: Vec2) {
        shape := CpSegmentShape new(level space getStaticBody(), cpv(p1), cpv(p2), 1.0)
        shape setFriction(0.9)
        level space addShape(shape)
    }

}
