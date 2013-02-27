
// sdk stuff
import structs/[List, ArrayList]

/**
 * The set of rules for a given level
 */
LevelDef: class {

    numEnemies := 1
    numBalls := 20

    bordersHurt := false
    selfHurt := false
    canMove := true

    message: String

    init: func (=message)

    init: func ~inherit (daddy: LevelDef, =message) {
        numEnemies = daddy numEnemies
        numBalls = daddy numBalls

        bordersHurt = daddy bordersHurt
        selfHurt = daddy selfHurt
        canMove = daddy canMove
    }

    getList: static func -> List<This> {
        defs := ArrayList<This> new()

        {
            def := This new("Grow balls to fill 66%")
            def numEnemies = 0
            defs add(def)
        }

        {
            def := This new(defs last(), "Enemies hurt while you grow")
            def numEnemies = 2
            defs add(def)
        }

        {
            def := This new(defs last(), "The more enemies the harder")
            def numEnemies = 3
            defs add(def)
        }

        {
            def := This new(defs last(), "That was obviously too easy")
            def numEnemies = 4
            defs add(def)
        }

        {
            def := This new(defs last(), "Is the whole game like this?")
            def numEnemies = 5
            defs add(def)
        }

        {
            def := This new(defs last(), "Your hubris is taking over")
            def numEnemies = 6
            defs add(def)
        }

        {
            def := This new(defs last(), "Last one before new rule")
            def numEnemies = 7
            defs add(def)
        }

        defs
    }
    
}

